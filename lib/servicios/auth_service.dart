import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/usuario.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Credenciales hardcodeadas
  static const String _adminEmail = 'admin';
  static const String _adminPassword = '1234';
  static const String _userEmail = 'usuario';
  static const String _userPassword = '1234';

  // Stream del usuario actual
  Stream<User?> get usuarioStream => _auth.authStateChanges();

  // Usuario actual
  User? get usuarioActual => _auth.currentUser;

  // ==================== AUTENTICACIÓN ====================

  /// Iniciar sesión
  Future<ResultadoAuth> iniciarSesion(String email, String password) async {
    try {
      String emailLimpio = email.trim().toLowerCase();

      // Verificar credenciales hardcodeadas
      if (emailLimpio == _adminEmail && password == _adminPassword) {
        return await _crearSesionLocal('admin', 'Administrador', 'admin');
      }

      if (emailLimpio == _userEmail && password == _userPassword) {
        return await _crearSesionLocal('usuario', 'Usuario', 'cliente');
      }

      // Si no son credenciales hardcodeadas, intentar con Firebase
      return await _loginFirebase(email, password);

    } catch (e) {
      return ResultadoAuth.error('Error inesperado: $e');
    }
  }

  /// Crear sesión local para usuarios hardcodeados
  Future<ResultadoAuth> _crearSesionLocal(String id, String nombre, String rol) async {
    try {
      // Crear email temporal para Firebase
      String tempEmail = '$id@naboocustoms.local';

      // Intentar login o crear usuario en Firebase
      UserCredential? userCredential;

      try {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: tempEmail,
          password: '123456', // Password temporal
        );
      } catch (e) {
        // Si no existe, crear el usuario
        try {
          userCredential = await _auth.createUserWithEmailAndPassword(
            email: tempEmail,
            password: '123456',
          );
        } catch (createError) {
          // Si ya existe pero la contraseña es diferente, intentar reset
          print('Error creando usuario: $createError');
        }
      }

      // Crear objeto usuario local
      Usuario usuario = Usuario(
        id: id,
        email: tempEmail,
        nombre: nombre,
        rol: rol,
        activo: true,
        fechaCreacion: DateTime.now(),
      );

      // Guardar en Firestore si tenemos userCredential
      if (userCredential?.user != null) {
        await _firestore
            .collection('usuarios')
            .doc(userCredential!.user!.uid)
            .set(usuario.toFirestore(), SetOptions(merge: true));
      }

      return ResultadoAuth.exitoso(usuario);
    } catch (e) {
      print('Error en sesión local: $e');
      // Aunque falle Firebase, permitir acceso local
      Usuario usuario = Usuario(
        id: id,
        email: '$id@naboocustoms.local',
        nombre: nombre,
        rol: rol,
        activo: true,
        fechaCreacion: DateTime.now(),
      );
      return ResultadoAuth.exitoso(usuario);
    }
  }

  /// Login normal con Firebase Auth
  Future<ResultadoAuth> _loginFirebase(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Verificar si el usuario existe en Firestore y está activo
      Usuario? usuario = await obtenerDatosUsuario(userCredential.user!.uid);

      if (usuario == null) {
        await cerrarSesion();
        return ResultadoAuth.error('Usuario no registrado en el sistema');
      }

      if (!usuario.estaActivo) {
        await cerrarSesion();
        return ResultadoAuth.error('Usuario desactivado. Contacta al administrador');
      }

      return ResultadoAuth.exitoso(usuario);
    } on FirebaseAuthException catch (e) {
      return ResultadoAuth.error(_manejarErrorAuth(e));
    }
  }

  /// Cerrar sesión
  Future<void> cerrarSesion() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error cerrando sesión: $e');
      // Continuar aunque falle el logout de Firebase
    }
  }

  /// Verificar si el usuario está autenticado
  bool get estaAutenticado => _auth.currentUser != null;

  // ==================== GESTIÓN DE USUARIOS ====================

  /// Obtener datos del usuario desde Firestore
  Future<Usuario?> obtenerDatosUsuario(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('usuarios').doc(uid).get();
      if (doc.exists) {
        return Usuario.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error obteniendo datos de usuario: $e');
      return null;
    }
  }

  /// Obtener datos del usuario actual
  Future<Usuario?> obtenerUsuarioActual() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return await obtenerDatosUsuario(user.uid);
    }
    return null;
  }

  /// Verificar si el usuario actual es admin
  Future<bool> esAdmin() async {
    Usuario? usuario = await obtenerUsuarioActual();
    return usuario?.esAdmin ?? false;
  }

  /// Crear nuevo usuario (solo para admins)
  Future<ResultadoAuth> crearUsuario({
    required String email,
    required String password,
    required String nombre,
    String rol = 'cliente',
  }) async {
    try {
      // Verificar que el email no existe ya en Firestore
      final existeQuery = await _firestore
          .collection('usuarios')
          .where('email', isEqualTo: email.trim())
          .get();

      if (existeQuery.docs.isNotEmpty) {
        return ResultadoAuth.error('Ya existe un usuario con este email en el sistema');
      }

      // Generar un ID único para el usuario
      String userId = _firestore.collection('usuarios').doc().id;

      // Intentar crear usuario en Firebase Auth
      UserCredential? userCredential;
      try {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );

        // Si se crea exitosamente, usar su UID
        userId = userCredential.user!.uid;

        // Actualizar el nombre del usuario
        await userCredential.user?.updateDisplayName(nombre);
      } catch (authError) {
        print('⚠️ Error en Firebase Auth, continuando con ID generado: $authError');
        // Continuar con el ID generado manualmente
      }

      // Crear documento en Firestore
      Usuario nuevoUsuario = Usuario(
        id: userId,
        email: email.trim(),
        nombre: nombre.trim(),
        rol: rol,
        activo: true,
        fechaCreacion: DateTime.now(),
      );

      await _firestore
          .collection('usuarios')
          .doc(userId)
          .set(nuevoUsuario.toFirestore());

      return ResultadoAuth.exitoso(nuevoUsuario);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return ResultadoAuth.error('Este email ya está registrado en Firebase Auth');
      }
      return ResultadoAuth.error(_manejarErrorAuth(e));
    } catch (e) {
      return ResultadoAuth.error('Error creando usuario: $e');
    }
  }

  /// Obtener todos los usuarios (solo para admins)
  Stream<List<Usuario>> obtenerTodosLosUsuarios() {
    return _firestore
        .collection('usuarios')
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Usuario.fromFirestore(doc))
        .toList());
  }

  /// Actualizar usuario (solo para admins)
  Future<bool> actualizarUsuario(String uid, Usuario usuario) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(uid)
          .update(usuario.toFirestore());
      return true;
    } catch (e) {
      print('Error actualizando usuario: $e');
      return false;
    }
  }

  /// Activar/Desactivar usuario (solo para admins)
  Future<bool> cambiarEstadoUsuario(String uid, bool activo) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(uid)
          .update({'activo': activo});
      return true;
    } catch (e) {
      print('Error cambiando estado de usuario: $e');
      return false;
    }
  }

  /// Eliminar usuario (solo para admins)
  Future<bool> eliminarUsuario(String uid) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(uid)
          .update({'activo': false});
      return true;
    } catch (e) {
      print('Error eliminando usuario: $e');
      return false;
    }
  }

  /// Restablecer contraseña
  Future<bool> restablecerPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } catch (e) {
      print('Error enviando email de restablecimiento: $e');
      return false;
    }
  }

  // ==================== UTILIDADES ====================

  /// Manejar errores de autenticación
  String _manejarErrorAuth(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'Email inválido';
      case 'user-disabled':
        return 'Usuario deshabilitado';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      case 'email-already-in-use':
        return 'El email ya está en uso';
      case 'weak-password':
        return 'La contraseña es muy débil (mínimo 6 caracteres)';
      case 'invalid-credential':
        return 'Credenciales inválidas';
      case 'network-request-failed':
        return 'Error de red. Verifica tu conexión a internet';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      default:
        return 'Error de autenticación: ${e.message ?? 'Desconocido'}';
    }
  }

  /// Validar email
  static bool emailValido(String email) {
    String emailLimpio = email.trim().toLowerCase();
    // Permitir credenciales hardcodeadas
    if (emailLimpio == 'admin' || emailLimpio == 'usuario') {
      return true;
    }
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validar contraseña
  static bool passwordValida(String password) {
    return password.length >= 4; // Mínimo 4 caracteres para permitir '1234'
  }

  /// Verificar conexión con Firebase Auth
  Future<bool> verificarConexion() async {
    try {
      _auth.currentUser;
      return true;
    } catch (e) {
      print('Error verificando conexión Firebase Auth: $e');
      return false;
    }
  }
}

// ==================== CLASE RESULTADO ====================

class ResultadoAuth {
  final bool exitoso;
  final String? error;
  final Usuario? usuario;

  ResultadoAuth._({
    required this.exitoso,
    this.error,
    this.usuario,
  });

  factory ResultadoAuth.exitoso(Usuario usuario) {
    return ResultadoAuth._(
      exitoso: true,
      usuario: usuario,
    );
  }

  factory ResultadoAuth.error(String mensaje) {
    return ResultadoAuth._(
      exitoso: false,
      error: mensaje,
    );
  }
}
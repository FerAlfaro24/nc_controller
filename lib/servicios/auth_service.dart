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

      print('🔐 Iniciando sesión para: $emailLimpio');

      // Verificar credenciales hardcodeadas PRIMERO
      if (emailLimpio == _adminEmail && password == _adminPassword) {
        print('✅ Login hardcodeado: Admin');
        return await _crearSesionLocal('admin', 'Administrador', 'admin');
      }

      if (emailLimpio == _userEmail && password == _userPassword) {
        print('✅ Login hardcodeado: Usuario');
        return await _crearSesionLocal('usuario', 'Usuario', 'cliente');
      }

      // Si no son credenciales hardcodeadas, intentar con Firebase
      print('🔥 Intentando login con Firebase...');
      return await _loginFirebaseBasico(email, password);

    } catch (e) {
      print('❌ Error inesperado en iniciarSesion: $e');
      return ResultadoAuth.error('Error inesperado: $e');
    }
  }

  /// Login básico sin tocar Firestore hasta después del login
  Future<ResultadoAuth> _loginFirebaseBasico(String email, String password) async {
    try {
      print('🔐 Login Firebase básico: $email');

      // 1. Solo hacer login en Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      String uid = userCredential.user!.uid;
      String userEmail = userCredential.user!.email ?? email.trim();
      String displayName = userCredential.user!.displayName ?? email.split('@')[0];

      print('✅ Login exitoso en Firebase Auth, UID: $uid');

      // 2. Crear usuario simple SIN consultar Firestore
      Usuario usuario = Usuario(
        id: uid,
        email: userEmail,
        nombre: displayName,
        rol: 'cliente',
        activo: true,
        fechaCreacion: DateTime.now(),
      );

      // 3. Guardar en Firestore de forma asíncrona (sin esperar)
      _guardarUsuarioAsync(uid, usuario);

      print('✅ Login completo exitoso para: ${usuario.nombre}');
      return ResultadoAuth.exitoso(usuario);

    } on FirebaseAuthException catch (e) {
      print('❌ Error Firebase Auth: ${e.code} - ${e.message}');
      return ResultadoAuth.error(_manejarErrorAuth(e));
    } catch (e) {
      print('❌ Error inesperado en login básico: $e');
      return ResultadoAuth.error('Error de conexión. Verifica tu internet.');
    }
  }

  /// Guardar usuario en Firestore de forma asíncrona
  void _guardarUsuarioAsync(String uid, Usuario usuario) {
    _firestore
        .collection('usuarios')
        .doc(uid)
        .set(usuario.toFirestore(), SetOptions(merge: true))
        .then((_) => print('✅ Usuario guardado en Firestore async'))
        .catchError((e) => print('⚠️ Error guardando en Firestore async: $e'));
  }

  /// Crear sesión local para usuarios hardcodeados
  Future<ResultadoAuth> _crearSesionLocal(String id, String nombre, String rol) async {
    try {
      print('🏠 Creando sesión local para: $id');

      // Crear email temporal para Firebase
      String tempEmail = '$id@naboocustoms.local';

      // Intentar login o crear usuario en Firebase
      UserCredential? userCredential;

      try {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: tempEmail,
          password: '123456', // Password temporal
        );
        print('✅ Login existente en Firebase para usuario local: $id');
      } catch (e) {
        // Si no existe, crear el usuario
        try {
          userCredential = await _auth.createUserWithEmailAndPassword(
            email: tempEmail,
            password: '123456',
          );
          print('✅ Usuario local creado en Firebase: $id');
        } catch (createError) {
          print('⚠️ Error creando usuario local en Firebase: $createError');
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
        _guardarUsuarioAsync(userCredential!.user!.uid, usuario);
      }

      return ResultadoAuth.exitoso(usuario);
    } catch (e) {
      print('⚠️ Error en sesión local: $e');
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

  /// Cerrar sesión
  Future<void> cerrarSesion() async {
    try {
      print('🚪 Cerrando sesión...');
      await _auth.signOut();
      print('✅ Sesión cerrada exitosamente');
    } catch (e) {
      print('⚠️ Error cerrando sesión: $e');
      // Continuar aunque falle el logout de Firebase
    }
  }

  /// Verificar si el usuario está autenticado
  bool get estaAutenticado => _auth.currentUser != null;

  // ==================== GESTIÓN DE USUARIOS ====================

  /// Obtener datos del usuario actual
  Future<Usuario?> obtenerUsuarioActual() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return Usuario(
        id: user.uid,
        email: user.email ?? 'unknown@example.com',
        nombre: user.displayName ?? 'Usuario',
        rol: 'cliente',
        activo: true,
        fechaCreacion: DateTime.now(),
      );
    }
    return null;
  }

  /// Verificar si el usuario actual es admin
  Future<bool> esAdmin() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String email = user.email ?? '';
      return email.contains('@naboocustoms.local') || email == _adminEmail;
    }
    return false;
  }

  /// Crear nuevo usuario SOLO EN FIREBASE AUTH
  Future<ResultadoAuth> crearUsuario({
    required String email,
    required String password,
    required String nombre,
    String rol = 'cliente',
  }) async {
    try {
      print('👤 Creando usuario SOLO Firebase Auth: $email');

      // Crear usuario en Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      String userId = userCredential.user!.uid;
      print('✅ Usuario creado en Firebase Auth con UID: $userId');

      // Actualizar el display name
      await userCredential.user?.updateDisplayName(nombre);

      // Crear objeto usuario
      Usuario nuevoUsuario = Usuario(
        id: userId,
        email: email.trim(),
        nombre: nombre.trim(),
        rol: rol,
        activo: true,
        fechaCreacion: DateTime.now(),
      );

      // Guardar en Firestore de forma asíncrona
      _guardarUsuarioAsync(userId, nuevoUsuario);

      print('✅ Usuario creado exitosamente: ${nuevoUsuario.email}');
      return ResultadoAuth.exitoso(nuevoUsuario);

    } on FirebaseAuthException catch (e) {
      print('❌ Error Firebase Auth creando usuario: ${e.code} - ${e.message}');
      return ResultadoAuth.error(_manejarErrorAuth(e));
    } catch (e) {
      print('❌ Error creando usuario: $e');
      return ResultadoAuth.error('Error creando usuario: $e');
    }
  }

  /// Obtener todos los usuarios - SIMPLIFICADO
  Stream<List<Usuario>> obtenerTodosLosUsuarios() {
    print('📋 Obteniendo usuarios de Firebase Auth...');

    // Retornar stream básico que no cause problemas
    return Stream.value([
      Usuario(
        id: 'placeholder',
        email: 'Carga usuarios con "Verificar Datos"',
        nombre: 'Lista vacía por seguridad',
        rol: 'cliente',
        activo: false,
        fechaCreacion: DateTime.now(),
      )
    ]);
  }

  /// Cargar usuarios de forma manual y segura
  Future<List<Usuario>> cargarUsuariosManuales() async {
    try {
      print('📋 Cargando usuarios manualmente...');

      QuerySnapshot snapshot = await _firestore
          .collection('usuarios')
          .orderBy('fechaCreacion', descending: true)
          .get();

      List<Usuario> usuarios = [];

      for (var doc in snapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          Usuario usuario = Usuario(
            id: doc.id,
            email: data['email']?.toString() ?? 'sin-email',
            nombre: data['nombre']?.toString() ?? 'Sin nombre',
            rol: data['rol']?.toString() ?? 'cliente',
            activo: data['activo'] == true,
            fechaCreacion: _parsearFecha(data['fechaCreacion']),
          );

          usuarios.add(usuario);
          print('✅ Usuario cargado: ${usuario.email}');
        } catch (e) {
          print('⚠️ Error con usuario ${doc.id}, eliminando: $e');
          await doc.reference.delete();
        }
      }

      print('📋 Total usuarios cargados: ${usuarios.length}');
      return usuarios;
    } catch (e) {
      print('❌ Error cargando usuarios: $e');
      return [];
    }
  }

  DateTime _parsearFecha(dynamic fecha) {
    try {
      if (fecha is Timestamp) return fecha.toDate();
      if (fecha is String) return DateTime.parse(fecha);
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  /// Eliminar usuario completamente
  Future<bool> eliminarUsuario(String uid) async {
    try {
      print('🗑️ Eliminando usuario: $uid');
      await _firestore.collection('usuarios').doc(uid).delete();
      print('✅ Usuario eliminado');
      return true;
    } catch (e) {
      print('❌ Error eliminando usuario: $e');
      return false;
    }
  }

  /// Cambiar estado de usuario
  Future<bool> cambiarEstadoUsuario(String uid, bool activo) async {
    try {
      print('🔄 Cambiando estado usuario $uid: $activo');
      await _firestore.collection('usuarios').doc(uid).update({'activo': activo});
      return true;
    } catch (e) {
      print('❌ Error cambiando estado: $e');
      return false;
    }
  }

  /// Actualizar usuario
  Future<bool> actualizarUsuario(String uid, Usuario usuario) async {
    try {
      print('📝 Actualizando usuario: $uid');
      await _firestore.collection('usuarios').doc(uid).update(usuario.toFirestore());
      return true;
    } catch (e) {
      print('❌ Error actualizando usuario: $e');
      return false;
    }
  }

  /// LIMPIAR TODA LA BASE DE DATOS
  Future<void> limpiarBaseDatos() async {
    try {
      print('🧹 LIMPIANDO TODA LA BASE DE DATOS...');

      QuerySnapshot snapshot = await _firestore.collection('usuarios').get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
        print('🗑️ Eliminado: ${doc.id}');
      }

      print('✅ Base de datos limpiada completamente');
    } catch (e) {
      print('❌ Error limpiando base de datos: $e');
    }
  }

  // ==================== UTILIDADES ====================

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

  static bool emailValido(String email) {
    String emailLimpio = email.trim().toLowerCase();
    if (emailLimpio == 'admin' || emailLimpio == 'usuario') {
      return true;
    }
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool passwordValida(String password) {
    return password.length >= 4;
  }

  Future<bool> verificarConexion() async {
    try {
      _auth.currentUser;
      return true;
    } catch (e) {
      print('❌ Error verificando conexión Firebase Auth: $e');
      return false;
    }
  }
}

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
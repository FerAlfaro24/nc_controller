import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/usuario.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream del usuario actual
  Stream<User?> get usuarioStream => _auth.authStateChanges();

  // Usuario actual
  User? get usuarioActual => _auth.currentUser;

  // ==================== AUTENTICACIÓN ====================

  /// Iniciar sesión
  Future<ResultadoAuth> iniciarSesion(String email, String password) async {
    try {
      // Intentar login con Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Verificar si el usuario existe en Firestore y está activo
      Usuario? usuario = await obtenerDatosUsuario(userCredential.user!.uid);

      if (usuario == null) {
        await cerrarSesion();
        return ResultadoAuth.error('Usuario no encontrado en el sistema');
      }

      if (!usuario.estaActivo) {
        await cerrarSesion();
        return ResultadoAuth.error('Usuario desactivado. Contacta al administrador');
      }

      return ResultadoAuth.exitoso(usuario);
    } on FirebaseAuthException catch (e) {
      return ResultadoAuth.error(_manejarErrorAuth(e));
    } catch (e) {
      return ResultadoAuth.error('Error inesperado: $e');
    }
  }

  /// Cerrar sesión
  Future<void> cerrarSesion() async {
    await _auth.signOut();
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
      // Crear usuario en Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Crear documento en Firestore
      Usuario nuevoUsuario = Usuario(
        id: userCredential.user!.uid,
        email: email.trim(),
        nombre: nombre.trim(),
        rol: rol,
        activo: true,
        fechaCreacion: DateTime.now(),
      );

      await _firestore
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .set(nuevoUsuario.toFirestore());

      return ResultadoAuth.exitoso(nuevoUsuario);
    } on FirebaseAuthException catch (e) {
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
      // Desactivar en lugar de eliminar completamente
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
        return 'La contraseña es muy débil';
      case 'invalid-credential':
        return 'Credenciales inválidas';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }

  /// Validar email
  static bool emailValido(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validar contraseña
  static bool passwordValida(String password) {
    return password.length >= 6;
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
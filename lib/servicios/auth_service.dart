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
  static const String _adminUser = 'admin';
  static const String _adminPassword = '1234';
  static const String _userUser = 'usuario';
  static const String _userPassword = '1234';

  // Stream del usuario actual
  Stream<User?> get usuarioStream => _auth.authStateChanges();

  // Usuario actual
  User? get usuarioActual => _auth.currentUser;

  // ==================== AUTENTICACIÓN ====================

  /// Iniciar sesión con usuario y contraseña (sin email)
  Future<ResultadoAuth> iniciarSesion(String usuario, String password) async {
    try {
      String usuarioLimpio = usuario.trim().toLowerCase();

      print('🔐 Iniciando sesión para: $usuarioLimpio');

      // Verificar credenciales hardcodeadas PRIMERO
      if (usuarioLimpio == _adminUser && password == _adminPassword) {
        print('✅ Login hardcodeado: Admin');
        return await _crearSesionLocal('admin', 'Administrador', 'admin');
      }

      if (usuarioLimpio == _userUser && password == _userPassword) {
        print('✅ Login hardcodeado: Usuario');
        return await _crearSesionLocal('usuario', 'Usuario Normal', 'cliente');
      }

      // Si no son credenciales hardcodeadas, buscar en Firestore
      print('🔍 Buscando usuario en base de datos...');
      return await _loginFirestore(usuarioLimpio, password);

    } catch (e) {
      print('❌ Error inesperado en iniciarSesion: $e');
      return ResultadoAuth.error('Error inesperado: $e');
    }
  }

  /// Login buscando en Firestore directamente
  Future<ResultadoAuth> _loginFirestore(String usuario, String password) async {
    try {
      print('🔍 Buscando usuario en Firestore: $usuario');

      // Buscar usuario por nombre de usuario en Firestore
      QuerySnapshot query = await _firestore
          .collection('usuarios')
          .where('usuario', isEqualTo: usuario)
          .where('activo', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return ResultadoAuth.error('Usuario no encontrado');
      }

      DocumentSnapshot doc = query.docs.first;
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Verificar contraseña (en un sistema real sería hasheada)
      String passwordGuardada = data['password'] ?? '';
      if (passwordGuardada != password) {
        return ResultadoAuth.error('Contraseña incorrecta');
      }

      // Crear sesión de Firebase Auth temporal
      String emailTemporal = '${usuario}@naboocustoms.local';
      await _crearSesionFirebaseAuth(emailTemporal, password);

      // Crear objeto usuario
      Usuario usuarioObj = Usuario(
        id: doc.id,
        email: emailTemporal, // Email temporal para Firebase
        nombre: data['nombre'] ?? usuario,
        rol: data['rol'] ?? 'cliente',
        activo: data['activo'] ?? true,
        fechaCreacion: _parsearFecha(data['fechaCreacion']),
      );

      print('✅ Login exitoso para: ${usuarioObj.nombre}');
      return ResultadoAuth.exitoso(usuarioObj);

    } catch (e) {
      print('❌ Error en login Firestore: $e');
      return ResultadoAuth.error('Error de autenticación: $e');
    }
  }

  /// Crear sesión en Firebase Auth de forma temporal
  Future<void> _crearSesionFirebaseAuth(String email, String password) async {
    try {
      // Intentar login primero
      await _auth.signInWithEmailAndPassword(email: email, password: '123456');
    } catch (e) {
      // Si no existe, crear usuario temporal
      try {
        await _auth.createUserWithEmailAndPassword(email: email, password: '123456');
      } catch (createError) {
        print('⚠️ Error creando sesión temporal: $createError');
      }
    }
  }

  /// Crear sesión local para usuarios hardcodeados
  Future<ResultadoAuth> _crearSesionLocal(String id, String nombre, String rol) async {
    try {
      print('🏠 Creando sesión local para: $id');

      // Crear email temporal para Firebase
      String tempEmail = '$id@naboocustoms.local';
      await _crearSesionFirebaseAuth(tempEmail, '123456');

      // Crear objeto usuario local
      Usuario usuario = Usuario(
        id: id,
        email: tempEmail,
        nombre: nombre,
        rol: rol,
        activo: true,
        fechaCreacion: DateTime.now(),
      );

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
    }
  }

  /// Verificar si el usuario está autenticado
  bool get estaAutenticado => _auth.currentUser != null;

  // ==================== GESTIÓN DE USUARIOS ====================

  /// Obtener datos del usuario actual
  Future<Usuario?> obtenerUsuarioActual() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String email = user.email ?? '';
      bool esAdminHardcodeado = email.contains('admin@naboocustoms.local');

      return Usuario(
        id: user.uid,
        email: email,
        nombre: user.displayName ?? (esAdminHardcodeado ? 'Administrador' : 'Usuario'),
        rol: esAdminHardcodeado ? 'admin' : 'cliente',
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
      return email.contains('admin@naboocustoms.local');
    }
    return false;
  }

  /// Crear nuevo usuario - SOLO CON USUARIO Y CONTRASEÑA
  Future<ResultadoAuth> crearUsuario({
    required String usuario,
    required String nombre,
    required String password,
    String rol = 'cliente',
  }) async {
    try {
      print('👤 Creando usuario: $usuario');

      // Verificar que el usuario no exista
      QuerySnapshot existeQuery = await _firestore
          .collection('usuarios')
          .where('usuario', isEqualTo: usuario.trim().toLowerCase())
          .limit(1)
          .get();

      if (existeQuery.docs.isNotEmpty) {
        return ResultadoAuth.error('El usuario "$usuario" ya existe');
      }

      // Crear nuevo usuario en Firestore
      Usuario nuevoUsuario = Usuario(
        id: '', // Se asignará automáticamente
        email: '${usuario.trim().toLowerCase()}@naboocustoms.local', // Email temporal
        nombre: nombre.trim(),
        rol: rol,
        activo: true,
        fechaCreacion: DateTime.now(),
      );

      // Guardar en Firestore con campos adicionales
      DocumentReference docRef = await _firestore.collection('usuarios').add({
        'usuario': usuario.trim().toLowerCase(),
        'nombre': nombre.trim(),
        'password': password, // En un sistema real esto sería hasheado
        'rol': rol,
        'activo': true,
        'fechaCreacion': FieldValue.serverTimestamp(),
        'email': '${usuario.trim().toLowerCase()}@naboocustoms.local',
      });

      // Actualizar el usuario con el ID correcto
      nuevoUsuario = Usuario(
        id: docRef.id,
        email: nuevoUsuario.email,
        nombre: nuevoUsuario.nombre,
        rol: nuevoUsuario.rol,
        activo: nuevoUsuario.activo,
        fechaCreacion: nuevoUsuario.fechaCreacion,
      );

      print('✅ Usuario creado exitosamente: $usuario');
      return ResultadoAuth.exitoso(nuevoUsuario);

    } catch (e) {
      print('❌ Error creando usuario: $e');
      return ResultadoAuth.error('Error creando usuario: $e');
    }
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
            email: data['email']?.toString() ?? '${data['usuario']}@naboocustoms.local',
            nombre: data['nombre']?.toString() ?? 'Sin nombre',
            rol: data['rol']?.toString() ?? 'cliente',
            activo: data['activo'] == true,
            fechaCreacion: _parsearFecha(data['fechaCreacion']),
          );

          usuarios.add(usuario);
          print('✅ Usuario cargado: ${data['usuario']} - ${usuario.nombre}');
        } catch (e) {
          print('⚠️ Error con usuario ${doc.id}: $e');
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

  /// LIMPIAR TODA LA BASE DE DATOS
  Future<void> limpiarBaseDatos() async {
    try {
      print('🧹 LIMPIANDO TODA LA BASE DE DATOS...');

      // Limpiar usuarios
      QuerySnapshot usuariosSnapshot = await _firestore.collection('usuarios').get();
      for (var doc in usuariosSnapshot.docs) {
        await doc.reference.delete();
        print('🗑️ Usuario eliminado: ${doc.id}');
      }

      // Limpiar figuras
      QuerySnapshot figurasSnapshot = await _firestore.collection('figuras').get();
      for (var doc in figurasSnapshot.docs) {
        await doc.reference.delete();
        print('🗑️ Figura eliminada: ${doc.id}');
      }

      // Limpiar configuraciones
      QuerySnapshot configSnapshot = await _firestore.collection('configuraciones').get();
      for (var doc in configSnapshot.docs) {
        await doc.reference.delete();
        print('🗑️ Configuración eliminada: ${doc.id}');
      }

      print('✅ Base de datos limpiada completamente');
    } catch (e) {
      print('❌ Error limpiando base de datos: $e');
      rethrow;
    }
  }

  // ==================== UTILIDADES ====================

  static bool usuarioValido(String usuario) {
    String usuarioLimpio = usuario.trim().toLowerCase();
    // Solo letras, números y algunos caracteres especiales
    return RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(usuarioLimpio) && usuarioLimpio.length >= 3;
  }

  static bool passwordValida(String password) {
    return password.length >= 4;
  }

  Future<bool> verificarConexion() async {
    try {
      await _firestore.collection('test').limit(1).get();
      return true;
    } catch (e) {
      print('❌ Error verificando conexión: $e');
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
import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String id;
  final String email;
  final String nombre;
  final String rol; // "cliente" o "admin"
  final bool activo;
  final DateTime fechaCreacion;

  Usuario({
    required this.id,
    required this.email,
    required this.nombre,
    required this.rol,
    required this.activo,
    required this.fechaCreacion,
  });

  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    try {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      return Usuario(
        id: doc.id,
        email: _getString(data, 'email'),
        nombre: _getString(data, 'nombre'),
        rol: _getString(data, 'rol', defaultValue: 'cliente'),
        activo: _getBool(data, 'activo', defaultValue: true),
        fechaCreacion: _getDateTime(data, 'fechaCreacion'),
      );
    } catch (e) {
      print('❌ Error parseando usuario ${doc.id}: $e');
      // Retornar usuario con valores por defecto en caso de error
      return Usuario(
        id: doc.id,
        email: 'error@example.com',
        nombre: 'Usuario con Error',
        rol: 'cliente',
        activo: false,
        fechaCreacion: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'nombre': nombre,
      'rol': rol,
      'activo': activo,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
    };
  }

  // Método para verificar si es administrador
  bool get esAdmin => rol == 'admin';

  // Método para verificar si está activo
  bool get estaActivo => activo;

  // Método para crear copia con cambios
  Usuario copiarCon({
    String? email,
    String? nombre,
    String? rol,
    bool? activo,
  }) {
    return Usuario(
      id: id,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      rol: rol ?? this.rol,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion,
    );
  }

  // Métodos helper para parsear datos de forma segura
  static String _getString(Map<String, dynamic> data, String key, {String defaultValue = ''}) {
    try {
      final value = data[key];
      if (value == null) return defaultValue;
      if (value is String) return value;
      return value.toString();
    } catch (e) {
      print('⚠️ Error obteniendo string para $key: $e');
      return defaultValue;
    }
  }

  static bool _getBool(Map<String, dynamic> data, String key, {bool defaultValue = false}) {
    try {
      final value = data[key];
      if (value == null) return defaultValue;
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      if (value is int) return value != 0;
      return defaultValue;
    } catch (e) {
      print('⚠️ Error obteniendo bool para $key: $e');
      return defaultValue;
    }
  }

  static DateTime _getDateTime(Map<String, dynamic> data, String key) {
    try {
      final value = data[key];
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    } catch (e) {
      print('⚠️ Error obteniendo DateTime para $key: $e');
      return DateTime.now();
    }
  }

  @override
  String toString() {
    return 'Usuario{id: $id, email: $email, nombre: $nombre, rol: $rol, activo: $activo}';
  }
}
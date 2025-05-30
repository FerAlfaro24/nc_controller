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
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Usuario(
      id: doc.id,
      email: data['email'] ?? '',
      nombre: data['nombre'] ?? '',
      rol: data['rol'] ?? 'cliente',
      activo: data['activo'] ?? true,
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
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
}
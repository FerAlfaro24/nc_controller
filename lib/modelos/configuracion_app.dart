import 'package:cloud_firestore/cloud_firestore.dart';

class ConfiguracionApp {
  final String textoMarquee;
  final PublicidadPush publicidadPush;
  final DateTime fechaActualizacion;

  ConfiguracionApp({
    required this.textoMarquee,
    required this.publicidadPush,
    required this.fechaActualizacion,
  });

  factory ConfiguracionApp.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ConfiguracionApp(
      textoMarquee: data['textoMarquee'] ?? '¡Bienvenido a Naboo Customs!',
      publicidadPush: PublicidadPush.fromMap(data['publicidadPush'] ?? {}),
      fechaActualizacion: (data['fechaActualizacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'textoMarquee': textoMarquee,
      'publicidadPush': publicidadPush.toMap(),
      'fechaActualizacion': Timestamp.fromDate(fechaActualizacion),
    };
  }

  // Configuración por defecto
  static ConfiguracionApp porDefecto() {
    return ConfiguracionApp(
      textoMarquee: '¡Nuevas figuras disponibles! Visita nuestro catálogo',
      publicidadPush: PublicidadPush.vacia(),
      fechaActualizacion: DateTime.now(),
    );
  }

  // Método para crear copia con cambios
  ConfiguracionApp copiarCon({
    String? textoMarquee,
    PublicidadPush? publicidadPush,
  }) {
    return ConfiguracionApp(
      textoMarquee: textoMarquee ?? this.textoMarquee,
      publicidadPush: publicidadPush ?? this.publicidadPush,
      fechaActualizacion: DateTime.now(),
    );
  }
}

class PublicidadPush {
  final bool activa;
  final String titulo;
  final String descripcion;
  final String imagenUrl;
  final String imagenPublicId; // ID de Cloudinary para gestión
  final String accionUrl; // URL a la que redirige al hacer clic
  final DateTime fechaCreacion;
  final DateTime? fechaExpiracion;

  PublicidadPush({
    required this.activa,
    required this.titulo,
    required this.descripcion,
    required this.imagenUrl,
    required this.imagenPublicId,
    required this.accionUrl,
    required this.fechaCreacion,
    this.fechaExpiracion,
  });

  factory PublicidadPush.fromMap(Map<String, dynamic> map) {
    return PublicidadPush(
      activa: map['activa'] ?? false,
      titulo: map['titulo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      imagenUrl: map['imagenUrl'] ?? '',
      imagenPublicId: map['imagenPublicId'] ?? '',
      accionUrl: map['accionUrl'] ?? '',
      fechaCreacion: (map['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fechaExpiracion: (map['fechaExpiracion'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'activa': activa,
      'titulo': titulo,
      'descripcion': descripcion,
      'imagenUrl': imagenUrl,
      'imagenPublicId': imagenPublicId,
      'accionUrl': accionUrl,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaExpiracion': fechaExpiracion != null ? Timestamp.fromDate(fechaExpiracion!) : null,
    };
  }

  static PublicidadPush vacia() {
    return PublicidadPush(
      activa: false,
      titulo: '',
      descripcion: '',
      imagenUrl: '',
      imagenPublicId: '',
      accionUrl: '',
      fechaCreacion: DateTime.now(),
    );
  }

  bool get estaExpirada {
    if (fechaExpiracion == null) return false;
    return DateTime.now().isAfter(fechaExpiracion!);
  }

  // CORREGIDO: Cambié deberíaMostrarse por deberiaMostrarse (sin tilde)
  bool get deberiaMostrarse => activa && !estaExpirada;

  PublicidadPush copiarCon({
    bool? activa,
    String? titulo,
    String? descripcion,
    String? imagenUrl,
    String? imagenPublicId,
    String? accionUrl,
    DateTime? fechaExpiracion,
  }) {
    return PublicidadPush(
      activa: activa ?? this.activa,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      imagenPublicId: imagenPublicId ?? this.imagenPublicId,
      accionUrl: accionUrl ?? this.accionUrl,
      fechaCreacion: fechaCreacion,
      fechaExpiracion: fechaExpiracion ?? this.fechaExpiracion,
    );
  }
}
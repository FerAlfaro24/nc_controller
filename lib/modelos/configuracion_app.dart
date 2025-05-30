import 'package:cloud_firestore/cloud_firestore.dart';

class ConfiguracionApp {
  final String textoMarquee;
  final String imagenPublicidad;
  final bool mostrarPublicidad;
  final DateTime fechaActualizacion;

  ConfiguracionApp({
    required this.textoMarquee,
    required this.imagenPublicidad,
    required this.mostrarPublicidad,
    required this.fechaActualizacion,
  });

  factory ConfiguracionApp.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ConfiguracionApp(
      textoMarquee: data['textoMarquee'] ?? '¡Bienvenido a Naboo Customs!',
      imagenPublicidad: data['imagenPublicidad'] ?? '',
      mostrarPublicidad: data['mostrarPublicidad'] ?? false,
      fechaActualizacion: (data['fechaActualizacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'textoMarquee': textoMarquee,
      'imagenPublicidad': imagenPublicidad,
      'mostrarPublicidad': mostrarPublicidad,
      'fechaActualizacion': Timestamp.fromDate(fechaActualizacion),
    };
  }

  // Configuración por defecto
  static ConfiguracionApp porDefecto() {
    return ConfiguracionApp(
      textoMarquee: '¡Nuevas figuras disponibles! Visita nuestro catálogo',
      imagenPublicidad: '',
      mostrarPublicidad: false,
      fechaActualizacion: DateTime.now(),
    );
  }

  // Método para crear copia con cambios
  ConfiguracionApp copiarCon({
    String? textoMarquee,
    String? imagenPublicidad,
    bool? mostrarPublicidad,
  }) {
    return ConfiguracionApp(
      textoMarquee: textoMarquee ?? this.textoMarquee,
      imagenPublicidad: imagenPublicidad ?? this.imagenPublicidad,
      mostrarPublicidad: mostrarPublicidad ?? this.mostrarPublicidad,
      fechaActualizacion: DateTime.now(),
    );
  }
}
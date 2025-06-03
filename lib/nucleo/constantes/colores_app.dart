import 'package:flutter/material.dart';

class ColoresApp {
  ColoresApp._();

  // Colores principales - tema espacial futurista
  static const Color oscuroPrimario = Color(0xFF0A0A0F);
  static const Color azulPrimario = Color(0xFF1E3A8A);
  static const Color cyanPrimario = Color(0xFF06B6D4);
  static const Color moradoPrimario = Color(0xFF7C3AED);

  // Colores de acento
  static const Color verdeAcento = Color(0xFF10B981);
  static const Color naranjaAcento = Color(0xFFF59E0B);
  static const Color rojoAcento = Color(0xFFEF4444);
  static const Color rosaAcento = Color(0xFF833AB4);

  // Grises espaciales
  static const Color fondoOscuro = Color(0xFF0F0F0F);
  static const Color superficieOscura = Color(0xFF1A1A1A);
  static const Color tarjetaOscura = Color(0xFF252525);
  static const Color bordeGris = Color(0xFF404040);

  // Texto
  static const Color textoPrimario = Color(0xFFFFFFFF);
  static const Color textoSecundario = Color(0xFFB3B3B3);
  static const Color textoApagado = Color(0xFF808080);

  // Estados
  static const Color exito = Color(0xFF10B981);
  static const Color advertencia = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color informacion = Color(0xFF06B6D4);

  // Bluetooth específicos
  static const Color bluetoothConectado = Color(0xFF10B981);
  static const Color bluetoothDesconectado = Color(0xFFEF4444);
  static const Color bluetoothBuscando = Color(0xFFF59E0B);

  // LED específicos
  static const Color ledEncendido = Color(0xFF10B981);
  static const Color ledApagado = Color(0xFF404040);

  // Gradientes
  static const LinearGradient gradientePrimario = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [azulPrimario, moradoPrimario],
  );

  static const LinearGradient gradienteAcento = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cyanPrimario, verdeAcento],
  );

  static const LinearGradient gradienteFondo = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [fondoOscuro, oscuroPrimario],
  );
}
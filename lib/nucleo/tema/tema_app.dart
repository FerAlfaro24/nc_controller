import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constantes/colores_app.dart';

class TemaApp {
  TemaApp._();

  static ThemeData get temaOscuro {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Esquema de colores
      colorScheme: const ColorScheme.dark(
        primary: ColoresApp.azulPrimario,
        secondary: ColoresApp.cyanPrimario,
        tertiary: ColoresApp.moradoPrimario,
        surface: ColoresApp.superficieOscura,
        background: ColoresApp.fondoOscuro,
        error: ColoresApp.error,
        onPrimary: ColoresApp.textoPrimario,
        onSecondary: ColoresApp.textoPrimario,
        onSurface: ColoresApp.textoPrimario,
        onBackground: ColoresApp.textoPrimario,
        onError: ColoresApp.textoPrimario,
        outline: ColoresApp.bordeGris,
      ),

      // Tipografía futurista
      textTheme: GoogleFonts.orbitronTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: ColoresApp.textoPrimario,
            letterSpacing: 1.2,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: ColoresApp.textoPrimario,
            letterSpacing: 1.1,
          ),
          displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: ColoresApp.textoPrimario,
            letterSpacing: 1.0,
          ),
          headlineLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: ColoresApp.textoPrimario,
            letterSpacing: 0.8,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: ColoresApp.textoPrimario,
            letterSpacing: 0.6,
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: ColoresApp.textoPrimario,
            letterSpacing: 0.4,
          ),
          titleLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ColoresApp.textoPrimario,
            letterSpacing: 0.2,
          ),
          titleMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ColoresApp.textoSecundario,
            letterSpacing: 0.2,
          ),
          titleSmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: ColoresApp.textoApagado,
            letterSpacing: 0.1,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: ColoresApp.textoSecundario,
            letterSpacing: 0.1,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: ColoresApp.textoSecundario,
            letterSpacing: 0.1,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: ColoresApp.textoApagado,
            letterSpacing: 0.1,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ColoresApp.textoPrimario,
            letterSpacing: 0.3,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: ColoresApp.textoSecundario,
            letterSpacing: 0.2,
          ),
          labelSmall: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: ColoresApp.textoApagado,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // Barra de aplicación
      appBarTheme: const AppBarTheme(
        backgroundColor: ColoresApp.superficieOscura,
        foregroundColor: ColoresApp.textoPrimario,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ColoresApp.textoPrimario,
          letterSpacing: 1.0,
        ),
      ),

      // Tarjetas
      cardTheme: const CardThemeData(
        color: ColoresApp.tarjetaOscura,
        elevation: 8,
        shadowColor: ColoresApp.azulPrimario,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColoresApp.azulPrimario,
          foregroundColor: ColoresApp.textoPrimario,
          elevation: 4,
          shadowColor: ColoresApp.azulPrimario.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Botones con borde
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ColoresApp.cyanPrimario,
          side: const BorderSide(color: ColoresApp.cyanPrimario, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Campos de texto
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColoresApp.tarjetaOscura,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColoresApp.bordeGris),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColoresApp.bordeGris),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColoresApp.cyanPrimario, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColoresApp.error),
        ),
        labelStyle: const TextStyle(color: ColoresApp.textoSecundario),
        hintStyle: const TextStyle(color: ColoresApp.textoApagado),
        contentPadding: const EdgeInsets.all(16),
      ),

      // Cajón de navegación
      drawerTheme: const DrawerThemeData(
        backgroundColor: ColoresApp.superficieOscura,
        scrimColor: ColoresApp.oscuroPrimario,
      ),

      // Barra de navegación inferior
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ColoresApp.superficieOscura,
        selectedItemColor: ColoresApp.cyanPrimario,
        unselectedItemColor: ColoresApp.textoApagado,
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      ),

      // Botón flotante
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: ColoresApp.cyanPrimario,
        foregroundColor: ColoresApp.textoPrimario,
        elevation: 8,
        shape: CircleBorder(),
      ),

      // Divisor
      dividerTheme: const DividerThemeData(
        color: ColoresApp.bordeGris,
        thickness: 1,
      ),

      // Interruptor
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return ColoresApp.cyanPrimario;
          }
          return ColoresApp.textoApagado;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return ColoresApp.cyanPrimario.withOpacity(0.3);
          }
          return ColoresApp.bordeGris;
        }),
      ),
    );
  }
}
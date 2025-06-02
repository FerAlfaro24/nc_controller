import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'nucleo/tema/tema_app.dart';
import 'servicios/auth_service.dart';
import 'servicios/firebase_service.dart';
import 'pantallas/login_screen.dart';

void main() async {
  // CRÍTICO: Configurar manejo de errores ANTES de cualquier otra cosa
  FlutterError.onError = (FlutterErrorDetails details) {
    print('🚨 Flutter Error capturado: ${details.exception}');
    print('Stack trace: ${details.stack}');
  };

  // Asegurar que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase inicializado correctamente");
  } catch (e) {
    print("❌ Error inicializando Firebase: $e");
  }

  // IMPORTANTE: Usar runZonedGuarded para capturar errores async
  runZonedGuarded(
        () => runApp(const AplicacionPrincipal()),
        (error, stackTrace) {
      print('🚨 Error async capturado: $error');
      print('Stack trace: $stackTrace');
    },
  );
}

class AplicacionPrincipal extends StatelessWidget {
  const AplicacionPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NC Controller',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.temaOscuro,

      // DIRECTO A LOGIN SIN PROVIDER
      home: const AppInitializer(),

      // Configurar manejo de errores personalizado MEJORADO
      builder: (context, widget) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return _buildErrorWidget(context, errorDetails);
        };
        return widget!;
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context, FlutterErrorDetails errorDetails) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(0.2),
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'ERROR DETECTADO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                Text(
                  'Error: ${errorDetails.exception.toString()}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                const Text(
                  'La aplicación encontró un problema. Intenta reiniciarla.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: () {
                    // Navegar a login como recuperación
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const AppInitializer()),
                          (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06B6D4),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text(
                    'REINICIAR',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Clase SIMPLIFICADA que maneja la inicialización SIN PROVIDER
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;
  String _initStatus = 'Iniciando...';
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() {
        _initStatus = 'Configurando servicios...';
        _hasError = false;
        _errorMessage = '';
      });

      // Pequeña pausa para asegurar que Flutter esté completamente listo
      await Future.delayed(const Duration(milliseconds: 500));

      // Inicializar servicios de manera segura DIRECTAMENTE
      print("🔧 Inicializando AuthService...");
      final authService = AuthService();
      await Future.delayed(const Duration(milliseconds: 200));

      print("🔧 Inicializando FirebaseService...");
      final firebaseService = FirebaseService();
      await Future.delayed(const Duration(milliseconds: 200));

      setState(() => _initStatus = 'Verificando conexión...');

      // Verificar que los servicios funcionen
      bool connectionOk = await firebaseService.verificarConexion();
      print("🔗 Conexión Firebase: ${connectionOk ? 'OK' : 'FALLO'}");

      if (!connectionOk) {
        throw Exception('No se pudo conectar a Firebase');
      }

      setState(() => _initStatus = 'Listo!');
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        setState(() => _isInitialized = true);
      }

    } catch (e) {
      print("❌ Error en inicialización: $e");

      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _initStatus = 'Error: $e';
        });

        // Reintentar después de un delay
        Timer(const Duration(seconds: 3), () {
          if (mounted && _hasError) {
            _initializeApp();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorScreen();
    }

    if (!_isInitialized) {
      return _buildLoadingScreen();
    }

    // Una vez inicializado, ir DIRECTO AL LOGIN SIN PROVIDER
    return const PantallaLogin();
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(0.2),
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'ERROR DE INICIALIZACIÓN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                const Text(
                  'Reintentando automáticamente...',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () => _initializeApp(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06B6D4),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text(
                    'REINTENTAR',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F0F0F),
              Color(0xFF0A0A0F),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo animado
                TweenAnimationBuilder<double>(
                  duration: const Duration(seconds: 2),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.rotate(
                      angle: value * 2 * 3.14159,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF1E3A8A).withOpacity(value),
                              Color(0xFF7C3AED).withOpacity(value),
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.rocket_launch,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                const Text(
                  'NABOO CUSTOMS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),

                const Text(
                  'Controller',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 48),

                // Indicador de progreso
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF06B6D4)),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  _initStatus,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    print("🔧 Disposing AppInitializer");
    super.dispose();
  }
}
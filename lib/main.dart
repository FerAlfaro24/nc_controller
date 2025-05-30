import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
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

      // CLAVE: Usar una pantalla inicial que maneje la inicialización
      home: const AppInitializer(),

      // Configurar manejo de errores personalizado
      builder: (context, widget) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return _buildErrorWidget(errorDetails);
        };
        return widget!;
      },
    );
  }

  Widget _buildErrorWidget(FlutterErrorDetails errorDetails) {
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

                const Text(
                  'La aplicación encontró un problema y necesita reiniciarse.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: () {
                    // Forzar reinicio completo
                    main();
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

// Nueva clase que maneja la inicialización paso a paso
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;
  String _initStatus = 'Iniciando...';
  AuthService? _authService;
  FirebaseService? _firebaseService;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() => _initStatus = 'Configurando servicios...');

      // Pequeña pausa para asegurar que Flutter esté completamente listo
      await Future.delayed(const Duration(milliseconds: 500));

      // Inicializar servicios de manera segura
      _authService = AuthService();
      await Future.delayed(const Duration(milliseconds: 100));

      _firebaseService = FirebaseService();
      await Future.delayed(const Duration(milliseconds: 100));

      setState(() => _initStatus = 'Verificando conexión...');

      // Verificar que los servicios funcionen
      bool connectionOk = await _firebaseService!.verificarConexion();
      print("🔗 Conexión Firebase: ${connectionOk ? 'OK' : 'FALLO'}");

      setState(() => _initStatus = 'Listo!');
      await Future.delayed(const Duration(milliseconds: 300));

      setState(() => _isInitialized = true);

    } catch (e) {
      print("❌ Error en inicialización: $e");
      setState(() => _initStatus = 'Error: $e');

      // Reintentar después de un delay
      await Future.delayed(const Duration(seconds: 2));
      _initializeApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return _buildLoadingScreen();
    }

    // Una vez inicializado, crear el Provider tree
    return MultiProvider(
      providers: [
        Provider<AuthService>.value(value: _authService!),
        Provider<FirebaseService>.value(value: _firebaseService!),
      ],
      child: const PantallaLogin(),
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
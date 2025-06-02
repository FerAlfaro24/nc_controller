import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'nucleo/tema/tema_app.dart';
import 'servicios/auth_service.dart';
import 'servicios/firebase_service.dart';
import 'servicios/cloudinary_service.dart';
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
  int _progress = 0;
  final int _totalSteps = 5;

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
        _progress = 0;
      });

      // Pequeña pausa para asegurar que Flutter esté completamente listo
      await Future.delayed(const Duration(milliseconds: 800));

      // Paso 1: Inicializar AuthService
      setState(() {
        _initStatus = 'Inicializando sistema de autenticación...';
        _progress = 1;
      });
      print("🔧 Inicializando AuthService...");
      final authService = AuthService();
      await Future.delayed(const Duration(milliseconds: 500));

      // Paso 2: Inicializar FirebaseService
      setState(() {
        _initStatus = 'Conectando con Firebase...';
        _progress = 2;
      });
      print("🔧 Inicializando FirebaseService...");
      final firebaseService = FirebaseService();
      await Future.delayed(const Duration(milliseconds: 500));

      // Paso 3: Inicializar CloudinaryService
      setState(() {
        _initStatus = 'Configurando servicio de imágenes...';
        _progress = 3;
      });
      print("🔧 Inicializando CloudinaryService...");
      final cloudinaryService = CloudinaryService();
      cloudinaryService.inicializar();
      await Future.delayed(const Duration(milliseconds: 500));

      // Paso 4: Verificar conexiones
      setState(() {
        _initStatus = 'Verificando conexiones...';
        _progress = 4;
      });

      // Verificar que los servicios funcionen
      bool connectionOk = await firebaseService.verificarConexion();
      print("🔗 Conexión Firebase: ${connectionOk ? 'OK' : 'FALLO'}");

      if (!connectionOk) {
        throw Exception('No se pudo conectar a Firebase');
      }

      // Paso 5: Finalización
      setState(() {
        _initStatus = 'Finalizando configuración...';
        _progress = 5;
      });
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() => _initStatus = '¡Listo para usar!');
      await Future.delayed(const Duration(milliseconds: 400));

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

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Reintentando automáticamente...',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _initializeApp(),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF06B6D4),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Salir de la aplicación
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const PantallaLogin()),
                              (route) => false,
                        );
                      },
                      icon: const Icon(Icons.skip_next, size: 18),
                      label: const Text('Continuar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    double progressValue = _progress / _totalSteps;

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
                // Logo animado con progreso
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Círculo de progreso
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: progressValue,
                        strokeWidth: 4,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF06B6D4)),
                      ),
                    ),

                    // Logo central rotando
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
                                  Color(0xFF1E3A8A).withOpacity(0.8),
                                  Color(0xFF7C3AED).withOpacity(0.8),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF06B6D4).withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.rocket_launch,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Títulos
                const Text(
                  'NABOO CUSTOMS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 8),

                const Text(
                  'Controller',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 50),

                // Barra de progreso detallada
                Container(
                  width: 280,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      // Barra de progreso
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progressValue,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF06B6D4), Color(0xFF10B981)],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Texto de estado
                      Text(
                        _initStatus,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Indicador de progreso en texto
                      Text(
                        'Paso $_progress de $_totalSteps',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Indicadores de estado de servicios
                _construirIndicadoresServicios(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirIndicadoresServicios() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Text(
            'Servicios',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _indicadorServicio(
                'Firebase',
                Icons.cloud,
                _progress >= 2,
              ),
              _indicadorServicio(
                'Auth',
                Icons.security,
                _progress >= 1,
              ),
              _indicadorServicio(
                'Cloudinary',
                Icons.image,
                _progress >= 3,
              ),
              _indicadorServicio(
                'Sistema',
                Icons.check_circle,
                _progress >= 5,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _indicadorServicio(String nombre, IconData icono, bool activo) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: activo
                ? const Color(0xFF10B981).withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icono,
            size: 16,
            color: activo ? const Color(0xFF10B981) : Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          nombre,
          style: TextStyle(
            color: activo ? const Color(0xFF10B981) : Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    print("🔧 Disposing AppInitializer");
    super.dispose();
  }
}
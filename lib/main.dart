import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
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

  // 🔒 NUEVO: Fijar orientación solo en vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 🚀 CAMBIO: NO inicializar Firebase aquí, lo hacemos después
  // try {
  //   await Firebase.initializeApp(
  //     options: DefaultFirebaseOptions.currentPlatform,
  //   );
  //   print("✅ Firebase inicializado correctamente");
  // } catch (e) {
  //   print("❌ Error inicializando Firebase: $e");
  // }

  print("✅ Flutter inicializado - arrancando app inmediatamente");

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

class _AppInitializerState extends State<AppInitializer>
    with TickerProviderStateMixin {
  bool _isInitialized = false;
  String _initStatus = 'Iniciando...';
  bool _hasError = false;
  String _errorMessage = '';
  int _progress = 0;
  final int _totalSteps = 5;

  // 🆕 NUEVO: Flag para controlar Firebase
  bool _firebaseInitialized = false;

  // Controladores de animación
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late AnimationController _particleController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // 🚀 CAMBIO: Pequeño delay para que UI se renderice primero
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _checkBluetoothAndInitialize();
      }
    });
  }

  // 🆕 NUEVA función para verificar Bluetooth antes de inicializar
  Future<void> _checkBluetoothAndInitialize() async {
    try {
      // Solicitar permisos de Bluetooth
      await [
        Permission.bluetooth,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.location,
      ].request();

      // Verificar si Bluetooth está habilitado
      bool? isEnabled = await FlutterBluetoothSerial.instance.isEnabled;

      if (isEnabled != true) {
        // Mostrar diálogo para activar Bluetooth
        bool? shouldEnable = await _showBluetoothDialog();

        if (shouldEnable == true) {
          await FlutterBluetoothSerial.instance.requestEnable();
        }
      }

      // Continuar con la inicialización normal
      _initializeApp();

    } catch (e) {
      print("⚠️ Error con Bluetooth: $e");
      // Continuar aunque haya error con Bluetooth
      _initializeApp();
    }
  }

  // 🆕 NUEVO diálogo simple para activar Bluetooth
  Future<bool?> _showBluetoothDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F0F0F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: const Color(0xFF00D4FF).withOpacity(0.3),
            ),
          ),
          title: Row(
            children: [
              Icon(
                Icons.bluetooth,
                color: const Color(0xFF00D4FF),
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Activar Bluetooth',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Para usar NC Controller necesitas activar el Bluetooth. ¿Deseas activarlo ahora?',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Omitir',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4FF),
              ),
              child: const Text(
                'Activar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _initializeAnimations() {
    // Animación de pulso para el logo
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Animación de rotación
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    // Animación de fade-in
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Animación de partículas
    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ));

    // Iniciar animaciones
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    _fadeController.forward();
    _particleController.repeat();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() {
        _initStatus = 'Configurando servicios...';
        _hasError = false;
        _errorMessage = '';
        _progress = 0;
      });

      // 🔥 CAMBIO: Inicializar Firebase AQUÍ (después de mostrar UI)
      if (!_firebaseInitialized) {
        setState(() {
          _initStatus = 'Inicializando Firebase...';
          _progress = 1;
        });
        print("🔥 Inicializando Firebase...");

        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        _firebaseInitialized = true;
        print("✅ Firebase inicializado correctamente");

        await Future.delayed(const Duration(milliseconds: 300));
      }

      // Paso 2: Inicializar AuthService
      setState(() {
        _initStatus = 'Inicializando sistema de autenticación...';
        _progress = 2;
      });
      print("🔧 Inicializando AuthService...");
      final authService = AuthService();
      await Future.delayed(const Duration(milliseconds: 300));

      // Paso 3: Inicializar FirebaseService
      setState(() {
        _initStatus = 'Conectando con Firebase...';
        _progress = 3;
      });
      print("🔧 Inicializando FirebaseService...");
      final firebaseService = FirebaseService();
      await Future.delayed(const Duration(milliseconds: 300));

      // Paso 4: Inicializar CloudinaryService
      setState(() {
        _initStatus = 'Configurando servicio de imágenes...';
        _progress = 4;
      });
      print("🔧 Inicializando CloudinaryService...");
      final cloudinaryService = CloudinaryService();
      cloudinaryService.inicializar();
      await Future.delayed(const Duration(milliseconds: 300));

      // Paso 5: Verificar conexiones
      setState(() {
        _initStatus = 'Verificando conexiones...';
        _progress = 5;
      });

      // Verificar que los servicios funcionen
      bool connectionOk = await firebaseService.verificarConexion();
      print("🔗 Conexión Firebase: ${connectionOk ? 'OK' : 'FALLO'}");

      if (!connectionOk) {
        throw Exception('No se pudo conectar a Firebase');
      }

      setState(() => _initStatus = '¡Sistema listo para usar!');
      await Future.delayed(const Duration(milliseconds: 500));

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
      return _buildFuturisticLoadingScreen();
    }

    // Una vez inicializado, ir DIRECTO AL LOGIN SIN PROVIDER
    return const PantallaLogin();
  }

  Widget _buildFuturisticLoadingScreen() {
    double progressValue = _progress / _totalSteps;

    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo con overlay
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/imagenes/fondomenu.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Overlay oscuro con gradiente
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0F0F0F).withOpacity(0.85),
                  const Color(0xFF0A0A0F).withOpacity(0.95),
                  const Color(0xFF000000).withOpacity(0.98),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Partículas flotantes animadas
          ...List.generate(20, (index) => _buildFloatingParticle(index)),

          // Contenido principal
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Spacer flexible para centrar mejor
                        const Expanded(flex: 1, child: SizedBox()),

                        // Logo principal con múltiples efectos
                        _buildHolographicLogo(progressValue),

                        SizedBox(height: MediaQuery.of(context).size.height * 0.04),

                        // Título con efecto neón
                        _buildNeonTitle(),

                        SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                        // Panel de control futurista
                        _buildFuturisticControlPanel(progressValue),

                        SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                        // Grid de servicios con animaciones
                        _buildServicesGrid(),

                        // Spacer flexible para el final
                        const Expanded(flex: 1, child: SizedBox()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHolographicLogo(double progress) {
    double screenWidth = MediaQuery.of(context).size.width;
    double logoSize = screenWidth * 0.45; // 45% del ancho de pantalla
    logoSize = logoSize.clamp(150.0, 200.0); // Mínimo 150, máximo 200

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _rotationAnimation]),
      builder: (context, child) {
        return Container(
          width: logoSize,
          height: logoSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Círculos de progreso múltiples
              ...List.generate(3, (index) => _buildProgressRing(progress, index, logoSize)),

              // Logo central con efectos
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Container(
                    width: logoSize * 0.5,
                    height: logoSize * 0.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF00D4FF),
                          const Color(0xFF0099CC),
                          const Color(0xFF006699),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D4FF).withOpacity(0.6),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                        BoxShadow(
                          color: const Color(0xFF0099CC).withOpacity(0.4),
                          blurRadius: 50,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.rocket_launch,
                      size: logoSize * 0.25,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Anillo exterior giratorio
              Transform.rotate(
                angle: -_rotationAnimation.value * 0.5,
                child: Container(
                  width: logoSize * 0.9,
                  height: logoSize * 0.9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00D4FF).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: CustomPaint(
                    painter: HologramRingPainter(
                      progress: progress,
                      color: const Color(0xFF00D4FF),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressRing(double progress, int ringIndex, double logoSize) {
    double size = logoSize * (0.7 + (ringIndex * 0.1));
    double strokeWidth = 3.0 - (ringIndex * 0.5);

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        value: progress,
        strokeWidth: strokeWidth,
        backgroundColor: Colors.white.withOpacity(0.1),
        valueColor: AlwaysStoppedAnimation<Color>(
          [
            const Color(0xFF00D4FF),
            const Color(0xFF0099CC),
            const Color(0xFF006699),
          ][ringIndex].withOpacity(0.8 - (ringIndex * 0.2)),
        ),
      ),
    );
  }

  Widget _buildNeonTitle() {
    double screenWidth = MediaQuery.of(context).size.width;
    double titleFontSize = (screenWidth * 0.08).clamp(24.0, 32.0);
    double subtitleFontSize = (screenWidth * 0.04).clamp(12.0, 16.0);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF00D4FF).withOpacity(0.5),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D4FF).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            'NABOO CUSTOMS',
            style: TextStyle(
              color: Colors.white,
              fontSize: titleFontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              shadows: const [
                Shadow(
                  color: Color(0xFF00D4FF),
                  blurRadius: 10,
                ),
                Shadow(
                  color: Color(0xFF0099CC),
                  blurRadius: 20,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'CONTROLLER SYSTEM',
          style: TextStyle(
            color: const Color(0xFF00D4FF).withOpacity(0.8),
            fontSize: subtitleFontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFuturisticControlPanel(double progress) {
    double screenWidth = MediaQuery.of(context).size.width;
    double panelWidth = (screenWidth * 0.85).clamp(280.0, 320.0);

    return Container(
      width: panelWidth,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00D4FF).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Barra de progreso principal con efectos
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                // Progreso base
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF00D4FF),
                          Color(0xFF0099CC),
                          Color(0xFF00FF94),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D4FF).withOpacity(0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
                // Efecto de brillo que se mueve
                AnimatedBuilder(
                  animation: _particleAnimation,
                  builder: (context, child) {
                    return Positioned(
                      left: (progress * (panelWidth - 80)) - 20,
                      child: Container(
                        width: 40,
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              const Color(0xFF00D4FF).withOpacity(0.8),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Estado del sistema
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _initStatus,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4FF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF00D4FF).withOpacity(0.5),
                  ),
                ),
                child: Text(
                  '$_progress/$_totalSteps',
                  style: const TextStyle(
                    color: Color(0xFF00D4FF),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Detalles técnicos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTechDetail('VELOCIDAD', '${(progress * 100).toInt()}%'),
              _buildTechDetail('ESTADO', 'ACTIVO'),
              _buildTechDetail('CONEXIÓN', 'SEGURA'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTechDetail(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.withOpacity(0.8),
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF00D4FF),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildServicesGrid() {
    final services = [
      {'name': 'FIREBASE', 'icon': Icons.cloud, 'active': _progress >= 1},
      {'name': 'AUTH', 'icon': Icons.security, 'active': _progress >= 2},
      {'name': 'STORAGE', 'icon': Icons.storage, 'active': _progress >= 4},
      {'name': 'SISTEMA', 'icon': Icons.check_circle, 'active': _progress >= 5},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            'MÓDULOS DEL SISTEMA',
            style: TextStyle(
              color: Colors.grey.withOpacity(0.9),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: services.map((service) => _buildServiceModule(
              service['name'] as String,
              service['icon'] as IconData,
              service['active'] as bool,
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceModule(String name, IconData icon, bool active) {
    double screenWidth = MediaQuery.of(context).size.width;
    double moduleSize = (screenWidth * 0.18).clamp(60.0, 80.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: moduleSize,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF00D4FF).withOpacity(0.2)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active
              ? const Color(0xFF00D4FF).withOpacity(0.6)
              : Colors.grey.withOpacity(0.3),
        ),
        boxShadow: active ? [
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ] : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              icon,
              size: 16,
              color: active ? const Color(0xFF00D4FF) : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              color: active ? const Color(0xFF00D4FF) : Colors.grey,
              fontSize: 8,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (active) ...[
            const SizedBox(height: 3),
            Container(
              width: 3,
              height: 3,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF00FF94),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF00FF94),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        double screenWidth = MediaQuery.of(context).size.width;
        double screenHeight = MediaQuery.of(context).size.height;

        double x = (index * 47) % screenWidth;
        double y = ((index * 97) % screenHeight) +
            (50 * sin(_particleAnimation.value * 2 * pi + index));

        return Positioned(
          left: x,
          top: y,
          child: Container(
            width: 2 + (index % 3),
            height: 2 + (index % 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: [
                const Color(0xFF00D4FF),
                const Color(0xFF0099CC),
                const Color(0xFF00FF94),
              ][index % 3].withOpacity(0.6),
              boxShadow: [
                BoxShadow(
                  color: [
                    const Color(0xFF00D4FF),
                    const Color(0xFF0099CC),
                    const Color(0xFF00FF94),
                  ][index % 3].withOpacity(0.4),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      body: Stack(
        children: [
          // Mismo fondo que la pantalla de carga
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/imagenes/fondomenu.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.red.withOpacity(0.1),
                  const Color(0xFF0F0F0F).withOpacity(0.9),
                ],
              ),
            ),
          ),
          SafeArea(
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _fadeController.dispose();
    _particleController.dispose();
    print("🔧 Disposing AppInitializer");
    super.dispose();
  }
}

// Painter personalizado para el anillo holográfico
class HologramRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  HologramRingPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Dibujar segmentos del anillo
    for (int i = 0; i < 8; i++) {
      final startAngle = (i * 45) * (pi / 180);
      final sweepAngle = 30 * (pi / 180);

      if (i / 8 <= progress) {
        paint.color = color.withOpacity(0.8);
      } else {
        paint.color = color.withOpacity(0.2);
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
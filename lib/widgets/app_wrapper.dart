import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../servicios/auth_service.dart';
import '../../servicios/firebase_service.dart';

class AppWrapper extends StatefulWidget {
  final Widget child;

  const AppWrapper({
    super.key,
    required this.child,
  });

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  late AuthService _authService;
  late FirebaseService _firebaseService;
  bool _servicesInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _initializeServices() {
    try {
      print("🔧 Inicializando servicios...");
      _authService = AuthService();
      _firebaseService = FirebaseService();

      setState(() {
        _servicesInitialized = true;
      });
      print("✅ Servicios inicializados correctamente");
    } catch (e) {
      print("❌ Error inicializando servicios: $e");
      // Intentar de nuevo después de un delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          _initializeServices();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_servicesInitialized) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF0F0F0F),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF7C3AED)],
                    ),
                  ),
                  child: const Icon(
                    Icons.rocket_launch,
                    size: 60,
                    color: Colors.white,
                  ),
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
                const SizedBox(height: 16),
                const Text(
                  'Inicializando...',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF06B6D4)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        Provider<AuthService>.value(value: _authService),
        Provider<FirebaseService>.value(value: _firebaseService),
      ],
      child: widget.child,
    );
  }

  @override
  void dispose() {
    print("🔧 Dispose AppWrapper");
    super.dispose();
  }
}
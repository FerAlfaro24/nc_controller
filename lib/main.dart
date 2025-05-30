import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'nucleo/tema/tema_app.dart';
import 'servicios/auth_service.dart';
import 'servicios/firebase_service.dart';
import 'servicios/database_initializer.dart';
import 'pantallas/login_screen.dart';

void main() async {
  // Asegurar que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializar Firebase con configuración corregida
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase inicializado correctamente");

    // Opcional: Inicializar base de datos en desarrollo
    // await DatabaseInitializer.inicializarBaseDatos();

  } catch (e) {
    print("❌ Error inicializando Firebase: $e");
    // Continuar sin Firebase por ahora para evitar que se crashee la app
  }

  runApp(const AplicacionPrincipal());
}

class AplicacionPrincipal extends StatelessWidget {
  const AplicacionPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Servicios de la aplicación
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<FirebaseService>(
          create: (_) => FirebaseService(),
        ),
      ],
      child: MaterialApp(
        title: 'NC Controller',
        debugShowCheckedModeBanner: false,

        // Usar el tema personalizado
        theme: TemaApp.temaOscuro,

        // Pantalla inicial es el login
        home: const PantallaLogin(),
      ),
    );
  }
}
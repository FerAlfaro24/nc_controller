import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importante que esté aquí
import '../servicios/auth_service.dart';
import '../nucleo/constantes/colores_app.dart';
import 'home_screen.dart';
import 'admin_screen.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

// --- CLASE MODIFICADA ---
// Ahora usa SharedPreferences para guardar los datos de forma persistente.
class _CredencialesManager {
  // Claves para guardar los valores en SharedPreferences. Es una buena práctica.
  static const String _keyRecordarme = 'recordarme';
  static const String _keyUsuario = 'ultimo_usuario';
  static const String _keyPassword = 'ultima_password';

  // El método 'guardar' ahora es asíncrono porque SharedPreferences lo es.
  static Future<void> guardar(bool recordarme, String usuario, String password) async {
    // 1. Obtener la instancia de SharedPreferences.
    final prefs = await SharedPreferences.getInstance();

    // 2. Guardar el estado del checkbox "Recordarme".
    await prefs.setBool(_keyRecordarme, recordarme);

    if (recordarme) {
      // 3. Si "Recordarme" está activo, guardamos usuario y contraseña.
      await prefs.setString(_keyUsuario, usuario);
      await prefs.setString(_keyPassword, password);
      print('💾 Credenciales guardadas persistentemente para: $usuario');
    } else {
      // 4. Si no, eliminamos las credenciales del almacenamiento.
      await prefs.remove(_keyUsuario);
      await prefs.remove(_keyPassword);
      print('🗑️ Credenciales eliminadas del almacenamiento persistente');
    }
  }

  // El método 'cargar' también es asíncrono.
  static Future<Map<String, dynamic>> cargar() async {
    final prefs = await SharedPreferences.getInstance();

    // Leemos los valores del almacenamiento.
    // Usamos '??' (operador de coalescencia nula) para dar un valor por defecto
    // si la clave no existe (por ejemplo, la primera vez que se abre la app).
    final bool recordarme = prefs.getBool(_keyRecordarme) ?? false;
    final String usuario = prefs.getString(_keyUsuario) ?? '';
    final String password = prefs.getString(_keyPassword) ?? '';

    print('📂 Credenciales cargadas desde almacenamiento persistente.');

    return {
      'recordarme': recordarme,
      'usuario': usuario,
      'password': password,
    };
  }
}


class _PantallaLoginState extends State<PantallaLogin>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _cargando = false;
  bool _mostrarPassword = false;
  bool _recordarme = false;

  final AuthService _authService = AuthService();

  // Controladores de animación
  late AnimationController _logoAnimationController;
  late AnimationController _formAnimationController;
  late AnimationController _buttonAnimationController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _formFadeAnimation;
  late Animation<double> _buttonPulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // La llamada ahora es a un método asíncrono, pero se maneja correctamente.
      _cargarCredencialesGuardadas();
    });
  }

  void _initAnimations() {
    // ... (Tu código de animación permanece igual, no es necesario cambiarlo)
    // Animación del logo
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    _logoRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.easeInOut,
    ));

    // Animación del formulario
    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _formFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeInOut,
    ));

    // Animación del botón
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _buttonPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));

    // Iniciar animaciones
    _logoAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _formAnimationController.forward();
    });
  }

  // --- MÉTODO MODIFICADO ---
  // Ahora es 'async' para poder usar 'await' con el _CredencialesManager
  Future<void> _cargarCredencialesGuardadas() async {
    try {
      // 'await' espera a que se carguen los datos del almacenamiento
      final credenciales = await _CredencialesManager.cargar();

      if (credenciales['recordarme'] == true) {
        setState(() {
          _recordarme = true;
          _usuarioController.text = credenciales['usuario'] ?? '';
          _passwordController.text = credenciales['password'] ?? '';
        });

        print('📂 Credenciales aplicadas a los controladores: ${credenciales['usuario']}');
      }
    } catch (e) {
      print('❌ Error al cargar credenciales desde SharedPreferences: $e');
    }
  }

  // --- MÉTODO MODIFICADO ---
  // También se convierte en 'async'
  Future<void> _guardarCredenciales() async {
    try {
      // 'await' espera a que se guarden los datos en el almacenamiento
      await _CredencialesManager.guardar(
        _recordarme,
        _usuarioController.text,
        _passwordController.text,
      );
    } catch (e) {
      print('❌ Error al guardar credenciales en SharedPreferences: $e');
    }
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    _logoAnimationController.dispose();
    _formAnimationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  // El resto de tus métodos (_iniciarSesion, autocompletar, etc.)
  // y tu widget build() pueden permanecer exactamente iguales, ya que
  // las llamadas a _guardarCredenciales() ya son compatibles con `async`.

  Future<void> _iniciarSesion() async {
    // ... (sin cambios aquí)
    if (!_formKey.currentState!.validate()) return;

    _buttonAnimationController.forward().then((_) {
      _buttonAnimationController.reverse();
    });

    setState(() => _cargando = true);

    try {
      // Esta llamada es muy importante. Si el usuario inicia sesión y
      // tiene "Recordarme" activado, aquí es donde las credenciales se
      // guardan persistentemente.
      await _guardarCredenciales();

      ResultadoAuth resultado = await _authService.iniciarSesion(
        _usuarioController.text,
        _passwordController.text,
      );

      if (mounted) {
        // ... (El resto del método no cambia)
        setState(() => _cargando = false);

        if (resultado.exitoso && resultado.usuario != null) {
          print('✅ Login exitoso para: ${resultado.usuario!.nombre}');

          final snackBarController = ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text('¡Bienvenido, ${resultado.usuario!.nombre}!'),
                ],
              ),
              backgroundColor: ColoresApp.exito,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 2),
            ),
          );

          await snackBarController.closed;

          if (mounted) {
            if (resultado.usuario!.esAdmin) {
              print('🔄 Navegando a pantalla admin');
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const PantallaAdmin(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOutCubic,
                      )),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 600),
                ),
              );
            } else {
              print('🔄 Navegando a pantalla home');
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const PantallaHome(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOutCubic,
                      )),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 600),
                ),
              );
            }
          }
        } else {
          print('❌ Error de login: ${resultado.error}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(resultado.error ?? 'Error desconocido')),
                ],
              ),
              backgroundColor: ColoresApp.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Excepción en login: $e');
      if (mounted) {
        setState(() => _cargando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: ColoresApp.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _autocompletarAdmin() async {
    _usuarioController.text = 'admin';
    _passwordController.text = '1234';
    // Si recordarme está activo, guardamos inmediatamente
    if (_recordarme) {
      await _guardarCredenciales();
    }
  }

  void _autocompletarUsuario() async {
    _usuarioController.text = 'usuario';
    _passwordController.text = '1234';
    // Si recordarme está activo, guardamos inmediatamente
    if (_recordarme) {
      await _guardarCredenciales();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tu método build() permanece intacto.
    // La lógica del checkbox ya llama a _guardarCredenciales() correctamente.
    // ... tu código del build ...
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/imagenes/fondomenu.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 24.0,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 48.0,
                  ),
                  child: IntrinsicHeight(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo animado
                          AnimatedBuilder(
                            animation: _logoAnimationController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _logoScaleAnimation.value,
                                child: Transform.rotate(
                                  angle: _logoRotationAnimation.value * 0.1,
                                  child: Container(
                                    padding: const EdgeInsets.all(25),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          ColoresApp.cyanPrimario,
                                          ColoresApp.azulPrimario,
                                          ColoresApp.azulPrimario.withOpacity(0.7),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: ColoresApp.cyanPrimario.withOpacity(0.4),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.rocket_launch,
                                      size: 65,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 40),

                          // Título animado
                          SlideTransition(
                            position: _formSlideAnimation,
                            child: FadeTransition(
                              opacity: _formFadeAnimation,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.4),
                                      Colors.black.withOpacity(0.2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: ColoresApp.cyanPrimario.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) => LinearGradient(
                                        colors: [
                                          ColoresApp.cyanPrimario,
                                          ColoresApp.azulPrimario,
                                        ],
                                      ).createShader(bounds),
                                      child: Text(
                                        'NC CONTROLLER',
                                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(0.5),
                                              offset: const Offset(0, 2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'INICIO DE SESIÓN',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: ColoresApp.cyanPrimario,
                                        letterSpacing: 1.5,
                                        fontWeight: FontWeight.w500,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.5),
                                            offset: const Offset(0, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Formulario animado
                          SlideTransition(
                            position: _formSlideAnimation,
                            child: FadeTransition(
                              opacity: _formFadeAnimation,
                              child: Column(
                                children: [
                                  // Campo Usuario
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: LinearGradient(
                                        colors: [
                                          ColoresApp.tarjetaOscura.withOpacity(0.9),
                                          ColoresApp.tarjetaOscura.withOpacity(0.7),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: ColoresApp.cyanPrimario.withOpacity(0.3),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: ColoresApp.cyanPrimario.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: TextFormField(
                                      controller: _usuarioController,
                                      style: const TextStyle(
                                        color: ColoresApp.textoPrimario,
                                        fontSize: 16,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: 'Usuario',
                                        labelStyle: TextStyle(
                                          color: ColoresApp.cyanPrimario.withOpacity(0.8),
                                        ),
                                        hintText: 'Ingresa tu usuario',
                                        hintStyle: TextStyle(
                                          color: ColoresApp.textoSecundario.withOpacity(0.6),
                                        ),
                                        prefixIcon: Container(
                                          margin: const EdgeInsets.all(12),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                ColoresApp.cyanPrimario.withOpacity(0.2),
                                                ColoresApp.azulPrimario.withOpacity(0.2),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.person,
                                            color: ColoresApp.cyanPrimario,
                                            size: 20,
                                          ),
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.all(20),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor ingresa tu usuario';
                                        }
                                        if (value.length < 3) {
                                          return 'El usuario debe tener al menos 3 caracteres';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),

                                  // Campo Contraseña
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: LinearGradient(
                                        colors: [
                                          ColoresApp.tarjetaOscura.withOpacity(0.9),
                                          ColoresApp.tarjetaOscura.withOpacity(0.7),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: ColoresApp.cyanPrimario.withOpacity(0.3),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: ColoresApp.cyanPrimario.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: TextFormField(
                                      controller: _passwordController,
                                      obscureText: !_mostrarPassword,
                                      style: const TextStyle(
                                        color: ColoresApp.textoPrimario,
                                        fontSize: 16,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: 'Contraseña',
                                        labelStyle: TextStyle(
                                          color: ColoresApp.cyanPrimario.withOpacity(0.8),
                                        ),
                                        hintText: 'Ingresa tu contraseña',
                                        hintStyle: TextStyle(
                                          color: ColoresApp.textoSecundario.withOpacity(0.6),
                                        ),
                                        prefixIcon: Container(
                                          margin: const EdgeInsets.all(12),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                ColoresApp.cyanPrimario.withOpacity(0.2),
                                                ColoresApp.azulPrimario.withOpacity(0.2),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.lock,
                                            color: ColoresApp.cyanPrimario,
                                            size: 20,
                                          ),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _mostrarPassword ? Icons.visibility : Icons.visibility_off,
                                            color: ColoresApp.textoSecundario,
                                          ),
                                          onPressed: () {
                                            setState(() => _mostrarPassword = !_mostrarPassword);
                                          },
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.all(20),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor ingresa tu contraseña';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),

                                  // Checkbox Recordarme
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.black.withOpacity(0.4),
                                          Colors.black.withOpacity(0.2),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: ColoresApp.cyanPrimario.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: _recordarme
                                                  ? ColoresApp.cyanPrimario
                                                  : ColoresApp.cyanPrimario.withOpacity(0.5),
                                              width: 2,
                                            ),
                                            gradient: _recordarme
                                                ? LinearGradient(
                                              colors: [
                                                ColoresApp.cyanPrimario,
                                                ColoresApp.azulPrimario,
                                              ],
                                            )
                                                : null,
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(6),
                                              onTap: () async {
                                                setState(() => _recordarme = !_recordarme);
                                                // Esta lógica es perfecta. Llama al guardado persistente.
                                                await _guardarCredenciales();
                                              },
                                              child: _recordarme
                                                  ? const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 16,
                                              )
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () async {
                                              setState(() => _recordarme = !_recordarme);
                                              // Y esta también.
                                              await _guardarCredenciales();
                                            },
                                            child: Text(
                                              'Recordarme',
                                              style: TextStyle(
                                                color: ColoresApp.cyanPrimario,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black.withOpacity(0.5),
                                                    offset: const Offset(0, 1),
                                                    blurRadius: 2,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Botones de autocompletar
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 24),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.black.withOpacity(0.3),
                                          Colors.black.withOpacity(0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: ColoresApp.bordeGris.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextButton.icon(
                                            onPressed: _autocompletarAdmin,
                                            icon: const Icon(
                                              Icons.admin_panel_settings,
                                              color: ColoresApp.rojoAcento,
                                              size: 18,
                                            ),
                                            label: const Text(
                                              'Admin',
                                              style: TextStyle(
                                                color: ColoresApp.rojoAcento,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            style: TextButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 1,
                                          height: 30,
                                          color: ColoresApp.bordeGris.withOpacity(0.3),
                                        ),
                                        Expanded(
                                          child: TextButton.icon(
                                            onPressed: _autocompletarUsuario,
                                            icon: const Icon(
                                              Icons.person,
                                              color: ColoresApp.cyanPrimario,
                                              size: 18,
                                            ),
                                            label: const Text(
                                              'Usuario',
                                              style: TextStyle(
                                                color: ColoresApp.cyanPrimario,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            style: TextButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Botón de login animado
                                  AnimatedBuilder(
                                    animation: _buttonPulseAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _buttonPulseAnimation.value,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(16),
                                            gradient: LinearGradient(
                                              colors: [
                                                ColoresApp.azulPrimario,
                                                ColoresApp.cyanPrimario,
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: ColoresApp.azulPrimario.withOpacity(0.4),
                                                blurRadius: 15,
                                                offset: const Offset(0, 8),
                                              ),
                                              BoxShadow(
                                                color: ColoresApp.cyanPrimario.withOpacity(0.2),
                                                blurRadius: 20,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: _cargando ? null : _iniciarSesion,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(vertical: 18),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                              ),
                                              child: _cargando
                                                  ? Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  const Text(
                                                    'AUTENTICANDO...',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w600,
                                                      letterSpacing: 1,
                                                    ),
                                                  ),
                                                ],
                                              )
                                                  : Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.login,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Text(
                                                    'INICIAR SESIÓN',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w600,
                                                      letterSpacing: 1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Nota: Asumo que tus otras clases como AuthService, ColoresApp, etc.,
// están definidas correctamente en otros archivos.
import 'package:flutter/material.dart';
import '../servicios/auth_service.dart';
import '../nucleo/constantes/colores_app.dart';
import 'home_screen.dart';
import 'admin_screen.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _cargando = false;
  bool _mostrarPassword = false;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      ResultadoAuth resultado = await _authService.iniciarSesion(
        _usuarioController.text,
        _passwordController.text,
      );

      if (mounted) {
        setState(() => _cargando = false);

        if (resultado.exitoso && resultado.usuario != null) {
          print('✅ Login exitoso para: ${resultado.usuario!.nombre}');

          // --- INICIO DE LA CORRECCIÓN ---
          // Mostramos el SnackBar y guardamos su controlador para saber cuándo termina.
          final snackBarController = ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡Bienvenido, ${resultado.usuario!.nombre}!'),
              backgroundColor: ColoresApp.exito,
              duration: const Duration(seconds: 2),
            ),
          );

          // Esperamos a que el SnackBar se haya cerrado completamente.
          await snackBarController.closed;
          // --- FIN DE LA CORRECCIÓN ---

          // Ahora que el mensaje desapareció, navegamos.
          if (mounted) {
            if (resultado.usuario!.esAdmin) {
              print('🔄 Navegando a pantalla admin');
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const PantallaAdmin()),
              );
            } else {
              print('🔄 Navegando a pantalla home');
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const PantallaHome()),
              );
            }
          }
        } else {
          print('❌ Error de login: ${resultado.error}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resultado.error ?? 'Error desconocido'),
              backgroundColor: ColoresApp.error,
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
            content: Text('Error: $e'),
            backgroundColor: ColoresApp.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _autocompletarAdmin() {
    _usuarioController.text = 'admin';
    _passwordController.text = '1234';
  }

  void _autocompletarUsuario() {
    _usuarioController.text = 'usuario';
    _passwordController.text = '1234';
  }

  @override
  Widget build(BuildContext context) {
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
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: ColoresApp.gradientePrimario,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.rocket_launch,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'NABOO CUSTOMS',
                                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.5),
                                        offset: const Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Centro de Control',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white70,
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
                          const SizedBox(height: 40),
                          Container(
                            decoration: BoxDecoration(
                              color: ColoresApp.tarjetaOscura.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: ColoresApp.bordeGris),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _usuarioController,
                              style: const TextStyle(color: ColoresApp.textoPrimario),
                              decoration: const InputDecoration(
                                labelText: 'Usuario',
                                hintText: 'admin, usuario, juan123',
                                prefixIcon: Icon(Icons.person, color: ColoresApp.cyanPrimario),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
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
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: ColoresApp.tarjetaOscura.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: ColoresApp.bordeGris),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: !_mostrarPassword,
                              style: const TextStyle(color: ColoresApp.textoPrimario),
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                hintText: '1234',
                                prefixIcon: const Icon(Icons.lock, color: ColoresApp.cyanPrimario),
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
                                contentPadding: const EdgeInsets.all(16),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu contraseña';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextButton.icon(
                                    onPressed: _autocompletarAdmin,
                                    icon: const Icon(Icons.admin_panel_settings, color: ColoresApp.rojoAcento, size: 20),
                                    label: const Text(
                                      'Admin',
                                      style: TextStyle(color: ColoresApp.rojoAcento, fontSize: 12),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: TextButton.icon(
                                    onPressed: _autocompletarUsuario,
                                    icon: const Icon(Icons.person, color: ColoresApp.cyanPrimario, size: 20),
                                    label: const Text(
                                      'Usuario',
                                      style: TextStyle(color: ColoresApp.cyanPrimario, fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: ColoresApp.azulPrimario.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _cargando ? null : _iniciarSesion,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColoresApp.azulPrimario,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _cargando
                                    ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                                    : const Text(
                                  'INICIAR SESIÓN',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          if (_cargando)
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Autenticando...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: ColoresApp.informacion.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: ColoresApp.informacion.withOpacity(0.5)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: ColoresApp.informacion,
                                  size: 24,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Usuarios de Prueba',
                                  style: TextStyle(
                                    color: ColoresApp.informacion,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        offset: const Offset(0, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Administrador: admin / 1234\nUsuario: usuario / 1234',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.5),
                                        offset: const Offset(0, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
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
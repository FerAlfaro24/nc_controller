import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../servicios/auth_service.dart';
import '../nucleo/constantes/colores_app.dart';
import 'home_screen.dart';
import 'admin_screen.dart'; // Importación correcta

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _cargando = false;
  bool _mostrarPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      final authService = context.read<AuthService>();

      print('Intentando login con: ${_emailController.text} / ${_passwordController.text}');

      ResultadoAuth resultado = await authService.iniciarSesion(
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) {
        setState(() => _cargando = false);

        if (resultado.exitoso && resultado.usuario != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡Bienvenido, ${resultado.usuario!.nombre}!'),
              backgroundColor: ColoresApp.exito,
              duration: const Duration(seconds: 2),
            ),
          );

          // Pequeña pausa para mostrar el mensaje
          await Future.delayed(const Duration(milliseconds: 500));

          // Navegar según el rol del usuario
          if (mounted) {
            if (resultado.usuario!.esAdmin) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const PantallaAdmin()), // Nombre correcto
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const PantallaHome()),
              );
            }
          }
        } else {
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
    _emailController.text = 'admin';
    _passwordController.text = '1234';
  }

  void _autocompletarUsuario() {
    _emailController.text = 'usuario';
    _passwordController.text = '1234';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: ColoresApp.gradienteFondo,
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
                          // Logo o título
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: ColoresApp.gradientePrimario,
                            ),
                            child: const Icon(
                              Icons.rocket_launch,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 32),

                          Text(
                            'NABOO CUSTOMS',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: ColoresApp.textoPrimario,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Text(
                            'Centro de Control',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: ColoresApp.textoSecundario,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Campo Usuario
                          Container(
                            decoration: BoxDecoration(
                              color: ColoresApp.tarjetaOscura,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: ColoresApp.bordeGris),
                            ),
                            child: TextFormField(
                              controller: _emailController,
                              style: const TextStyle(color: ColoresApp.textoPrimario),
                              decoration: const InputDecoration(
                                labelText: 'Usuario',
                                hintText: 'admin o usuario',
                                prefixIcon: Icon(Icons.person, color: ColoresApp.cyanPrimario),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu usuario';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Campo Contraseña
                          Container(
                            decoration: BoxDecoration(
                              color: ColoresApp.tarjetaOscura,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: ColoresApp.bordeGris),
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

                          // Botones de acceso rápido
                          Row(
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
                          const SizedBox(height: 16),

                          // Botón de login
                          SizedBox(
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
                          const SizedBox(height: 32),

                          // Información de credenciales
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: ColoresApp.informacion.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: ColoresApp.informacion.withOpacity(0.3)),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: ColoresApp.informacion,
                                  size: 24,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Credenciales de Prueba',
                                  style: TextStyle(
                                    color: ColoresApp.informacion,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Administrador: admin / 1234\nUsuario: usuario / 1234',
                                  style: TextStyle(
                                    color: ColoresApp.textoSecundario,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Botón volver
                          TextButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back, color: ColoresApp.textoApagado),
                            label: const Text(
                              'Volver',
                              style: TextStyle(color: ColoresApp.textoApagado),
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
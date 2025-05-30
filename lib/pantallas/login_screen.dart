import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../servicios/auth_service.dart';
import '../nucleo/constantes/colores_app.dart';

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
  bool _esRegistro = false;
  bool _mostrarPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _enviarFormulario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      final authService = context.read<AuthService>();
      ResultadoAuth resultado;

      if (_esRegistro) {
        resultado = await authService.registrarUsuario(
          email: _emailController.text,
          password: _passwordController.text,
          nombre: _emailController.text.split('@').first, // Usar parte del email como nombre
        );
      } else {
        resultado = await authService.iniciarSesion(
          _emailController.text,
          _passwordController.text,
        );
      }

      if (mounted) {
        if (resultado.exitoso) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_esRegistro ? '¡Registro exitoso!' : '¡Bienvenido!'),
              backgroundColor: ColoresApp.exito,
            ),
          );
          Navigator.of(context).pop(); // Volver a la pantalla principal
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resultado.error ?? 'Error desconocido'),
              backgroundColor: ColoresApp.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: ColoresApp.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: ColoresApp.gradienteFondo,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
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
                      _esRegistro ? 'Crear cuenta' : 'Iniciar sesión',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: ColoresApp.textoSecundario,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Campo Email
                    Container(
                      decoration: BoxDecoration(
                        color: ColoresApp.tarjetaOscura,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ColoresApp.bordeGris),
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: ColoresApp.textoPrimario),
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email, color: ColoresApp.cyanPrimario),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu email';
                          }
                          if (!AuthService.emailValido(value)) {
                            return 'Por favor ingresa un email válido';
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
                          if (!AuthService.passwordValida(value)) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Botón principal
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _cargando ? null : _enviarFormulario,
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
                            : Text(
                          _esRegistro ? 'REGISTRARSE' : 'INICIAR SESIÓN',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Alternar entre login y registro
                    TextButton(
                      onPressed: () {
                        setState(() => _esRegistro = !_esRegistro);
                      },
                      child: RichText(
                        text: TextSpan(
                          text: _esRegistro
                              ? '¿Ya tienes cuenta? '
                              : '¿No tienes cuenta? ',
                          style: const TextStyle(color: ColoresApp.textoSecundario),
                          children: [
                            TextSpan(
                              text: _esRegistro ? 'Iniciar sesión' : 'Registrarse',
                              style: const TextStyle(
                                color: ColoresApp.cyanPrimario,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
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
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../nucleo/constantes/colores_app.dart';
import '../servicios/auth_service.dart';
import 'login_screen.dart';

class PantallaHome extends StatefulWidget {
  const PantallaHome({super.key});

  @override
  State<PantallaHome> createState() => _PantallaHomeState();
}

class _PantallaHomeState extends State<PantallaHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('NABOO CUSTOMS'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.rocket_launch),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _construirDrawer(context),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CENTRO DE CONTROL',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Controla tus figuras futuristas',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),

              // Tarjetas principales
              Row(
                children: [
                  Expanded(
                    child: _tarjetaNavegacion(
                      'NAVES',
                      Icons.rocket,
                      ColoresApp.azulPrimario,
                          () {
                        print("Navegando a NAVES");
                        // TODO: Navegar a pantalla de naves
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _tarjetaNavegacion(
                      'DIORAMAS',
                      Icons.landscape,
                      ColoresApp.moradoPrimario,
                          () {
                        print("Navegando a DIORAMAS");
                        // TODO: Navegar a pantalla de dioramas
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _tarjetaNavegacion(
                      'BLUETOOTH',
                      Icons.bluetooth,
                      ColoresApp.cyanPrimario,
                          () {
                        print("Navegando a BLUETOOTH");
                        // TODO: Navegar a configuración bluetooth
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _tarjetaNavegacion(
                      'PERFIL',
                      Icons.person,
                      ColoresApp.verdeAcento,
                          () {
                        print("Navegando a PERFIL");
                        // TODO: Navegar a perfil de usuario
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Sección de estado
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColoresApp.tarjetaOscura,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ColoresApp.bordeGris),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ESTADO DEL SISTEMA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _itemEstado('Firebase', true, 'Conectado'),
                    _itemEstado('Bluetooth', false, 'Desconectado'),
                    _itemEstado('Figuras', true, '4 disponibles'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1A1A1A),
      child: Column(
        children: [
          // Header del drawer
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E3A8A),
                  Color(0xFF7C3AED),
                ],
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.rocket_launch,
                    size: 60,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'NABOO CUSTOMS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    'Control Center',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Items del menú
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _itemDrawer(
                  context,
                  Icons.home,
                  'INICIO',
                      () {
                    Navigator.pop(context);
                    print("Ya estás en INICIO");
                  },
                ),
                _itemDrawer(
                  context,
                  Icons.rocket,
                  'NAVES',
                      () {
                    Navigator.pop(context);
                    print("Navegando a NAVES");
                  },
                ),
                _itemDrawer(
                  context,
                  Icons.landscape,
                  'DIORAMAS',
                      () {
                    Navigator.pop(context);
                    print("Navegando a DIORAMAS");
                  },
                ),
                _itemDrawer(
                  context,
                  Icons.bluetooth,
                  'BLUETOOTH',
                      () {
                    Navigator.pop(context);
                    print("Navegando a BLUETOOTH");
                  },
                ),
                const Divider(color: Color(0xFF404040)),
                _itemDrawer(
                  context,
                  Icons.person,
                  'PERFIL',
                      () {
                    Navigator.pop(context);
                    print("Navegando a PERFIL");
                  },
                ),
              ],
            ),
          ),

          // Footer con cerrar sesión MEJORADO
          Container(
            padding: const EdgeInsets.all(16),
            child: _itemDrawer(
              context,
              Icons.exit_to_app,
              'CERRAR SESIÓN',
                  () async {
                Navigator.pop(context); // Cerrar drawer

                // Mostrar confirmación simple
                final confirmar = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF252525),
                    title: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                      '¿Estás seguro de que quieres cerrar sesión?',
                      style: TextStyle(color: Colors.grey),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Cerrar Sesión'),
                      ),
                    ],
                  ),
                );

                // Si confirma, cerrar sesión de forma segura
                if (confirmar == true && mounted) {
                  try {
                    // IMPORTANTE: Usar el AuthService de forma segura
                    final authService = Provider.of<AuthService>(context, listen: false);
                    await authService.cerrarSesion();

                    // Mostrar mensaje de despedida
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text('¡Hasta luego!'),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 1),
                        ),
                      );

                      // Pequeña pausa para mostrar el mensaje
                      await Future.delayed(const Duration(milliseconds: 500));

                      // Navegar a login limpiando toda la pila de navegación
                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const PantallaLogin()),
                              (route) => false,
                        );
                      }
                    }
                  } catch (e) {
                    print('⚠️ Error cerrando sesión: $e');
                    // Aún así, navegar al login
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const PantallaLogin()),
                            (route) => false,
                      );
                    }
                  }
                }
              },
              esLogout: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemDrawer(BuildContext context, IconData icono, String titulo, VoidCallback onTap, {bool esLogout = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(
          icono,
          color: esLogout ? Colors.red : Colors.cyan,
          size: 24,
        ),
        title: Text(
          titulo,
          style: TextStyle(
            color: esLogout ? Colors.red : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        hoverColor: Colors.cyan.withOpacity(0.1),
        splashColor: Colors.cyan.withOpacity(0.2),
      ),
    );
  }

  Widget _tarjetaNavegacion(String titulo, IconData icono, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: ColoresApp.tarjetaOscura,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icono,
                size: 40,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              titulo,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemEstado(String titulo, bool activo, String descripcion) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: activo ? ColoresApp.exito : ColoresApp.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  descripcion,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
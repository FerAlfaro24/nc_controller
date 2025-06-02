import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../nucleo/constantes/colores_app.dart';
import '../servicios/auth_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'gestion_usuarios_screen.dart';
import 'utilidades_admin_screen.dart';

class PantallaAdmin extends StatefulWidget {
  const PantallaAdmin({super.key});

  @override
  State<PantallaAdmin> createState() => _PantallaAdminState();
}

class _PantallaAdminState extends State<PantallaAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('PANEL ADMINISTRADOR'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
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
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header de administrador
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: ColoresApp.gradientePrimario,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.admin_panel_settings,
                      size: 40,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PANEL DE ADMINISTRACIÓN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Control total del sistema',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // CONFIGURACIÓN DE APLICACIÓN
              _seccionAdmin(
                'CONFIGURACIÓN DE APLICACIÓN',
                [
                  _tarjetaAdmin(
                    'Texto Marquee',
                    'Configurar mensaje deslizante',
                    Icons.text_fields,
                    ColoresApp.cyanPrimario,
                        () {
                      print("Configurar texto marquee");
                    },
                  ),
                  _tarjetaAdmin(
                    'Publicidad Push',
                    'Gestionar imagen promocional',
                    Icons.campaign,
                    ColoresApp.naranjaAcento,
                        () {
                      print("Gestionar publicidad");
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // GESTIÓN DE CONTENIDO
              _seccionAdmin(
                'GESTIÓN DE CONTENIDO',
                [
                  _tarjetaAdmin(
                    'Gestionar Usuarios',
                    'Crear, editar y administrar usuarios',
                    Icons.people,
                    ColoresApp.verdeAcento,
                        () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PantallaGestionUsuarios(),
                        ),
                      );
                    },
                  ),
                  _tarjetaAdmin(
                    'Gestionar Figuras',
                    'Agregar naves y dioramas',
                    Icons.category,
                    ColoresApp.moradoPrimario,
                        () {
                      print("Gestionar figuras");
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ESTADÍSTICAS Y MONITOREO
              _seccionAdmin(
                'ESTADÍSTICAS Y MONITOREO',
                [
                  _tarjetaAdmin(
                    'Estadísticas',
                    'Ver uso de la aplicación',
                    Icons.analytics,
                    ColoresApp.azulPrimario,
                        () {
                      print("Ver estadísticas");
                    },
                  ),
                  _tarjetaAdmin(
                    'Utilidades Admin',
                    'Configuración y herramientas',
                    Icons.build,
                    ColoresApp.rojoAcento,
                        () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PantallaUtilidadesAdmin(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Sección final más compacta
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColoresApp.informacion.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColoresApp.informacion.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.swap_horiz,
                      color: ColoresApp.informacion,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Modo Usuario',
                        style: TextStyle(
                          color: ColoresApp.informacion,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const PantallaHome()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColoresApp.informacion,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: const Size(60, 30),
                      ),
                      child: const Text('Ver', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ),

              // Espaciado final para evitar que el último elemento toque el bottom
              const SizedBox(height: 20),
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
                  Color(0xFFEF4444), // Rojo para admin
                  Color(0xFFF59E0B), // Naranja para admin
                ],
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    size: 60,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'ADMINISTRADOR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    'Panel de Control',
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
                  Icons.dashboard,
                  'PANEL PRINCIPAL',
                      () {
                    Navigator.pop(context);
                    print("Ya estás en el panel principal");
                  },
                ),
                _itemDrawer(
                  context,
                  Icons.people,
                  'USUARIOS',
                      () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PantallaGestionUsuarios(),
                      ),
                    );
                  },
                ),
                _itemDrawer(
                  context,
                  Icons.category,
                  'FIGURAS',
                      () {
                    Navigator.pop(context);
                    print("Navegando a gestión de figuras");
                  },
                ),
                _itemDrawer(
                  context,
                  Icons.settings,
                  'UTILIDADES',
                      () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PantallaUtilidadesAdmin(),
                      ),
                    );
                  },
                ),
                const Divider(color: Color(0xFF404040)),
                _itemDrawer(
                  context,
                  Icons.person,
                  'MODO USUARIO',
                      () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const PantallaHome()),
                    );
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
                      'Cerrar Sesión Administrativa',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                      '¿Estás seguro de que quieres cerrar la sesión de administrador?',
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
                              Text('Sesión administrativa cerrada'),
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
          color: esLogout ? Colors.red : Colors.orange,
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
        hoverColor: Colors.orange.withOpacity(0.1),
        splashColor: Colors.orange.withOpacity(0.2),
      ),
    );
  }

  Widget _seccionAdmin(String titulo, List<Widget> tarjetas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        // Usar Column y Row en lugar de GridView para mejor control
        for (int i = 0; i < tarjetas.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(child: tarjetas[i]),
                const SizedBox(width: 12),
                if (i + 1 < tarjetas.length)
                  Expanded(child: tarjetas[i + 1])
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
      ],
    );
  }

  Widget _tarjetaAdmin(String titulo, String descripcion, IconData icono, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100, // Altura fija para evitar overflow
        padding: const EdgeInsets.all(12),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icono,
                size: 20,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              titulo,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Text(
                descripcion,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
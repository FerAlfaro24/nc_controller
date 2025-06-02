import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../nucleo/constantes/colores_app.dart';
import '../servicios/auth_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'gestion_usuarios_screen.dart';
import 'utilidades_admin_screen.dart';
import 'gestion_publicidad_screen.dart';

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
            onPressed: () {
              _mostrarInfoAdmin(context);
            },
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
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ColoresApp.rojoAcento.withOpacity(0.8),
                      ColoresApp.naranjaAcento.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: ColoresApp.rojoAcento.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        size: 32,
                        color: Colors.white,
                      ),
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
                            'Control total del sistema NC Controller',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // CONFIGURACIÓN DE APLICACIÓN
              _seccionAdmin(
                'CONFIGURACIÓN DE APLICACIÓN',
                Icons.settings,
                ColoresApp.cyanPrimario,
                [
                  _tarjetaAdmin(
                    'Texto Marquee',
                    'Configurar mensaje deslizante',
                    Icons.text_fields,
                    ColoresApp.cyanPrimario,
                        () {
                      _mostrarDialogoTextoMarquee();
                    },
                  ),
                  _tarjetaAdmin(
                    'Publicidad Push',
                    'Gestionar promociones con Cloudinary',
                    Icons.campaign,
                    ColoresApp.naranjaAcento,
                        () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PantallaGestionPublicidad(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // GESTIÓN DE CONTENIDO
              _seccionAdmin(
                'GESTIÓN DE CONTENIDO',
                Icons.inventory,
                ColoresApp.verdeAcento,
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
                      _mostrarEnConstruccion('Gestión de Figuras');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ESTADÍSTICAS Y MONITOREO
              _seccionAdmin(
                'ESTADÍSTICAS Y MONITOREO',
                Icons.analytics,
                ColoresApp.azulPrimario,
                [
                  _tarjetaAdmin(
                    'Estadísticas',
                    'Ver uso de la aplicación',
                    Icons.analytics,
                    ColoresApp.azulPrimario,
                        () {
                      _mostrarEstadisticas();
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

              const SizedBox(height: 20),

              // ACCESO RÁPIDO
              _seccionAdmin(
                'ACCESO RÁPIDO',
                Icons.flash_on,
                ColoresApp.rosaAcento,
                [
                  _tarjetaAdmin(
                    'Vista Usuario',
                    'Ver app como cliente',
                    Icons.person,
                    ColoresApp.informacion,
                        () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const PantallaHome()),
                      );
                    },
                  ),
                  _tarjetaAdmin(
                    'Logs del Sistema',
                    'Ver registros y errores',
                    Icons.list_alt,
                    ColoresApp.advertencia,
                        () {
                      _mostrarLogs();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // INFORMACIÓN DEL SISTEMA
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
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: ColoresApp.informacion,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'INFORMACIÓN DEL SISTEMA',
                          style: TextStyle(
                            color: ColoresApp.textoPrimario,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _itemInformacion('Versión', '1.0.0'),
                    _itemInformacion('Firebase', 'Conectado'),
                    _itemInformacion('Cloudinary', 'Activo'),
                    _itemInformacion('Usuarios', '4 registrados'),
                    _itemInformacion('Figuras', '4 disponibles'),
                    _itemInformacion('Última actualización', 'Hace 2 minutos'),
                  ],
                ),
              ),

              // Espaciado final para evitar que el último elemento toque el bottom
              const SizedBox(height: 24),
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
                  Icons.campaign,
                  'PUBLICIDAD',
                      () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PantallaGestionPublicidad(),
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
                    _mostrarEnConstruccion('Gestión de Figuras');
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
                    final authService = Provider.of<AuthService>(context, listen: false);
                    await authService.cerrarSesion();

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

                      await Future.delayed(const Duration(milliseconds: 500));

                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const PantallaLogin()),
                              (route) => false,
                        );
                      }
                    }
                  } catch (e) {
                    print('⚠️ Error cerrando sesión: $e');
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

  Widget _seccionAdmin(String titulo, IconData icono, Color color, List<Widget> tarjetas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Grid de tarjetas
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
        height: 110,
        padding: const EdgeInsets.all(16),
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
            Row(
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
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: ColoresApp.textoApagado,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              titulo,
              style: const TextStyle(
                color: ColoresApp.textoPrimario,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                descripcion,
                style: const TextStyle(
                  color: ColoresApp.textoSecundario,
                  fontSize: 11,
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

  Widget _itemInformacion(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$titulo:',
            style: const TextStyle(
              color: ColoresApp.textoSecundario,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            valor,
            style: const TextStyle(
              color: ColoresApp.textoPrimario,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoTextoMarquee() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColoresApp.tarjetaOscura,
        title: Row(
          children: [
            Icon(Icons.text_fields, color: ColoresApp.cyanPrimario),
            const SizedBox(width: 8),
            const Text(
              'Configurar Texto Marquee',
              style: TextStyle(color: ColoresApp.textoPrimario),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Esta funcionalidad permite editar el texto que se desliza en la pantalla principal.',
              style: TextStyle(color: ColoresApp.textoSecundario),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColoresApp.informacion.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ColoresApp.informacion.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: ColoresApp.informacion, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Se implementará junto con la gestión de figuras',
                      style: TextStyle(
                        color: ColoresApp.informacion,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: ColoresApp.cyanPrimario),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _mostrarEstadisticas() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColoresApp.tarjetaOscura,
        title: Row(
          children: [
            Icon(Icons.analytics, color: ColoresApp.azulPrimario),
            const SizedBox(width: 8),
            const Text(
              'Estadísticas del Sistema',
              style: TextStyle(color: ColoresApp.textoPrimario),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _estatistica('Usuarios Activos', '4', ColoresApp.verdeAcento),
            _estatistica('Figuras Disponibles', '4', ColoresApp.azulPrimario),
            _estatistica('Conexiones Bluetooth', '0', ColoresApp.advertencia),
            _estatistica('Imágenes en Cloudinary', '2', ColoresApp.cyanPrimario),
            _estatistica('Sesiones Admin', '1', ColoresApp.rojoAcento),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: ColoresApp.azulPrimario),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _estatistica(String titulo, String valor, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                color: ColoresApp.textoPrimario,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColoresApp.tarjetaOscura,
        title: Row(
          children: [
            Icon(Icons.list_alt, color: ColoresApp.advertencia),
            const SizedBox(width: 8),
            const Text(
              'Logs del Sistema',
              style: TextStyle(color: ColoresApp.textoPrimario),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _logEntry('✅', '2024-01-15 10:30:25', 'Firebase inicializado correctamente'),
                    _logEntry('✅', '2024-01-15 10:30:26', 'AuthService inicializado'),
                    _logEntry('✅', '2024-01-15 10:30:27', 'CloudinaryService inicializado'),
                    _logEntry('📤', '2024-01-15 10:45:12', 'Imagen subida a Cloudinary'),
                    _logEntry('👤', '2024-01-15 10:47:33', 'Usuario admin logueado'),
                    _logEntry('⚙️', '2024-01-15 10:48:15', 'Configuración actualizada'),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: ColoresApp.advertencia),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _logEntry(String emoji, String tiempo, String mensaje) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          Text(
            tiempo,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensaje,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarEnConstruccion(String seccion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColoresApp.tarjetaOscura,
        title: Row(
          children: [
            Icon(Icons.construction, color: ColoresApp.naranjaAcento),
            const SizedBox(width: 8),
            Text(
              'En Construcción',
              style: TextStyle(color: ColoresApp.textoPrimario),
            ),
          ],
        ),
        content: Text(
          'La sección "$seccion" está en desarrollo.\n\n¡Pronto estará disponible con funcionalidades completas!',
          style: TextStyle(color: ColoresApp.textoSecundario),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: ColoresApp.naranjaAcento),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _mostrarInfoAdmin(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColoresApp.tarjetaOscura,
        title: Row(
          children: [
            Icon(Icons.admin_panel_settings, color: ColoresApp.rojoAcento),
            const SizedBox(width: 8),
            const Text(
              'Panel de Administración',
              style: TextStyle(color: ColoresApp.textoPrimario),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Naboo Customs Controller Admin',
              style: TextStyle(
                color: ColoresApp.textoPrimario,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Panel de control completo para gestionar:\n\n'
                  '• Usuarios y permisos\n'
                  '• Publicidad push con Cloudinary\n'
                  '• Configuración del sistema\n'
                  '• Monitoreo y estadísticas\n'
                  '• Utilidades administrativas',
              style: TextStyle(color: ColoresApp.textoSecundario),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ColoresApp.rojoAcento.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, color: ColoresApp.rojoAcento, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Acceso restringido a administradores',
                      style: TextStyle(
                        color: ColoresApp.rojoAcento,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: ColoresApp.rojoAcento),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
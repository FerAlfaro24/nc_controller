import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../nucleo/constantes/colores_app.dart';
import '../servicios/auth_service.dart';
import '../servicios/firebase_service.dart';
import '../modelos/configuracion_app.dart';
import '../widgets/publicidad_push_widget.dart';
import 'login_screen.dart';

class PantallaHome extends StatefulWidget {
  const PantallaHome({super.key});

  @override
  State<PantallaHome> createState() => _PantallaHomeState();
}

class _PantallaHomeState extends State<PantallaHome> {
  bool _publicidadMostrada = false;

  @override
  void initState() {
    super.initState();
    _mostrarPublicidadSiCorresponde();
  }

  void _mostrarPublicidadSiCorresponde() {
    // Esperar un poco para que la pantalla se cargue completamente
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && !_publicidadMostrada) {
        final firebaseService = FirebaseService();

        // Escuchar la configuración para obtener la publicidad
        firebaseService.obtenerConfiguracion().listen((config) {
          if (mounted && !_publicidadMostrada && config.publicidadPush.deberíaMostrarse) {
            _publicidadMostrada = true;
            PublicidadPushModal.mostrar(context, config.publicidadPush);
          }
        });
      }
    });
  }

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
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Texto marquee dinámico de Firebase
                  StreamBuilder<ConfiguracionApp>(
                    stream: FirebaseService().obtenerConfiguracion(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'Cargando...',
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        );
                      }

                      return Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: ColoresApp.cyanPrimario.withOpacity(0.3)),
                        ),
                        child: Center(
                          child: _TextoMarquee(
                            texto: snapshot.data!.textoMarquee,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),

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
                            _mostrarEnConstruccion(context, 'Naves');
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
                            _mostrarEnConstruccion(context, 'Dioramas');
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
                            _mostrarEnConstruccion(context, 'Bluetooth');
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
                            _mostrarEnConstruccion(context, 'Perfil');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Sección de estado del sistema
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
                            const Icon(
                              Icons.monitor_heart,
                              color: ColoresApp.cyanPrimario,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'ESTADO DEL SISTEMA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _itemEstado('Firebase', true, 'Conectado'),
                        _itemEstado('Bluetooth', false, 'Desconectado'),
                        _itemEstado('Figuras', true, '4 disponibles'),
                        _itemEstado('Cloudinary', true, 'Imágenes activas'),
                      ],
                    ),
                  ),

                  // Sección de accesos rápidos
                  const SizedBox(height: 24),
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
                            const Icon(
                              Icons.link,
                              color: ColoresApp.verdeAcento,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'ENLACES RÁPIDOS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _botonEnlace(
                                'Instagram',
                                Icons.camera_alt,
                                ColoresApp.rosaAcento,
                                'https://instagram.com/naboocustoms',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _botonEnlace(
                                'Facebook',
                                Icons.facebook,
                                ColoresApp.azulPrimario,
                                'https://facebook.com/naboocustoms',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: _botonEnlace(
                            'Catálogo en Drive',
                            Icons.folder_open,
                            ColoresApp.naranjaAcento,
                            'https://drive.google.com/catalogo-naboocustoms',
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Espaciado final
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
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
                    _mostrarEnConstruccion(context, 'Naves');
                  },
                ),
                _itemDrawer(
                  context,
                  Icons.landscape,
                  'DIORAMAS',
                      () {
                    Navigator.pop(context);
                    _mostrarEnConstruccion(context, 'Dioramas');
                  },
                ),
                _itemDrawer(
                  context,
                  Icons.bluetooth,
                  'BLUETOOTH',
                      () {
                    Navigator.pop(context);
                    _mostrarEnConstruccion(context, 'Bluetooth');
                  },
                ),
                const Divider(color: Color(0xFF404040)),
                _itemDrawer(
                  context,
                  Icons.person,
                  'PERFIL',
                      () {
                    Navigator.pop(context);
                    _mostrarEnConstruccion(context, 'Perfil');
                  },
                ),
                _itemDrawer(
                  context,
                  Icons.help_outline,
                  'AYUDA',
                      () {
                    Navigator.pop(context);
                    _mostrarAyuda(context);
                  },
                ),
              ],
            ),
          ),

          // Footer con cerrar sesión
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
                    final authService = Provider.of<AuthService>(context, listen: false);
                    await authService.cerrarSesion();

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

  Widget _botonEnlace(String titulo, IconData icono, Color color, String url) {
    return ElevatedButton.icon(
      onPressed: () {
        // TODO: Implementar apertura de URLs
        _mostrarInfo(context, 'Enlace: $titulo', 'Se abriría: $url');
      },
      icon: Icon(icono, size: 18),
      label: Text(titulo),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }

  void _mostrarEnConstruccion(BuildContext context, String seccion) {
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
            style: ElevatedButton.styleFrom(backgroundColor: ColoresApp.cyanPrimario),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _mostrarAyuda(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColoresApp.tarjetaOscura,
        title: Row(
          children: [
            Icon(Icons.help, color: ColoresApp.cyanPrimario),
            const SizedBox(width: 8),
            Text(
              'Ayuda',
              style: TextStyle(color: ColoresApp.textoPrimario),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Naboo Customs Controller',
              style: TextStyle(
                color: ColoresApp.textoPrimario,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aplicación para controlar figuras con Arduino y Bluetooth.\n\n'
                  '• Conecta tus figuras vía Bluetooth\n'
                  '• Controla LEDs y música\n'
                  '• Activa efectos de humo\n'
                  '• Gestiona tu colección',
              style: TextStyle(color: ColoresApp.textoSecundario),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: ColoresApp.cyanPrimario),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarInfo(BuildContext context, String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColoresApp.tarjetaOscura,
        title: Text(titulo, style: TextStyle(color: ColoresApp.textoPrimario)),
        content: Text(mensaje, style: TextStyle(color: ColoresApp.textoSecundario)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: ColoresApp.cyanPrimario),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Widget personalizado para texto marquee
class _TextoMarquee extends StatefulWidget {
  final String texto;

  const _TextoMarquee({required this.texto});

  @override
  State<_TextoMarquee> createState() => _TextoMarqueeState();
}

class _TextoMarqueeState extends State<_TextoMarquee>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: -1.0).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value * MediaQuery.of(context).size.width, 0),
          child: Text(
            widget.texto,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.visible,
            maxLines: 1,
          ),
        );
      },
    );
  }
}
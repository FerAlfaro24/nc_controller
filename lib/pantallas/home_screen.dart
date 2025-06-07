import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../nucleo/constantes/colores_app.dart';
import '../servicios/auth_service.dart';
import '../servicios/firebase_service.dart';
import '../modelos/configuracion_app.dart';
import '../widgets/publicidad_push_widget.dart';
import '../widgets/complete_text_marquee.dart';
import '../widgets/instagram_feed_widget.dart';
import 'login_screen.dart';
import 'catalogo_naves_screen.dart';
import 'catalogo_dioramas_screen.dart';

class PantallaHome extends StatefulWidget {
  const PantallaHome({super.key});

  @override
  State<PantallaHome> createState() => _PantallaHomeState();
}

class _PantallaHomeState extends State<PantallaHome> {
  bool _publicidadMostradaEnEstaSession = false;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    print('🏠 PantallaHome: initState ejecutado');
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _verificarYMostrarPublicidad();
      }
    });
  }

  Future<void> _verificarYMostrarPublicidad() async {
    print('📢 Verificando publicidad (intento por cada carga de PantallaHome)...');
    try {
      final config = await _firebaseService.obtenerConfiguracion().first;
      final publicidad = config.publicidadPush;

      print('📢 Estado publicidad desde Firebase:');
      print('   - Activa: ${publicidad.activa}');
      print('   - Título: "${publicidad.titulo}"');
      print('   - Imagen URL presente: ${publicidad.imagenUrl.isNotEmpty}');
      print('   - Expirada: ${publicidad.estaExpirada}');

      bool deberiaMostrarSegunFirebase = publicidad.activa &&
          publicidad.titulo.trim().isNotEmpty &&
          !publicidad.estaExpirada;

      if (deberiaMostrarSegunFirebase) {
        print('✅ Publicidad CUMPLE condiciones de Firebase. Mostrando: "${publicidad.titulo}"');
        if (mounted) {
          await PublicidadPushModal.mostrar(context, publicidad);
        }
      } else {
        print('❌ Publicidad NO CUMPLE condiciones de Firebase. No se muestra:');
        print('   - Activa: ${publicidad.activa}');
        print('   - Título vacío o solo espacios: ${publicidad.titulo.trim().isEmpty}');
        print('   - Expirada: ${publicidad.estaExpirada}');
      }
    } catch (e) {
      print('❌ Error crítico verificando/obteniendo publicidad desde Firebase: $e');
    }
  }

  void _debugMostrarPublicidad() async {
    print('🐞 DEBUG: Botón "Debug Publicidad" presionado.');
    try {
      final config = await _firebaseService.obtenerConfiguracion().first;
      final publicidad = config.publicidadPush;

      print('🐞 DEBUG: Configuración de publicidad obtenida para debug:');
      print('   - Activa: ${publicidad.activa}');
      print('   - Título: "${publicidad.titulo}"');
      print('   - Expirada: ${publicidad.estaExpirada}');

      bool deberiaMostrarDebug = publicidad.activa &&
          publicidad.titulo.trim().isNotEmpty &&
          !publicidad.estaExpirada;

      if (deberiaMostrarDebug) {
        print('🐞 DEBUG: Publicidad CUMPLE condiciones Firebase. Intentando mostrar modal.');
        if (mounted) {
          await PublicidadPushModal.mostrar(context, publicidad);
        }
      } else {
        print('🐞 DEBUG: Publicidad NO CUMPLE condiciones Firebase. No se muestra el modal.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('DEBUG: Publicidad no cumple condiciones para mostrarse (Activa: ${publicidad.activa}, Título: "${publicidad.titulo}", Expirada: ${publicidad.estaExpirada})'),
              backgroundColor: ColoresApp.advertencia.withOpacity(0.8),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error en debug publicidad: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('DEBUG: Error obteniendo publicidad: $e'),
            backgroundColor: ColoresApp.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _navegarANaves() {
    print('🚀 Navegando a catálogo de naves...');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PantallaCatalogoNaves(),
      ),
    ).then((_) {
      print('🔙 Regresando del catálogo de naves');
    });
  }

  void _navegarADioramas() {
    print('🏛️ Navegando a catálogo de dioramas...');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PantallaCatalogoDioramas(),
      ),
    ).then((_) {
      print('🔙 Regresando del catálogo de dioramas');
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _confirmarSalidaApp,
      child: Scaffold(
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
              icon: const Icon(Icons.campaign, color: ColoresApp.naranjaAcento),
              onPressed: _debugMostrarPublicidad,
              tooltip: 'Debug Publicidad',
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
                StreamBuilder<ConfiguracionApp>(
                  stream: _firebaseService.obtenerConfiguracion(),
                  builder: (context, snapshot) {
                    print('🏠 StreamBuilder marquee - ConnectionState: ${snapshot.connectionState}, HasData: ${snapshot.hasData}, HasError: ${snapshot.hasError}');
                    if (snapshot.hasError) {
                      print('   Error en Stream Marquee: ${snapshot.error}');
                    }
                    String textoMarquee = '¡Bienvenido a Naboo Customs! 🚀';
                    if (snapshot.hasData) {
                      final configuracion = snapshot.data!;
                      if (configuracion.textoMarquee.isNotEmpty) {
                        textoMarquee = configuracion.textoMarquee;
                      }
                      print('🎨 Texto marquee actualizado: "$textoMarquee"');
                    } else if (snapshot.connectionState == ConnectionState.waiting) {
                      textoMarquee = 'Cargando noticias...';
                    } else if (snapshot.hasError) {
                      textoMarquee = 'Error al cargar noticias.';
                    }
                    return Container(
                      key: ValueKey(textoMarquee),
                      decoration: BoxDecoration(
                        border: Border.all(color: ColoresApp.cyanPrimario.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CompleteTextMarquee(
                        text: textoMarquee,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        duration: const Duration(seconds: 10),
                        height: 40,
                        backgroundColor: Colors.black.withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                Row(
                  children: [
                    Expanded(
                      child: _tarjetaNavegacion(
                        'NAVES',
                        Icons.rocket,
                        ColoresApp.azulPrimario,
                        _navegarANaves,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _tarjetaNavegacion(
                        'DIORAMAS',
                        Icons.landscape,
                        ColoresApp.moradoPrimario,
                        _navegarADioramas,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
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
                              'https://www.instagram.com/naboo.customs/',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _botonEnlace(
                              'Facebook',
                              Icons.facebook,
                              ColoresApp.azulPrimario,
                              'https://www.facebook.com/Nabbo.customs/',
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
                          'https://drive.google.com/drive/folders/1bzZ8g6QDotavLFLg9h5puTd4bvqoBCQL',
                        ),
                      ),
                    ],
                  ),
                ),
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
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF833AB4),
                                  Color(0xFFE1306C),
                                  Color(0xFFFCAF45),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'SÍGUENOS EN INSTAGRAM',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const InstagramFeedWidget(),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmarSalidaApp() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF252525),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(
              Icons.logout,
              color: ColoresApp.advertencia,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'Cerrar Sesión',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que quieres cerrar sesión y regresar al inicio?',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Cerrar Sesión'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColoresApp.advertencia,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _cerrarSesionYRegresarLogin();
    }

    return false;
  }

  Future<void> _cerrarSesionYRegresarLogin() async {
    try {
      print('🚪 Cerrando sesión desde botón atrás...');

      final authService = AuthService();
      await authService.cerrarSesion();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Sesión cerrada correctamente'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
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
      print("❌ Error al cerrar sesión desde botón atrás: $e");

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const PantallaLogin()),
              (route) => false,
        );
      }
    }
  }

  Widget _construirDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1A1A1A),
      child: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
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
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _itemDrawer(context, Icons.home, 'INICIO', () => Navigator.pop(context)),
                _itemDrawer(context, Icons.rocket, 'NAVES', () {
                  Navigator.pop(context);
                  _navegarANaves();
                }),
                _itemDrawer(context, Icons.landscape, 'DIORAMAS', () {
                  Navigator.pop(context);
                  _navegarADioramas();
                }),
                const Divider(color: Color(0xFF404040), height: 1, thickness: 1),
                _itemDrawer(context, Icons.help_outline, 'AYUDA', () {
                  Navigator.pop(context);
                  _mostrarAyuda(context);
                }),
              ],
            ),
          ),
          const Divider(color: Color(0xFF404040), height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _itemDrawer(context, Icons.exit_to_app, 'CERRAR SESIÓN', () async {
              Navigator.pop(context);
              await _cerrarSesionSegura(context);
            }, esLogout: true),
          ),
        ],
      ),
    );
  }

  Future<void> _cerrarSesionSegura(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF252525),
        title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      try {
        print('🚪 Iniciando proceso de cierre de sesión...');

        final authService = AuthService();

        await authService.cerrarSesion();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('¡Hasta luego! Sesión cerrada.'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
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
        print("❌ Error al cerrar sesión: $e");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cerrar sesión: $e'),
              backgroundColor: ColoresApp.error,
            ),
          );

          await Future.delayed(const Duration(milliseconds: 300));

          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const PantallaLogin()),
                  (route) => false,
            );
          }
        }
      }
    }
  }

  Widget _itemDrawer(BuildContext context, IconData icono, String titulo, VoidCallback onTap, {bool esLogout = false}) {
    final colorIcono = esLogout ? Colors.redAccent : ColoresApp.cyanPrimario.withOpacity(0.8);
    final colorTexto = esLogout ? Colors.redAccent : Colors.white.withOpacity(0.9);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(icono, color: colorIcono, size: 24),
        title: Text(
          titulo,
          style: TextStyle(
            color: colorTexto,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        hoverColor: ColoresApp.cyanPrimario.withOpacity(0.05),
        splashColor: ColoresApp.cyanPrimario.withOpacity(0.1),
        dense: true,
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
              color: color.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
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
                border: Border.all(color: color.withOpacity(0.3), width: 1.5),
              ),
              child: Icon(icono, size: 36, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              titulo,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _botonEnlace(String titulo, IconData icono, Color color, String url) {
    return ElevatedButton.icon(
      onPressed: () => _abrirEnlace(url, titulo),
      icon: Icon(icono, size: 20),
      label: Text(titulo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
      ),
    );
  }

  Future<void> _abrirEnlace(String url, String nombre) async {
    try {
      print('🔗 Intentando abrir enlace: "$nombre" ($url)');
      final uri = Uri.parse(url);
      if (!await canLaunchUrl(uri)) {
        print('❌ No se puede lanzar la URL (canLaunchUrl falló): $url');
        throw Exception('No hay aplicación disponible para abrir este enlace o la URL es inválida.');
      }
      bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        print('❌ Falló el lanzamiento de la URL (launchUrl devolvió false): $url');
        throw Exception('No se pudo abrir el enlace, aunque la URL parecía válida.');
      }
      print('✅ Enlace "$nombre" abierto o intento de apertura iniciado.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Abriendo $nombre...'),
            backgroundColor: ColoresApp.exito,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Error crítico abriendo enlace "$nombre" ($url): $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Error abriendo $nombre.'),
                Text('Detalle: ${e.toString().substring(0, (e.toString().length > 100) ? 100 : e.toString().length)}...', style: const TextStyle(fontSize: 10)),
                Text('URL: $url', style: const TextStyle(fontSize: 10)),
              ],
            ),
            backgroundColor: ColoresApp.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _mostrarAyuda(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColoresApp.tarjetaOscura,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.help_center_rounded, color: ColoresApp.cyanPrimario),
            const SizedBox(width: 10),
            Text('Centro de Ayuda', style: TextStyle(color: ColoresApp.textoPrimario, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Naboo Customs Controller v1.0', style: TextStyle(color: ColoresApp.textoPrimario, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Text(
                'Esta aplicación te permite interactuar y controlar tus figuras customizadas de Naboo Customs equipadas con tecnología Arduino y Bluetooth.',
                style: TextStyle(color: ColoresApp.textoSecundario, height: 1.4),
              ),
              const SizedBox(height: 10),
              Text(
                'Funcionalidades principales:',
                style: TextStyle(color: ColoresApp.textoPrimario.withOpacity(0.8), fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                '• Conexión Bluetooth con tus figuras.\n'
                    '• Control de sistemas de LEDs y secuencias de luces.\n'
                    '• Reproducción de efectos de sonido y música.\n'
                    '• Activación de efectos especiales (ej. humo).\n'
                    '• Gestión y visualización de tu colección de figuras.',
                style: TextStyle(color: ColoresApp.textoSecundario, height: 1.4),
              ),
              const SizedBox(height: 12),
              Text(
                'Si encuentras algún problema o tienes sugerencias, no dudes en contactarnos a través de nuestras redes sociales.',
                style: TextStyle(color: ColoresApp.textoSecundario.withOpacity(0.8), fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
                backgroundColor: ColoresApp.cyanPrimario,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                textStyle: const TextStyle(fontWeight: FontWeight.bold)
            ),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

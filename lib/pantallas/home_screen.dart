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

class _PantallaHomeState extends State<PantallaHome>
    with TickerProviderStateMixin {
  bool _publicidadMostradaEnEstaSession = false;
  final FirebaseService _firebaseService = FirebaseService();

  // Controladores de animación
  late AnimationController _logoAnimationController;
  late AnimationController _cardsAnimationController;
  late AnimationController _fadeAnimationController;
  late AnimationController _pulseAnimationController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<Offset> _cardsSlideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    print('🏠 PantallaHome: initState ejecutado');
    _initAnimations();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _verificarYMostrarPublicidad();
      }
    });
  }

  void _initAnimations() {
    // Animación del logo
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.easeInOut,
    ));

    // Animación de las tarjetas
    _cardsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _cardsSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardsAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Animación de fade general
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));

    // Animación de pulso continuo
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));

    // Iniciar animaciones secuenciales
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoAnimationController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _fadeAnimationController.forward();

    await Future.delayed(const Duration(milliseconds: 700));
    _cardsAnimationController.forward();

    // Iniciar pulso continuo
    _pulseAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _cardsAnimationController.dispose();
    _fadeAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
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
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const PantallaCatalogoNaves(),
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
    ).then((_) {
      print('🔙 Regresando del catálogo de naves');
    });
  }

  void _navegarADioramas() {
    print('🏛️ Navegando a catálogo de dioramas...');
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const PantallaCatalogoDioramas(),
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
          title: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                ColoresApp.cyanPrimario,
                ColoresApp.azulPrimario,
              ],
            ).createShader(bounds),
            child: const Text(
              'NC CONTROLLER',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          backgroundColor: Colors.black.withOpacity(0.9),
          elevation: 0,
          leading: Builder(
            builder: (context) => Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColoresApp.cyanPrimario.withOpacity(0.3),
                    ColoresApp.azulPrimario.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
          actions: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ColoresApp.naranjaAcento.withOpacity(0.3),
                          ColoresApp.rojoAcento.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: ColoresApp.naranjaAcento.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.campaign, color: ColoresApp.naranjaAcento),
                      onPressed: _debugMostrarPublicidad,
                      tooltip: 'Debug Publicidad',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        drawer: _construirDrawer(context),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/imagenes/fondologin.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Marquee animado
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: StreamBuilder<ConfiguracionApp>(
                          stream: _firebaseService.obtenerConfiguracion(),
                          builder: (context, snapshot) {
                            String textoMarquee = '¡Bienvenido a Naboo Customs! 🚀';
                            if (snapshot.hasData) {
                              final configuracion = snapshot.data!;
                              if (configuracion.textoMarquee.isNotEmpty) {
                                textoMarquee = configuracion.textoMarquee;
                              }
                            } else if (snapshot.connectionState == ConnectionState.waiting) {
                              textoMarquee = 'Cargando noticias...';
                            } else if (snapshot.hasError) {
                              textoMarquee = 'Error al cargar noticias.';
                            }
                            return Container(
                              key: ValueKey(textoMarquee),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    ColoresApp.cyanPrimario.withOpacity(0.2),
                                    ColoresApp.azulPrimario.withOpacity(0.2),
                                  ],
                                ),
                                border: Border.all(
                                  color: ColoresApp.cyanPrimario.withOpacity(0.5),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: ColoresApp.cyanPrimario.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 4),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: CompleteTextMarquee(
                                text: textoMarquee,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black,
                                      offset: Offset(0, 1),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                                duration: const Duration(seconds: 12),
                                height: 50,
                                backgroundColor: Colors.black.withOpacity(0.4),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // Logo animado
                FadeTransition(
                  opacity: _logoOpacityAnimation,
                  child: AnimatedBuilder(
                    animation: _logoScaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Center(
                            child: Image.asset(
                              'assets/imagenes/img.png',
                              height: 160,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      // Título del centro de control
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.black.withOpacity(0.6),
                                Colors.black.withOpacity(0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: ColoresApp.cyanPrimario.withOpacity(0.4),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: ColoresApp.cyanPrimario.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    ColoresApp.cyanPrimario,
                                    ColoresApp.azulPrimario,
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  'CENTRO DE CONTROL',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.7),
                                        offset: const Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Controla tus figuras futuristas',
                                style: TextStyle(
                                  color: ColoresApp.cyanPrimario.withOpacity(0.9),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
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

                      const SizedBox(height: 32),

                      // Tarjetas de navegación FUTURISTAS
                      SlideTransition(
                        position: _cardsSlideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Row(
                            children: [
                              Expanded(
                                child: _tarjetaNavegacionFuturista(
                                  'NAVES',
                                  Icons.rocket_launch,
                                  ColoresApp.azulPrimario,
                                  ColoresApp.cyanPrimario,
                                  _navegarANaves,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _tarjetaNavegacionFuturista(
                                  'DIORAMAS',
                                  Icons.landscape,
                                  ColoresApp.moradoPrimario,
                                  const Color(0xFF9C27B0),
                                  _navegarADioramas,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Enlaces SIMPLIFICADOS
                      SlideTransition(
                        position: _cardsSlideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: ColoresApp.verdeAcento.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ENLACES',
                                  style: TextStyle(
                                    color: ColoresApp.verdeAcento,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _botonEnlaceSimple(
                                        'Insta',
                                        Icons.camera_alt,
                                        const Color(0xFFE1306C),
                                        'https://www.instagram.com/naboo.customs/',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _botonEnlaceSimple(
                                        'Face',
                                        Icons.facebook,
                                        const Color(0xFF1877F2),
                                        'https://www.facebook.com/Nabbo.customs/',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _botonEnlaceSimple(
                                  'Catálogo Drive',
                                  Icons.folder_open,
                                  ColoresApp.naranjaAcento,
                                  'https://drive.google.com/drive/folders/1bzZ8g6QDotavLFLg9h5puTd4bvqoBCQL',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Instagram feed
                      SlideTransition(
                        position: _cardsSlideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  ColoresApp.tarjetaOscura.withOpacity(0.9),
                                  ColoresApp.tarjetaOscura.withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: ColoresApp.rosaAcento.withOpacity(0.4),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: ColoresApp.rosaAcento.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF833AB4),
                                            Color(0xFFE1306C),
                                            Color(0xFFFCAF45),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: ColoresApp.rosaAcento.withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      'SÍGUENOS',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                const InstagramFeedWidget(),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // TARJETAS FUTURISTAS
  Widget _tarjetaNavegacionFuturista(String titulo, IconData icono, Color colorPrimario, Color colorSecundario, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colorPrimario, colorSecundario],
          ),
          boxShadow: [
            BoxShadow(
              color: colorPrimario.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            splashColor: Colors.white.withOpacity(0.2),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      icono,
                      size: 32,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(0, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // BOTONES DE ENLACE SIMPLES
  Widget _botonEnlaceSimple(String titulo, IconData icono, Color color, String url) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _abrirEnlace(url, titulo),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icono,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
        backgroundColor: ColoresApp.tarjetaOscura,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: ColoresApp.advertencia.withOpacity(0.5),
            width: 2,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColoresApp.advertencia.withOpacity(0.3),
                    ColoresApp.rojoAcento.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.logout,
                color: ColoresApp.advertencia,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  ColoresApp.advertencia,
                  ColoresApp.rojoAcento,
                ],
              ).createShader(bounds),
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de que quieres cerrar sesión y regresar al inicio?',
          style: TextStyle(
            color: ColoresApp.textoSecundario,
            fontSize: 16,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: ColoresApp.textoSecundario,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColoresApp.advertencia,
                  ColoresApp.rojoAcento,
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: ColoresApp.advertencia.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Cerrar Sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Sesión cerrada correctamente'),
              ],
            ),
            backgroundColor: ColoresApp.exito,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const PantallaLogin(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1.0, 0.0),
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
      backgroundColor: const Color(0xFF0F0F0F),
      child: Column(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ColoresApp.azulPrimario,
                  ColoresApp.cyanPrimario,
                  ColoresApp.moradoPrimario,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: ColoresApp.cyanPrimario.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.rocket_launch,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'NABOO CUSTOMS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Control Center',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0F0F0F),
                    const Color(0xFF1A1A1A),
                  ],
                ),
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 20),
                  _itemDrawer(context, Icons.home, 'INICIO', () => Navigator.pop(context)),
                  _itemDrawer(context, Icons.rocket, 'NAVES', () {
                    Navigator.pop(context);
                    _navegarANaves();
                  }),
                  _itemDrawer(context, Icons.landscape, 'DIORAMAS', () {
                    Navigator.pop(context);
                    _navegarADioramas();
                  }),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          ColoresApp.cyanPrimario.withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  _itemDrawer(context, Icons.help_outline, 'AYUDA', () {
                    Navigator.pop(context);
                    _mostrarAyuda(context);
                  }),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  ColoresApp.rojoAcento.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
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
        backgroundColor: ColoresApp.tarjetaOscura,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: ColoresApp.rojoAcento.withOpacity(0.5),
            width: 2,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColoresApp.rojoAcento.withOpacity(0.3),
                    ColoresApp.advertencia.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.logout,
                color: ColoresApp.rojoAcento,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  ColoresApp.rojoAcento,
                  ColoresApp.advertencia,
                ],
              ).createShader(bounds),
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de que quieres cerrar sesión?',
          style: TextStyle(
            color: ColoresApp.textoSecundario,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: ColoresApp.textoSecundario),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ColoresApp.rojoAcento, ColoresApp.advertencia],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cerrar Sesión'),
            ),
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
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('¡Hasta luego! Sesión cerrada.'),
                ],
              ),
              backgroundColor: ColoresApp.exito,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 2),
            ),
          );

          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const PantallaLogin(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(-1.0, 0.0),
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
    final colorIcono = esLogout ? ColoresApp.rojoAcento : ColoresApp.cyanPrimario;
    final colorTexto = esLogout ? ColoresApp.rojoAcento : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: esLogout
            ? LinearGradient(
          colors: [
            ColoresApp.rojoAcento.withOpacity(0.1),
            Colors.transparent,
          ],
        )
            : null,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorIcono.withOpacity(0.2),
                colorIcono.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorIcono.withOpacity(0.3),
            ),
          ),
          child: Icon(icono, color: colorIcono, size: 20),
        ),
        title: Text(
          titulo,
          style: TextStyle(
            color: colorTexto,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        hoverColor: colorIcono.withOpacity(0.05),
        splashColor: colorIcono.withOpacity(0.1),
        dense: true,
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
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: ColoresApp.cyanPrimario.withOpacity(0.5),
            width: 2,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColoresApp.cyanPrimario.withOpacity(0.3),
                    ColoresApp.azulPrimario.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ColoresApp.cyanPrimario.withOpacity(0.5),
                ),
              ),
              child: Icon(Icons.help_center_rounded, color: ColoresApp.cyanPrimario),
            ),
            const SizedBox(width: 16),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  ColoresApp.cyanPrimario,
                  ColoresApp.azulPrimario,
                ],
              ).createShader(bounds),
              child: Text(
                'Centro de Ayuda',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Naboo Customs Controller v1.0',
                style: TextStyle(
                  color: ColoresApp.textoPrimario,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Esta aplicación te permite interactuar y controlar tus figuras customizadas de Naboo Customs equipadas con tecnología Arduino y Bluetooth.',
                style: TextStyle(
                  color: ColoresApp.textoSecundario,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Funcionalidades principales:',
                style: TextStyle(
                  color: ColoresApp.textoPrimario.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '• Conexión Bluetooth con tus figuras.\n'
                    '• Control de sistemas de LEDs y secuencias de luces.\n'
                    '• Reproducción de efectos de sonido y música.\n'
                    '• Activación de efectos especiales (ej. humo).\n'
                    '• Gestión y visualización de tu colección de figuras.',
                style: TextStyle(
                  color: ColoresApp.textoSecundario,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Si encuentras algún problema o tienes sugerencias, no dudes en contactarnos a través de nuestras redes sociales.',
                style: TextStyle(
                  color: ColoresApp.textoSecundario.withOpacity(0.8),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColoresApp.cyanPrimario,
                  ColoresApp.azulPrimario,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: ColoresApp.cyanPrimario.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text('Cerrar'),
            ),
          ),
        ],
      ),
    );
  }
}
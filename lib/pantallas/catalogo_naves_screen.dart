import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../nucleo/constantes/colores_app.dart';
import '../servicios/firebase_service.dart';
import '../modelos/figura.dart';
import 'control_figura_screen.dart';

class PantallaCatalogoNaves extends StatefulWidget {
  const PantallaCatalogoNaves({super.key});

  @override
  State<PantallaCatalogoNaves> createState() => _PantallaCatalogoNavesState();
}

class _PantallaCatalogoNavesState extends State<PantallaCatalogoNaves>
    with TickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _busquedaController = TextEditingController();
  String _terminoBusqueda = '';
  bool _cargando = false;

  // Controladores de animación
  late AnimationController _headerController;
  late AnimationController _searchController;
  late AnimationController _gridController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _searchSlideAnimation;
  late Animation<double> _searchFadeAnimation;
  late Animation<double> _gridFadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Animación del header
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    ));

    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeInOut,
    ));

    // Animación de la barra de búsqueda
    _searchController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _searchSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _searchController,
      curve: Curves.easeOutCubic,
    ));

    _searchFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchController,
      curve: Curves.easeInOut,
    ));

    // Animación del grid
    _gridController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _gridFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gridController,
      curve: Curves.easeInOut,
    ));

    // Animación de pulso
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Animación shimmer
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));

    // Iniciar animaciones secuenciales
    _startAnimations();
  }

  void _startAnimations() async {
    _headerController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _searchController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _gridController.forward();

    // Animaciones continuas
    _pulseController.repeat(reverse: true);
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    _headerController.dispose();
    _searchController.dispose();
    _gridController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0F),
              Color(0xFF1A1A2E),
              Color(0xFF0F0F0F),
              Color(0xFF2A2A3E),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _construirHeader(),
              _construirBarraBusquedaEspectacular(),
              Expanded(
                child: _construirCatalogoNaves(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirHeader() {
    return SlideTransition(
      position: _headerSlideAnimation,
      child: FadeTransition(
        opacity: _headerFadeAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            ColoresApp.azulPrimario.withOpacity(0.3),
                            ColoresApp.cyanPrimario.withOpacity(0.3),
                          ],
                        ),
                        border: Border.all(
                          color: ColoresApp.azulPrimario.withOpacity(0.6),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ColoresApp.azulPrimario.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: ColoresApp.cyanPrimario.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: ColoresApp.azulPrimario,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedBuilder(
                      animation: _shimmerAnimation,
                      builder: (context, child) {
                        return Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    ColoresApp.azulPrimario,
                                    ColoresApp.cyanPrimario,
                                    ColoresApp.azulPrimario,
                                  ],
                                  stops: [
                                    (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                                    _shimmerAnimation.value.clamp(0.0, 1.0),
                                    (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.rocket_launch_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  ColoresApp.textoPrimario,
                                  ColoresApp.azulPrimario,
                                  ColoresApp.cyanPrimario,
                                ],
                              ).createShader(bounds),
                              child: const Text(
                                'NAVES',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 3.0,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black,
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.black.withOpacity(0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: ColoresApp.textoSecundario.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Flota Espacial Naboo Customs',
                        style: TextStyle(
                          color: ColoresApp.cyanPrimario,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirBarraBusquedaEspectacular() {
    return SlideTransition(
      position: _searchSlideAnimation,
      child: FadeTransition(
        opacity: _searchFadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ColoresApp.superficieOscura.withOpacity(0.9),
                ColoresApp.superficieOscura.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              width: 2,
              color: Colors.transparent,
            ),
            boxShadow: [
              BoxShadow(
                color: ColoresApp.azulPrimario.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: ColoresApp.cyanPrimario.withOpacity(0.1),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  ColoresApp.azulPrimario.withOpacity(0.1),
                  Colors.transparent,
                  ColoresApp.cyanPrimario.withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: ColoresApp.azulPrimario.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColoresApp.azulPrimario.withOpacity(0.2),
                        ColoresApp.cyanPrimario.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    color: ColoresApp.azulPrimario,
                    size: 24,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _busquedaController,
                    style: const TextStyle(
                      color: ColoresApp.textoPrimario,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Buscar naves espaciales...',
                      hintStyle: TextStyle(
                        color: ColoresApp.textoApagado.withOpacity(0.7),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _terminoBusqueda = value.toLowerCase();
                      });
                    },
                  ),
                ),
                if (_terminoBusqueda.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          _busquedaController.clear();
                          setState(() {
                            _terminoBusqueda = '';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                ColoresApp.error.withOpacity(0.2),
                                Colors.redAccent.withOpacity(0.2),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: ColoresApp.error.withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: ColoresApp.error,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirCatalogoNaves() {
    return FadeTransition(
      opacity: _gridFadeAnimation,
      child: StreamBuilder<List<Figura>>(
        stream: _firebaseService.obtenerFigurasPorTipo('nave'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _construirCargandoEspectacular();
          }

          if (snapshot.hasError) {
            return _construirErrorEspectacular(snapshot.error.toString());
          }

          final naves = snapshot.data ?? [];

          // Filtrar naves según término de búsqueda
          final navesFiltradas = naves.where((nave) {
            if (_terminoBusqueda.isEmpty) return true;
            return nave.nombre.toLowerCase().contains(_terminoBusqueda) ||
                nave.descripcion.toLowerCase().contains(_terminoBusqueda);
          }).toList();

          if (navesFiltradas.isEmpty) {
            return _construirSinResultadosEspectacular();
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            color: ColoresApp.azulPrimario,
            backgroundColor: ColoresApp.tarjetaOscura,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: ColoresApp.azulPrimario.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                ColoresApp.azulPrimario.withOpacity(0.2),
                                ColoresApp.cyanPrimario.withOpacity(0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.inventory_2_rounded,
                            color: ColoresApp.azulPrimario,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${navesFiltradas.length} nave${navesFiltradas.length == 1 ? '' : 's'} encontrada${navesFiltradas.length == 1 ? '' : 's'}',
                          style: TextStyle(
                            color: ColoresApp.cyanPrimario,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.55, // Ajustado para hacer las tarjetas más altas
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 600 + (index * 100)),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 50 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: _construirTarjetaNaveEspectacular(navesFiltradas[index]),
                              ),
                            );
                          },
                        );
                      },
                      childCount: navesFiltradas.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _construirTarjetaNaveEspectacular(Figura nave) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  PantallaControlFigura(figura: nave),
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
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ColoresApp.superficieOscura.withOpacity(0.9),
                ColoresApp.superficieOscura.withOpacity(0.7),
                Colors.black.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              width: 2,
              color: Colors.transparent,
            ),
            boxShadow: [
              BoxShadow(
                color: ColoresApp.azulPrimario.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: ColoresApp.cyanPrimario.withOpacity(0.1),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ColoresApp.azulPrimario.withOpacity(0.1),
                  Colors.transparent,
                  ColoresApp.cyanPrimario.withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: ColoresApp.azulPrimario.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3, // Ajustado para darle más espacio a la imagen
                    child: _construirImagenNave(nave),
                  ),
                  _construirInfoNave(nave),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirImagenNave(Figura nave) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ColoresApp.azulPrimario.withOpacity(0.2),
                ColoresApp.superficieOscura,
              ],
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _mostrarImagenCompleta(context, nave),
              child: nave.imagenSeleccion.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: nave.imagenSeleccion,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColoresApp.superficieOscura,
                        ColoresApp.superficieOscura.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                ColoresApp.azulPrimario.withOpacity(0.2),
                                ColoresApp.cyanPrimario.withOpacity(0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const CircularProgressIndicator(
                            color: ColoresApp.azulPrimario,
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Cargando...',
                            style: TextStyle(
                              color: ColoresApp.azulPrimario,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.withOpacity(0.1),
                        Colors.redAccent.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.rocket_launch_outlined,
                      color: ColoresApp.azulPrimario,
                      size: 40,
                    ),
                  ),
                ),
              )
                  : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColoresApp.azulPrimario.withOpacity(0.1),
                      ColoresApp.superficieOscura,
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.rocket_launch_outlined,
                    color: ColoresApp.azulPrimario,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  ColoresApp.superficieOscura.withOpacity(0.9),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColoresApp.azulPrimario,
                  ColoresApp.cyanPrimario,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: ColoresApp.azulPrimario.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              'NAVE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: InkWell(
            onTap: () => _mostrarImagenCompleta(context, nave),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ColoresApp.cyanPrimario.withOpacity(0.5),
                ),
              ),
              child: const Icon(
                Icons.zoom_in_rounded,
                color: ColoresApp.cyanPrimario,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirInfoNave(Figura nave) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.1),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                ColoresApp.textoPrimario,
                ColoresApp.cyanPrimario,
              ],
            ).createShader(bounds),
            child: Text(
              nave.nombre,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                height: 1.2,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          if (nave.descripcion.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ColoresApp.textoSecundario.withOpacity(0.2),
                ),
              ),
              child: Text(
                nave.descripcion,
                style: TextStyle(
                  color: ColoresApp.textoSecundario.withOpacity(0.9),
                  fontSize: 11,
                  height: 1.3,
                  letterSpacing: 0.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (nave.componentes.leds.cantidad > 0)
                _construirChipComponenteEspectacular(
                  Icons.lightbulb_rounded,
                  '${nave.componentes.leds.cantidad}',
                  ColoresApp.verdeAcento,
                ),
              if (nave.componentes.musica.disponible)
                _construirChipComponenteEspectacular(
                  Icons.music_note_rounded,
                  '${nave.componentes.musica.cantidad}',
                  ColoresApp.cyanPrimario,
                ),
              if (nave.componentes.humidificador.disponible)
                _construirChipComponenteEspectacular(
                  Icons.cloud_rounded,
                  '',
                  ColoresApp.informacion,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColoresApp.azulPrimario.withOpacity(0.2),
                      ColoresApp.cyanPrimario.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'DISPONIBLE',
                  style: TextStyle(
                    color: ColoresApp.cyanPrimario,
                    fontSize: 6,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColoresApp.azulPrimario,
                      ColoresApp.cyanPrimario,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: ColoresApp.azulPrimario.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              PantallaControlFigura(figura: nave),
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
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirChipComponenteEspectacular(IconData icono, String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 12, color: color),
          if (texto.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              texto,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _mostrarImagenCompleta(BuildContext context, Figura nave) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: ColoresApp.azulPrimario.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: ColoresApp.cyanPrimario.withOpacity(0.2),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: nave.imagenSeleccion,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Container(
                        height: 400,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ColoresApp.superficieOscura,
                              ColoresApp.superficieOscura.withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: ColoresApp.azulPrimario,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 400,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.red.withOpacity(0.1),
                              Colors.redAccent.withOpacity(0.05),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.error_outline_rounded,
                            color: Colors.red,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _construirCargandoEspectacular() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColoresApp.azulPrimario.withOpacity(0.2),
                  ColoresApp.cyanPrimario.withOpacity(0.2),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ColoresApp.azulPrimario.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              color: ColoresApp.azulPrimario,
              strokeWidth: 4,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: ColoresApp.azulPrimario.withOpacity(0.3),
              ),
            ),
            child: const Text(
              'Cargando flota de naves...',
              style: TextStyle(
                color: ColoresApp.cyanPrimario,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirErrorEspectacular(String error) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red.withOpacity(0.1),
              Colors.redAccent.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.red.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.withOpacity(0.2),
                    Colors.redAccent.withOpacity(0.2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Error en la conexión',
              style: TextStyle(
                color: ColoresApp.textoPrimario,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No se pudieron cargar las naves',
              style: TextStyle(
                color: ColoresApp.textoSecundario,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColoresApp.azulPrimario,
                    ColoresApp.cyanPrimario,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton.icon(
                onPressed: () => setState(() {}),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirSinResultadosEspectacular() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ColoresApp.azulPrimario.withOpacity(0.1),
              ColoresApp.cyanPrimario.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ColoresApp.azulPrimario.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColoresApp.azulPrimario.withOpacity(0.2),
                    ColoresApp.cyanPrimario.withOpacity(0.2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 48,
                color: ColoresApp.azulPrimario,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sin resultados',
              style: TextStyle(
                color: ColoresApp.textoPrimario,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _terminoBusqueda.isEmpty
                  ? 'No hay naves registradas'
                  : 'No se encontraron naves con "$_terminoBusqueda"',
              style: TextStyle(
                color: ColoresApp.textoSecundario,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (_terminoBusqueda.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColoresApp.azulPrimario.withOpacity(0.2),
                      ColoresApp.cyanPrimario.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton.icon(
                  onPressed: () {
                    _busquedaController.clear();
                    setState(() {
                      _terminoBusqueda = '';
                    });
                  },
                  icon: const Icon(Icons.clear_rounded),
                  label: const Text('Limpiar búsqueda'),
                  style: TextButton.styleFrom(
                    foregroundColor: ColoresApp.azulPrimario,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

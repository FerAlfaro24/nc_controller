// Archivo: lib/pantallas/catalogo_dioramas_screen.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../nucleo/constantes/colores_app.dart';
import '../servicios/firebase_service.dart';
import '../modelos/figura.dart';
import '../widgets/auto_scrolling_text.dart';

class PantallaCatalogoDioramas extends StatefulWidget {
  const PantallaCatalogoDioramas({super.key});

  @override
  State<PantallaCatalogoDioramas> createState() => _PantallaCatalogoDioramasState();
}

class _PantallaCatalogoDioramasState extends State<PantallaCatalogoDioramas> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _busquedaController = TextEditingController();
  String _terminoBusqueda = '';
  bool _cargando = false;

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0A0F),
              Color(0xFF2E1A47), // Tono más púrpura para dioramas
              Color(0xFF0F0F0F),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _construirHeader(),
              _construirBarraBusqueda(),
              Expanded(
                child: _construirCatalogoDioramas(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          // Botón de regresar con efecto futurista
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ColoresApp.moradoPrimario.withOpacity(0.3),
                  ColoresApp.azulPrimario.withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: ColoresApp.moradoPrimario.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: ColoresApp.moradoPrimario,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Título con animación
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: ColoresApp.moradoPrimario.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ColoresApp.moradoPrimario.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.landscape,
                        color: ColoresApp.moradoPrimario,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'COLECCIÓN',
                        style: TextStyle(
                          color: ColoresApp.moradoPrimario,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                AutoScrollingText(
                  text: 'DIORAMAS ÉPICOS',
                  style: const TextStyle(
                    color: ColoresApp.textoPrimario,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                  duration: const Duration(seconds: 6),
                ),
              ],
            ),
          ),

          // Icono de diorama decorativo
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ColoresApp.moradoPrimario.withOpacity(0.3),
                  ColoresApp.rosaAcento.withOpacity(0.1),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: ColoresApp.moradoPrimario.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.terrain,
              color: ColoresApp.moradoPrimario,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirBarraBusqueda() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ColoresApp.tarjetaOscura.withOpacity(0.8),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: ColoresApp.moradoPrimario.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ColoresApp.moradoPrimario.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: ColoresApp.moradoPrimario.withOpacity(0.7),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _busquedaController,
              style: const TextStyle(color: ColoresApp.textoPrimario),
              decoration: InputDecoration(
                hintText: 'Buscar dioramas épicos...',
                hintStyle: TextStyle(
                  color: ColoresApp.textoApagado,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _terminoBusqueda = value.toLowerCase();
                });
              },
            ),
          ),
          if (_terminoBusqueda.isNotEmpty)
            GestureDetector(
              onTap: () {
                _busquedaController.clear();
                setState(() {
                  _terminoBusqueda = '';
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: ColoresApp.error.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.clear,
                  color: ColoresApp.error,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _construirCatalogoDioramas() {
    return StreamBuilder<List<Figura>>(
      stream: _firebaseService.obtenerFigurasPorTipo('diorama'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _construirCargando();
        }

        if (snapshot.hasError) {
          return _construirError(snapshot.error.toString());
        }

        final dioramas = snapshot.data ?? [];

        // Filtrar dioramas según término de búsqueda
        final dioramasFiltrados = dioramas.where((diorama) {
          if (_terminoBusqueda.isEmpty) return true;
          return diorama.nombre.toLowerCase().contains(_terminoBusqueda) ||
              diorama.descripcion.toLowerCase().contains(_terminoBusqueda);
        }).toList();

        if (dioramasFiltrados.isEmpty) {
          return _construirSinResultados();
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          color: ColoresApp.moradoPrimario,
          backgroundColor: ColoresApp.tarjetaOscura,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      return _construirTarjetaDiorama(dioramasFiltrados[index]);
                    },
                    childCount: dioramasFiltrados.length,
                  ),
                ),
              ),

              // Espaciado inferior
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _construirTarjetaDiorama(Figura diorama) {
    return GestureDetector(
      onTap: () {
        // TODO: Navegar a la pantalla de control del diorama
        _mostrarProximamente(diorama.nombre);
      },
      child: Container(
        decoration: BoxDecoration(
          color: ColoresApp.tarjetaOscura.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ColoresApp.moradoPrimario.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ColoresApp.moradoPrimario.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen principal
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            ColoresApp.superficieOscura,
                            ColoresApp.tarjetaOscura,
                          ],
                        ),
                      ),
                      child: diorama.imagenSeleccion.isNotEmpty
                          ? CachedNetworkImage(
                        imageUrl: diorama.imagenSeleccion,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: ColoresApp.superficieOscura,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: ColoresApp.moradoPrimario,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: ColoresApp.superficieOscura,
                          child: const Center(
                            child: Icon(
                              Icons.terrain_outlined,
                              color: ColoresApp.moradoPrimario,
                              size: 40,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        color: ColoresApp.superficieOscura,
                        child: const Center(
                          child: Icon(
                            Icons.terrain_outlined,
                            color: ColoresApp.moradoPrimario,
                            size: 40,
                          ),
                        ),
                      ),
                    ),

                    // Overlay de gradiente
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
                              ColoresApp.tarjetaOscura.withOpacity(0.9),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Indicadores de características
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _construirIndicadoresCaracteristicas(diorama),
                    ),
                  ],
                ),
              ),

              // Información del diorama
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre del diorama con auto-scroll
                      AutoScrollingText(
                        text: diorama.nombre,
                        style: const TextStyle(
                          color: ColoresApp.textoPrimario,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        duration: const Duration(seconds: 4),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 6),

                      // Descripción con auto-scroll
                      if (diorama.descripcion.isNotEmpty)
                        Expanded(
                          child: AutoScrollingText(
                            text: diorama.descripcion,
                            style: const TextStyle(
                              color: ColoresApp.textoSecundario,
                              fontSize: 11,
                              height: 1.3,
                            ),
                            duration: const Duration(seconds: 5),
                            maxLines: 2,
                          ),
                        ),

                      const SizedBox(height: 8),

                      // Componentes disponibles
                      _construirComponentesDisponibles(diorama),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirIndicadoresCaracteristicas(Figura diorama) {
    return Column(
      children: [
        // Indicador de tipo Diorama
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: ColoresApp.moradoPrimario.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'DIORAMA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirComponentesDisponibles(Figura diorama) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // LEDs
        if (diorama.componentes.leds.cantidad > 0)
          _construirChipComponente(
            Icons.lightbulb_outline,
            '${diorama.componentes.leds.cantidad}',
            ColoresApp.verdeAcento,
          ),

        // Música
        if (diorama.componentes.musica.disponible)
          _construirChipComponente(
            Icons.music_note_outlined,
            '${diorama.componentes.musica.cantidad}',
            ColoresApp.cyanPrimario,
          ),

        // Humidificador
        if (diorama.componentes.humidificador.disponible)
          _construirChipComponente(
            Icons.cloud_outlined,
            '',
            ColoresApp.azulPrimario,
          ),

        const Spacer(),

        // Botón de acceso rápido
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: ColoresApp.moradoPrimario.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.play_arrow,
            color: ColoresApp.moradoPrimario,
            size: 16,
          ),
        ),
      ],
    );
  }

  Widget _construirChipComponente(IconData icono, String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 10, color: color),
          if (texto.isNotEmpty) ...[
            const SizedBox(width: 2),
            Text(
              texto,
              style: TextStyle(
                color: color,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _construirCargando() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: ColoresApp.moradoPrimario,
            strokeWidth: 3,
          ),
          SizedBox(height: 24),
          Text(
            'Cargando dioramas épicos...',
            style: TextStyle(
              color: ColoresApp.textoSecundario,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ColoresApp.error.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: ColoresApp.error.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 48,
              color: ColoresApp.error,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Error en la conexión',
            style: TextStyle(
              color: ColoresApp.textoPrimario,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No se pudieron cargar los dioramas',
            style: TextStyle(
              color: ColoresApp.textoSecundario,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColoresApp.moradoPrimario,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirSinResultados() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ColoresApp.moradoPrimario.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: ColoresApp.moradoPrimario.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.search_off,
              size: 48,
              color: ColoresApp.moradoPrimario,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Sin resultados',
            style: TextStyle(
              color: ColoresApp.textoPrimario,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _terminoBusqueda.isEmpty
                ? 'No hay dioramas registrados'
                : 'No se encontraron dioramas con "$_terminoBusqueda"',
            style: TextStyle(
              color: ColoresApp.textoSecundario,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          if (_terminoBusqueda.isNotEmpty) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                _busquedaController.clear();
                setState(() {
                  _terminoBusqueda = '';
                });
              },
              icon: const Icon(Icons.clear),
              label: const Text('Limpiar búsqueda'),
              style: TextButton.styleFrom(
                foregroundColor: ColoresApp.moradoPrimario,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _mostrarProximamente(String nombreDiorama) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColoresApp.tarjetaOscura,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: ColoresApp.moradoPrimario.withOpacity(0.3),
            width: 1,
          ),
        ),
        title: Row(
          children: [
            Icon(
              Icons.terrain,
              color: ColoresApp.moradoPrimario,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                nombreDiorama,
                style: const TextStyle(
                  color: ColoresApp.textoPrimario,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'La pantalla de control para este diorama estará disponible próximamente.\n\n¡Prepárate para explorar mundos épicos!',
          style: TextStyle(
            color: ColoresApp.textoSecundario,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColoresApp.moradoPrimario,
              foregroundColor: Colors.white,
            ),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
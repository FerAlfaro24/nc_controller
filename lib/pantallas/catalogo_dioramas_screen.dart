// Archivo: lib/pantallas/catalogo_dioramas_screen.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../nucleo/constantes/colores_app.dart';
import '../servicios/firebase_service.dart';
import '../modelos/figura.dart';
import 'control_figura_screen.dart';

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
              _construirBarraBusquedaMejorada(),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Row(
        children: [
          // Botón de regresar mejorado
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColoresApp.superficieOscura.withOpacity(0.8),
              border: Border.all(
                color: ColoresApp.moradoPrimario.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: ColoresApp.moradoPrimario.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
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
          const SizedBox(width: 20),

          // Título principal mejorado y más llamativo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título principal grande y llamativo
                Row(
                  children: [
                    Icon(
                      Icons.landscape,
                      color: ColoresApp.moradoPrimario,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'DIORAMA',
                      style: TextStyle(
                        color: ColoresApp.textoPrimario,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Subtítulo descriptivo
                Text(
                  'Mundos Épicos Naboo Customs',
                  style: TextStyle(
                    color: ColoresApp.textoSecundario,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirBarraBusquedaMejorada() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: ColoresApp.superficieOscura.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColoresApp.moradoPrimario.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ColoresApp.moradoPrimario.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono de búsqueda con estilo
          Container(
            padding: const EdgeInsets.all(14),
            child: Icon(
              Icons.search_rounded,
              color: ColoresApp.moradoPrimario,
              size: 22,
            ),
          ),

          // Campo de texto mejorado
          Expanded(
            child: TextField(
              controller: _busquedaController,
              style: const TextStyle(
                color: ColoresApp.textoPrimario,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar dioramas épicos...',
                hintStyle: TextStyle(
                  color: ColoresApp.textoApagado.withOpacity(0.7),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
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

          // Botón limpiar con animación
          if (_terminoBusqueda.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  _busquedaController.clear();
                  setState(() {
                    _terminoBusqueda = '';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: ColoresApp.error.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ColoresApp.error.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: ColoresApp.error,
                    size: 16,
                  ),
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
              // Información de resultados
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        color: ColoresApp.textoSecundario,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${dioramasFiltrados.length} diorama${dioramasFiltrados.length == 1 ? '' : 's'} encontrado${dioramasFiltrados.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          color: ColoresApp.textoSecundario,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Grid de dioramas mejorado
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 18,
                    childAspectRatio: 0.68,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      return _construirTarjetaDioramaRedisenada(dioramasFiltrados[index]);
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

  Widget _construirTarjetaDioramaRedisenada(Figura diorama) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PantallaControlFigura(figura: diorama),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: ColoresApp.superficieOscura.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ColoresApp.moradoPrimario.withOpacity(0.3),
            width: 1.5,
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
              // Imagen principal con overlay mejorado
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
                            ColoresApp.moradoPrimario.withOpacity(0.1),
                            ColoresApp.superficieOscura,
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

                    // Overlay de gradiente sutil
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              ColoresApp.superficieOscura.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Badge de tipo en la esquina
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: ColoresApp.moradoPrimario.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'DIORAMA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Información del diorama mejorada
              Container(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del diorama - AHORA VISIBLE Y BIEN DISEÑADO
                    Text(
                      diorama.nombre,
                      style: const TextStyle(
                        color: ColoresApp.textoPrimario,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Descripción breve
                    if (diorama.descripcion.isNotEmpty)
                      Text(
                        diorama.descripcion,
                        style: TextStyle(
                          color: ColoresApp.textoSecundario.withOpacity(0.8),
                          fontSize: 11,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: 10),

                    // Componentes disponibles usando Wrap
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
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
                            ColoresApp.informacion,
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Botón de acceso centrado
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ColoresApp.moradoPrimario.withOpacity(0.8),
                              ColoresApp.rosaAcento.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 16,
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

  Widget _construirChipComponente(IconData icono, String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 12, color: color),
          if (texto.isNotEmpty) ...[
            const SizedBox(width: 3),
            Text(
              texto,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _construirCargando() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ColoresApp.moradoPrimario.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: ColoresApp.moradoPrimario,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Cargando dioramas épicos...',
            style: TextStyle(
              color: ColoresApp.textoSecundario,
              fontSize: 16,
              fontWeight: FontWeight.w500,
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
}
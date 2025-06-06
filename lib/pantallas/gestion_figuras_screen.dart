// Archivo: lib/pantallas/gestion_figuras_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../servicios/cloudinary_service.dart';
import '../servicios/firebase_service.dart';
import '../modelos/figura.dart';
import '../nucleo/constantes/colores_app.dart';

class PantallaGestionFiguras extends StatefulWidget {
  const PantallaGestionFiguras({super.key});

  @override
  State<PantallaGestionFiguras> createState() => _PantallaGestionFigurasState();
}

class _PantallaGestionFigurasState extends State<PantallaGestionFiguras> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final FirebaseService _firebaseService = FirebaseService();

  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GESTIÓN DE FIGURAS'),
        backgroundColor: ColoresApp.superficieOscura,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ColoresApp.cyanPrimario,
          labelColor: ColoresApp.textoPrimario,
          unselectedLabelColor: ColoresApp.textoSecundario,
          tabs: const [
            Tab(text: 'NAVES', icon: Icon(Icons.rocket)),
            Tab(text: 'DIORAMAS', icon: Icon(Icons.landscape)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: ColoresApp.verdeAcento),
            onPressed: () => _mostrarDialogoCrearFigura(),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: ColoresApp.gradienteFondo),
        child: TabBarView(
          controller: _tabController,
          children: [
            _construirListaFiguras('nave'),
            _construirListaFiguras('diorama'),
          ],
        ),
      ),
    );
  }

  Widget _construirListaFiguras(String tipo) {
    return StreamBuilder<List<Figura>>(
      stream: _firebaseService.obtenerFigurasPorTipo(tipo),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: ColoresApp.cyanPrimario),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: ColoresApp.error, size: 64),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}', style: const TextStyle(color: ColoresApp.error)),
              ],
            ),
          );
        }

        final figuras = snapshot.data ?? [];

        if (figuras.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  tipo == 'nave' ? Icons.rocket : Icons.landscape,
                  size: 64,
                  color: ColoresApp.textoApagado,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay ${tipo}s registradas',
                  style: const TextStyle(color: ColoresApp.textoSecundario, fontSize: 18),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _mostrarDialogoCrearFigura(tipoInicial: tipo),
                  icon: const Icon(Icons.add),
                  label: Text('Crear ${tipo == 'nave' ? 'Nave' : 'Diorama'}'),
                  style: ElevatedButton.styleFrom(backgroundColor: ColoresApp.cyanPrimario),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemCount: figuras.length,
          itemBuilder: (context, index) {
            final figura = figuras[index];
            return _construirTarjetaFigura(figura);
          },
        );
      },
    );
  }

  Widget _construirTarjetaFigura(Figura figura) {
    return GestureDetector(
      onTap: () => _mostrarDialogoEditarFigura(figura),
      child: Container(
        decoration: BoxDecoration(
          color: ColoresApp.tarjetaOscura,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColoresApp.bordeGris.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Container(
                  color: ColoresApp.superficieOscura,
                  child: figura.imagenSeleccion.isNotEmpty
                      ? CachedNetworkImage(
                    imageUrl: figura.imagenSeleccion,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ColoresApp.cyanPrimario,
                      ),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: ColoresApp.textoApagado,
                      ),
                    ),
                  )
                      : Icon(
                    figura.tipo == 'nave'
                        ? Icons.rocket_launch_outlined
                        : Icons.terrain_outlined,
                    size: 40,
                    color: ColoresApp.textoApagado,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        figura.nombre,
                        style: const TextStyle(
                          color: ColoresApp.textoPrimario,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4.0,
                        runSpacing: 4.0,
                        children: [
                          if (figura.componentes.leds.cantidad > 0)
                            _componenteChip(Icons.lightbulb_outline, ColoresApp.verdeAcento),
                          if (figura.componentes.musica.disponible)
                            _componenteChip(Icons.music_note_outlined, ColoresApp.cyanPrimario),
                          if (figura.componentes.humidificador.disponible)
                            _componenteChip(Icons.cloud_outlined, ColoresApp.azulPrimario),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () => _mostrarDialogoEditarFigura(figura),
                            icon: const Icon(
                              Icons.edit,
                              size: 20,
                              color: ColoresApp.cyanPrimario,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'Editar',
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _confirmarEliminarFigura(figura),
                            icon: const Icon(
                              Icons.delete_forever,
                              size: 20,
                              color: ColoresApp.error,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'Eliminar',
                          ),
                        ],
                      ),
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

  Widget _componenteChip(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }

  void _mostrarDialogoCrearFigura({String? tipoInicial}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _DialogoFigura(
        titulo: 'Crear Figura',
        tipoInicial: tipoInicial,
        onGuardar: (figuraData) async {
          setState(() => _cargando = true);
          try {
            final exito = await _crearFigura(figuraData);
            if (exito && mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Figura creada exitosamente'),
                  backgroundColor: ColoresApp.exito,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ Error creando: ${e.toString()}'),
                  backgroundColor: ColoresApp.error,
                ),
              );
            }
          } finally {
            if (mounted) setState(() => _cargando = false);
          }
        },
      ),
    );
  }

  void _mostrarDialogoEditarFigura(Figura figura) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _DialogoFigura(
        titulo: 'Editar Figura',
        figura: figura,
        onGuardar: (figuraData) async {
          setState(() => _cargando = true);
          try {
            final exito = await _editarFigura(figura, figuraData);
            if (exito && mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Figura actualizada exitosamente'),
                  backgroundColor: ColoresApp.exito,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ Error editando: ${e.toString()}'),
                  backgroundColor: ColoresApp.error,
                ),
              );
            }
          } finally {
            if (mounted) setState(() => _cargando = false);
          }
        },
      ),
    );
  }

  Future<void> _confirmarEliminarFigura(Figura figura) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColoresApp.tarjetaOscura,
        title: const Text('Confirmar Eliminación', style: TextStyle(color: ColoresApp.textoPrimario)),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${figura.nombre}"?\n\nEsta acción no se puede deshacer.',
          style: const TextStyle(color: ColoresApp.textoSecundario),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: ColoresApp.textoSecundario)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: ColoresApp.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _cargando = true);
    try {
      final List<Future<void>> deleteFutures = [];
      if (figura.imagenSeleccionPublicId.isNotEmpty) {
        deleteFutures.add(_cloudinaryService.eliminarImagen(figura.imagenSeleccionPublicId));
      }
      for (final publicId in figura.imagenesExtraPublicIds) {
        if (publicId.isNotEmpty) {
          deleteFutures.add(_cloudinaryService.eliminarImagen(publicId));
        }
      }
      await Future.wait(deleteFutures);

      final exito = await _firebaseService.eliminarFiguraPermanente(figura.id);

      if (!exito) throw Exception('No se pudo eliminar la figura de la base de datos.');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Figura eliminada exitosamente'),
            backgroundColor: ColoresApp.exito,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error eliminando figura: ${e.toString()}'),
            backgroundColor: ColoresApp.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<bool> _crearFigura(Map<String, dynamic> figuraData) async {
    try {
      if (figuraData['imagenSeleccion'] == null) throw Exception('La imagen principal es obligatoria');

      String imagenSeleccionUrl = '';
      String imagenSeleccionPublicId = '';

      final response = await _cloudinaryService.subirImagenPublicidad(figuraData['imagenSeleccion']);
      if (response != null && response.secureUrl.isNotEmpty) {
        imagenSeleccionUrl = response.secureUrl;
        imagenSeleccionPublicId = response.publicId;
      } else {
        throw Exception('Error subiendo imagen principal a Cloudinary');
      }

      final List<String> imagenesExtraUrls = [];
      final List<String> imagenesExtraPublicIds = [];

      for (final imagen in (figuraData['imagenesExtra'] as List<XFile>)) {
        final extraResponse = await _cloudinaryService.subirImagenPublicidad(imagen);
        if (extraResponse != null && extraResponse.secureUrl.isNotEmpty) {
          imagenesExtraUrls.add(extraResponse.secureUrl);
          imagenesExtraPublicIds.add(extraResponse.publicId);
        }
      }

      final figura = Figura(
        id: '',
        nombre: figuraData['nombre'],
        tipo: figuraData['tipo'],
        descripcion: figuraData['descripcion'] ?? '',
        imagenSeleccion: imagenSeleccionUrl,
        imagenesExtra: imagenesExtraUrls,
        imagenSeleccionPublicId: imagenSeleccionPublicId,
        imagenesExtraPublicIds: imagenesExtraPublicIds,
        bluetoothConfig: ConfiguracionBluetooth(
          tipoModulo: figuraData['bluetoothTipo'] ?? 'classic',
          nombreDispositivo: figuraData['bluetoothNombre'],
        ),
        componentes: ComponentesFigura(
          leds: ConfiguracionLeds(
            cantidad: figuraData['ledsQuantity'] ?? 0,
            nombres: List<String>.from(figuraData['ledsNombres'] ?? []),
          ),
          musica: ConfiguracionMusica(
            disponible: figuraData['musicaDisponible'] ?? false,
            cantidad: figuraData['musicaQuantity'] ?? 0,
            canciones: List<String>.from(figuraData['musicaNombres'] ?? []),
          ),
          humidificador: ConfiguracionHumidificador(
            disponible: figuraData['humoDisponible'] ?? false,
          ),
        ),
        activo: true,
        fechaCreacion: DateTime.now(),
      );

      final figuraId = await _firebaseService.crearFigura(figura);
      return figuraId != null;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> _editarFigura(Figura figuraActual, Map<String, dynamic> figuraData) async {
    try {
      String imagenSeleccionUrl = figuraActual.imagenSeleccion;
      String imagenSeleccionPublicId = figuraActual.imagenSeleccionPublicId;

      if (figuraData['imagenSeleccion'] != null) {
        if (figuraActual.imagenSeleccionPublicId.isNotEmpty) {
          await _cloudinaryService.eliminarImagen(figuraActual.imagenSeleccionPublicId);
        }
        final response = await _cloudinaryService.subirImagenPublicidad(figuraData['imagenSeleccion']);
        if (response != null && response.secureUrl.isNotEmpty) {
          imagenSeleccionUrl = response.secureUrl;
          imagenSeleccionPublicId = response.publicId;
        }
      }

      final List<XFile> nuevasImagenesExtra = figuraData['imagenesExtra'] as List<XFile>;
      List<String> urlsFinales = [];
      List<String> idsFinales = [];

      urlsFinales.addAll(figuraData['imagenesExtraUrlExistentes']);

      for (final imagen in nuevasImagenesExtra) {
        final extraResponse = await _cloudinaryService.subirImagenPublicidad(imagen);
        if (extraResponse != null && extraResponse.secureUrl.isNotEmpty) {
          urlsFinales.add(extraResponse.secureUrl);
          idsFinales.add(extraResponse.publicId);
        }
      }

      final figuraActualizada = figuraActual.copiarCon(
        nombre: figuraData['nombre'],
        tipo: figuraData['tipo'],
        descripcion: figuraData['descripcion'] ?? '',
        imagenSeleccion: imagenSeleccionUrl,
        imagenesExtra: urlsFinales,
        imagenSeleccionPublicId: imagenSeleccionPublicId,
        imagenesExtraPublicIds: idsFinales,
        bluetoothConfig: ConfiguracionBluetooth(
          tipoModulo: figuraData['bluetoothTipo'] ?? 'classic',
          nombreDispositivo: figuraData['bluetoothNombre'],
        ),
        componentes: ComponentesFigura(
          leds: ConfiguracionLeds(
            cantidad: figuraData['ledsQuantity'] ?? 0,
            nombres: List<String>.from(figuraData['ledsNombres'] ?? []),
          ),
          musica: ConfiguracionMusica(
            disponible: figuraData['musicaDisponible'] ?? false,
            cantidad: figuraData['musicaQuantity'] ?? 0,
            canciones: List<String>.from(figuraData['musicaNombres'] ?? []),
          ),
          humidificador: ConfiguracionHumidificador(
            disponible: figuraData['humoDisponible'] ?? false,
          ),
        ),
      );

      return await _firebaseService.actualizarFigura(figuraActual.id, figuraActualizada);
    } catch (e) {
      rethrow;
    }
  }
}

class _DialogoFigura extends StatefulWidget {
  final String titulo;
  final Figura? figura;
  final String? tipoInicial;
  final Function(Map<String, dynamic>) onGuardar;

  const _DialogoFigura({
    required this.titulo,
    this.figura,
    this.tipoInicial,
    required this.onGuardar,
  });

  @override
  State<_DialogoFigura> createState() => _DialogoFiguraState();
}

class _DialogoFiguraState extends State<_DialogoFigura> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _bluetoothNombreController = TextEditingController();
  final _scrollController = ScrollController();

  String _tipoSeleccionado = 'nave';
  String _bluetoothTipo = 'classic';
  int _ledsQuantity = 0;
  bool _musicaDisponible = false;
  int _musicaQuantity = 0;
  bool _humoDisponible = false;

  List<TextEditingController> _ledsNombresControllers = [];
  List<TextEditingController> _musicaNombresControllers = [];

  XFile? _imagenSeleccion;
  final List<XFile> _imagenesExtra = [];

  String? _imagenSeleccionUrlExistente;
  List<String> _imagenesExtraUrlExistentes = [];

  final ImagePicker _imagePicker = ImagePicker();
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _inicializarFormulario();
  }

  void _inicializarFormulario() {
    if (widget.figura != null) {
      final f = widget.figura!;
      _nombreController.text = f.nombre;
      _descripcionController.text = f.descripcion;
      _bluetoothNombreController.text = f.bluetoothConfig.nombreDispositivo;
      _tipoSeleccionado = f.tipo;
      _bluetoothTipo = f.bluetoothConfig.tipoModulo;
      _ledsQuantity = f.componentes.leds.cantidad;
      _musicaDisponible = f.componentes.musica.disponible;
      _musicaQuantity = f.componentes.musica.cantidad;
      _humoDisponible = f.componentes.humidificador.disponible;

      _imagenSeleccionUrlExistente = f.imagenSeleccion;
      _imagenesExtraUrlExistentes = List.from(f.imagenesExtra);

      _ledsNombresControllers = f.componentes.leds.nombres.map((nombre) => TextEditingController(text: nombre)).toList();
      _musicaNombresControllers = f.componentes.musica.canciones.map((nombre) => TextEditingController(text: nombre)).toList();
    } else {
      _tipoSeleccionado = widget.tipoInicial ?? 'nave';
    }
  }

  void _actualizarControladores(List<TextEditingController> controllers, int nuevaCantidad, String prefijo) {
    if (nuevaCantidad == controllers.length) return;

    while (nuevaCantidad < controllers.length) {
      controllers.removeLast().dispose();
    }
    while (nuevaCantidad > controllers.length) {
      controllers.add(TextEditingController(text: '$prefijo ${controllers.length + 1}'));
    }
    setState(() {});
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _bluetoothNombreController.dispose();
    _scrollController.dispose();
    for (var controller in _ledsNombresControllers) {
      controller.dispose();
    }
    for (var controller in _musicaNombresControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 600;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(isLargeScreen ? 24 : 12),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          width: isLargeScreen ? 600 : double.infinity,
          height: screenSize.height * 0.9,
          decoration: BoxDecoration(
            color: ColoresApp.tarjetaOscura,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColoresApp.bordeGris),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _construirHeader(),
                Expanded(
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _construirSeccionBasica(),
                          const SizedBox(height: 24),
                          _construirSeccionBluetooth(),
                          const SizedBox(height: 24),
                          _construirSeccionImagenes(),
                          const SizedBox(height: 24),
                          _construirSeccionComponentes(),
                        ],
                      ),
                    ),
                  ),
                ),
                _construirFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ColoresApp.superficieOscura,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(widget.figura == null ? Icons.add_box : Icons.edit, color: ColoresApp.cyanPrimario),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.titulo,
              style: const TextStyle(color: ColoresApp.textoPrimario, fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: ColoresApp.textoSecundario),
          ),
        ],
      ),
    );
  }

  Widget _construirFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.superficieOscura,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        border: Border(top: BorderSide(color: ColoresApp.bordeGris)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _guardando ? null : _guardarFigura,
              icon: _guardando
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Icon(Icons.save, size: 18),
              label: Text(_guardando ? 'Guardando...' : 'Guardar'),
              style: ElevatedButton.styleFrom(backgroundColor: ColoresApp.cyanPrimario),
            ),
          ),
        ],
      ),
    );
  }

  Widget _seccion(String titulo, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(color: ColoresApp.textoPrimario, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _construirSeccionBasica() {
    return _seccion('Información Básica', [
      DropdownButtonFormField<String>(
        value: _tipoSeleccionado,
        style: const TextStyle(color: ColoresApp.textoPrimario),
        decoration: const InputDecoration(
          labelText: 'Tipo',
          prefixIcon: Icon(Icons.category, color: ColoresApp.cyanPrimario),
        ),
        dropdownColor: ColoresApp.tarjetaOscura,
        items: const [
          DropdownMenuItem(value: 'nave', child: Text('Nave')),
          DropdownMenuItem(value: 'diorama', child: Text('Diorama')),
        ],
        onChanged: (value) => setState(() => _tipoSeleccionado = value ?? 'nave'),
        validator: (value) => value == null ? 'Selecciona un tipo' : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _nombreController,
        style: const TextStyle(color: ColoresApp.textoPrimario),
        decoration: const InputDecoration(
          labelText: 'Nombre',
          prefixIcon: Icon(Icons.title, color: ColoresApp.cyanPrimario),
        ),
        validator: (v) => v == null || v.trim().isEmpty ? 'El nombre es obligatorio' : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _descripcionController,
        style: const TextStyle(color: ColoresApp.textoPrimario),
        decoration: const InputDecoration(
          labelText: 'Descripción (Opcional)',
          prefixIcon: Icon(Icons.description, color: ColoresApp.cyanPrimario),
        ),
        maxLines: 3,
      ),
    ]);
  }

  Widget _construirSeccionBluetooth() {
    return _seccion('Configuración Bluetooth', [
      DropdownButtonFormField<String>(
        value: _bluetoothTipo,
        style: const TextStyle(color: ColoresApp.textoPrimario),
        decoration: const InputDecoration(
          labelText: 'Tipo de Módulo',
          prefixIcon: Icon(Icons.bluetooth, color: ColoresApp.cyanPrimario),
        ),
        dropdownColor: ColoresApp.tarjetaOscura,
        items: const [
          DropdownMenuItem(value: 'classic', child: Text('Bluetooth Classic (HC-05/06)')),
          DropdownMenuItem(value: 'ble', child: Text('Bluetooth Low Energy (BLE)')),
        ],
        onChanged: (value) => setState(() => _bluetoothTipo = value ?? 'classic'),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _bluetoothNombreController,
        style: const TextStyle(color: ColoresApp.textoPrimario),
        decoration: const InputDecoration(
          labelText: 'Nombre del Dispositivo',
          hintText: 'HC05_MiFigura',
          prefixIcon: Icon(Icons.devices, color: ColoresApp.cyanPrimario),
        ),
        validator: (v) => v == null || v.trim().isEmpty ? 'El nombre del dispositivo es obligatorio' : null,
      ),
    ]);
  }

  Widget _construirSeccionImagenes() {
    return _seccion('Imágenes', [
      const Text('Imagen de Selección (Catálogo)', style: TextStyle(color: ColoresApp.textoSecundario)),
      const SizedBox(height: 8),
      _construirSelectorImagenPrincipal(),
      const SizedBox(height: 16),
      const Text('Imágenes Extra (Hasta 2)', style: TextStyle(color: ColoresApp.textoSecundario)),
      const SizedBox(height: 8),
      _construirSelectorImagenesExtra(),
    ]);
  }

  Widget _construirSelectorImagenPrincipal() {
    return GestureDetector(
      onTap: () async {
        final imagen = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 1024);
        if (imagen != null)
          setState(() {
            _imagenSeleccion = imagen;
            _imagenSeleccionUrlExistente = null;
          });
      },
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: ColoresApp.superficieOscura,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColoresApp.bordeGris, style: BorderStyle.solid),
        ),
        child: _imagenSeleccion != null
            ? _buildImagePreview(Image.file(File(_imagenSeleccion!.path), fit: BoxFit.cover), () => setState(() => _imagenSeleccion = null))
            : _imagenSeleccionUrlExistente != null && _imagenSeleccionUrlExistente!.isNotEmpty
            ? _buildImagePreview(CachedNetworkImage(imageUrl: _imagenSeleccionUrlExistente!, fit: BoxFit.cover), () => setState(() => _imagenSeleccionUrlExistente = null))
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _construirSelectorImagenesExtra() {
    return Column(
      children: [
        if (_imagenesExtra.isNotEmpty || _imagenesExtraUrlExistentes.isNotEmpty)
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ..._imagenesExtraUrlExistentes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final url = entry.value;
                  return _buildExtraImagePreview(
                    CachedNetworkImage(imageUrl: url, width: 80, height: 80, fit: BoxFit.cover),
                        () => setState(() => _imagenesExtraUrlExistentes.removeAt(index)),
                  );
                }),
                ..._imagenesExtra.asMap().entries.map((entry) {
                  final index = entry.key;
                  final file = entry.value;
                  return _buildExtraImagePreview(
                    Image.file(File(file.path), width: 80, height: 80, fit: BoxFit.cover),
                        () => setState(() => _imagenesExtra.removeAt(index)),
                  );
                }),
              ],
            ),
          ),
        if (_imagenesExtra.length + _imagenesExtraUrlExistentes.length < 2)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final imagen = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 1024);
                  if (imagen != null) setState(() => _imagenesExtra.add(imagen));
                },
                icon: const Icon(Icons.add_a_photo_outlined),
                label: Text('Agregar Imagen Extra (${_imagenesExtra.length + _imagenesExtraUrlExistentes.length}/2)'),
                style: ElevatedButton.styleFrom(backgroundColor: ColoresApp.bordeGris, foregroundColor: ColoresApp.textoPrimario),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImagePreview(Widget imageWidget, VoidCallback onRemove) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(11),
      child: Stack(
        fit: StackFit.expand,
        children: [
          imageWidget,
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtraImagePreview(Widget imageWidget, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      width: 80,
      height: 80,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            imageWidget,
            Positioned(
              top: 2,
              right: 2,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined, size: 40, color: ColoresApp.textoApagado),
        SizedBox(height: 8),
        Text('Tocar para seleccionar imagen', style: TextStyle(color: ColoresApp.textoApagado)),
      ],
    );
  }

  Widget _construirSeccionComponentes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Componentes', style: TextStyle(color: ColoresApp.textoPrimario, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        _buildComponenteLEDs(),
        const SizedBox(height: 16),
        _buildComponenteMusica(),
        const SizedBox(height: 16),
        _construirComponenteContainer(
          icono: Icons.cloud,
          titulo: 'Humidificador (Humo)',
          color: ColoresApp.azulPrimario,
          switchValue: _humoDisponible,
          onSwitchChanged: (value) => setState(() => _humoDisponible = value),
          child: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildComponenteLEDs() {
    return _construirComponenteContainer(
      icono: Icons.lightbulb,
      titulo: 'LEDs',
      color: ColoresApp.verdeAcento,
      child: Column(
        children: [
          DropdownButtonFormField<int>(
            value: _ledsQuantity,
            decoration: const InputDecoration(labelText: 'Cantidad de LEDs'),
            dropdownColor: ColoresApp.tarjetaOscura,
            items: List.generate(6, (i) => DropdownMenuItem(value: i, child: Text(i == 0 ? 'Sin LEDs' : '$i LED${i > 1 ? 's' : ''}'))),
            onChanged: (value) {
              setState(() {
                _ledsQuantity = value ?? 0;
                _actualizarControladores(_ledsNombresControllers, _ledsQuantity, 'LED');
              });
            },
          ),
          if (_ledsQuantity > 0) ...[
            const SizedBox(height: 16),
            ...List.generate(_ledsQuantity, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextFormField(
                controller: _ledsNombresControllers[i],
                style: const TextStyle(color: ColoresApp.textoPrimario),
                decoration: InputDecoration(
                  labelText: 'Nombre LED ${i + 1}',
                  isDense: true,
                  prefixIcon: const Icon(Icons.label_important_outline, size: 20),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'El nombre es requerido' : null,
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildComponenteMusica() {
    return _construirComponenteContainer(
      icono: Icons.music_note,
      titulo: 'Música',
      color: ColoresApp.cyanPrimario,
      switchValue: _musicaDisponible,
      onSwitchChanged: (value) {
        setState(() {
          _musicaDisponible = value;
          if (_musicaDisponible && _musicaQuantity == 0) {
            _musicaQuantity = 1;
          }
          _actualizarControladores(_musicaNombresControllers, _musicaDisponible ? _musicaQuantity : 0, 'Canción');
        });
      },
      child: !_musicaDisponible
          ? const SizedBox.shrink()
          : Column(
        children: [
          DropdownButtonFormField<int>(
            value: _musicaQuantity,
            decoration: const InputDecoration(labelText: 'Cantidad de Canciones'),
            dropdownColor: ColoresApp.tarjetaOscura,
            items: List.generate(5, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1} Canción${i > 0 ? 'es' : ''}'))),
            onChanged: (value) {
              setState(() {
                _musicaQuantity = value ?? 1;
                _actualizarControladores(_musicaNombresControllers, _musicaQuantity, 'Canción');
              });
            },
          ),
          if (_musicaQuantity > 0) ...[
            const SizedBox(height: 16),
            ...List.generate(_musicaQuantity, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextFormField(
                controller: _musicaNombresControllers[i],
                style: const TextStyle(color: ColoresApp.textoPrimario),
                decoration: InputDecoration(
                  labelText: 'Nombre Canción ${i + 1}',
                  isDense: true,
                  prefixIcon: const Icon(Icons.label_important_outline, size: 20),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'El nombre es requerido' : null,
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _construirComponenteContainer({
    required IconData icono,
    required String titulo,
    required Color color,
    required Widget child,
    bool? switchValue,
    Function(bool)? onSwitchChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.superficieOscura,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: color),
              const SizedBox(width: 8),
              Expanded(child: Text(titulo, style: const TextStyle(color: ColoresApp.textoPrimario, fontWeight: FontWeight.w600))),
              if (switchValue != null && onSwitchChanged != null)
                Switch(
                  value: switchValue,
                  onChanged: onSwitchChanged,
                  activeColor: color,
                ),
            ],
          ),
          if (child is! SizedBox) const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  void _guardarFigura() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imagenSeleccion == null && (_imagenSeleccionUrlExistente == null || _imagenSeleccionUrlExistente!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La imagen de selección es obligatoria'),
          backgroundColor: ColoresApp.error,
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    final figuraData = {
      'nombre': _nombreController.text.trim(),
      'tipo': _tipoSeleccionado,
      'descripcion': _descripcionController.text.trim(),
      'bluetoothTipo': _bluetoothTipo,
      'bluetoothNombre': _bluetoothNombreController.text.trim(),
      'imagenSeleccion': _imagenSeleccion,
      'imagenesExtra': _imagenesExtra,
      'imagenesExtraUrlExistentes': _imagenesExtraUrlExistentes,
      'ledsQuantity': _ledsQuantity,
      'ledsNombres': _ledsNombresControllers.map((c) => c.text.trim()).toList(),
      'musicaDisponible': _musicaDisponible,
      'musicaQuantity': _musicaQuantity,
      'musicaNombres': _musicaNombresControllers.map((c) => c.text.trim()).toList(),
      'humoDisponible': _humoDisponible,
    };

    try {
      await widget.onGuardar(figuraData);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }
}

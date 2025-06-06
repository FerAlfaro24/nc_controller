// Archivo: lib/pantallas/gestion_figuras_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../servicios/cloudinary_service.dart';
import '../servicios/firebase_service.dart';
import '../modelos/figura.dart';
import '../nucleo/constantes/colores_app.dart';
import '../widgets/auto_scrolling_text.dart';

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
            childAspectRatio: 0.75,
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
          border: Border.all(color: ColoresApp.bordeGris),
          boxShadow: [
            BoxShadow(
              color: ColoresApp.cyanPrimario.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: figura.imagenSeleccion.isNotEmpty
                      ? CachedNetworkImage(
                    imageUrl: figura.imagenSeleccion,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: ColoresApp.superficieOscura,
                      child: const Center(
                        child: CircularProgressIndicator(color: ColoresApp.cyanPrimario),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: ColoresApp.superficieOscura,
                      child: const Center(
                        child: Icon(Icons.error, color: ColoresApp.error),
                      ),
                    ),
                  )
                      : Container(
                    color: ColoresApp.superficieOscura,
                    child: Icon(
                      figura.tipo == 'nave' ? Icons.rocket : Icons.landscape,
                      size: 32,
                      color: ColoresApp.textoApagado,
                    ),
                  ),
                ),
              ),
            ),

            // Información
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre con auto-scroll
                    AutoScrollingText(
                      text: figura.nombre,
                      style: const TextStyle(
                        color: ColoresApp.textoPrimario,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      duration: const Duration(seconds: 3),
                    ),
                    const SizedBox(height: 4),

                    // Tipo y Bluetooth
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: figura.tipo == 'nave'
                                ? ColoresApp.azulPrimario.withOpacity(0.2)
                                : ColoresApp.verdeAcento.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            figura.tipo.toUpperCase(),
                            style: TextStyle(
                              color: figura.tipo == 'nave' ? ColoresApp.azulPrimario : ColoresApp.verdeAcento,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: figura.bluetoothConfig.tipoModulo == 'ble'
                                ? ColoresApp.moradoPrimario.withOpacity(0.2)
                                : ColoresApp.naranjaAcento.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            figura.bluetoothConfig.tipoModulo.toUpperCase(),
                            style: TextStyle(
                              color: figura.bluetoothConfig.tipoModulo == 'ble'
                                  ? ColoresApp.moradoPrimario
                                  : ColoresApp.naranjaAcento,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Iconos de componentes
                    Row(
                      children: [
                        if (figura.componentes.leds.cantidad > 0) ...[
                          Icon(Icons.lightbulb, size: 16, color: ColoresApp.verdeAcento),
                          Text(
                            '${figura.componentes.leds.cantidad}',
                            style: const TextStyle(color: ColoresApp.textoSecundario, fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (figura.componentes.musica.disponible) ...[
                          Icon(Icons.music_note, size: 16, color: ColoresApp.cyanPrimario),
                          Text(
                            '${figura.componentes.musica.cantidad}',
                            style: const TextStyle(color: ColoresApp.textoSecundario, fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (figura.componentes.humidificador.disponible)
                          Icon(Icons.cloud, size: 16, color: ColoresApp.azulPrimario),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Botones de acción
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _mostrarDialogoEditarFigura(figura),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Editar', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(foregroundColor: ColoresApp.cyanPrimario),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _confirmarEliminarFigura(figura),
                    icon: const Icon(Icons.delete, size: 18, color: ColoresApp.error),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
                  content: Text('❌ Error: $e'),
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
            final exito = await _editarFigura(figura.id, figuraData);
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
                  content: Text('❌ Error: $e'),
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

    if (confirmar == true) {
      try {
        setState(() => _cargando = true);
        await _eliminarFigura(figura);
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
              content: Text('❌ Error eliminando figura: $e'),
              backgroundColor: ColoresApp.error,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _cargando = false);
      }
    }
  }

  Future<bool> _crearFigura(Map<String, dynamic> figuraData) async {
    try {
      // Subir imágenes a Cloudinary
      final imagenSeleccionUrl = await _subirImagen(figuraData['imagenSeleccion']);
      final imagenesExtraUrls = await _subirImagenesExtra(figuraData['imagenesExtra']);

      // Crear figura
      final figura = Figura(
        id: '',
        nombre: figuraData['nombre'],
        tipo: figuraData['tipo'],
        descripcion: figuraData['descripcion'] ?? '',
        imagenSeleccion: imagenSeleccionUrl['url'] ?? '',
        imagenesExtra: imagenesExtraUrls.map((img) => img['url'] as String).toList(),
        imagenSeleccionPublicId: imagenSeleccionUrl['publicId'] ?? '',
        imagenesExtraPublicIds: imagenesExtraUrls.map((img) => img['publicId'] as String).toList(),
        bluetoothConfig: ConfiguracionBluetooth(
          tipoModulo: figuraData['bluetoothTipo'],
          nombreDispositivo: figuraData['bluetoothNombre'],
        ),
        componentes: ComponentesFigura(
          leds: ConfiguracionLeds(
            cantidad: figuraData['ledsQuantity'],
            nombres: List<String>.from(figuraData['ledsNombres'] ?? []),
          ),
          musica: ConfiguracionMusica(
            disponible: figuraData['musicaDisponible'],
            cantidad: figuraData['musicaQuantity'] ?? 0,
            canciones: List<String>.from(figuraData['musicaNombres'] ?? []),
          ),
          humidificador: ConfiguracionHumidificador(
            disponible: figuraData['humoDisponible'],
          ),
        ),
        activo: true,
        fechaCreacion: DateTime.now(),
      );

      final figuraId = await _firebaseService.crearFigura(figura);
      return figuraId != null;
    } catch (e) {
      print('Error creando figura: $e');
      return false;
    }
  }

  Future<bool> _editarFigura(String figuraId, Map<String, dynamic> figuraData) async {
    // Similar a _crearFigura pero actualizando
    // Implementar lógica de actualización
    return true;
  }

  Future<void> _eliminarFigura(Figura figura) async {
    // Eliminar imágenes de Cloudinary
    if (figura.imagenSeleccionPublicId.isNotEmpty) {
      await _cloudinaryService.eliminarImagen(figura.imagenSeleccionPublicId);
    }
    for (final publicId in figura.imagenesExtraPublicIds) {
      if (publicId.isNotEmpty) {
        await _cloudinaryService.eliminarImagen(publicId);
      }
    }

    // Eliminar de Firestore
    // Implementar eliminación en FirebaseService
  }

  Future<Map<String, String>> _subirImagen(XFile? imagen) async {
    if (imagen == null) return {'url': '', 'publicId': ''};

    final response = await _cloudinaryService.subirImagenPublicidad(imagen);
    return {
      'url': response?.secureUrl ?? '',
      'publicId': response?.publicId ?? '',
    };
  }

  Future<List<Map<String, String>>> _subirImagenesExtra(List<XFile> imagenes) async {
    final List<Map<String, String>> resultados = [];

    for (final imagen in imagenes) {
      final resultado = await _subirImagen(imagen);
      resultados.add(resultado);
    }

    return resultados;
  }
}

// Widget separado para el diálogo de crear/editar figura
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

  String _tipoSeleccionado = 'nave';
  String _bluetoothTipo = 'classic';
  int _ledsQuantity = 1;
  bool _musicaDisponible = false;
  int _musicaQuantity = 0;
  bool _humoDisponible = false;

  List<String> _ledsNombres = [];
  List<String> _musicaNombres = [];

  XFile? _imagenSeleccion;
  List<XFile> _imagenesExtra = [];

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _inicializarFormulario();
  }

  void _inicializarFormulario() {
    if (widget.figura != null) {
      // Edición: cargar datos existentes
      final figura = widget.figura!;
      _nombreController.text = figura.nombre;
      _descripcionController.text = figura.descripcion;
      _bluetoothNombreController.text = figura.bluetoothConfig.nombreDispositivo;
      _tipoSeleccionado = figura.tipo;
      _bluetoothTipo = figura.bluetoothConfig.tipoModulo;
      _ledsQuantity = figura.componentes.leds.cantidad;
      _musicaDisponible = figura.componentes.musica.disponible;
      _musicaQuantity = figura.componentes.musica.cantidad;
      _humoDisponible = figura.componentes.humidificador.disponible;
      _ledsNombres = List.from(figura.componentes.leds.nombres);
      _musicaNombres = List.from(figura.componentes.musica.canciones);
    } else {
      // Creación: valores por defecto
      _tipoSeleccionado = widget.tipoInicial ?? 'nave';
      _ledsNombres = ['LED 1'];
      _inicializarNombresLeds();
    }
  }

  void _inicializarNombresLeds() {
    _ledsNombres = List.generate(_ledsQuantity, (index) => 'LED ${index + 1}');
  }

  void _inicializarNombresMusica() {
    _musicaNombres = List.generate(_musicaQuantity, (index) => 'Canción ${index + 1}');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _bluetoothNombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700, maxWidth: 500),
        decoration: BoxDecoration(
          color: ColoresApp.tarjetaOscura,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColoresApp.bordeGris),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColoresApp.cyanPrimario.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(Icons.add_box, color: ColoresApp.cyanPrimario),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.titulo,
                      style: const TextStyle(
                        color: ColoresApp.textoPrimario,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: ColoresApp.textoSecundario),
                  ),
                ],
              ),
            ),

            // Formulario
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _construirSeccionBasica(),
                      const SizedBox(height: 20),
                      _construirSeccionBluetooth(),
                      const SizedBox(height: 20),
                      _construirSeccionImagenes(),
                      const SizedBox(height: 20),
                      _construirSeccionComponentes(),
                    ],
                  ),
                ),
              ),
            ),

            // Botones de acción
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
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
                    child: ElevatedButton(
                      onPressed: _guardarFigura,
                      style: ElevatedButton.styleFrom(backgroundColor: ColoresApp.cyanPrimario),
                      child: const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirSeccionBasica() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'INFORMACIÓN BÁSICA',
          style: TextStyle(
            color: ColoresApp.textoPrimario,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Tipo
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

        // Nombre
        TextFormField(
          controller: _nombreController,
          style: const TextStyle(color: ColoresApp.textoPrimario),
          decoration: const InputDecoration(
            labelText: 'Nombre',
            prefixIcon: Icon(Icons.title, color: ColoresApp.cyanPrimario),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre es obligatorio';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Descripción
        TextFormField(
          controller: _descripcionController,
          style: const TextStyle(color: ColoresApp.textoPrimario),
          decoration: const InputDecoration(
            labelText: 'Descripción (Opcional)',
            prefixIcon: Icon(Icons.description, color: ColoresApp.cyanPrimario),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _construirSeccionBluetooth() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CONFIGURACIÓN BLUETOOTH',
          style: TextStyle(
            color: ColoresApp.textoPrimario,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Tipo Bluetooth
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

        // Nombre dispositivo
        TextFormField(
          controller: _bluetoothNombreController,
          style: const TextStyle(color: ColoresApp.textoPrimario),
          decoration: const InputDecoration(
            labelText: 'Nombre del Dispositivo',
            hintText: 'HC05_MiFigura',
            prefixIcon: Icon(Icons.devices, color: ColoresApp.cyanPrimario),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre del dispositivo es obligatorio';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _construirSeccionImagenes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'IMÁGENES',
          style: TextStyle(
            color: ColoresApp.textoPrimario,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Imagen de selección
        const Text(
          'Imagen de Selección (Catálogo)',
          style: TextStyle(color: ColoresApp.textoSecundario, fontSize: 14),
        ),
        const SizedBox(height: 8),
        _construirSelectorImagen(
          imagen: _imagenSeleccion,
          onSeleccionar: () async {
            final imagen = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (imagen != null) {
              setState(() => _imagenSeleccion = imagen);
            }
          },
          onEliminar: () => setState(() => _imagenSeleccion = null),
        ),
        const SizedBox(height: 16),

        // Imágenes extra
        const Text(
          'Imágenes Extra (Hasta 2)',
          style: TextStyle(color: ColoresApp.textoSecundario, fontSize: 14),
        ),
        const SizedBox(height: 8),
        _construirImagenesExtra(),
      ],
    );
  }

  Widget _construirSelectorImagen({
    required XFile? imagen,
    required VoidCallback onSeleccionar,
    required VoidCallback onEliminar,
  }) {
    return GestureDetector(
      onTap: onSeleccionar,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: ColoresApp.superficieOscura,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColoresApp.bordeGris, style: BorderStyle.dashed),
        ),
        child: imagen != null
            ? Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(imagen.path),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onEliminar,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: ColoresApp.error,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        )
            : const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 32, color: ColoresApp.textoApagado),
            SizedBox(height: 8),
            Text('Tocar para seleccionar imagen', style: TextStyle(color: ColoresApp.textoApagado)),
          ],
        ),
      ),
    );
  }

  Widget _construirImagenesExtra() {
    return Column(
      children: [
        // Mostrar imágenes seleccionadas
        if (_imagenesExtra.isNotEmpty)
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _imagenesExtra.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_imagenesExtra[index].path),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => setState(() => _imagenesExtra.removeAt(index)),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: ColoresApp.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

        // Botón para agregar más imágenes
        if (_imagenesExtra.length < 2)
          ElevatedButton.icon(
            onPressed: () async {
              final imagen = await _imagePicker.pickImage(source: ImageSource.gallery);
              if (imagen != null) {
                setState(() => _imagenesExtra.add(imagen));
              }
            },
            icon: const Icon(Icons.add),
            label: Text('Agregar Imagen Extra (${_imagenesExtra.length}/2)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColoresApp.bordeGris,
              foregroundColor: ColoresApp.textoPrimario,
            ),
          ),
      ],
    );
  }

  Widget _construirSeccionComponentes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'COMPONENTES',
          style: TextStyle(
            color: ColoresApp.textoPrimario,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        // LEDs
        _construirSeccionLeds(),
        const SizedBox(height: 20),

        // Música
        _construirSeccionMusica(),
        const SizedBox(height: 20),

        // Humidificador
        _construirSeccionHumidificador(),
      ],
    );
  }

  Widget _construirSeccionLeds() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.superficieOscura,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColoresApp.verdeAcento.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: ColoresApp.verdeAcento),
              const SizedBox(width: 8),
              const Text(
                'LEDs',
                style: TextStyle(color: ColoresApp.textoPrimario, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Cantidad de LEDs
          DropdownButtonFormField<int>(
            value: _ledsQuantity,
            style: const TextStyle(color: ColoresApp.textoPrimario),
            decoration: const InputDecoration(
              labelText: 'Cantidad de LEDs',
              border: OutlineInputBorder(),
            ),
            dropdownColor: ColoresApp.tarjetaOscura,
            items: List.generate(6, (index) => index)
                .map((value) => DropdownMenuItem(
              value: value,
              child: Text(value == 0 ? 'Sin LEDs' : '$value LED${value > 1 ? 's' : ''}'),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _ledsQuantity = value ?? 0;
                _inicializarNombresLeds();
              });
            },
          ),

          // Nombres de LEDs
          if (_ledsQuantity > 0) ...[
            const SizedBox(height: 12),
            const Text(
              'Nombres de los LEDs:',
              style: TextStyle(color: ColoresApp.textoSecundario, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ...List.generate(_ledsQuantity, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextFormField(
                  initialValue: _ledsNombres.length > index ? _ledsNombres[index] : 'LED ${index + 1}',
                  style: const TextStyle(color: ColoresApp.textoPrimario),
                  decoration: InputDecoration(
                    labelText: 'LED ${index + 1}',
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    if (_ledsNombres.length > index) {
                      _ledsNombres[index] = value;
                    } else {
                      _ledsNombres.add(value);
                    }
                  },
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _construirSeccionMusica() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.superficieOscura,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColoresApp.cyanPrimario.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.music_note, color: ColoresApp.cyanPrimario),
              const SizedBox(width: 8),
              const Text(
                'Música',
                style: TextStyle(color: ColoresApp.textoPrimario, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Switch(
                value: _musicaDisponible,
                onChanged: (value) => setState(() {
                  _musicaDisponible = value;
                  if (!value) {
                    _musicaQuantity = 0;
                    _musicaNombres.clear();
                  }
                }),
                activeColor: ColoresApp.cyanPrimario,
              ),
            ],
          ),

          if (_musicaDisponible) ...[
            const SizedBox(height: 12),

            // Cantidad de canciones
            DropdownButtonFormField<int>(
              value: _musicaQuantity,
              style: const TextStyle(color: ColoresApp.textoPrimario),
              decoration: const InputDecoration(
                labelText: 'Cantidad de Canciones',
                border: OutlineInputBorder(),
              ),
              dropdownColor: ColoresApp.tarjetaOscura,
              items: List.generate(6, (index) => index + 1)
                  .map((value) => DropdownMenuItem(
                value: value,
                child: Text('$value Canción${value > 1 ? 'es' : ''}'),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _musicaQuantity = value ?? 1;
                  _inicializarNombresMusica();
                });
              },
            ),

            // Nombres de canciones
            if (_musicaQuantity > 0) ...[
              const SizedBox(height: 12),
              const Text(
                'Nombres de las Canciones:',
                style: TextStyle(color: ColoresApp.textoSecundario, fontSize: 14),
              ),
              const SizedBox(height: 8),
              ...List.generate(_musicaQuantity, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextFormField(
                    initialValue: _musicaNombres.length > index ? _musicaNombres[index] : 'Canción ${index + 1}',
                    style: const TextStyle(color: ColoresApp.textoPrimario),
                    decoration: InputDecoration(
                      labelText: 'Canción ${index + 1}',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      if (_musicaNombres.length > index) {
                        _musicaNombres[index] = value;
                      } else {
                        _musicaNombres.add(value);
                      }
                    },
                  ),
                );
              }),
            ],
          ],
        ],
      ),
    );
  }

  Widget _construirSeccionHumidificador() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.superficieOscura,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColoresApp.azulPrimario.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud, color: ColoresApp.azulPrimario),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Humidificador (Humo)',
              style: TextStyle(color: ColoresApp.textoPrimario, fontWeight: FontWeight.w600),
            ),
          ),
          Switch(
            value: _humoDisponible,
            onChanged: (value) => setState(() => _humoDisponible = value),
            activeColor: ColoresApp.azulPrimario,
          ),
        ],
      ),
    );
  }

  void _guardarFigura() {
    if (!_formKey.currentState!.validate()) return;

    // Validaciones adicionales
    if (_imagenSeleccion == null && widget.figura?.imagenSeleccion.isEmpty != false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La imagen de selección es obligatoria'),
          backgroundColor: ColoresApp.error,
        ),
      );
      return;
    }

    final figuraData = {
      'nombre': _nombreController.text.trim(),
      'tipo': _tipoSeleccionado,
      'descripcion': _descripcionController.text.trim(),
      'bluetoothTipo': _bluetoothTipo,
      'bluetoothNombre': _bluetoothNombreController.text.trim(),
      'imagenSeleccion': _imagenSeleccion,
      'imagenesExtra': _imagenesExtra,
      'ledsQuantity': _ledsQuantity,
      'ledsNombres': _ledsNombres,
      'musicaDisponible': _musicaDisponible,
      'musicaQuantity': _musicaQuantity,
      'musicaNombres': _musicaNombres,
      'humoDisponible': _humoDisponible,
    };

    widget.onGuardar(figuraData);
  }
}
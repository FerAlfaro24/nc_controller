import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../servicios/cloudinary_service.dart';
import '../servicios/firebase_service.dart';
import '../modelos/configuracion_app.dart';
import '../nucleo/constantes/colores_app.dart';

class PantallaGestionPublicidad extends StatefulWidget {
  const PantallaGestionPublicidad({super.key});

  @override
  State<PantallaGestionPublicidad> createState() => _PantallaGestionPublicidadState();
}

class _PantallaGestionPublicidadState extends State<PantallaGestionPublicidad> {
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final FirebaseService _firebaseService = FirebaseService();
  final ImagePicker _imagePicker = ImagePicker();

  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _accionUrlController = TextEditingController();

  bool _cargando = false;
  bool _publicidadActiva = false;
  DateTime? _fechaExpiracion;

  ConfiguracionApp? _configuracionActual;
  XFile? _imagenSeleccionada;

  @override
  void initState() {
    super.initState();
    _cargarConfiguracion();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _accionUrlController.dispose();
    super.dispose();
  }

  Future<void> _cargarConfiguracion() async {
    setState(() => _cargando = true);

    try {
      // Escuchar cambios en la configuración
      _firebaseService.obtenerConfiguracion().listen((config) {
        if (mounted) {
          setState(() {
            _configuracionActual = config;
            _publicidadActiva = config.publicidadPush.activa;
            _tituloController.text = config.publicidadPush.titulo;
            _descripcionController.text = config.publicidadPush.descripcion;
            _accionUrlController.text = config.publicidadPush.accionUrl;
            _fechaExpiracion = config.publicidadPush.fechaExpiracion;
            _cargando = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _cargando = false);
        _mostrarError('Error cargando configuración: $e');
      }
    }
  }

  Future<void> _seleccionarImagen() async {
    try {
      final XFile? imagen = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (imagen != null) {
        setState(() => _imagenSeleccionada = imagen);
      }
    } catch (e) {
      _mostrarError('Error seleccionando imagen: $e');
    }
  }

  Future<void> _guardarPublicidad() async {
    if (!_validarFormulario()) return;

    setState(() => _cargando = true);

    try {
      String? imagenUrl;
      String? imagenPublicId;

      // Si hay una imagen seleccionada, subirla a Cloudinary
      if (_imagenSeleccionada != null) {
        final response = await _cloudinaryService.subirImagenPublicidad(_imagenSeleccionada!);

        if (response != null) {
          imagenUrl = response.secureUrl;
          imagenPublicId = response.publicId;

          // Si había una imagen anterior, eliminarla
          if (_configuracionActual?.publicidadPush.imagenPublicId.isNotEmpty == true) {
            await _cloudinaryService.eliminarImagen(_configuracionActual!.publicidadPush.imagenPublicId);
          }
        } else {
          throw Exception('Error subiendo imagen a Cloudinary');
        }
      } else {
        // Mantener imagen actual si no se seleccionó una nueva
        imagenUrl = _configuracionActual?.publicidadPush.imagenUrl ?? '';
        imagenPublicId = _configuracionActual?.publicidadPush.imagenPublicId ?? '';
      }

      // Crear nueva configuración de publicidad
      final nuevaPublicidad = PublicidadPush(
        activa: _publicidadActiva,
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        imagenUrl: imagenUrl,
        imagenPublicId: imagenPublicId,
        accionUrl: _accionUrlController.text.trim(),
        fechaCreacion: _configuracionActual?.publicidadPush.fechaCreacion ?? DateTime.now(),
        fechaExpiracion: _fechaExpiracion,
      );

      // Actualizar configuración en Firebase
      final nuevaConfiguracion = _configuracionActual?.copiarCon(
        publicidadPush: nuevaPublicidad,
      ) ?? ConfiguracionApp(
        textoMarquee: _configuracionActual?.textoMarquee ?? '¡Bienvenido a Naboo Customs!',
        publicidadPush: nuevaPublicidad,
        fechaActualizacion: DateTime.now(),
      );

      final exito = await _firebaseService.actualizarConfiguracion(nuevaConfiguracion);

      if (exito) {
        _mostrarExito('Publicidad guardada exitosamente');
        setState(() => _imagenSeleccionada = null);
      } else {
        throw Exception('Error guardando en Firebase');
      }
    } catch (e) {
      _mostrarError('Error guardando publicidad: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  bool _validarFormulario() {
    if (_tituloController.text.trim().isEmpty) {
      _mostrarError('El título es obligatorio');
      return false;
    }

    if (_descripcionController.text.trim().isEmpty) {
      _mostrarError('La descripción es obligatoria');
      return false;
    }

    if (_publicidadActiva && _imagenSeleccionada == null &&
        (_configuracionActual?.publicidadPush.imagenUrl.isEmpty ?? true)) {
      _mostrarError('Se requiere una imagen para activar la publicidad');
      return false;
    }

    return true;
  }

  Future<void> _eliminarPublicidad() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColoresApp.tarjetaOscura,
        title: const Text('Confirmar Eliminación', style: TextStyle(color: ColoresApp.textoPrimario)),
        content: const Text(
          '¿Estás seguro de que quieres eliminar la publicidad actual?',
          style: TextStyle(color: ColoresApp.textoSecundario),
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
      setState(() => _cargando = true);

      try {
        // Eliminar imagen de Cloudinary si existe
        if (_configuracionActual?.publicidadPush.imagenPublicId.isNotEmpty == true) {
          await _cloudinaryService.eliminarImagen(_configuracionActual!.publicidadPush.imagenPublicId);
        }

        // Limpiar formulario
        _tituloController.clear();
        _descripcionController.clear();
        _accionUrlController.clear();
        setState(() {
          _publicidadActiva = false;
          _fechaExpiracion = null;
          _imagenSeleccionada = null;
        });

        // Guardar configuración vacía
        await _guardarPublicidad();

        _mostrarExito('Publicidad eliminada exitosamente');
      } catch (e) {
        _mostrarError('Error eliminando publicidad: $e');
      } finally {
        if (mounted) setState(() => _cargando = false);
      }
    }
  }

  void _mostrarError(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: ColoresApp.error,
        ),
      );
    }
  }

  void _mostrarExito(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: ColoresApp.exito,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GESTIÓN DE PUBLICIDAD'),
        backgroundColor: ColoresApp.superficieOscura,
        actions: [
          if (!_cargando)
            IconButton(
              icon: const Icon(Icons.save, color: ColoresApp.verdeAcento),
              onPressed: _guardarPublicidad,
            ),
          if (_configuracionActual?.publicidadPush.imagenUrl.isNotEmpty == true)
            IconButton(
              icon: const Icon(Icons.delete, color: ColoresApp.error),
              onPressed: _eliminarPublicidad,
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: ColoresApp.gradienteFondo),
        child: _cargando
            ? const Center(child: CircularProgressIndicator(color: ColoresApp.cyanPrimario))
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _construirSwitchActivo(),
              const SizedBox(height: 24),
              _construirSeccionImagen(),
              const SizedBox(height: 24),
              _construirFormulario(),
              const SizedBox(height: 24),
              _construirSeccionExpiracion(),
              const SizedBox(height: 32),
              _construirPreview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirSwitchActivo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.tarjetaOscura,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColoresApp.bordeGris),
      ),
      child: Row(
        children: [
          Icon(
            _publicidadActiva ? Icons.campaign : Icons.campaign_outlined,
            color: _publicidadActiva ? ColoresApp.verdeAcento : ColoresApp.textoApagado,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Publicidad Activa',
                  style: TextStyle(
                    color: ColoresApp.textoPrimario,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _publicidadActiva
                      ? 'La publicidad se mostrará a los usuarios'
                      : 'La publicidad está desactivada',
                  style: const TextStyle(
                    color: ColoresApp.textoSecundario,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _publicidadActiva,
            onChanged: (value) => setState(() => _publicidadActiva = value),
            activeColor: ColoresApp.verdeAcento,
          ),
        ],
      ),
    );
  }

  Widget _construirSeccionImagen() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.tarjetaOscura,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColoresApp.bordeGris),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.image, color: ColoresApp.cyanPrimario),
              const SizedBox(width: 8),
              const Text(
                'Imagen de Publicidad',
                style: TextStyle(
                  color: ColoresApp.textoPrimario,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _seleccionarImagen,
                icon: const Icon(Icons.upload, size: 18),
                label: const Text('Seleccionar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColoresApp.cyanPrimario,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Preview de imagen
          if (_imagenSeleccionada != null || _configuracionActual?.publicidadPush.imagenUrl.isNotEmpty == true)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ColoresApp.bordeGris),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _imagenSeleccionada != null
                    ? Image.file(
                  File(_imagenSeleccionada!.path),
                  fit: BoxFit.cover,
                )
                    : CachedNetworkImage(
                  imageUrl: _configuracionActual!.publicidadPush.imagenUrl,
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
                ),
              ),
            )
          else
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: ColoresApp.superficieOscura,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ColoresApp.bordeGris, style: BorderStyle.solid),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported, size: 48, color: ColoresApp.textoApagado),
                  SizedBox(height: 8),
                  Text(
                    'No hay imagen seleccionada',
                    style: TextStyle(color: ColoresApp.textoApagado),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _construirFormulario() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.tarjetaOscura,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColoresApp.bordeGris),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.edit, color: ColoresApp.cyanPrimario),
              SizedBox(width: 8),
              Text(
                'Contenido de la Publicidad',
                style: TextStyle(
                  color: ColoresApp.textoPrimario,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _tituloController,
            style: const TextStyle(color: ColoresApp.textoPrimario),
            decoration: const InputDecoration(
              labelText: 'Título',
              hintText: '¡Nueva colección disponible!',
              prefixIcon: Icon(Icons.title, color: ColoresApp.cyanPrimario),
            ),
            maxLength: 50,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _descripcionController,
            style: const TextStyle(color: ColoresApp.textoPrimario),
            decoration: const InputDecoration(
              labelText: 'Descripción',
              hintText: 'Descubre las nuevas figuras de la saga...',
              prefixIcon: Icon(Icons.description, color: ColoresApp.cyanPrimario),
            ),
            maxLines: 3,
            maxLength: 150,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _accionUrlController,
            style: const TextStyle(color: ColoresApp.textoPrimario),
            decoration: const InputDecoration(
              labelText: 'URL de Acción (Opcional)',
              hintText: 'https://drive.google.com/catalogo',
              prefixIcon: Icon(Icons.link, color: ColoresApp.cyanPrimario),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirSeccionExpiracion() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.tarjetaOscura,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColoresApp.bordeGris),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.schedule, color: ColoresApp.cyanPrimario),
              SizedBox(width: 8),
              Text(
                'Fecha de Expiración (Opcional)',
                style: TextStyle(
                  color: ColoresApp.textoPrimario,
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
                child: Text(
                  _fechaExpiracion != null
                      ? 'Expira: ${_fechaExpiracion!.day}/${_fechaExpiracion!.month}/${_fechaExpiracion!.year}'
                      : 'Sin fecha de expiración',
                  style: const TextStyle(color: ColoresApp.textoSecundario),
                ),
              ),
              if (_fechaExpiracion != null)
                TextButton.icon(
                  onPressed: () => setState(() => _fechaExpiracion = null),
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text('Quitar'),
                  style: TextButton.styleFrom(foregroundColor: ColoresApp.error),
                ),
              ElevatedButton.icon(
                onPressed: _seleccionarFechaExpiracion,
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(_fechaExpiracion != null ? 'Cambiar' : 'Seleccionar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColoresApp.cyanPrimario,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _seleccionarFechaExpiracion() async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: _fechaExpiracion ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: ColoresApp.cyanPrimario,
              surface: ColoresApp.tarjetaOscura,
            ),
          ),
          child: child!,
        );
      },
    );

    if (fecha != null) {
      setState(() => _fechaExpiracion = fecha);
    }
  }

  Widget _construirPreview() {
    if (!_publicidadActiva || _tituloController.text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.tarjetaOscura,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColoresApp.verdeAcento),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.preview, color: ColoresApp.verdeAcento),
              SizedBox(width: 8),
              Text(
                'Vista Previa',
                style: TextStyle(
                  color: ColoresApp.textoPrimario,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Widget de preview que simula cómo se verá
          _WidgetPublicidadPreview(
            titulo: _tituloController.text.trim(),
            descripcion: _descripcionController.text.trim(),
            imagenFile: _imagenSeleccionada,
            imagenUrl: _configuracionActual?.publicidadPush.imagenUrl,
          ),
        ],
      ),
    );
  }
}

class _WidgetPublicidadPreview extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final XFile? imagenFile;
  final String? imagenUrl;

  const _WidgetPublicidadPreview({
    required this.titulo,
    required this.descripcion,
    this.imagenFile,
    this.imagenUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColoresApp.superficieOscura,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColoresApp.bordeGris),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          if (imagenFile != null || (imagenUrl?.isNotEmpty == true))
            Container(
              height: 150,
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: imagenFile != null
                    ? Image.file(
                  File(imagenFile!.path),
                  fit: BoxFit.cover,
                )
                    : CachedNetworkImage(
                  imageUrl: imagenUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: ColoresApp.bordeGris,
                    child: const Center(
                      child: CircularProgressIndicator(color: ColoresApp.cyanPrimario),
                    ),
                  ),
                ),
              ),
            ),

          // Contenido
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: ColoresApp.textoPrimario,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (descripcion.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    descripcion,
                    style: const TextStyle(
                      color: ColoresApp.textoSecundario,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColoresApp.cyanPrimario,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text('Ver más'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

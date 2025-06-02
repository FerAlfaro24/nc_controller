import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;
  CloudinaryService._internal();

  // CONFIGURA ESTAS CREDENCIALES CON TUS DATOS DE CLOUDINARY
  static const String _cloudName = 'fcfda466bfb6352ebd2d497baa772e'; // Reemplaza con tu cloud name
  static const String _uploadPreset = 'nc-controller-preset'; // Crear este preset en Cloudinary

  late final CloudinaryPublic _cloudinary;

  void inicializar() {
    _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);
    print('✅ CloudinaryService inicializado con cloud: $_cloudName');
  }

  /// Subir imagen de publicidad a Cloudinary
  Future<CloudinaryResponse?> subirImagenPublicidad(XFile imagen) async {
    try {
      print('📤 Subiendo imagen a Cloudinary...');

      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imagen.path,
          folder: 'nc-controller/publicidad', // Organizar en carpetas
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      print('✅ Imagen subida exitosamente: ${response.secureUrl}');
      return response;
    } catch (e) {
      print('❌ Error subiendo imagen a Cloudinary: $e');
      return null;
    }
  }

  /// Eliminar imagen de Cloudinary
  Future<bool> eliminarImagen(String publicId) async {
    try {
      print('🗑️ Eliminando imagen de Cloudinary: $publicId');

      await _cloudinary.destroy(publicId);
      print('✅ Imagen eliminada exitosamente');
      return true;
    } catch (e) {
      print('❌ Error eliminando imagen: $e');
      return false;
    }
  }

  /// Generar URL optimizada para diferentes tamaños
  String generarUrlOptimizada(String publicId, {
    int? width,
    int? height,
    String quality = 'auto',
    String format = 'auto',
  }) {
    String baseUrl = 'https://res.cloudinary.com/$_cloudName/image/upload/';

    List<String> transformaciones = [];

    if (width != null) transformaciones.add('w_$width');
    if (height != null) transformaciones.add('h_$height');
    transformaciones.add('q_$quality');
    transformaciones.add('f_$format');
    transformaciones.add('c_fill'); // Crop para mantener aspecto

    String transformacion = transformaciones.join(',');
    return '$baseUrl$transformacion/$publicId';
  }

  /// URLs predefinidas para la app
  String urlParaMovil(String publicId) => generarUrlOptimizada(
    publicId,
    width: 800,
    height: 600,
  );

  String urlParaPreview(String publicId) => generarUrlOptimizada(
    publicId,
    width: 300,
    height: 200,
  );

  String urlParaThumbnail(String publicId) => generarUrlOptimizada(
    publicId,
    width: 150,
    height: 100,
  );
}
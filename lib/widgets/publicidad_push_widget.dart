import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../modelos/configuracion_app.dart';
import '../nucleo/constantes/colores_app.dart';

class PublicidadPushWidget extends StatelessWidget {
  final PublicidadPush publicidad;
  final VoidCallback? onCerrar;

  const PublicidadPushWidget({
    super.key,
    required this.publicidad,
    this.onCerrar,
  });

  @override
  Widget build(BuildContext context) {
    if (!publicidad.deberiaMostrarse) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.tarjetaOscura,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.cyanPrimario, width: 2),
        boxShadow: [
          BoxShadow(
            color: ColoresApp.cyanPrimario.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header con botón de cerrar
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 8, top: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ColoresApp.cyanPrimario.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.campaign,
                        size: 16,
                        color: ColoresApp.cyanPrimario,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'NOVEDAD',
                        style: TextStyle(
                          color: ColoresApp.cyanPrimario,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (onCerrar != null)
                  IconButton(
                    onPressed: onCerrar,
                    icon: const Icon(Icons.close, color: ColoresApp.textoApagado),
                    iconSize: 20,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
              ],
            ),
          ),

          // Imagen
          if (publicidad.imagenUrl.isNotEmpty)
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ColoresApp.bordeGris),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: publicidad.imagenUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: ColoresApp.superficieOscura,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: ColoresApp.cyanPrimario),
                          SizedBox(height: 8),
                          Text(
                            'Cargando imagen...',
                            style: TextStyle(color: ColoresApp.textoApagado, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: ColoresApp.superficieOscura,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: ColoresApp.error, size: 32),
                          SizedBox(height: 8),
                          Text(
                            'Error cargando imagen',
                            style: TextStyle(color: ColoresApp.error, fontSize: 12),
                          ),
                        ],
                      ),
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
                  publicidad.titulo,
                  style: const TextStyle(
                    color: ColoresApp.textoPrimario,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),

                if (publicidad.descripcion.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    publicidad.descripcion,
                    style: const TextStyle(
                      color: ColoresApp.textoSecundario,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Botones de acción
                Row(
                  children: [
                    if (publicidad.accionUrl.isNotEmpty)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _abrirUrl(publicidad.accionUrl),
                          icon: const Icon(Icons.open_in_new, size: 18),
                          label: const Text('Ver más'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColoresApp.cyanPrimario,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onCerrar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColoresApp.bordeGris,
                            foregroundColor: ColoresApp.textoPrimario,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Entendido'),
                        ),
                      ),

                    if (publicidad.accionUrl.isNotEmpty && onCerrar != null) ...[
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: onCerrar,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ColoresApp.textoSecundario,
                          side: const BorderSide(color: ColoresApp.bordeGris),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ],
                ),

                // Información de expiración
                if (publicidad.fechaExpiracion != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ColoresApp.advertencia.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: ColoresApp.advertencia,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Válido hasta: ${_formatearFecha(publicidad.fechaExpiracion!)}',
                          style: TextStyle(
                            color: ColoresApp.advertencia,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error abriendo URL: $e');
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}

// Modal overlay para mostrar la publicidad
class PublicidadPushModal extends StatelessWidget {
  final PublicidadPush publicidad;

  const PublicidadPushModal({
    super.key,
    required this.publicidad,
  });

  static Future<void> mostrar(BuildContext context, PublicidadPush publicidad) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (context) => PublicidadPushModal(publicidad: publicidad),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: PublicidadPushWidget(
        publicidad: publicidad,
        onCerrar: () => Navigator.of(context).pop(),
      ),
    );
  }
}
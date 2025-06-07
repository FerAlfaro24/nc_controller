// lib/widgets/instagram_feed_widget.dart

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../nucleo/constantes/colores_app.dart';

class InstagramFeedWidget extends StatefulWidget {
  const InstagramFeedWidget({super.key});

  @override
  State<InstagramFeedWidget> createState() => _InstagramFeedWidgetState();
}

class _InstagramFeedWidgetState extends State<InstagramFeedWidget> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  // Contenido HTML y JS mejorado para el widget de Elfsight.
  // Se eliminó la lógica de error por timeout que causaba el problema.
  final String _htmlContent = '''
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Instagram Feed</title>
    <style>
        /* Estilos para el cuerpo del HTML */
        body {
            margin: 0;
            padding: 0;
            background-color: transparent; /* Fondo transparente */
            overflow: hidden; /* Evitar barras de scroll */
        }
        /* Contenedor principal del widget */
        .elfsight-app-1f147595-b028-4709-a7ab-cc79dbeeabad {
            background-color: transparent !important; /* Forzar fondo transparente */
        }
    </style>
</head>
<body>
    <div class="elfsight-app-1f147595-b028-4709-a7ab-cc79dbeeabad" data-elfsight-app-lazy></div>
    
    <script src="https://static.elfsight.com/platform/platform.js" data-use-service-core defer></script>
</body>
</html>
  ''';

  @override
  void initState() {
    super.initState();

    // Configuración del WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent) // Clave para el fondo transparente
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('📱 WebView: Cargando feed de Instagram...');
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (String url) {
            print('✅ WebView: Feed cargado correctamente.');
            if (mounted) {
              // Se da un pequeño margen para que el script de Elfsight renderice las imágenes
              Future.delayed(const Duration(milliseconds: 1500), () {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ WebView Error: ${error.description}');
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
        ),
      )
      ..loadHtmlString(_htmlContent); // Cargar el contenido HTML
  }

  // Función para reintentar la carga del feed si falla
  Future<void> _reloadWidget() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    await _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380, // Altura fija y ajustada para el widget
      decoration: BoxDecoration(
        color: ColoresApp.tarjetaOscura,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.bordeGris.withOpacity(0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // El WebView que contiene el feed de Instagram
            WebViewWidget(controller: _controller),

            // Muestra un indicador de carga nativo mientras el WebView se prepara
            if (_isLoading)
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: ColoresApp.cyanPrimario),
                    SizedBox(height: 16),
                    Text(
                      'Cargando feed de Instagram...',
                      style: TextStyle(color: ColoresApp.textoSecundario),
                    ),
                  ],
                ),
              ),

            // Muestra un mensaje de error solo si la carga realmente falla
            if (_hasError)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, color: ColoresApp.error, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'No se pudo cargar el feed',
                      style: TextStyle(
                        color: ColoresApp.textoPrimario,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Verifica tu conexión a internet.',
                      style: TextStyle(color: ColoresApp.textoSecundario),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _reloadWidget,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColoresApp.cyanPrimario,
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
}
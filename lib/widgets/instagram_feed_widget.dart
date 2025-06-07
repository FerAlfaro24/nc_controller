// Este archivo va en: lib/widgets/instagram_feed_widget.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../nucleo/constantes/colores_app.dart';

class InstagramFeedWidget extends StatefulWidget {
  const InstagramFeedWidget({super.key});

  @override
  State<InstagramFeedWidget> createState() => _InstagramFeedWidgetState();
}

class _InstagramFeedWidgetState extends State<InstagramFeedWidget> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  final String _htmlContent = '''
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Instagram Feed</title>
    <style>
        body {
            margin: 0;
            padding: 16px;
            background-color: #0F0F0F;
            font-family: 'Arial', sans-serif;
            overflow-x: hidden;
        }
        
        .container {
            width: 100%;
            max-width: 100%;
            margin: 0 auto;
        }
        
        /* Estilos para el widget de Elfsight */
        .elfsight-app-1f147595-b028-4709-a7ab-cc79dbeeabad {
            width: 100% !important;
            max-width: 100% !important;
            border-radius: 12px;
            overflow: hidden;
            background-color: rgba(37, 37, 37, 0.8);
            border: 1px solid rgba(6, 182, 212, 0.3);
        }
        
        /* Personalización adicional */
        .instagram-header {
            text-align: center;
            margin-bottom: 16px;
            padding: 12px;
            background: linear-gradient(135deg, #833AB4, #FD1D1D, #F77737, #FCAF45);
            border-radius: 12px;
        }
        
        .instagram-title {
            color: white;
            font-size: 18px;
            font-weight: bold;
            margin: 0;
            letter-spacing: 0.5px;
        }
        
        .instagram-subtitle {
            color: rgba(255, 255, 255, 0.8);
            font-size: 12px;
            margin: 4px 0 0 0;
        }
        
        /* Loader personalizado */
        .loading-container {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 200px;
            color: #06B6D4;
        }
        
        .loading-spinner {
            width: 40px;
            height: 40px;
            border: 3px solid rgba(6, 182, 212, 0.3);
            border-top: 3px solid #06B6D4;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-bottom: 16px;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        .loading-text {
            font-size: 14px;
            color: #B3B3B3;
        }
        
        /* Error state */
        .error-container {
            text-align: center;
            padding: 32px 16px;
            color: #EF4444;
        }
        
        .error-icon {
            font-size: 48px;
            margin-bottom: 16px;
        }
        
        .error-text {
            font-size: 16px;
            margin-bottom: 8px;
        }
        
        .error-subtitle {
            font-size: 12px;
            color: #808080;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Header personalizado -->
        <div class="instagram-header">
            <h3 class="instagram-title">📸 NABOO CUSTOMS</h3>
            <p class="instagram-subtitle">Síguenos en Instagram</p>
        </div>
        
        <!-- Loading state -->
        <div id="loading" class="loading-container">
            <div class="loading-spinner"></div>
            <div class="loading-text">Cargando feed de Instagram...</div>
        </div>
        
        <!-- Error state (hidden by default) -->
        <div id="error" class="error-container" style="display: none;">
            <div class="error-icon">⚠️</div>
            <div class="error-text">No se pudo cargar el feed</div>
            <div class="error-subtitle">Verifica tu conexión a internet</div>
        </div>
        
        <!-- Instagram Widget -->
        <div id="instagram-widget">
            <div class="elfsight-app-1f147595-b028-4709-a7ab-cc79dbeeabad" data-elfsight-app-lazy></div>
        </div>
    </div>

    <!-- Elfsight Script -->
    <script src="https://static.elfsight.com/platform/platform.js" async></script>
    
    <script>
        // Manejar la carga del widget
        let loadTimeout;
        let isWidgetLoaded = false;
        
        // Timeout para mostrar error si no carga en 10 segundos
        loadTimeout = setTimeout(() => {
            if (!isWidgetLoaded) {
                document.getElementById('loading').style.display = 'none';
                document.getElementById('error').style.display = 'block';
                
                // Notificar a Flutter sobre el error
                if (window.flutter_inappwebview) {
                    window.flutter_inappwebview.callHandler('onError', 'Widget timeout');
                }
            }
        }, 10000);
        
        // Detectar cuando el script de Elfsight se ha cargado
        function checkElfsightLoaded() {
            if (window.eapps && window.eapps.WidgetManager) {
                console.log('Elfsight cargado correctamente');
                isWidgetLoaded = true;
                clearTimeout(loadTimeout);
                
                // Ocultar loading después de un breve delay
                setTimeout(() => {
                    document.getElementById('loading').style.display = 'none';
                    
                    // Notificar a Flutter que terminó de cargar
                    if (window.flutter_inappwebview) {
                        window.flutter_inappwebview.callHandler('onLoaded');
                    }
                }, 2000);
                
                return true;
            }
            return false;
        }
        
        // Verificar cada 500ms si Elfsight está disponible
        const checkInterval = setInterval(() => {
            if (checkElfsightLoaded()) {
                clearInterval(checkInterval);
            }
        }, 500);
        
        // También escuchar el evento load del window
        window.addEventListener('load', () => {
            setTimeout(() => {
                if (!checkElfsightLoaded()) {
                    // Si aún no se ha cargado después del load, seguir intentando
                    console.log('Esperando a que Elfsight esté disponible...');
                }
            }, 1000);
        });
        
        // Función para reintentar la carga
        function retryLoad() {
            document.getElementById('error').style.display = 'none';
            document.getElementById('loading').style.display = 'block';
            location.reload();
        }
    </script>
</body>
</html>
  ''';

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0F0F0F))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            print('🔄 Instagram WebView: Progreso $progress%');
          },
          onPageStarted: (String url) {
            print('📱 Instagram WebView: Página iniciada');
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (String url) {
            print('✅ Instagram WebView: Página terminada');
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ Instagram WebView Error: ${error.description}');
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
        ),
      )
      ..addJavaScriptChannel(
        'onLoaded',
        onMessageReceived: (JavaScriptMessage message) {
          print('✅ Instagram Widget: Carga completada');
          if (mounted) {
            setState(() {
              _isLoading = false;
              _hasError = false;
            });
          }
        },
      )
      ..addJavaScriptChannel(
        'onError',
        onMessageReceived: (JavaScriptMessage message) {
          print('❌ Instagram Widget Error: ${message.message}');
          if (mounted) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          }
        },
      )
      ..loadHtmlString(_htmlContent);
  }

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
      height: 350, // Altura fija para el widget
      decoration: BoxDecoration(
        color: ColoresApp.tarjetaOscura,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.bordeGris),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // WebView principal
            WebViewWidget(controller: _controller),

            // Overlay de carga (solo si está cargando y no hay error)
            if (_isLoading && !_hasError)
              Container(
                color: ColoresApp.tarjetaOscura,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: ColoresApp.cyanPrimario,
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Cargando feed de Instagram...',
                        style: TextStyle(
                          color: ColoresApp.textoSecundario,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Overlay de error
            if (_hasError)
              Container(
                color: ColoresApp.tarjetaOscura,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ColoresApp.error.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.wifi_off,
                          size: 48,
                          color: ColoresApp.error,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Error cargando Instagram',
                        style: TextStyle(
                          color: ColoresApp.textoPrimario,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Verifica tu conexión a internet',
                        style: TextStyle(
                          color: ColoresApp.textoSecundario,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _reloadWidget,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Reintentar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColoresApp.cyanPrimario,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
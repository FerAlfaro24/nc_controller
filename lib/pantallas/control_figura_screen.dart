// lib/pantallas/control_figura_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_audio/just_audio.dart';
import '../modelos/figura.dart';
import '../servicios/bluetooth_service.dart';
import '../nucleo/constantes/colores_app.dart';
import '../widgets/bluetooth_connection_widget.dart';
import '../widgets/led_control_widget.dart';
import '../widgets/music_player_widget.dart';
import '../widgets/smoke_control_widget.dart';

class PantallaControlFigura extends StatefulWidget {
  final Figura figura;

  const PantallaControlFigura({
    super.key,
    required this.figura,
  });

  @override
  State<PantallaControlFigura> createState() => _PantallaControlFiguraState();
}

class _PantallaControlFiguraState extends State<PantallaControlFigura>
    with TickerProviderStateMixin {
  final BluetoothService _bluetoothService = BluetoothService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  BluetoothConnectionState _connectionState = BluetoothConnectionState.disconnected;
  BluetoothDevice? _connectedDevice;
  List<bool> _ledStates = [];
  bool _isPlaying = false;
  int _currentSongIndex = 0;
  bool _smokeEnabled = false;
  int _currentImageIndex = 0;
  Timer? _imageTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeLEDs();
    _initializeBluetooth();
    _startImageRotation();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _initializeLEDs() {
    _ledStates = List.filled(widget.figura.componentes.leds.cantidad, false);
  }

  void _initializeBluetooth() async {
    await _bluetoothService.initialize();

    _bluetoothService.connectionState.listen((state) {
      if (mounted) {
        setState(() {
          _connectionState = state;
        });
      }
    });
  }

  void _startImageRotation() {
    if (widget.figura.imagenesExtra.isNotEmpty) {
      _imageTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (mounted) {
          setState(() {
            _currentImageIndex = (_currentImageIndex + 1) %
                (widget.figura.imagenesExtra.length + 1);
          });
        }
      });
    }
  }

  String get _currentImageUrl {
    if (_currentImageIndex == 0) {
      return widget.figura.imagenSeleccion;
    } else {
      return widget.figura.imagenesExtra[_currentImageIndex - 1];
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _audioPlayer.dispose();
    _imageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/imagenes/fondovacio.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildMainImageSection(),
                          const SizedBox(height: 24),
                          _buildConnectionSection(),
                          const SizedBox(height: 24),
                          _buildControlsSection(),
                          const SizedBox(height: 100),
                        ],
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          // Botón regresar futurista
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ColoresApp.azulPrimario.withOpacity(0.3),
                  ColoresApp.cyanPrimario.withOpacity(0.3),
                ],
              ),
              border: Border.all(
                color: ColoresApp.cyanPrimario.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: ColoresApp.cyanPrimario.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 20),

          // Información de la figura
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      widget.figura.tipo == 'nave'
                          ? Icons.rocket_launch
                          : Icons.landscape,
                      color: widget.figura.tipo == 'nave'
                          ? ColoresApp.azulPrimario
                          : ColoresApp.moradoPrimario,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.figura.nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Sistema de Control ${widget.figura.tipo == 'nave' ? 'Espacial' : 'Ambiental'}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainImageSection() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.figura.tipo == 'nave'
                ? ColoresApp.azulPrimario.withOpacity(0.2)
                : ColoresApp.moradoPrimario.withOpacity(0.2),
            Colors.black.withOpacity(0.6),
          ],
        ),
        border: Border.all(
          color: widget.figura.tipo == 'nave'
              ? ColoresApp.azulPrimario.withOpacity(0.3)
              : ColoresApp.moradoPrimario.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.figura.tipo == 'nave'
                ? ColoresApp.azulPrimario.withOpacity(0.2)
                : ColoresApp.moradoPrimario.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Imagen principal con animación de pulso
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: _currentImageUrl.isNotEmpty
                      ? CachedNetworkImage(
                    imageUrl: _currentImageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: ColoresApp.cyanPrimario,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Icon(
                          widget.figura.tipo == 'nave'
                              ? Icons.rocket_launch_outlined
                              : Icons.terrain_outlined,
                          size: 80,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  )
                      : Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Icon(
                        widget.figura.tipo == 'nave'
                            ? Icons.rocket_launch_outlined
                            : Icons.terrain_outlined,
                        size: 80,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Overlay con gradiente
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            // Indicadores de imágenes múltiples
            if (widget.figura.imagenesExtra.isNotEmpty)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.figura.imagenesExtra.length + 1,
                        (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == index
                            ? ColoresApp.cyanPrimario
                            : Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
              ),

            // Badge de tipo
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.figura.tipo == 'nave'
                      ? ColoresApp.azulPrimario.withOpacity(0.9)
                      : ColoresApp.moradoPrimario.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.figura.tipo.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionSection() {
    return BluetoothConnectionWidget(
      bluetoothService: _bluetoothService,
      figura: widget.figura,
      onConnectionChanged: (device, state) {
        setState(() {
          _connectedDevice = device;
          _connectionState = state;
        });
      },
    );
  }

  Widget _buildControlsSection() {
    if (_connectionState != BluetoothConnectionState.connected) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ColoresApp.advertencia.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.bluetooth_disabled,
              size: 48,
              color: ColoresApp.advertencia,
            ),
            const SizedBox(height: 16),
            const Text(
              'Conecta tu dispositivo Bluetooth',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Para acceder a los controles, primero conecta tu ${widget.figura.bluetoothConfig.nombreDispositivo}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Control de LEDs
        if (widget.figura.componentes.leds.cantidad > 0) ...[
          LEDControlWidget(
            ledConfig: widget.figura.componentes.leds,
            bluetoothService: _bluetoothService,
            onLEDStateChanged: (index, state) {
              setState(() {
                _ledStates[index] = state;
              });
            },
          ),
          const SizedBox(height: 24),
        ],

        // Control de Música
        if (widget.figura.componentes.musica.disponible) ...[
          MusicPlayerWidget(
            musicConfig: widget.figura.componentes.musica,
            audioPlayer: _audioPlayer,
            bluetoothService: _bluetoothService,
            onPlayStateChanged: (isPlaying, songIndex) {
              setState(() {
                _isPlaying = isPlaying;
                _currentSongIndex = songIndex;
              });
            },
          ),
          const SizedBox(height: 24),
        ],

        // Control de Humo
        if (widget.figura.componentes.humidificador.disponible) ...[
          SmokeControlWidget(
            bluetoothService: _bluetoothService,
            onSmokeStateChanged: (enabled) {
              setState(() {
                _smokeEnabled = enabled;
              });
            },
          ),
        ],
      ],
    );
  }
}
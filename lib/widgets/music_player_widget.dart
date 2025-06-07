import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../modelos/figura.dart';
import '../servicios/bluetooth_service.dart';
import '../nucleo/constantes/colores_app.dart';

class MusicPlayerWidget extends StatefulWidget {
  final ConfiguracionMusica musicConfig;
  final AudioPlayer audioPlayer;
  final BluetoothService bluetoothService;
  final Function(bool isPlaying, int songIndex) onPlayStateChanged;

  const MusicPlayerWidget({
    super.key,
    required this.musicConfig,
    required this.audioPlayer,
    required this.bluetoothService,
    required this.onPlayStateChanged,
  });

  @override
  State<MusicPlayerWidget> createState() => _MusicPlayerWidgetState();
}

class _MusicPlayerWidgetState extends State<MusicPlayerWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  bool _isPlaying = false;
  int _currentSongIndex = 0;
  double _progress = 0.0;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupAudioListeners();
  }

  void _setupAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(_rotationController);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _setupAudioListeners() {
    widget.audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });

        if (_isPlaying) {
          _rotationController.repeat();
          _pulseController.repeat(reverse: true);
        } else {
          _rotationController.stop();
          _pulseController.stop();
          _pulseController.reset();
        }

        widget.onPlayStateChanged(_isPlaying, _currentSongIndex);
      }
    });

    widget.audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
          if (_totalDuration.inMilliseconds > 0) {
            _progress = position.inMilliseconds / _totalDuration.inMilliseconds;
          }
        });
      }
    });

    widget.audioPlayer.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withOpacity(0.7),
            ColoresApp.cyanPrimario.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColoresApp.cyanPrimario.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: ColoresApp.cyanPrimario.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildPlayerDisplay(),
          const SizedBox(height: 20),
          _buildControls(),
          const SizedBox(height: 16),
          _buildProgress(),
          const SizedBox(height: 16),
          _buildSongList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isPlaying ? _pulseAnimation.value : 1.0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColoresApp.cyanPrimario.withOpacity(0.8),
                      ColoresApp.azulPrimario.withOpacity(0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ColoresApp.cyanPrimario.withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.music_note,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SISTEMA DE AUDIO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.musicConfig.cantidad} PISTA${widget.musicConfig.cantidad > 1 ? 'S' : ''} DISPONIBLE${widget.musicConfig.cantidad > 1 ? 'S' : ''}',
                style: TextStyle(
                  color: ColoresApp.cyanPrimario,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Indicador de estado
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _isPlaying
                ? ColoresApp.verdeAcento.withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isPlaying ? ColoresApp.verdeAcento : Colors.grey,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _isPlaying ? ColoresApp.verdeAcento : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _isPlaying ? 'PLAYING' : 'STOPPED',
                style: TextStyle(
                  color: _isPlaying ? ColoresApp.verdeAcento : Colors.grey,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerDisplay() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Vinyl disc animation
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * 2.0 * 3.14159,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.black,
                        ColoresApp.cyanPrimario.withOpacity(0.3),
                        Colors.black87,
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ),
                    border: Border.all(
                      color: _isPlaying ? ColoresApp.cyanPrimario : Colors.grey,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _isPlaying
                            ? ColoresApp.cyanPrimario.withOpacity(0.3)
                            : Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Vinyl lines
                      for (int i = 1; i <= 3; i++)
                        Container(
                          width: 80 - (i * 15),
                          height: 80 - (i * 15),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 0.5,
                            ),
                          ),
                        ),
                      // Center hole
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 20),
          // Song info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PISTA ${_currentSongIndex + 1}',
                  style: TextStyle(
                    color: ColoresApp.cyanPrimario,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getCurrentSongName(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'Figura Audio System',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Previous
        _buildControlButton(
          icon: Icons.skip_previous,
          onPressed: _previousSong,
          size: 32,
        ),
        // Play/Pause
        _buildControlButton(
          icon: _isPlaying ? Icons.pause : Icons.play_arrow,
          onPressed: _togglePlayPause,
          size: 48,
          isPrimary: true,
        ),
        // Next
        _buildControlButton(
          icon: Icons.skip_next,
          onPressed: _nextSong,
          size: 32,
        ),
        // Stop
        _buildControlButton(
          icon: Icons.stop,
          onPressed: _stop,
          size: 32,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required double size,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size + 16,
        height: size + 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isPrimary
              ? LinearGradient(
            colors: [
              ColoresApp.cyanPrimario,
              ColoresApp.azulPrimario,
            ],
          )
              : null,
          color: isPrimary ? null : Colors.white.withOpacity(0.1),
          border: Border.all(
            color: isPrimary ? Colors.transparent : Colors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: isPrimary
              ? [
            BoxShadow(
              color: ColoresApp.cyanPrimario.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.6,
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              _formatDuration(_currentPosition),
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
            const Spacer(),
            Text(
              _formatDuration(_totalDuration),
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColoresApp.cyanPrimario,
                    ColoresApp.verdeAcento,
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSongList() {
    if (widget.musicConfig.canciones.length <= 1) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LISTA DE REPRODUCCIÓN',
          style: TextStyle(
            color: ColoresApp.cyanPrimario,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.musicConfig.canciones.length,
            separatorBuilder: (context, index) => const Divider(
              color: Colors.white12,
              height: 1,
              thickness: 1,
            ),
            itemBuilder: (context, index) {
              final isCurrentSong = index == _currentSongIndex;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCurrentSong
                        ? ColoresApp.cyanPrimario.withOpacity(0.2)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isCurrentSong ? ColoresApp.cyanPrimario : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isCurrentSong ? ColoresApp.cyanPrimario : Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  widget.musicConfig.canciones[index],
                  style: TextStyle(
                    color: isCurrentSong ? ColoresApp.cyanPrimario : Colors.white,
                    fontSize: 14,
                    fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: isCurrentSong && _isPlaying
                    ? Icon(
                  Icons.equalizer,
                  color: ColoresApp.cyanPrimario,
                  size: 20,
                )
                    : null,
                onTap: () => _selectSong(index),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getCurrentSongName() {
    if (_currentSongIndex < widget.musicConfig.canciones.length) {
      return widget.musicConfig.canciones[_currentSongIndex];
    }
    return 'Sin título';
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _pause();
    } else {
      await _play();
    }
  }

  Future<void> _play() async {
    // Enviar comando Bluetooth para reproducir
    final success = await widget.bluetoothService.reproducirCancionEspecifica(_currentSongIndex + 1);

    if (success) {
      // Simular reproducción local para UI
      await widget.audioPlayer.play();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error reproduciendo música'),
            backgroundColor: ColoresApp.error,
          ),
        );
      }
    }
  }

  Future<void> _pause() async {
    final success = await widget.bluetoothService.pausarMusica();

    if (success) {
      await widget.audioPlayer.pause();
    }
  }

  Future<void> _stop() async {
    final success = await widget.bluetoothService.detenerMusica();

    if (success) {
      await widget.audioPlayer.stop();
      setState(() {
        _progress = 0.0;
        _currentPosition = Duration.zero;
      });
    }
  }

  Future<void> _nextSong() async {
    if (_currentSongIndex < widget.musicConfig.canciones.length - 1) {
      setState(() {
        _currentSongIndex++;
      });
    } else {
      setState(() {
        _currentSongIndex = 0;
      });
    }

    if (_isPlaying) {
      await _play();
    }
  }

  Future<void> _previousSong() async {
    if (_currentSongIndex > 0) {
      setState(() {
        _currentSongIndex--;
      });
    } else {
      setState(() {
        _currentSongIndex = widget.musicConfig.canciones.length - 1;
      });
    }

    if (_isPlaying) {
      await _play();
    }
  }

  Future<void> _selectSong(int index) async {
    setState(() {
      _currentSongIndex = index;
    });

    await _play();
  }
}
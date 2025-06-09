import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../servicios/bluetooth_service.dart';
import '../nucleo/constantes/colores_app.dart';

class SmokeControlWidget extends StatefulWidget {
  final BluetoothService bluetoothService;
  final Function(bool enabled) onSmokeStateChanged;

  const SmokeControlWidget({
    super.key,
    required this.bluetoothService,
    required this.onSmokeStateChanged,
  });

  @override
  State<SmokeControlWidget> createState() => _SmokeControlWidgetState();
}

class _SmokeControlWidgetState extends State<SmokeControlWidget>
    with TickerProviderStateMixin {
  late AnimationController _smokeController;
  late AnimationController _pulseController;
  late Animation<double> _smokeAnimation;
  late Animation<double> _pulseAnimation;

  bool _smokeEnabled = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _smokeController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _smokeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _smokeController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _smokeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define el nuevo color base para este widget
    final Color colorHumo = Colors.blueGrey[200]!; // <-- CAMBIO

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withOpacity(0.7),
            colorHumo.withOpacity(0.1), // <-- CAMBIO
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorHumo.withOpacity(0.3), // <-- CAMBIO
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: colorHumo.withOpacity(0.2), // <-- CAMBIO
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildSmokeVisualization(),
          const SizedBox(height: 20),
          _buildControls(),
          const SizedBox(height: 16),
          _buildStatusInfo(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final Color colorHumo = Colors.blueGrey[200]!; // <-- CAMBIO

    return Row(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _smokeEnabled ? _pulseAnimation.value : 1.0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorHumo.withOpacity(0.8),     // <-- CAMBIO
                      Colors.blueGrey[600]!.withOpacity(0.8), // <-- CAMBIO
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorHumo.withOpacity(0.5), // <-- CAMBIO
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.cloud,
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
                'SISTEMA DE EFECTOS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'GENERADOR DE HUMO',
                style: TextStyle(
                  color: colorHumo, // <-- CAMBIO
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
            color: _smokeEnabled
                ? ColoresApp.verdeAcento.withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _smokeEnabled ? ColoresApp.verdeAcento : Colors.grey,
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
                  color: _smokeEnabled ? ColoresApp.verdeAcento : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _smokeEnabled ? 'ACTIVO' : 'INACTIVO',
                style: TextStyle(
                  color: _smokeEnabled ? ColoresApp.verdeAcento : Colors.grey,
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

  Widget _buildSmokeVisualization() {
    final Color colorHumo = Colors.blueGrey[200]!; // <-- CAMBIO

    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Fondo con gradiente
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.grey.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Partículas de humo animadas
          if (_smokeEnabled) ..._buildSmokeParticles(),

          // Humidificador central
          Center(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _smokeEnabled ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: _smokeEnabled
                            ? [
                          colorHumo.withOpacity(0.6), // <-- CAMBIO
                          colorHumo.withOpacity(0.2), // <-- CAMBIO
                          Colors.transparent,
                        ]
                            : [
                          Colors.grey.withOpacity(0.5),
                          Colors.grey.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _smokeEnabled
                            ? colorHumo.withOpacity(0.8) // <-- CAMBIO
                            : Colors.grey.withOpacity(0.5),
                        border: Border.all(
                          color: _smokeEnabled ? Colors.white : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.cloud_queue, // <-- CAMBIO de Icono
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Texto de estado superpuesto
          if (!_smokeEnabled)
            Center(
              child: Text(
                'DESACTIVADO',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildSmokeParticles() {
    return List.generate(12, (index) { // <-- CAMBIO: Más partículas
      return AnimatedBuilder(
        animation: _smokeAnimation,
        builder: (context, child) {
          final progress = (_smokeAnimation.value + (index * 0.083)) % 1.0;
          final xOffset = 20 + (index * 25.0) + (progress * 20);
          final yOffset = 150 - (progress * 130) - (index * 3);
          final opacity = (1 - progress) * 0.6;
          final size = 6.0 + (progress * 15);

          return Positioned(
            left: xOffset,
            bottom: yOffset,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(opacity), // <-- CAMBIO
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(opacity * 0.5), // <-- CAMBIO
                    blurRadius: size, // <-- CAMBIO: Más desenfoque
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildControls() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : () => _toggleSmoke(true),
            icon: _isProcessing && _smokeEnabled
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(Icons.cloud, size: 20),
            label: const Text('ACTIVAR'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _smokeEnabled
                  ? Colors.blueGrey[700]!.withOpacity(0.5) // <-- CAMBIO
                  : Colors.blueGrey[600],                  // <-- CAMBIO
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : () => _toggleSmoke(false),
            icon: _isProcessing && !_smokeEnabled
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(Icons.cloud_off, size: 20),
            label: const Text('DESACTIVAR'),
            style: ElevatedButton.styleFrom(
              backgroundColor: !_smokeEnabled
                  ? Colors.grey.withOpacity(0.3)
                  : Colors.grey[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusInfo() {
    final Color colorHumo = Colors.blueGrey[200]!; // <-- CAMBIO

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: colorHumo, // <-- CAMBIO
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'INFORMACIÓN DEL SISTEMA',
                style: TextStyle(
                  color: colorHumo, // <-- CAMBIO
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Estado:', _smokeEnabled ? 'Funcionando' : 'Detenido'),
          _buildInfoRow('Tipo:', 'Humidificador ultrasónico'),
          _buildInfoRow('Modo:', 'Control remoto Bluetooth'),
          _buildInfoRow('Seguridad:', 'Auto-apagado activado'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: _smokeEnabled && label == 'Estado:'
                  ? ColoresApp.verdeAcento
                  : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleSmoke(bool enable) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Enviar comando Bluetooth
      final success = await widget.bluetoothService.controlarHumo(enable);

      if (success) {
        setState(() {
          _smokeEnabled = enable;
        });

        // Controlar animaciones
        if (enable) {
          _smokeController.repeat();
          _pulseController.repeat(reverse: true);
        } else {
          _smokeController.stop();
          _smokeController.reset();
          _pulseController.stop();
          _pulseController.reset();
        }

        // Feedback háptico
        HapticFeedback.mediumImpact();

        // Notificar cambio
        widget.onSmokeStateChanged(enable);

        // Mostrar mensaje de confirmación
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    enable ? Icons.cloud : Icons.cloud_off,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    enable ? 'Humo activado' : 'Humo desactivado',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              backgroundColor: enable ? Colors.blueGrey[700] : Colors.grey[700], // <-- CAMBIO
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } else {
        // Error en el comando
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Error ${enable ? 'activando' : 'desactivando'} el humo',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              backgroundColor: ColoresApp.error,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Error inesperado
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: ColoresApp.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
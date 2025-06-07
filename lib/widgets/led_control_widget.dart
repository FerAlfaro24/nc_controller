import 'package:flutter/material.dart';
import '../modelos/figura.dart';
import '../servicios/bluetooth_service.dart';
import '../nucleo/constantes/colores_app.dart';

class LEDControlWidget extends StatefulWidget {
  final ConfiguracionLeds ledConfig;
  final BluetoothService bluetoothService;
  final Function(int index, bool state) onLEDStateChanged;

  const LEDControlWidget({
    super.key,
    required this.ledConfig,
    required this.bluetoothService,
    required this.onLEDStateChanged,
  });

  @override
  State<LEDControlWidget> createState() => _LEDControlWidgetState();
}

class _LEDControlWidgetState extends State<LEDControlWidget>
    with TickerProviderStateMixin {
  late List<bool> _ledStates;
  late List<AnimationController> _pulseControllers;
  late List<Animation<double>> _pulseAnimations;

  @override
  void initState() {
    super.initState();
    _initializeLEDs();
    _setupAnimations();
  }

  void _initializeLEDs() {
    _ledStates = List.filled(widget.ledConfig.cantidad, false);
  }

  void _setupAnimations() {
    _pulseControllers = List.generate(
      widget.ledConfig.cantidad,
          (index) => AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      ),
    );

    _pulseAnimations = _pulseControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.3).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _pulseControllers) {
      controller.dispose();
    }
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
            ColoresApp.verdeAcento.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColoresApp.verdeAcento.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: ColoresApp.verdeAcento.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildControlGrid(),
          const SizedBox(height: 16),
          _buildMasterControls(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ColoresApp.verdeAcento.withOpacity(0.8),
                ColoresApp.cyanPrimario.withOpacity(0.8),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: ColoresApp.verdeAcento.withOpacity(0.5),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.lightbulb,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SISTEMA DE ILUMINACIÓN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.ledConfig.cantidad} LED${widget.ledConfig.cantidad > 1 ? 'S' : ''} DISPONIBLE${widget.ledConfig.cantidad > 1 ? 'S' : ''}',
                style: TextStyle(
                  color: ColoresApp.verdeAcento,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Indicador de estado general
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getGeneralStatusColor().withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getGeneralStatusColor(),
              width: 1,
            ),
          ),
          child: Text(
            _getGeneralStatusText(),
            style: TextStyle(
              color: _getGeneralStatusColor(),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.ledConfig.cantidad <= 2 ? 2 : 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: widget.ledConfig.cantidad,
      itemBuilder: (context, index) {
        return _buildLEDControl(index);
      },
    );
  }

  Widget _buildLEDControl(int index) {
    final isOn = _ledStates[index];
    final ledName = index < widget.ledConfig.nombres.length
        ? widget.ledConfig.nombres[index]
        : 'LED ${index + 1}';

    return AnimatedBuilder(
      animation: _pulseAnimations[index],
      builder: (context, child) {
        return Transform.scale(
          scale: isOn ? _pulseAnimations[index].value : 1.0,
          child: GestureDetector(
            onTap: () => _toggleLED(index),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isOn
                      ? [
                    ColoresApp.verdeAcento.withOpacity(0.8),
                    ColoresApp.cyanPrimario.withOpacity(0.8),
                  ]
                      : [
                    Colors.grey.withOpacity(0.3),
                    Colors.grey.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isOn ? ColoresApp.verdeAcento : Colors.grey,
                  width: 2,
                ),
                boxShadow: isOn
                    ? [
                  BoxShadow(
                    color: ColoresApp.verdeAcento.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
                    : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icono LED con animación
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isOn)
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ColoresApp.verdeAcento.withOpacity(0.3),
                          ),
                        ),
                      Icon(
                        Icons.lightbulb,
                        size: 28,
                        color: isOn ? Colors.white : Colors.grey,
                      ),
                      if (isOn)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  ColoresApp.verdeAcento.withOpacity(0.6),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Nombre del LED
                  Text(
                    ledName,
                    style: TextStyle(
                      color: isOn ? Colors.white : Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Estado
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isOn
                          ? Colors.white.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isOn ? 'ON' : 'OFF',
                      style: TextStyle(
                        color: isOn ? Colors.white : Colors.grey,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMasterControls() {
    final allOn = _ledStates.every((state) => state);
    final anyOn = _ledStates.any((state) => state);

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _toggleAllLEDs(true),
            icon: const Icon(Icons.flash_on, size: 18),
            label: const Text('ENCENDER TODO'),
            style: ElevatedButton.styleFrom(
              backgroundColor: allOn
                  ? ColoresApp.verdeAcento.withOpacity(0.3)
                  : ColoresApp.verdeAcento,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _toggleAllLEDs(false),
            icon: const Icon(Icons.flash_off, size: 18),
            label: const Text('APAGAR TODO'),
            style: ElevatedButton.styleFrom(
              backgroundColor: !anyOn
                  ? Colors.grey.withOpacity(0.3)
                  : Colors.grey[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _toggleLED(int index) async {
    final newState = !_ledStates[index];

    // Enviar comando Bluetooth
    bool success = await widget.bluetoothService.controlarLED(index + 1, newState);

    if (success) {
      setState(() {
        _ledStates[index] = newState;
      });

      // Animación de pulso cuando se enciende
      if (newState) {
        _pulseControllers[index].repeat(reverse: true);
      } else {
        _pulseControllers[index].stop();
        _pulseControllers[index].reset();
      }

      // Feedback háptico
      HapticFeedback.lightImpact();

      // Notificar cambio
      widget.onLEDStateChanged(index, newState);
    } else {
      // Mostrar error si no se pudo enviar el comando
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error controlando LED ${index + 1}'),
            backgroundColor: ColoresApp.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _toggleAllLEDs(bool turnOn) async {
    List<Future<bool>> futures = [];

    for (int i = 0; i < widget.ledConfig.cantidad; i++) {
      if (_ledStates[i] != turnOn) {
        futures.add(widget.bluetoothService.controlarLED(i + 1, turnOn));
      }
    }

    try {
      final results = await Future.wait(futures);
      final allSuccess = results.every((result) => result);

      if (allSuccess) {
        setState(() {
          for (int i = 0; i < widget.ledConfig.cantidad; i++) {
            _ledStates[i] = turnOn;

            if (turnOn) {
              _pulseControllers[i].repeat(reverse: true);
            } else {
              _pulseControllers[i].stop();
              _pulseControllers[i].reset();
            }
          }
        });

        // Feedback háptico
        HapticFeedback.mediumImpact();

        // Notificar cambios
        for (int i = 0; i < widget.ledConfig.cantidad; i++) {
          widget.onLEDStateChanged(i, turnOn);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error controlando algunos LEDs'),
              backgroundColor: ColoresApp.advertencia,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: ColoresApp.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Color _getGeneralStatusColor() {
    final onCount = _ledStates.where((state) => state).length;
    if (onCount == 0) return Colors.grey;
    if (onCount == widget.ledConfig.cantidad) return ColoresApp.verdeAcento;
    return ColoresApp.advertencia;
  }

  String _getGeneralStatusText() {
    final onCount = _ledStates.where((state) => state).length;
    if (onCount == 0) return 'APAGADO';
    if (onCount == widget.ledConfig.cantidad) return 'ENCENDIDO';
    return '$onCount/${widget.ledConfig.cantidad}';
  }
}
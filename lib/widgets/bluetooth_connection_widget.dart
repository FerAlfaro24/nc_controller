import 'package:flutter/material.dart';
import '../servicios/bluetooth_service.dart';
import '../modelos/figura.dart';
import '../nucleo/constantes/colores_app.dart';

class BluetoothConnectionWidget extends StatefulWidget {
  final BluetoothService bluetoothService;
  final Figura figura;
  final Function(BluetoothDevice?, BluetoothConnectionState) onConnectionChanged;

  const BluetoothConnectionWidget({
    super.key,
    required this.bluetoothService,
    required this.figura,
    required this.onConnectionChanged,
  });

  @override
  State<BluetoothConnectionWidget> createState() => _BluetoothConnectionWidgetState();
}

class _BluetoothConnectionWidgetState extends State<BluetoothConnectionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  BluetoothConnectionState _connectionState = BluetoothConnectionState.disconnected;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _connectedDevice;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupBluetoothListeners();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _setupBluetoothListeners() {
    // Escuchar cambios de estado de conexión
    widget.bluetoothService.connectionState.listen((state) {
      if (mounted) {
        setState(() {
          _connectionState = state;
        });

        _updatePulseAnimation();
        widget.onConnectionChanged(_connectedDevice, state);
      }
    });

    // Escuchar dispositivos descubiertos
    widget.bluetoothService.discoveredDevices.listen((devices) {
      if (mounted) {
        setState(() {
          _devices = devices;
        });
      }
    });
  }

  void _updatePulseAnimation() {
    switch (_connectionState) {
      case BluetoothConnectionState.connecting:
        _pulseController.repeat(reverse: true);
        break;
      case BluetoothConnectionState.connected:
        _pulseController.forward();
        break;
      case BluetoothConnectionState.error:
        _pulseController.forward();
        break;
      default:
        _pulseController.stop();
        _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getConnectionColor().withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getConnectionColor().withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildConnectionStatus(),
          const SizedBox(height: 20),
          _buildActionButton(),
          if (_isScanning || _devices.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildDevicesList(),
          ],
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
              scale: _connectionState == BluetoothConnectionState.connecting
                  ? _pulseAnimation.value
                  : 1.0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getConnectionColor().withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getConnectionColor(),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getConnectionColor().withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  _getConnectionIcon(),
                  color: _getConnectionColor(),
                  size: 28,
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
              Text(
                'CONEXIÓN BLUETOOTH',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Dispositivo: ${widget.figura.bluetoothConfig.nombreDispositivo}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              Text(
                'Tipo: ${widget.figura.bluetoothConfig.tipoModulo.toUpperCase()}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionStatus() {
    String statusText;
    String description;

    switch (_connectionState) {
      case BluetoothConnectionState.connected:
        statusText = 'CONECTADO';
        description = _connectedDevice?.name ?? 'Dispositivo conectado';
        break;
      case BluetoothConnectionState.connecting:
        statusText = 'CONECTANDO...';
        description = 'Estableciendo conexión';
        break;
      case BluetoothConnectionState.error:
        statusText = 'ERROR';
        description = 'Falló la conexión';
        break;
      default:
        statusText = 'DESCONECTADO';
        description = 'Busca y conecta tu dispositivo';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getConnectionColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getConnectionColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getConnectionColor(),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getConnectionColor().withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    color: _getConnectionColor(),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
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

  Widget _buildActionButton() {
    if (_connectionState == BluetoothConnectionState.connected) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _disconnect,
          icon: const Icon(Icons.bluetooth_disabled, size: 20),
          label: const Text('DESCONECTAR'),
          style: ElevatedButton.styleFrom(
            backgroundColor: ColoresApp.error,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isScanning ? _stopScan : _startScan,
        icon: Icon(
          _isScanning ? Icons.stop : Icons.bluetooth_searching,
          size: 20,
        ),
        label: Text(_isScanning ? 'DETENER BÚSQUEDA' : 'BUSCAR DISPOSITIVOS'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isScanning ? ColoresApp.advertencia : ColoresApp.cyanPrimario,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildDevicesList() {
    if (_isScanning && _devices.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const CircularProgressIndicator(
              color: ColoresApp.cyanPrimario,
              strokeWidth: 2,
            ),
            const SizedBox(height: 12),
            Text(
              'Buscando dispositivos...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_devices.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.devices,
                  color: ColoresApp.cyanPrimario,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'DISPOSITIVOS ENCONTRADOS',
                  style: TextStyle(
                    color: ColoresApp.cyanPrimario,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: Colors.white12,
            height: 1,
            thickness: 1,
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _devices.length,
            separatorBuilder: (context, index) => const Divider(
              color: Colors.white12,
              height: 1,
              thickness: 1,
            ),
            itemBuilder: (context, index) {
              final device = _devices[index];
              return _buildDeviceTile(device);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceTile(BluetoothDevice device) {
    final isTargetDevice = device.name.toLowerCase().contains(
      widget.figura.bluetoothConfig.nombreDispositivo.toLowerCase(),
    );

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isTargetDevice
              ? ColoresApp.verdeAcento.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          device.type == BluetoothDeviceType.ble
              ? Icons.bluetooth
              : Icons.bluetooth_connected,
          color: isTargetDevice ? ColoresApp.verdeAcento : Colors.white70,
          size: 20,
        ),
      ),
      title: Text(
        device.name,
        style: TextStyle(
          color: isTargetDevice ? ColoresApp.verdeAcento : Colors.white,
          fontSize: 14,
          fontWeight: isTargetDevice ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            device.address,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: device.type == BluetoothDeviceType.ble
                      ? ColoresApp.azulPrimario.withOpacity(0.3)
                      : ColoresApp.moradoPrimario.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  device.type == BluetoothDeviceType.ble ? 'BLE' : 'CLASSIC',
                  style: TextStyle(
                    color: device.type == BluetoothDeviceType.ble
                        ? ColoresApp.azulPrimario
                        : ColoresApp.moradoPrimario,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (device.rssi != null) ...[
                const SizedBox(width: 8),
                Icon(
                  _getSignalIcon(device.rssi!),
                  color: _getSignalColor(device.rssi!),
                  size: 12,
                ),
                const SizedBox(width: 2),
                Text(
                  '${device.rssi} dBm',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 9,
                  ),
                ),
              ],
              if (isTargetDevice) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: ColoresApp.verdeAcento.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    'COMPATIBLE',
                    style: TextStyle(
                      color: ColoresApp.verdeAcento,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      trailing: _connectionState == BluetoothConnectionState.connecting
          ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: ColoresApp.cyanPrimario,
        ),
      )
          : IconButton(
        onPressed: () => _connectToDevice(device),
        icon: const Icon(
          Icons.link,
          color: ColoresApp.cyanPrimario,
          size: 20,
        ),
      ),
      onTap: () => _connectToDevice(device),
    );
  }

  Color _getConnectionColor() {
    switch (_connectionState) {
      case BluetoothConnectionState.connected:
        return ColoresApp.exito;
      case BluetoothConnectionState.connecting:
        return ColoresApp.advertencia;
      case BluetoothConnectionState.error:
        return ColoresApp.error;
      default:
        return ColoresApp.textoApagado;
    }
  }

  IconData _getConnectionIcon() {
    switch (_connectionState) {
      case BluetoothConnectionState.connected:
        return Icons.bluetooth_connected;
      case BluetoothConnectionState.connecting:
        return Icons.bluetooth_searching;
      case BluetoothConnectionState.error:
        return Icons.bluetooth_disabled;
      default:
        return Icons.bluetooth;
    }
  }

  IconData _getSignalIcon(int rssi) {
    if (rssi > -50) return Icons.signal_cellular_4_bar;
    if (rssi > -70) return Icons.signal_cellular_3_bar;
    if (rssi > -80) return Icons.signal_cellular_2_bar;
    return Icons.signal_cellular_1_bar;
  }

  Color _getSignalColor(int rssi) {
    if (rssi > -50) return ColoresApp.exito;
    if (rssi > -70) return ColoresApp.advertencia;
    return ColoresApp.error;
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _devices.clear();
    });

    final deviceType = widget.figura.bluetoothConfig.tipoModulo == 'ble'
        ? BluetoothDeviceType.ble
        : BluetoothDeviceType.classic;

    final success = await widget.bluetoothService.startDiscovery(
      deviceType: deviceType,
    );

    if (!success) {
      setState(() {
        _isScanning = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error iniciando búsqueda Bluetooth'),
            backgroundColor: ColoresApp.error,
          ),
        );
      }
    }

    // Detener automáticamente después de 30 segundos
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _isScanning) {
        _stopScan();
      }
    });
  }

  Future<void> _stopScan() async {
    await widget.bluetoothService.stopDiscovery();
    setState(() {
      _isScanning = false;
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    if (_connectionState == BluetoothConnectionState.connecting) return;

    await _stopScan();

    final success = await widget.bluetoothService.connectToDevice(device);

    if (success) {
      setState(() {
        _connectedDevice = device;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error conectando a ${device.name}'),
            backgroundColor: ColoresApp.error,
          ),
        );
      }
    }
  }

  Future<void> _disconnect() async {
    await widget.bluetoothService.disconnect();
    setState(() {
      _connectedDevice = null;
    });
  }
}
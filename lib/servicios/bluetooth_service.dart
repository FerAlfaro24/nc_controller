import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

enum BluetoothConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

enum BluetoothDeviceType {
  classic, // HC-05, HC-06
  ble,     // Bluetooth Low Energy
}

class BluetoothDevice {
  final String name;
  final String address;
  final BluetoothDeviceType type;
  final int? rssi;
  final bool isConnected;

  BluetoothDevice({
    required this.name,
    required this.address,
    required this.type,
    this.rssi,
    this.isConnected = false,
  });

  @override
  String toString() => 'BluetoothDevice(name: $name, address: $address, type: $type)';
}

// Comandos para controlar las figuras
class ComandosBluetooth {
  // LEDs - Mantenemos "1" para encender y "0" para apagar
  static const String LED_ENCENDER = "1";
  static const String LED_APAGAR = "0";

  // Para múltiples LEDs, usamos el formato: LED[número][estado]
  static String ledComando(int numeroLed, bool encender) {
    return "LED${numeroLed}${encender ? '1' : '0'}";
  }

  // Música - Comandos para reproducir canciones
  static const String MUSICA_PLAY = "PLAY";
  static const String MUSICA_STOP = "STOP";
  static const String MUSICA_PAUSE = "PAUSE";
  static const String MUSICA_NEXT = "NEXT";
  static const String MUSICA_PREV = "PREV";

  // Para canción específica: SONG[número]
  static String reproducirCancion(int numeroCancion) {
    return "SONG$numeroCancion";
  }

  // Humidificador/Humo
  static const String HUMO_ENCENDER = "SMOKE1";
  static const String HUMO_APAGAR = "SMOKE0";

  // Comando de estado para obtener información del dispositivo
  static const String OBTENER_ESTADO = "STATUS";

  // Comando de prueba de conexión
  static const String TEST_CONEXION = "PING";
}

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  static const MethodChannel _methodChannel = MethodChannel('nc_bluetooth');

  // Streams para estado
  final StreamController<BluetoothConnectionState> _connectionStateController =
  StreamController<BluetoothConnectionState>.broadcast();
  final StreamController<List<BluetoothDevice>> _devicesController =
  StreamController<List<BluetoothDevice>>.broadcast();
  final StreamController<String> _dataController =
  StreamController<String>.broadcast();

  // Estado actual
  BluetoothConnectionState _currentState = BluetoothConnectionState.disconnected;
  BluetoothDevice? _connectedDevice;
  List<BluetoothDevice> _discoveredDevices = [];

  // Getters para streams
  Stream<BluetoothConnectionState> get connectionState => _connectionStateController.stream;
  Stream<List<BluetoothDevice>> get discoveredDevices => _devicesController.stream;
  Stream<String> get dataReceived => _dataController.stream;

  // Getters para estado
  BluetoothConnectionState get currentState => _currentState;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isConnected => _currentState == BluetoothConnectionState.connected;

  /// Inicializar el servicio de Bluetooth
  Future<bool> initialize() async {
    try {
      print('🔵 Inicializando servicio Bluetooth...');

      // Verificar permisos
      if (!await _requestPermissions()) {
        print('❌ Permisos de Bluetooth denegados');
        return false;
      }

      // Verificar si Bluetooth está habilitado
      if (!await isBluetoothEnabled()) {
        print('❌ Bluetooth no está habilitado');
        return false;
      }

      // Configurar listeners de métodos nativos
      _methodChannel.setMethodCallHandler(_handleMethodCall);

      print('✅ Servicio Bluetooth inicializado');
      return true;
    } catch (e) {
      print('❌ Error inicializando Bluetooth: $e');
      return false;
    }
  }

  /// Solicitar permisos de Bluetooth
  Future<bool> _requestPermissions() async {
    try {
      // Permisos para Android 12+
      if (Platform.isAndroid) {
        final Map<Permission, PermissionStatus> statuses = await [
          Permission.bluetooth,
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.bluetoothAdvertise,
          Permission.location,
        ].request();

        // Verificar que todos los permisos críticos estén concedidos
        bool bluetoothGranted = statuses[Permission.bluetooth]?.isGranted ?? false;
        bool locationGranted = statuses[Permission.location]?.isGranted ?? false;

        if (!bluetoothGranted || !locationGranted) {
          print('❌ Permisos críticos denegados');
          return false;
        }
      }

      return true;
    } catch (e) {
      print('❌ Error solicitando permisos: $e');
      return false;
    }
  }

  /// Verificar si Bluetooth está habilitado
  Future<bool> isBluetoothEnabled() async {
    try {
      return await _methodChannel.invokeMethod('isBluetoothEnabled') ?? false;
    } catch (e) {
      print('❌ Error verificando Bluetooth: $e');
      return false;
    }
  }

  /// Solicitar habilitar Bluetooth
  Future<bool> enableBluetooth() async {
    try {
      return await _methodChannel.invokeMethod('enableBluetooth') ?? false;
    } catch (e) {
      print('❌ Error habilitando Bluetooth: $e');
      return false;
    }
  }

  /// Escanear dispositivos Bluetooth
  Future<bool> startDiscovery({BluetoothDeviceType? deviceType}) async {
    try {
      print('🔍 Iniciando búsqueda de dispositivos...');
      _discoveredDevices.clear();
      _devicesController.add(_discoveredDevices);

      final success = await _methodChannel.invokeMethod('startDiscovery', {
        'deviceType': deviceType?.toString() ?? 'both',
      });

      return success ?? false;
    } catch (e) {
      print('❌ Error iniciando búsqueda: $e');
      return false;
    }
  }

  /// Detener escaneo
  Future<bool> stopDiscovery() async {
    try {
      return await _methodChannel.invokeMethod('stopDiscovery') ?? false;
    } catch (e) {
      print('❌ Error deteniendo búsqueda: $e');
      return false;
    }
  }

  /// Conectar a un dispositivo
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      print('🔗 Conectando a ${device.name} (${device.address})...');
      _updateConnectionState(BluetoothConnectionState.connecting);

      final success = await _methodChannel.invokeMethod('connectToDevice', {
        'address': device.address,
        'type': device.type.toString(),
      });

      if (success == true) {
        _connectedDevice = device;
        _updateConnectionState(BluetoothConnectionState.connected);
        print('✅ Conectado a ${device.name}');

        // Enviar comando de prueba
        await Future.delayed(const Duration(milliseconds: 500));
        await sendCommand(ComandosBluetooth.TEST_CONEXION);
      } else {
        _updateConnectionState(BluetoothConnectionState.error);
        print('❌ Falló la conexión a ${device.name}');
      }

      return success ?? false;
    } catch (e) {
      print('❌ Error conectando: $e');
      _updateConnectionState(BluetoothConnectionState.error);
      return false;
    }
  }

  /// Desconectar dispositivo actual
  Future<bool> disconnect() async {
    try {
      print('🔌 Desconectando...');

      final success = await _methodChannel.invokeMethod('disconnect');

      if (success == true) {
        _connectedDevice = null;
        _updateConnectionState(BluetoothConnectionState.disconnected);
        print('✅ Desconectado');
      }

      return success ?? false;
    } catch (e) {
      print('❌ Error desconectando: $e');
      return false;
    }
  }

  /// Enviar comando al dispositivo conectado
  Future<bool> sendCommand(String command) async {
    if (!isConnected) {
      print('❌ No hay dispositivo conectado');
      return false;
    }

    try {
      print('📤 Enviando comando: $command');

      final success = await _methodChannel.invokeMethod('sendData', {
        'data': command,
      });

      if (success == true) {
        print('✅ Comando enviado: $command');
      } else {
        print('❌ Error enviando comando: $command');
      }

      return success ?? false;
    } catch (e) {
      print('❌ Error enviando comando $command: $e');
      return false;
    }
  }

  /// Métodos específicos para controlar componentes

  // Control de LEDs
  Future<bool> controlarLED(int numeroLed, bool encender) async {
    if (numeroLed == 1) {
      // LED principal usa comandos simples
      return await sendCommand(encender ? ComandosBluetooth.LED_ENCENDER : ComandosBluetooth.LED_APAGAR);
    } else {
      // LEDs adicionales usan formato extendido
      return await sendCommand(ComandosBluetooth.ledComando(numeroLed, encender));
    }
  }

  // Control de música
  Future<bool> reproducirMusica() async {
    return await sendCommand(ComandosBluetooth.MUSICA_PLAY);
  }

  Future<bool> pausarMusica() async {
    return await sendCommand(ComandosBluetooth.MUSICA_PAUSE);
  }

  Future<bool> detenerMusica() async {
    return await sendCommand(ComandosBluetooth.MUSICA_STOP);
  }

  Future<bool> siguienteCancion() async {
    return await sendCommand(ComandosBluetooth.MUSICA_NEXT);
  }

  Future<bool> cancionAnterior() async {
    return await sendCommand(ComandosBluetooth.MUSICA_PREV);
  }

  Future<bool> reproducirCancionEspecifica(int numeroCancion) async {
    return await sendCommand(ComandosBluetooth.reproducirCancion(numeroCancion));
  }

  // Control de humidificador
  Future<bool> controlarHumo(bool encender) async {
    return await sendCommand(encender ? ComandosBluetooth.HUMO_ENCENDER : ComandosBluetooth.HUMO_APAGAR);
  }

  // Obtener estado del dispositivo
  Future<bool> obtenerEstado() async {
    return await sendCommand(ComandosBluetooth.OBTENER_ESTADO);
  }

  /// Manejar llamadas desde el código nativo
  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onDeviceFound':
        _handleDeviceFound(call.arguments);
        break;
      case 'onConnectionStateChanged':
        _handleConnectionStateChanged(call.arguments);
        break;
      case 'onDataReceived':
        _handleDataReceived(call.arguments);
        break;
    }
  }

  void _handleDeviceFound(dynamic arguments) {
    try {
      final Map<String, dynamic> deviceData = Map<String, dynamic>.from(arguments);

      final device = BluetoothDevice(
        name: deviceData['name'] ?? 'Dispositivo desconocido',
        address: deviceData['address'] ?? '',
        type: deviceData['type'] == 'ble' ? BluetoothDeviceType.ble : BluetoothDeviceType.classic,
        rssi: deviceData['rssi'],
      );

      // Evitar duplicados
      if (!_discoveredDevices.any((d) => d.address == device.address)) {
        _discoveredDevices.add(device);
        _devicesController.add(List.from(_discoveredDevices));
        print('📱 Dispositivo encontrado: ${device.name}');
      }
    } catch (e) {
      print('❌ Error procesando dispositivo encontrado: $e');
    }
  }

  void _handleConnectionStateChanged(dynamic arguments) {
    try {
      final String state = arguments as String;
      BluetoothConnectionState newState;

      switch (state) {
        case 'connected':
          newState = BluetoothConnectionState.connected;
          break;
        case 'connecting':
          newState = BluetoothConnectionState.connecting;
          break;
        case 'disconnected':
          newState = BluetoothConnectionState.disconnected;
          _connectedDevice = null;
          break;
        default:
          newState = BluetoothConnectionState.error;
      }

      _updateConnectionState(newState);
    } catch (e) {
      print('❌ Error procesando cambio de estado: $e');
    }
  }

  void _handleDataReceived(dynamic arguments) {
    try {
      final String data = arguments as String;
      print('📥 Datos recibidos: $data');
      _dataController.add(data);
    } catch (e) {
      print('❌ Error procesando datos recibidos: $e');
    }
  }

  void _updateConnectionState(BluetoothConnectionState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      _connectionStateController.add(newState);
      print('🔄 Estado de conexión cambiado a: $newState');
    }
  }

  /// Limpiar recursos
  void dispose() {
    _connectionStateController.close();
    _devicesController.close();
    _dataController.close();
  }
}
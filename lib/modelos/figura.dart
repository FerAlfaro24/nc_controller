import 'package:cloud_firestore/cloud_firestore.dart';

class Figura {
  final String id;
  final String nombre;
  final String tipo; // "nave" o "diorama"
  final String descripcion;
  final String imagen;
  final ConfiguracionBluetooth bluetoothConfig;
  final ComponentesFigura componentes;
  final bool activo;
  final DateTime fechaCreacion;

  Figura({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.descripcion,
    required this.imagen,
    required this.bluetoothConfig,
    required this.componentes,
    required this.activo,
    required this.fechaCreacion,
  });

  factory Figura.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Figura(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      tipo: data['tipo'] ?? 'nave',
      descripcion: data['descripcion'] ?? '',
      imagen: data['imagen'] ?? '',
      bluetoothConfig: ConfiguracionBluetooth.fromMap(data['bluetoothConfig'] ?? {}),
      componentes: ComponentesFigura.fromMap(data['componentes'] ?? {}),
      activo: data['activo'] ?? true,
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'tipo': tipo,
      'descripcion': descripcion,
      'imagen': imagen,
      'bluetoothConfig': bluetoothConfig.toMap(),
      'componentes': componentes.toMap(),
      'activo': activo,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
    };
  }
}

class ConfiguracionBluetooth {
  final String tipoModulo; // "classic" o "ble"
  final String nombreDispositivo;

  ConfiguracionBluetooth({
    required this.tipoModulo,
    required this.nombreDispositivo,
  });

  factory ConfiguracionBluetooth.fromMap(Map<String, dynamic> map) {
    return ConfiguracionBluetooth(
      tipoModulo: map['tipoModulo'] ?? 'classic',
      nombreDispositivo: map['nombreDispositivo'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tipoModulo': tipoModulo,
      'nombreDispositivo': nombreDispositivo,
    };
  }
}

class ComponentesFigura {
  final ConfiguracionLeds leds;
  final ConfiguracionMusica musica;
  final ConfiguracionHumidificador humidificador;

  ComponentesFigura({
    required this.leds,
    required this.musica,
    required this.humidificador,
  });

  factory ComponentesFigura.fromMap(Map<String, dynamic> map) {
    return ComponentesFigura(
      leds: ConfiguracionLeds.fromMap(map['leds'] ?? {}),
      musica: ConfiguracionMusica.fromMap(map['musica'] ?? {}),
      humidificador: ConfiguracionHumidificador.fromMap(map['humidificador'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'leds': leds.toMap(),
      'musica': musica.toMap(),
      'humidificador': humidificador.toMap(),
    };
  }
}

class ConfiguracionLeds {
  final int cantidad;
  final List<String> nombres;

  ConfiguracionLeds({
    required this.cantidad,
    required this.nombres,
  });

  factory ConfiguracionLeds.fromMap(Map<String, dynamic> map) {
    return ConfiguracionLeds(
      cantidad: map['cantidad'] ?? 0,
      nombres: List<String>.from(map['nombres'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cantidad': cantidad,
      'nombres': nombres,
    };
  }
}

class ConfiguracionMusica {
  final List<String> canciones;
  final int cantidad;

  ConfiguracionMusica({
    required this.canciones,
    required this.cantidad,
  });

  factory ConfiguracionMusica.fromMap(Map<String, dynamic> map) {
    List<String> listaCanciones = List<String>.from(map['canciones'] ?? []);
    return ConfiguracionMusica(
      canciones: listaCanciones,
      cantidad: map['cantidad'] ?? listaCanciones.length,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'canciones': canciones,
      'cantidad': cantidad,
    };
  }
}

class ConfiguracionHumidificador {
  final bool disponible;

  ConfiguracionHumidificador({
    required this.disponible,
  });

  factory ConfiguracionHumidificador.fromMap(Map<String, dynamic> map) {
    return ConfiguracionHumidificador(
      disponible: map['disponible'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'disponible': disponible,
    };
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../modelos/usuario.dart';
import '../modelos/configuracion_app.dart';
import '../modelos/figura.dart';

class DatabaseInitializer {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Inicializar toda la base de datos con datos de ejemplo
  static Future<void> inicializarBaseDatos() async {
    try {
      print('🚀 Iniciando configuración de base de datos...');

      // 1. Crear colecciones básicas si no existen
      await _crearColeccionesBasicas();

      // 2. Crear usuarios de ejemplo
      await _crearUsuariosEjemplo();

      // 3. Crear configuración de app
      await _crearConfiguracionApp();

      // 4. Crear figuras de ejemplo
      await _crearFigurasEjemplo();

      print('✅ Base de datos inicializada correctamente');
    } catch (e) {
      print('❌ Error inicializando base de datos: $e');
      rethrow;
    }
  }

  /// Crear colecciones básicas para asegurar que existen
  static Future<void> _crearColeccionesBasicas() async {
    print('📁 Creando colecciones básicas...');

    // Crear documento temporal en cada colección para asegurar que existe
    final colecciones = ['usuarios', 'configuraciones', 'figuras'];

    for (String coleccion in colecciones) {
      try {
        await _firestore.collection(coleccion).doc('_temp').set({
          'creado': FieldValue.serverTimestamp(),
          'temporal': true,
        });

        // Eliminar el documento temporal inmediatamente
        await _firestore.collection(coleccion).doc('_temp').delete();
        print('✅ Colección $coleccion creada');
      } catch (e) {
        print('⚠️ Error con colección $coleccion: $e');
      }
    }
  }

  /// Crear usuarios de ejemplo
  static Future<void> _crearUsuariosEjemplo() async {
    print('👥 Creando usuarios de ejemplo...');

    final usuariosEjemplo = [
      {
        'email': 'juan.perez@naboocustoms.com',
        'nombre': 'Juan Pérez',
        'password': '123456',
        'rol': 'cliente',
      },
      {
        'email': 'maria.garcia@naboocustoms.com',
        'nombre': 'María García',
        'password': '123456',
        'rol': 'cliente',
      },
      {
        'email': 'admin.test@naboocustoms.com',
        'nombre': 'Admin Prueba',
        'password': '123456',
        'rol': 'admin',
      },
    ];

    for (var userData in usuariosEjemplo) {
      try {
        // Verificar si el usuario ya existe en Firestore
        final querySnapshot = await _firestore
            .collection('usuarios')
            .where('email', isEqualTo: userData['email'])
            .get();

        if (querySnapshot.docs.isEmpty) {
          // El usuario no existe, crearlo
          UserCredential? userCredential;

          try {
            // Intentar crear en Firebase Auth
            userCredential = await _auth.createUserWithEmailAndPassword(
              email: userData['email'] as String,
              password: userData['password'] as String,
            );
          } catch (authError) {
            print('⚠️ Usuario ${userData['email']} ya existe en Auth, continuando...');
            // Si el usuario ya existe en Auth, intentar hacer login para obtener el UID
            try {
              userCredential = await _auth.signInWithEmailAndPassword(
                email: userData['email'] as String,
                password: userData['password'] as String,
              );
            } catch (e) {
              print('❌ Error obteniendo UID para ${userData['email']}: $e');
              continue;
            }
          }

          if (userCredential?.user != null) {
            // Crear documento en Firestore
            final usuario = Usuario(
              id: userCredential!.user!.uid,
              email: userData['email'] as String,
              nombre: userData['nombre'] as String,
              rol: userData['rol'] as String,
              activo: true,
              fechaCreacion: DateTime.now(),
            );

            await _firestore
                .collection('usuarios')
                .doc(userCredential.user!.uid)
                .set(usuario.toFirestore());

            print('✅ Usuario ${userData['nombre']} creado');
          }
        } else {
          print('ℹ️ Usuario ${userData['email']} ya existe');
        }
      } catch (e) {
        print('❌ Error creando usuario ${userData['email']}: $e');
      }
    }

    // Cerrar sesión después de crear usuarios
    try {
      await _auth.signOut();
    } catch (e) {
      print('⚠️ Error cerrando sesión: $e');
    }
  }

  /// Crear configuración de la aplicación
  static Future<void> _crearConfiguracionApp() async {
    print('⚙️ Creando configuración de aplicación...');

    try {
      final configDoc = await _firestore.collection('configuraciones').doc('app').get();

      if (!configDoc.exists) {
        final config = ConfiguracionApp(
          textoMarquee: '¡Bienvenidos a Naboo Customs! Controla tus figuras futuristas 🚀',
          imagenPublicidad: '',
          mostrarPublicidad: false,
          fechaActualizacion: DateTime.now(),
        );

        await _firestore
            .collection('configuraciones')
            .doc('app')
            .set(config.toFirestore());

        print('✅ Configuración de app creada');
      } else {
        print('ℹ️ Configuración de app ya existe');
      }
    } catch (e) {
      print('❌ Error creando configuración: $e');
    }
  }

  /// Crear figuras de ejemplo
  static Future<void> _crearFigurasEjemplo() async {
    print('🏛️ Creando figuras de ejemplo...');

    final figurasEjemplo = [
      {
        'nombre': 'Podracer de Anakin',
        'tipo': 'nave',
        'descripcion': 'Icónico podracer de las carreras de Boonta Eve',
        'imagen': 'https://via.placeholder.com/300x200?text=Podracer',
        'componentes': {
          'leds': {'cantidad': 2, 'nombres': ['LED Motor Izquierdo', 'LED Motor Derecho']},
          'musica': {'canciones': ['Duel of the Fates', 'Anakin\'s Theme'], 'cantidad': 2},
          'humidificador': {'disponible': true},
        },
        'bluetoothConfig': {
          'tipoModulo': 'classic',
          'nombreDispositivo': 'HC05_Podracer',
        },
      },
      {
        'nombre': 'Palacio de Jabba',
        'tipo': 'diorama',
        'descripcion': 'Recreación del palacio del poderoso Jabba el Hutt',
        'imagen': 'https://via.placeholder.com/300x200?text=Palacio+Jabba',
        'componentes': {
          'leds': {'cantidad': 1, 'nombres': ['LED Principal']},
          'musica': {'canciones': ['Jabba\'s Theme'], 'cantidad': 1},
          'humidificador': {'disponible': false},
        },
        'bluetoothConfig': {
          'tipoModulo': 'ble',
          'nombreDispositivo': 'BLE_Jabba',
        },
      },
      {
        'nombre': 'Millennium Falcon',
        'tipo': 'nave',
        'descripcion': 'La nave más rápida de la galaxia',
        'imagen': 'https://via.placeholder.com/300x200?text=Millennium+Falcon',
        'componentes': {
          'leds': {'cantidad': 3, 'nombres': ['LED Cabina', 'LED Motores', 'LED Interior']},
          'musica': {'canciones': ['Imperial March', 'Main Theme', 'Cantina Band'], 'cantidad': 3},
          'humidificador': {'disponible': true},
        },
        'bluetoothConfig': {
          'tipoModulo': 'classic',
          'nombreDispositivo': 'HC05_Falcon',
        },
      },
      {
        'nombre': 'Cantina de Mos Eisley',
        'tipo': 'diorama',
        'descripcion': 'El famoso bar espacial de Tatooine',
        'imagen': 'https://via.placeholder.com/300x200?text=Cantina',
        'componentes': {
          'leds': {'cantidad': 4, 'nombres': ['LED Bar', 'LED Mesa 1', 'LED Mesa 2', 'LED Entrada']},
          'musica': {'canciones': ['Cantina Band', 'Jawa Theme'], 'cantidad': 2},
          'humidificador': {'disponible': true},
        },
        'bluetoothConfig': {
          'tipoModulo': 'ble',
          'nombreDispositivo': 'BLE_Cantina',
        },
      },
    ];

    for (var figuraData in figurasEjemplo) {
      try {
        // Verificar si la figura ya existe
        final querySnapshot = await _firestore
            .collection('figuras')
            .where('nombre', isEqualTo: figuraData['nombre'])
            .get();

        if (querySnapshot.docs.isEmpty) {
          // Crear componentes de forma segura
          final componentesData = figuraData['componentes'] as Map<String, dynamic>;
          final ledsData = componentesData['leds'] as Map<String, dynamic>;
          final musicaData = componentesData['musica'] as Map<String, dynamic>;
          final humidificadorData = componentesData['humidificador'] as Map<String, dynamic>;
          final bluetoothData = figuraData['bluetoothConfig'] as Map<String, dynamic>;

          final componentes = ComponentesFigura(
            leds: ConfiguracionLeds(
              cantidad: ledsData['cantidad'] as int,
              nombres: List<String>.from(ledsData['nombres'] as List),
            ),
            musica: ConfiguracionMusica(
              canciones: List<String>.from(musicaData['canciones'] as List),
              cantidad: musicaData['cantidad'] as int,
            ),
            humidificador: ConfiguracionHumidificador(
              disponible: humidificadorData['disponible'] as bool,
            ),
          );

          // Crear configuración bluetooth
          final bluetoothConfig = ConfiguracionBluetooth(
            tipoModulo: bluetoothData['tipoModulo'] as String,
            nombreDispositivo: bluetoothData['nombreDispositivo'] as String,
          );

          // Crear figura
          final figura = Figura(
            id: '', // Se asignará automáticamente
            nombre: figuraData['nombre'] as String,
            tipo: figuraData['tipo'] as String,
            descripcion: figuraData['descripcion'] as String,
            imagen: figuraData['imagen'] as String,
            bluetoothConfig: bluetoothConfig,
            componentes: componentes,
            activo: true,
            fechaCreacion: DateTime.now(),
          );

          await _firestore.collection('figuras').add(figura.toFirestore());
          print('✅ Figura ${figuraData['nombre']} creada');
        } else {
          print('ℹ️ Figura ${figuraData['nombre']} ya existe');
        }
      } catch (e) {
        print('❌ Error creando figura ${figuraData['nombre']}: $e');
      }
    }
  }

  /// Verificar y reparar datos existentes
  static Future<void> verificarYRepararDatos() async {
    print('🔍 Verificando integridad de datos...');

    try {
      // Verificar usuarios
      final usuarios = await _firestore.collection('usuarios').get();
      print('👥 Usuarios encontrados: ${usuarios.docs.length}');

      // Verificar configuración
      final config = await _firestore.collection('configuraciones').doc('app').get();
      print('⚙️ Configuración existe: ${config.exists}');

      // Verificar figuras
      final figuras = await _firestore.collection('figuras').get();
      print('🏛️ Figuras encontradas: ${figuras.docs.length}');

      print('✅ Verificación completada');
    } catch (e) {
      print('❌ Error en verificación: $e');
    }
  }

  /// Limpiar datos de prueba (usar con cuidado)
  static Future<void> limpiarDatosPrueba() async {
    print('🧹 Limpiando datos de prueba...');

    try {
      // Eliminar usuarios de prueba (mantener admin)
      final usuarios = await _firestore.collection('usuarios').get();
      for (var doc in usuarios.docs) {
        final usuario = Usuario.fromFirestore(doc);
        if (usuario.email.contains('@naboocustoms.com') && !usuario.esAdmin) {
          await doc.reference.delete();
          print('🗑️ Usuario ${usuario.nombre} eliminado');
        }
      }

      print('✅ Limpieza completada');
    } catch (e) {
      print('❌ Error en limpieza: $e');
    }
  }
}
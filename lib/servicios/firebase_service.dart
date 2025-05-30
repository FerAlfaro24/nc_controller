import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/figura.dart';
import '../modelos/configuracion_app.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== FIGURAS ====================

  /// Obtener figuras por tipo (nave o diorama)
  Stream<List<Figura>> obtenerFigurasPorTipo(String tipo) {
    return _firestore
        .collection('figuras')
        .where('tipo', isEqualTo: tipo)
        .where('activo', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Figura.fromFirestore(doc))
        .toList());
  }

  /// Obtener todas las figuras activas
  Stream<List<Figura>> obtenerTodasLasFiguras() {
    return _firestore
        .collection('figuras')
        .where('activo', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Figura.fromFirestore(doc))
        .toList());
  }

  /// Obtener figura específica por ID
  Future<Figura?> obtenerFigura(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('figuras').doc(id).get();
      if (doc.exists) {
        return Figura.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error obteniendo figura: $e');
      return null;
    }
  }

  /// Crear nueva figura (solo admins)
  Future<String?> crearFigura(Figura figura) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('figuras')
          .add(figura.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creando figura: $e');
      return null;
    }
  }

  // ==================== CONFIGURACIÓN ====================

  /// Obtener configuración de la app
  Stream<ConfiguracionApp> obtenerConfiguracion() {
    return _firestore
        .collection('configuraciones')
        .doc('app')
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return ConfiguracionApp.fromFirestore(doc);
      } else {
        return ConfiguracionApp.porDefecto();
      }
    });
  }

  /// Actualizar configuración de la app (solo admins)
  Future<bool> actualizarConfiguracion(ConfiguracionApp config) async {
    try {
      await _firestore
          .collection('configuraciones')
          .doc('app')
          .set(config.toFirestore(), SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error actualizando configuración: $e');
      return false;
    }
  }

  // ==================== UTILIDADES ====================

  /// Verificar conexión a Firestore
  Future<bool> verificarConexion() async {
    try {
      await _firestore.collection('test').limit(1).get();
      return true;
    } catch (e) {
      print('Error de conexión a Firestore: $e');
      return false;
    }
  }
}
// Archivo: lib/servicios/firebase_service.dart
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
        .orderBy('fechaCreacion', descending: true)
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
        .orderBy('fechaCreacion', descending: true)
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
      print('❌ Error obteniendo figura: $e');
      return null;
    }
  }

  /// Crear nueva figura
  Future<String?> crearFigura(Figura figura) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('figuras')
          .add(figura.toFirestore());
      print('✅ Figura creada con ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creando figura: $e');
      return null;
    }
  }

  /// Actualizar figura existente
  Future<bool> actualizarFigura(String figuraId, Figura figura) async {
    try {
      await _firestore
          .collection('figuras')
          .doc(figuraId)
          .update(figura.toFirestore());
      print('✅ Figura $figuraId actualizada');
      return true;
    } catch (e) {
      print('❌ Error actualizando figura: $e');
      return false;
    }
  }

  /// ✅ CORREGIDO: Eliminar figura (soft delete)
  Future<bool> eliminarFigura(String figuraId) async {
    try {
      await _firestore
          .collection('figuras')
          .doc(figuraId)
          .update({
        'activo': false,
        'fechaEliminacion': FieldValue.serverTimestamp(),
      });
      print('✅ Figura $figuraId eliminada (soft delete)');
      return true;
    } catch (e) {
      print('❌ Error eliminando figura: $e');
      return false;
    }
  }

  /// ✅ NUEVO: Eliminar figura permanentemente
  Future<bool> eliminarFiguraPermanente(String figuraId) async {
    try {
      await _firestore.collection('figuras').doc(figuraId).delete();
      print('✅ Figura $figuraId eliminada permanentemente');
      return true;
    } catch (e) {
      print('❌ Error eliminando figura permanentemente: $e');
      return false;
    }
  }

  /// Obtener figuras por página (para paginación)
  Future<List<Figura>> obtenerFigurasPaginadas({
    String? tipo,
    DocumentSnapshot? ultimoDocumento,
    int limite = 10,
  }) async {
    try {
      Query query = _firestore
          .collection('figuras')
          .where('activo', isEqualTo: true);

      if (tipo != null) {
        query = query.where('tipo', isEqualTo: tipo);
      }

      query = query.orderBy('fechaCreacion', descending: true);

      if (ultimoDocumento != null) {
        query = query.startAfterDocument(ultimoDocumento);
      }

      query = query.limit(limite);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Figura.fromFirestore(doc)).toList();
    } catch (e) {
      print('❌ Error obteniendo figuras paginadas: $e');
      return [];
    }
  }

  /// Buscar figuras por nombre
  Stream<List<Figura>> buscarFiguras(String termino) {
    if (termino.isEmpty) {
      return obtenerTodasLasFiguras();
    }

    return _firestore
        .collection('figuras')
        .where('activo', isEqualTo: true)
        .orderBy('nombre')
        .startAt([termino])
        .endAt([termino + '\uf8ff'])
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Figura.fromFirestore(doc))
        .toList());
  }

  /// Obtener estadísticas de figuras
  Future<Map<String, int>> obtenerEstadisticasFiguras() async {
    try {
      final naves = await _firestore
          .collection('figuras')
          .where('tipo', isEqualTo: 'nave')
          .where('activo', isEqualTo: true)
          .count()
          .get();

      final dioramas = await _firestore
          .collection('figuras')
          .where('tipo', isEqualTo: 'diorama')
          .where('activo', isEqualTo: true)
          .count()
          .get();

      return {
        'naves': naves.count ?? 0,
        'dioramas': dioramas.count ?? 0,
        'total': (naves.count ?? 0) + (dioramas.count ?? 0),
      };
    } catch (e) {
      print('❌ Error obteniendo estadísticas: $e');
      return {'naves': 0, 'dioramas': 0, 'total': 0};
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
      print('✅ Configuración actualizada');
      return true;
    } catch (e) {
      print('❌ Error actualizando configuración: $e');
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
      print('❌ Error de conexión a Firestore: $e');
      return false;
    }
  }

  /// Obtener información del sistema
  Future<Map<String, dynamic>> obtenerInfoSistema() async {
    try {
      final estadisticasFiguras = await obtenerEstadisticasFiguras();

      final usuarios = await _firestore
          .collection('usuarios')
          .where('activo', isEqualTo: true)
          .count()
          .get();

      return {
        'figuras': estadisticasFiguras,
        'usuarios': usuarios.count ?? 0,
        'ultimaActualizacion': DateTime.now(),
      };
    } catch (e) {
      print('❌ Error obteniendo info del sistema: $e');
      return {};
    }
  }

  /// Limpiar colección completa (solo para desarrollo)
  Future<bool> limpiarColeccion(String coleccion) async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _firestore.collection(coleccion).get();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ Colección $coleccion limpiada');
      return true;
    } catch (e) {
      print('❌ Error limpiando colección $coleccion: $e');
      return false;
    }
  }
}
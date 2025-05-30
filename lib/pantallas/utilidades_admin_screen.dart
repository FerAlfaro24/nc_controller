import 'package:flutter/material.dart';
import '../servicios/database_initializer.dart';
import '../nucleo/constantes/colores_app.dart';

class PantallaUtilidadesAdmin extends StatefulWidget {
  const PantallaUtilidadesAdmin({super.key});

  @override
  State<PantallaUtilidadesAdmin> createState() => _PantallaUtilidadesAdminState();
}

class _PantallaUtilidadesAdminState extends State<PantallaUtilidadesAdmin> {
  bool _cargando = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UTILIDADES ADMIN'),
        backgroundColor: ColoresApp.superficieOscura,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: ColoresApp.gradienteFondo,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CONFIGURACIÓN DE BASE DE DATOS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 20),

              _tarjetaUtilidad(
                'Inicializar Base de Datos',
                'Crear todas las colecciones y datos de ejemplo',
                Icons.storage,
                ColoresApp.verdeAcento,
                    () => _ejecutarAccion(
                  'Inicializando base de datos...',
                  DatabaseInitializer.inicializarBaseDatos,
                ),
              ),

              const SizedBox(height: 16),

              _tarjetaUtilidad(
                'Verificar Datos',
                'Revisar integridad de la base de datos',
                Icons.fact_check,
                ColoresApp.cyanPrimario,
                    () => _ejecutarAccion(
                  'Verificando datos...',
                  DatabaseInitializer.verificarYRepararDatos,
                ),
              ),

              const SizedBox(height: 16),

              _tarjetaUtilidad(
                'Limpiar Datos Prueba',
                'Eliminar usuarios y datos de ejemplo',
                Icons.cleaning_services,
                ColoresApp.advertencia,
                    () => _confirmarYEjecutar(
                  'Limpiar Datos',
                  '¿Estás seguro? Esta acción eliminará usuarios de prueba.',
                      () => DatabaseInitializer.limpiarDatosPrueba(),
                ),
              ),

              const SizedBox(height: 32),

              if (_cargando)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ColoresApp.informacion.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ColoresApp.informacion.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      CircularProgressIndicator(color: ColoresApp.informacion),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Procesando... Revisa la consola para ver el progreso.',
                          style: TextStyle(color: ColoresApp.informacion),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColoresApp.advertencia.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColoresApp.advertencia.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: ColoresApp.advertencia),
                        const SizedBox(width: 8),
                        Text(
                          'REGLAS DE FIRESTORE',
                          style: TextStyle(
                            color: ColoresApp.advertencia,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Si tienes errores de permisos, ve a Firebase Console > Firestore Database > Rules y usa estas reglas:\n\n'
                          'rules_version = \'2\';\n'
                          'service cloud.firestore {\n'
                          '  match /databases/{database}/documents {\n'
                          '    match /{document=**} {\n'
                          '      allow read, write: if true;\n'
                          '    }\n'
                          '  }\n'
                          '}',
                      style: TextStyle(
                        color: ColoresApp.textoSecundario,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tarjetaUtilidad(
      String titulo,
      String descripcion,
      IconData icono,
      Color color,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: _cargando ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColoresApp.tarjetaOscura,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icono, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descripcion,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (_cargando)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _ejecutarAccion(String mensaje, Future<void> Function() accion) async {
    setState(() => _cargando = true);

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: ColoresApp.informacion,
          duration: const Duration(seconds: 2),
        ),
      );

      await accion();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Operación completada exitosamente!'),
            backgroundColor: ColoresApp.exito,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: ColoresApp.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  Future<void> _confirmarYEjecutar(
      String titulo,
      String mensaje,
      Future<void> Function() accion,
      ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColoresApp.tarjetaOscura,
        title: Text(titulo, style: const TextStyle(color: Colors.white)),
        content: Text(mensaje, style: const TextStyle(color: ColoresApp.textoSecundario)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: ColoresApp.textoSecundario)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: ColoresApp.advertencia),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _ejecutarAccion('Ejecutando...', accion);
    }
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../servicios/auth_service.dart';
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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('UTILIDADES ADMIN'),
        backgroundColor: ColoresApp.superficieOscura,
        actions: [
          IconButton(
            icon: const Icon(Icons.info, color: ColoresApp.cyanPrimario),
            onPressed: () => _mostrarInformacionSistema(context),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: ColoresApp.gradienteFondo,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header de peligro
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColoresApp.rojoAcento.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColoresApp.rojoAcento.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning,
                      color: ColoresApp.rojoAcento,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ZONA DE PELIGRO',
                            style: TextStyle(
                              color: ColoresApp.rojoAcento,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Estas operaciones son irreversibles',
                            style: TextStyle(
                              color: ColoresApp.rojoAcento.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Sección de Base de Datos
              _seccionUtilidades(
                'BASE DE DATOS',
                [
                  _tarjetaUtilidad(
                    'Inicializar BD',
                    'Crear datos de ejemplo',
                    Icons.storage,
                    ColoresApp.verdeAcento,
                        () => _inicializarBaseDatos(),
                  ),
                  _tarjetaUtilidad(
                    'Verificar Datos',
                    'Revisar integridad',
                    Icons.verified,
                    ColoresApp.cyanPrimario,
                        () => _verificarDatos(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sección de Operaciones Peligrosas
              _seccionUtilidades(
                'OPERACIONES PELIGROSAS',
                [
                  _tarjetaUtilidad(
                    'Limpiar BD',
                    'Eliminar TODOS los datos',
                    Icons.delete_forever,
                    ColoresApp.rojoAcento,
                        () => _confirmarLimpiarBaseDatos(),
                  ),
                  _tarjetaUtilidad(
                    'Reset Completo',
                    'Reiniciar sistema',
                    Icons.refresh,
                    ColoresApp.advertencia,
                        () => _confirmarResetCompleto(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sección de Firebase Auth
              _seccionUtilidades(
                'FIREBASE AUTH',
                [
                  _tarjetaUtilidad(
                    'Consola Firebase',
                    'Gestionar usuarios Auth',
                    Icons.open_in_new,
                    ColoresApp.informacion,
                        () => _abrirConsolaFirebase(),
                  ),
                  _tarjetaUtilidad(
                    'Info Auth',
                    'Ver limitaciones',
                    Icons.help,
                    ColoresApp.cyanPrimario,
                        () => _mostrarInfoFirebaseAuth(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Estado del sistema
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColoresApp.tarjetaOscura,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ColoresApp.bordeGris),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ESTADO DEL SISTEMA',
                      style: TextStyle(
                        color: ColoresApp.textoPrimario,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _itemEstado('Firebase Auth', true, 'Funcionando'),
                    _itemEstado('Firestore', true, 'Conectado'),
                    _itemEstado('Storage', true, 'Disponible'),
                    _itemEstado('Autenticación', true, 'Admin logueado'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _seccionUtilidades(String titulo, List<Widget> tarjetas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: ColoresApp.textoPrimario,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < tarjetas.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(child: tarjetas[i]),
                const SizedBox(width: 12),
                if (i + 1 < tarjetas.length)
                  Expanded(child: tarjetas[i + 1])
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
      ],
    );
  }

  Widget _tarjetaUtilidad(String titulo, String descripcion, IconData icono, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: _cargando ? null : onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(12),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icono,
                size: 20,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              titulo,
              style: const TextStyle(
                color: ColoresApp.textoPrimario,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Text(
                descripcion,
                style: const TextStyle(
                  color: ColoresApp.textoSecundario,
                  fontSize: 10,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemEstado(String titulo, bool activo, String descripcion) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: activo ? ColoresApp.exito : ColoresApp.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: ColoresApp.textoPrimario,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  descripcion,
                  style: const TextStyle(
                    color: ColoresApp.textoSecundario,
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

  Future<void> _inicializarBaseDatos() async {
    setState(() => _cargando = true);
    try {
      await DatabaseInitializer.inicializarBaseDatos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Base de datos inicializada correctamente'),
            backgroundColor: ColoresApp.exito,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error inicializando BD: $e'),
            backgroundColor: ColoresApp.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _verificarDatos() async {
    setState(() => _cargando = true);
    try {
      await DatabaseInitializer.verificarYRepararDatos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Verificación completada'),
            backgroundColor: ColoresApp.exito,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error en verificación: $e'),
            backgroundColor: ColoresApp.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _confirmarLimpiarBaseDatos() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColoresApp.tarjetaOscura,
        title: const Text(
          '⚠️ ELIMINAR TODOS LOS DATOS',
          style: TextStyle(color: ColoresApp.rojoAcento),
        ),
        content: const Text(
          'Esta acción eliminará TODOS los usuarios, figuras y configuraciones.\n\n¿Estás completamente seguro?\n\nEsta acción NO se puede deshacer.',
          style: TextStyle(color: ColoresApp.textoPrimario),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: ColoresApp.textoSecundario)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColoresApp.rojoAcento,
              foregroundColor: Colors.white,
            ),
            child: const Text('SÍ, ELIMINAR TODO'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() => _cargando = true);
      try {
        final authService = context.read<AuthService>();
        await authService.limpiarBaseDatos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Base de datos limpiada completamente'),
              backgroundColor: ColoresApp.exito,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error limpiando BD: $e'),
              backgroundColor: ColoresApp.error,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _cargando = false);
      }
    }
  }

  Future<void> _confirmarResetCompleto() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColoresApp.tarjetaOscura,
        title: const Text(
          '🔄 RESET COMPLETO DEL SISTEMA',
          style: TextStyle(color: ColoresApp.advertencia),
        ),
        content: const Text(
          'Esto eliminará todo y recreará la base de datos con datos de ejemplo.\n\n¿Continuar?',
          style: TextStyle(color: ColoresApp.textoPrimario),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: ColoresApp.textoSecundario)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColoresApp.advertencia,
              foregroundColor: Colors.white,
            ),
            child: const Text('RESET COMPLETO'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() => _cargando = true);
      try {
        final authService = context.read<AuthService>();
        await authService.limpiarBaseDatos();
        await DatabaseInitializer.inicializarBaseDatos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Sistema reseteado y reinicializado'),
              backgroundColor: ColoresApp.exito,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error en reset: $e'),
              backgroundColor: ColoresApp.error,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _cargando = false);
      }
    }
  }

  void _abrirConsolaFirebase() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColoresApp.tarjetaOscura,
        title: const Text(
          '🔥 CONSOLA DE FIREBASE',
          style: TextStyle(color: ColoresApp.informacion),
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Para eliminar usuarios de Firebase Auth, ve a:',
                style: TextStyle(color: ColoresApp.textoPrimario),
              ),
              SizedBox(height: 12),
              Text(
                '1. Abre la consola de Firebase',
                style: TextStyle(color: ColoresApp.textoSecundario),
              ),
              SizedBox(height: 8),
              Text(
                '2. Proyecto → Authentication → Users',
                style: TextStyle(color: ColoresApp.textoSecundario),
              ),
              SizedBox(height: 8),
              Text(
                '3. Elimina usuarios manualmente',
                style: TextStyle(color: ColoresApp.textoSecundario),
              ),
              SizedBox(height: 16),
              Text(
                'URL: console.firebase.google.com',
                style: TextStyle(
                  color: ColoresApp.cyanPrimario,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido', style: TextStyle(color: ColoresApp.cyanPrimario)),
          ),
        ],
      ),
    );
  }

  void _mostrarInfoFirebaseAuth() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColoresApp.tarjetaOscura,
        title: const Text(
          'ℹ️ LIMITACIONES DE FIREBASE AUTH',
          style: TextStyle(color: ColoresApp.advertencia),
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '⚠️ Problema Identificado:',
                style: TextStyle(
                  color: ColoresApp.rojoAcento,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Firebase Auth mantiene usuarios aunque limpiemos Firestore. Esto causa el error "email already in use".',
                style: TextStyle(color: ColoresApp.textoPrimario),
              ),
              SizedBox(height: 16),
              Text(
                '✅ Soluciones:',
                style: TextStyle(
                  color: ColoresApp.verdeAcento,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '1. Usar emails únicos para cada prueba',
                style: TextStyle(color: ColoresApp.textoSecundario),
              ),
              SizedBox(height: 4),
              Text(
                '2. Eliminar usuarios desde la consola',
                style: TextStyle(color: ColoresApp.textoSecundario),
              ),
              SizedBox(height: 4),
              Text(
                '3. Usar diferentes proyectos para desarrollo',
                style: TextStyle(color: ColoresApp.textoSecundario),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido', style: TextStyle(color: ColoresApp.cyanPrimario)),
          ),
        ],
      ),
    );
  }

  void _mostrarInformacionSistema(BuildContext context) { // Added context parameter
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColoresApp.tarjetaOscura,
        title: const Text(
          'INFORMACIÓN DEL SISTEMA',
          style: TextStyle(color: ColoresApp.textoPrimario),
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🔧 Versión: 1.0.0', style: TextStyle(color: ColoresApp.textoSecundario)),
              SizedBox(height: 8),
              Text('🔥 Firebase: Conectado', style: TextStyle(color: ColoresApp.textoSecundario)),
              SizedBox(height: 8),
              Text('👤 Rol: Administrador', style: TextStyle(color: ColoresApp.textoSecundario)),
              SizedBox(height: 8),
              Text('📱 Plataforma: Flutter', style: TextStyle(color: ColoresApp.textoSecundario)),
              SizedBox(height: 16),
              Text(
                'Naboo Customs Controller\nSistema de control para figuras futuristas',
                style: TextStyle(color: ColoresApp.textoApagado, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar', style: TextStyle(color: ColoresApp.cyanPrimario)),
          ),
        ],
      ),
    );
  }
}
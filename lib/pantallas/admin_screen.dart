// Archivo: lib/pantallas/admin_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../nucleo/constantes/colores_app.dart';
import '../servicios/auth_service.dart';
import '../servicios/firebase_service.dart';
import '../modelos/configuracion_app.dart';
import '../widgets/auto_scrolling_text.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'gestion_usuarios_screen.dart';
import 'gestion_figuras_screen.dart'; // ✅ NUEVA IMPORTACIÓN
import 'utilidades_admin_screen.dart';
import 'gestion_publicidad_screen.dart';

class PantallaAdmin extends StatefulWidget {
  const PantallaAdmin({super.key});

  @override
  State<PantallaAdmin> createState() => _PantallaAdminState();
}

class _PantallaAdminState extends State<PantallaAdmin> {
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, dynamic> _infoSistema = {};

  @override
  void initState() {
    super.initState();
    _cargarInfoSistema();
  }

  Future<void> _cargarInfoSistema() async {
    try {
      final info = await _firebaseService.obtenerInfoSistema();
      if (mounted) {
        setState(() => _infoSistema = info);
      }
    } catch (e) {
      print('Error cargando info del sistema: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('PANEL ADMINISTRADOR'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarInfoSistema,
          ),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () => _mostrarInfoAdmin(context),
          ),
        ],
      ),
      drawer: _construirDrawer(context),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F0F0F),
              Color(0xFF0A0A0F),
            ],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header de administrador
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ColoresApp.rojoAcento.withOpacity(0.8),
                      ColoresApp.naranjaAcento.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: ColoresApp.rojoAcento.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PANEL DE ADMINISTRACIÓN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AutoScrollingText(
                            text: 'Control total del Sistema Naboo Customs',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                            duration: const Duration(seconds: 4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // GESTIÓN DE CONTENIDO
              _seccionAdmin(
                'GESTIÓN DE CONTENIDO',
                Icons.inventory,
                ColoresApp.verdeAcento,
                [
                  _tarjetaAdmin(
                    'Gestionar Figuras',
                    'Naves y Dioramas',
                    Icons.category,
                    ColoresApp.moradoPrimario,
                        () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PantallaGestionFiguras(),
                        ),
                      );
                    },
                  ),
                  _tarjetaAdmin(
                    'Gestionar Usuarios',
                    'Crear y editar',
                    Icons.people,
                    ColoresApp.verdeAcento,
                        () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PantallaGestionUsuarios(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // CONFIGURACIÓN DE APLICACIÓN
              _seccionAdmin(
                'CONFIGURACIÓN PUBLICIDAD',
                Icons.settings,
                ColoresApp.cyanPrimario,
                [
                  _tarjetaAdmin(
                    'Texto Marquee',
                    'Editar mensaje',
                    Icons.text_fields,
                    ColoresApp.cyanPrimario,
                        () {
                      _mostrarDialogoTextoMarquee();
                    },
                  ),
                  _tarjetaAdmin(
                    'Publicidad Push',
                    'Gestionar promociones',
                    Icons.campaign,
                    ColoresApp.naranjaAcento,
                        () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PantallaGestionPublicidad(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ESTADÍSTICAS Y MONITOREO
              _seccionAdmin(
                'ESTADÍSTICAS Y MONITOREO',
                Icons.analytics,
                ColoresApp.azulPrimario,
                [
                  _tarjetaAdmin(
                    'Estadísticas',
                    'Ver uso de app',
                    Icons.analytics,
                    ColoresApp.azulPrimario,
                        () {
                      _mostrarEstadisticas();
                    },
                  ),
                  _tarjetaAdmin(
                    'Utilidades Admin',
                    'Herramientas',
                    Icons.build,
                    ColoresApp.rojoAcento,
                        () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PantallaUtilidadesAdmin(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ACCESO RÁPIDO
              _seccionAdmin(
                'ACCESO RÁPIDO',
                Icons.flash_on,
                ColoresApp.rosaAcento,
                [
                  _tarjetaAdmin(
                    'Vista Usuario',
                    'Ver como cliente',
                    Icons.person,
                    ColoresApp.informacion,
                        () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const PantallaHome()),
                      );
                    },
                  ),
                  _tarjetaAdmin(
                    'Logs del Sistema',
                    'Ver registros',
                    Icons.list_alt,
                    ColoresApp.advertencia,
                        () {
                      _mostrarLogs();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // INFORMACIÓN DEL SISTEMA
              _construirInfoSistema(),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirInfoSistema() {
    final figuras = _infoSistema['figuras'] as Map<String, int>? ?? {};
    final usuarios = _infoSistema['usuarios'] as int? ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.tarjetaOscura,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.bordeGris),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: ColoresApp.informacion,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'INFORMACIÓN DEL SISTEMA',
                  style: TextStyle(
                    color: ColoresApp.textoPrimario,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: ColoresApp.cyanPrimario),
                onPressed: _cargarInfoSistema,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _itemInformacion('Versión', '1.0.0'),
          _itemInformacion('Firebase', 'Conectado'),
          _itemInformacion('Cloudinary', 'Activo'),
          _itemInformacion('Usuarios Activos', '$usuarios'),
          _itemInformacion('Naves', '${figuras['naves'] ?? 0}'),
          _itemInformacion('Dioramas', '${figuras['dioramas'] ?? 0}'),
          _itemInformacion('Total Figuras', '${figuras['total'] ?? 0}'),
          _itemInformacion('Última actualización', 'Ahora'),
        ],
      ),
    );
  }

  Widget _construirDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1A1A1A),
      child: Column(
        children: [
          // Header del drawer
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFEF4444),
                  Color(0xFFF59E0B),
                ],
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    size: 60,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'ADMINISTRADOR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    'Panel de Control',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Items del menú
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _itemDrawer(
                  context,
                  Icons.dashboard,
                  'PANEL PRINCIPAL',
                      () => Navigator.pop(context),
                ),
                _itemDrawer(
                  context,
                  Icons.category,
                  'FIGURAS',
                      () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PantallaGestionFiguras(),
                      ),
                    );
                  },
                ),
                _itemDrawer(
                  context,
                  Icons.people,
                  'USUARIOS',
                      () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PantallaGestionUsuarios(),
                      ),
                    );
                  },
                ),
                _itemDrawer(
                  context,
                  Icons.campaign,
                  'PUBLICIDAD',
                      () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PantallaGestionPublicidad(),
                      ),
                    );
                  },
                ),
                _itemDrawer(
                  context,
                  Icons.settings,
                  'UTILIDADES',
                      () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PantallaUtilidadesAdmin(),
                      ),
                    );
                  },
                ),
                const Divider(color: Color(0xFF404040)),
                _itemDrawer(
                  context,
                  Icons.person,
                  'MODO USUARIO',
                      () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const PantallaHome()),
                    );
                  },
                ),
              ],
            ),
          ),

          // Footer con cerrar sesión
          Container(
            padding: const EdgeInsets.all(16),
            child: _itemDrawer(
              context,
              Icons.exit_to_app,
              'CERRAR SESIÓN',
                  () async {
                Navigator.pop(context);
                await _cerrarSesionAdmin(context);
              },
              esLogout: true,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cerrarSesionAdmin(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF252525),
        title: const Text(
          'Cerrar Sesión Administrativa',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Estás seguro de que quieres cerrar la sesión de administrador?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        await authService.cerrarSesion();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Sesión administrativa cerrada'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );

          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const PantallaLogin()),
                  (route) => false,
            );
          }
        }
      } catch (e) {
        print('⚠️ Error cerrando sesión: $e');
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const PantallaLogin()),
                (route) => false,
          );
        }
      }
    }
  }

  Widget _itemDrawer(BuildContext context, IconData icono, String titulo, VoidCallback onTap, {bool esLogout = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(
          icono,
          color: esLogout ? Colors.red : Colors.orange,
          size: 24,
        ),
        title: Text(
          titulo,
          style: TextStyle(
            color: esLogout ? Colors.red : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        hoverColor: Colors.orange.withOpacity(0.1),
        splashColor: Colors.orange.withOpacity(0.2),
      ),
    );
  }

  Widget _seccionAdmin(String titulo, IconData icono, Color color, List<Widget> tarjetas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Grid de tarjetas
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

  Widget _tarjetaAdmin(String titulo, String descripcion, IconData icono, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 105,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Fila superior con icono y flecha
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icono,
                    size: 16,
                    color: color,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: ColoresApp.textoApagado,
                ),
              ],
            ),

            // Espacio para el texto con auto-scroll
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Título con auto-scroll
                  Flexible(
                    child: AutoScrollingText(
                      text: titulo,
                      style: const TextStyle(
                        color: ColoresApp.textoPrimario,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      duration: const Duration(seconds: 3),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Descripción con auto-scroll
                  Flexible(
                    child: AutoScrollingText(
                      text: descripcion,
                      style: const TextStyle(
                        color: ColoresApp.textoSecundario,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      duration: const Duration(seconds: 4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemInformacion(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$titulo:',
            style: const TextStyle(
              color: ColoresApp.textoSecundario,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            valor,
            style: const TextStyle(
              color: ColoresApp.textoPrimario,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Los demás métodos (_mostrarDialogoTextoMarquee, _mostrarEstadisticas, etc.) siguen igual
  // [Métodos restantes igual que antes...]

  void _mostrarDialogoTextoMarquee() async {
    final TextEditingController controller = TextEditingController();

    try {
      print('🔍 Admin: Cargando configuración actual...');
      final config = await _firebaseService.obtenerConfiguracion().first;
      controller.text = config.textoMarquee;
      print('✅ Admin: Texto actual cargado: "${config.textoMarquee}"');
    } catch (e) {
      print('❌ Admin: Error cargando configuración: $e');
      controller.text = '¡Bienvenidos a Naboo Customs!';
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: ColoresApp.tarjetaOscura,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: ColoresApp.cyanPrimario.withOpacity(0.3)),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColoresApp.cyanPrimario.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.text_fields, color: ColoresApp.cyanPrimario, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Editar Texto Marquee',
                  style: TextStyle(
                    color: ColoresApp.textoPrimario,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Este texto se mostrará deslizándose en la pantalla principal de todos los usuarios.',
                  style: TextStyle(
                    color: ColoresApp.textoSecundario,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  decoration: BoxDecoration(
                    color: ColoresApp.superficieOscura,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ColoresApp.bordeGris),
                  ),
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(
                      color: ColoresApp.textoPrimario,
                      fontSize: 16,
                    ),
                    maxLines: 3,
                    maxLength: 120,
                    decoration: InputDecoration(
                      hintText: 'Ej: ¡Nuevas figuras disponibles! Visita nuestro catálogo 🚀',
                      hintStyle: TextStyle(
                        color: ColoresApp.textoApagado,
                        fontSize: 14,
                      ),
                      filled: false,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                      counterStyle: TextStyle(
                        color: ColoresApp.textoSecundario,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Preview
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColoresApp.cyanPrimario.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: controller,
                      builder: (context, value, child) {
                        final texto = value.text.isEmpty
                            ? 'Vista previa del texto...'
                            : value.text;

                        return Container(
                          width: double.infinity,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              texto,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '↑ Vista previa de cómo se verá en la pantalla principal',
                  style: TextStyle(
                    color: ColoresApp.textoApagado,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: ColoresApp.textoSecundario),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _guardarTextoMarquee(dialogContext, controller.text),
              icon: const Icon(Icons.save, size: 18),
              label: const Text('Guardar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColoresApp.cyanPrimario,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _guardarTextoMarquee(BuildContext dialogContext, String nuevoTexto) async {
    print('🔄 Admin: Iniciando guardado de texto: "$nuevoTexto"');

    if (nuevoTexto.trim().isEmpty) {
      print('❌ Admin: Texto vacío, cancelando guardado');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ El texto no puede estar vacío'),
          backgroundColor: ColoresApp.error,
        ),
      );
      return;
    }

    try {
      // Mostrar indicador de carga
      showDialog(
        context: dialogContext,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ColoresApp.tarjetaOscura,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: ColoresApp.cyanPrimario),
                const SizedBox(height: 16),
                const Text(
                  'Guardando texto...',
                  style: TextStyle(color: ColoresApp.textoPrimario),
                ),
              ],
            ),
          ),
        ),
      );

      // Obtener configuración actual
      final configActual = await _firebaseService.obtenerConfiguracion().first;

      // Crear nueva configuración con el texto actualizado
      final nuevaConfig = configActual.copiarCon(
        textoMarquee: nuevoTexto.trim(),
      );

      // Guardar en Firebase
      final exito = await _firebaseService.actualizarConfiguracion(nuevaConfig);

      // Cerrar indicador de carga
      if (mounted) Navigator.of(context).pop();

      if (exito) {
        // Cerrar diálogo principal
        if (mounted) Navigator.of(dialogContext).pop();

        // Mostrar mensaje de éxito
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '✅ Texto guardado: "${nuevoTexto.trim()}"',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: ColoresApp.exito,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        throw Exception('Firebase devolvió false al guardar');
      }
    } catch (e) {
      print('❌ Admin: ERROR guardando texto marquee: $e');

      // Cerrar indicador de carga si está abierto
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Mostrar error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('❌ Error guardando texto'),
                Text('Detalles: $e', style: TextStyle(fontSize: 12)),
              ],
            ),
            backgroundColor: ColoresApp.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _mostrarEstadisticas() {
    final figuras = _infoSistema['figuras'] as Map<String, int>? ?? {};
    final usuarios = _infoSistema['usuarios'] as int? ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColoresApp.tarjetaOscura,
        title: Row(
          children: [
            Icon(Icons.analytics, color: ColoresApp.azulPrimario),
            const SizedBox(width: 8),
            const Text(
              'Estadísticas del Sistema',
              style: TextStyle(color: ColoresApp.textoPrimario),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _estatistica('Usuarios Activos', '$usuarios', ColoresApp.verdeAcento),
            _estatistica('Naves Disponibles', '${figuras['naves'] ?? 0}', ColoresApp.azulPrimario),
            _estatistica('Dioramas Disponibles', '${figuras['dioramas'] ?? 0}', ColoresApp.moradoPrimario),
            _estatistica('Total Figuras', '${figuras['total'] ?? 0}', ColoresApp.cyanPrimario),
            _estatistica('Conexiones Bluetooth', '0', ColoresApp.advertencia),
            _estatistica('Imágenes en Cloudinary', '${(figuras['total'] ?? 0) * 2}', ColoresApp.naranjaAcento),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: ColoresApp.azulPrimario),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _estatistica(String titulo, String valor, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                color: ColoresApp.textoPrimario,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColoresApp.tarjetaOscura,
        title: Row(
          children: [
            Icon(Icons.list_alt, color: ColoresApp.advertencia),
            const SizedBox(width: 8),
            const Text(
              'Logs del Sistema',
              style: TextStyle(color: ColoresApp.textoPrimario),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _logEntry('✅', '10:30:25', 'Firebase OK'),
                  _logEntry('✅', '10:30:26', 'AuthService OK'),
                  _logEntry('✅', '10:30:27', 'Cloudinary OK'),
                  _logEntry('📊', '10:45:12', 'Info sistema cargada'),
                  _logEntry('👤', '10:47:33', 'Admin logueado'),
                  _logEntry('⚙️', '10:48:15', 'Config actualizada'),
                  _logEntry('🖼️', '10:50:20', 'Figura creada'),
                  _logEntry('📝', '10:52:10', 'Marquee editado'),
                ],
              ),
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: ColoresApp.advertencia),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _logEntry(String emoji, String tiempo, String mensaje) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          Text(
            tiempo,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensaje,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarInfoAdmin(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColoresApp.tarjetaOscura,
        title: Row(
          children: [
            Icon(Icons.admin_panel_settings, color: ColoresApp.rojoAcento),
            const SizedBox(width: 8),
            const Text(
              'Panel de Admin',
              style: TextStyle(color: ColoresApp.textoPrimario),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Naboo Customs Controller Admin',
              style: TextStyle(
                color: ColoresApp.textoPrimario,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Panel de control completo para gestionar:\n\n'
                  '• Figuras (Naves y Dioramas)\n'
                  '• Usuarios y permisos\n'
                  '• Publicidad push\n'
                  '• Configuración del sistema\n'
                  '• Monitoreo y estadísticas',
              style: TextStyle(color: ColoresApp.textoSecundario),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ColoresApp.rojoAcento.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, color: ColoresApp.rojoAcento, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Acceso restringido a administradores',
                      style: TextStyle(
                        color: ColoresApp.rojoAcento,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: ColoresApp.rojoAcento),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
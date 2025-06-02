import 'package:flutter/material.dart';
import '../servicios/auth_service.dart';
import '../modelos/usuario.dart';
import '../nucleo/constantes/colores_app.dart';

class PantallaGestionUsuarios extends StatefulWidget {
  const PantallaGestionUsuarios({super.key});

  @override
  State<PantallaGestionUsuarios> createState() => _PantallaGestionUsuariosState();
}

class _PantallaGestionUsuariosState extends State<PantallaGestionUsuarios> {
  final TextEditingController _busquedaController = TextEditingController();
  String _terminoBusqueda = '';
  List<Usuario> _usuarios = [];
  bool _cargando = false;

  // CREAR INSTANCIA DIRECTA SIN PROVIDER
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> _cargarUsuarios() async {
    print('📋 Iniciando carga de usuarios...');
    setState(() => _cargando = true);

    try {
      final usuarios = await _authService.cargarUsuariosManuales();
      print('✅ Usuarios obtenidos: ${usuarios.length}');

      if (mounted) {
        setState(() {
          _usuarios = usuarios;
          _cargando = false;
        });
      }
    } catch (e) {
      print('❌ Error cargando usuarios: $e');
      if (mounted) {
        setState(() => _cargando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando usuarios: $e'),
            backgroundColor: ColoresApp.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('GESTIÓN DE USUARIOS'),
        backgroundColor: ColoresApp.superficieOscura,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: ColoresApp.cyanPrimario),
            onPressed: _cargarUsuarios,
          ),
          IconButton(
            icon: const Icon(Icons.person_add, color: ColoresApp.cyanPrimario),
            onPressed: _mostrarDialogoCrearUsuario,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: ColoresApp.gradienteFondo,
        ),
        child: Column(
          children: [
            // Barra de búsqueda
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _busquedaController,
                style: const TextStyle(color: ColoresApp.textoPrimario),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o usuario...',
                  hintStyle: const TextStyle(color: ColoresApp.textoApagado),
                  prefixIcon: const Icon(Icons.search, color: ColoresApp.cyanPrimario),
                  filled: true,
                  fillColor: ColoresApp.tarjetaOscura,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _terminoBusqueda = value.toLowerCase();
                  });
                },
              ),
            ),

            // Información de debug
            if (_cargando)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Cargando usuarios desde Firestore...',
                  style: TextStyle(color: ColoresApp.textoSecundario),
                ),
              ),

            if (!_cargando && _usuarios.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Total usuarios encontrados: ${_usuarios.length}',
                  style: const TextStyle(color: ColoresApp.textoSecundario),
                ),
              ),

            if (!_cargando && _usuarios.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Mostrando ${_usuarios.length} usuarios',
                  style: const TextStyle(color: ColoresApp.verdeAcento),
                ),
              ),

            // Lista de usuarios
            Expanded(
              child: _cargando
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: ColoresApp.cyanPrimario),
                    SizedBox(height: 16),
                    Text(
                      'Cargando usuarios...',
                      style: TextStyle(color: ColoresApp.textoSecundario),
                    ),
                  ],
                ),
              )
                  : _construirListaUsuarios(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoCrearUsuario,
        backgroundColor: ColoresApp.cyanPrimario,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _construirListaUsuarios() {
    final usuariosFiltrados = _usuarios.where((usuario) {
      if (_terminoBusqueda.isEmpty) return true;
      return usuario.nombre.toLowerCase().contains(_terminoBusqueda) ||
          usuario.email.split('@')[0].toLowerCase().contains(_terminoBusqueda);
    }).toList();

    if (usuariosFiltrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: 64,
              color: ColoresApp.textoApagado,
            ),
            const SizedBox(height: 16),
            Text(
              _terminoBusqueda.isEmpty
                  ? 'No hay usuarios registrados'
                  : 'No se encontraron usuarios',
              style: const TextStyle(
                color: ColoresApp.textoSecundario,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarUsuarios,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColoresApp.cyanPrimario,
              ),
              child: const Text('Recargar'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _mostrarDialogoCrearUsuario,
              icon: const Icon(Icons.person_add),
              label: const Text('Crear Primer Usuario'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColoresApp.verdeAcento,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: usuariosFiltrados.length,
      itemBuilder: (context, index) {
        final usuario = usuariosFiltrados[index];
        return _construirTarjetaUsuario(usuario);
      },
    );
  }

  Widget _construirTarjetaUsuario(Usuario usuario) {
    String nombreUsuario = usuario.email.split('@')[0];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ColoresApp.tarjetaOscura,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: usuario.estaActivo
              ? ColoresApp.bordeGris
              : ColoresApp.error.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: usuario.esAdmin
                ? ColoresApp.rojoAcento.withOpacity(0.1)
                : ColoresApp.cyanPrimario.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            usuario.esAdmin ? Icons.admin_panel_settings : Icons.person,
            color: usuario.esAdmin ? ColoresApp.rojoAcento : ColoresApp.cyanPrimario,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    usuario.nombre,
                    style: const TextStyle(
                      color: ColoresApp.textoPrimario,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@$nombreUsuario',
                    style: const TextStyle(
                      color: ColoresApp.textoSecundario,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (usuario.esAdmin)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ColoresApp.rojoAcento.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'ADMIN',
                  style: TextStyle(
                    color: ColoresApp.rojoAcento,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: usuario.estaActivo ? ColoresApp.exito : ColoresApp.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  usuario.estaActivo ? 'Activo' : 'Inactivo',
                  style: TextStyle(
                    color: usuario.estaActivo ? ColoresApp.exito : ColoresApp.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    'ID: ${usuario.id.substring(0, 8)}...',
                    style: const TextStyle(
                      color: ColoresApp.textoApagado,
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: ColoresApp.textoSecundario),
          color: ColoresApp.tarjetaOscura,
          onSelected: (value) async {
            switch (value) {
              case 'toggle_estado':
                await _cambiarEstadoUsuario(usuario);
                break;
              case 'eliminar':
                await _confirmarEliminarUsuario(usuario);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle_estado',
              child: Row(
                children: [
                  Icon(
                    usuario.estaActivo ? Icons.block : Icons.check_circle,
                    color: usuario.estaActivo ? ColoresApp.advertencia : ColoresApp.exito,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    usuario.estaActivo ? 'Desactivar' : 'Activar',
                    style: const TextStyle(color: ColoresApp.textoPrimario),
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'eliminar',
              child: Row(
                children: [
                  Icon(Icons.delete, color: ColoresApp.error, size: 20),
                  SizedBox(width: 8),
                  Text('Eliminar', style: TextStyle(color: ColoresApp.error)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoCrearUsuario() {
    showDialog(
      context: context,
      builder: (dialogContext) => _DialogoUsuario(
        titulo: 'Crear Usuario',
        onGuardar: (usuario, nombre, password, rol) async {
          print('🔧 Creando usuario: $usuario');

          final resultado = await _authService.crearUsuario(
            usuario: usuario,
            nombre: nombre,
            password: password,
            rol: rol,
          );

          if (mounted) {
            if (resultado.exitoso) {
              print('✅ Usuario creado exitosamente');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Usuario creado exitosamente'),
                  backgroundColor: ColoresApp.exito,
                ),
              );
              Navigator.of(dialogContext).pop();
              await _cargarUsuarios();
            } else {
              print('❌ Error creando usuario: ${resultado.error}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(resultado.error ?? 'Error desconocido'),
                  backgroundColor: ColoresApp.error,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _cambiarEstadoUsuario(Usuario usuario) async {
    final exito = await _authService.cambiarEstadoUsuario(
      usuario.id,
      !usuario.estaActivo,
    );

    if (mounted) {
      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                usuario.estaActivo ? 'Usuario desactivado' : 'Usuario activado'),
            backgroundColor: ColoresApp.exito,
          ),
        );
        await _cargarUsuarios();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cambiar estado del usuario'),
            backgroundColor: ColoresApp.error,
          ),
        );
      }
    }
  }

  Future<void> _confirmarEliminarUsuario(Usuario usuario) async {
    String nombreUsuario = usuario.email.split('@')[0];

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: ColoresApp.tarjetaOscura,
        title: const Text(
          'Confirmar Eliminación',
          style: TextStyle(color: ColoresApp.textoPrimario),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar al usuario "@$nombreUsuario" (${usuario.nombre})?\n\nEsta acción no se puede deshacer.',
          style: const TextStyle(color: ColoresApp.textoSecundario),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: ColoresApp.textoSecundario)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColoresApp.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final exito = await _authService.eliminarUsuario(usuario.id);

      if (mounted) {
        if (exito) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuario eliminado exitosamente'),
              backgroundColor: ColoresApp.exito,
            ),
          );
          await _cargarUsuarios();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al eliminar usuario'),
              backgroundColor: ColoresApp.error,
            ),
          );
        }
      }
    }
  }
}

class _DialogoUsuario extends StatefulWidget {
  final String titulo;
  final Function(String usuario, String nombre, String password, String rol) onGuardar;

  const _DialogoUsuario({
    required this.titulo,
    required this.onGuardar,
  });

  @override
  State<_DialogoUsuario> createState() => _DialogoUsuarioState();
}

class _DialogoUsuarioState extends State<_DialogoUsuario> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _nombreController = TextEditingController();
  final _passwordController = TextEditingController();
  String _rolSeleccionado = 'cliente';
  bool _mostrarPassword = false;

  @override
  void dispose() {
    _usuarioController.dispose();
    _nombreController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ColoresApp.tarjetaOscura,
      title: Text(
        widget.titulo,
        style: const TextStyle(color: ColoresApp.textoPrimario),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _usuarioController,
                style: const TextStyle(color: ColoresApp.textoPrimario),
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  hintText: 'juan123, maria_garcia, etc.',
                  prefixIcon: Icon(Icons.person, color: ColoresApp.cyanPrimario),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un usuario';
                  }
                  if (value.length < 3) {
                    return 'El usuario debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreController,
                style: const TextStyle(color: ColoresApp.textoPrimario),
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.badge, color: ColoresApp.cyanPrimario),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: !_mostrarPassword,
                style: const TextStyle(color: ColoresApp.textoPrimario),
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock, color: ColoresApp.cyanPrimario),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _mostrarPassword ? Icons.visibility : Icons.visibility_off,
                      color: ColoresApp.textoSecundario,
                    ),
                    onPressed: () => setState(() => _mostrarPassword = !_mostrarPassword),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una contraseña';
                  }
                  if (value.length < 4) {
                    return 'La contraseña debe tener al menos 4 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _rolSeleccionado,
                style: const TextStyle(color: ColoresApp.textoPrimario),
                decoration: const InputDecoration(
                  labelText: 'Rol',
                  prefixIcon: Icon(Icons.admin_panel_settings, color: ColoresApp.cyanPrimario),
                ),
                dropdownColor: ColoresApp.tarjetaOscura,
                items: const [
                  DropdownMenuItem(
                    value: 'cliente',
                    child: Text('Cliente'),
                  ),
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Administrador'),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _rolSeleccionado = value ?? 'cliente');
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: ColoresApp.textoSecundario)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onGuardar(
                _usuarioController.text.trim(),
                _nombreController.text.trim(),
                _passwordController.text,
                _rolSeleccionado,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ColoresApp.cyanPrimario,
            foregroundColor: Colors.white,
          ),
          child: const Text('Crear'),
        ),
      ],
    );
  }
}
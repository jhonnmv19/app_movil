import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/usuario_model.dart';
import '../../../data/services/session_service.dart';
import '../../../data/services/usuarios_service.dart';
import '../../../data/services/favoritos_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UsuariosService _usuariosService = UsuariosService();
  final FavoritosService _favoritosService = FavoritosService();
  UsuarioModel? _usuario;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final user = SessionService().usuarioActual;
    if (mounted) {
      setState(() {
        _usuario = user;
        _isLoading = false;
      });
    }
  }

  Future<void> _cerrarSesion() async {
    try {
      SessionService().cerrarSesion();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.welcome,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.accentLightOrange,
                    child: Text(
                      _usuario?.nombreCompleto.isNotEmpty == true
                          ? _usuario!.nombreCompleto[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryOrange,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _usuario?.nombreCompleto.isNotEmpty == true
                        ? _usuario!.nombreCompleto
                        : 'Usuario Comensal',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    _usuario?.email ?? 'Sin correo registrado',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: const Icon(Icons.edit, color: AppTheme.primaryOrange),
                    title: const Text('Editar Datos Personales'),
                    onTap: () => _dialogoEditarPerfil(context),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.favorite, color: AppTheme.primaryOrange),
                    title: const Text('Mis Platos / Lugares Favoritos'),
                    onTap: () {
                      if (_usuario != null) {
                        _mostrarModalFavoritos(context, _usuario!.id);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No hay sesión de usuario activa.'),
                          ),
                        );
                      }
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.help_outline, color: AppTheme.primaryOrange),
                    title: const Text('Ayuda y Soporte Técnico'),
                    subtitle: const Text('Reporta ubicaciones incorrectas o fallos'),
                    onTap: () => _dialogoSoporte(context),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    onTap: _cerrarSesion,
                  ),
                ],
              ),
            ),
    );
  }

  void _mostrarModalFavoritos(BuildContext context, int usuarioId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return Container(
          height: MediaQuery.of(modalContext).size.height * 0.7,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mis Favoritos Guardados',
                style: Theme.of(modalContext).textTheme.titleLarge,
              ),
              const Divider(),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _favoritosService.obtenerFavoritos(usuarioId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No tienes elementos guardados en favoritos.'),
                      );
                    }

                    final favoritos = snapshot.data!;

                    return ListView.builder(
                      itemCount: favoritos.length,
                      itemBuilder: (context, index) {
                        final item = favoritos[index];
                        final bool esEstablecimiento = item['establecimientos_r_sabor'] != null;
                        final data = esEstablecimiento
                            ? item['establecimientos_r_sabor']
                            : item['platillos_r_sabor'];

                        if (data == null) return const SizedBox.shrink();

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                esEstablecimiento
                                    ? (data['imagen_portada'] ?? '')
                                    : (data['imagen_url'] ?? ''),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.restaurant),
                              ),
                            ),
                            title: Text(
                              esEstablecimiento
                                  ? (data['nombre_comercial'] ?? '')
                                  : (data['nombre'] ?? ''),
                            ),
                            subtitle: Text(
                              esEstablecimiento
                                  ? (data['descripcion'] ?? 'Establecimiento')
                                  : 'Precio: Bs. ${data['precio_bs']}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () async {
                                final exito = await _favoritosService.eliminarFavorito(item['id']);
                                if (exito && modalContext.mounted) {
                                  Navigator.pop(modalContext);
                                  _mostrarModalFavoritos(context, usuarioId);
                                }
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

 void _dialogoEditarPerfil(BuildContext context) {
  final controllerNombre = TextEditingController(text: _usuario?.nombreCompleto);
  final controllerTel = TextEditingController(text: _usuario?.telefono);
  bool isSaving = false;

  showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text('Editar Perfil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controllerNombre,
                decoration: const InputDecoration(labelText: 'Nombre Completo'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controllerTel,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      final nuevoNombre = controllerNombre.text.trim();
                      final nuevoTel = controllerTel.text.trim();

                      if (nuevoNombre.isEmpty) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(content: Text('El nombre no puede estar vacío')),
                        );
                        return;
                      }

                      if (_usuario == null) return;

                      setDialogState(() => isSaving = true);

                      // 1. Petición a Supabase
                      final exito = await _usuariosService.actualizarPerfil(
                        _usuario!.id,
                        nuevoNombre,
                        nuevoTel,
                      );

                      if (!mounted) return;

                      if (exito) {
                        // 2. Actualizar objeto en sesión local
                        final usuarioActualizado = _usuario!.copyWith(
                          nombreCompleto: nuevoNombre,
                          telefono: nuevoTel,
                        );
                        SessionService().iniciarSesion(usuarioActualizado);

                        // 3. Refrescar estado del Widget principal
                        setState(() {
                          _usuario = usuarioActualizado;
                        });

                        // 4. Cerrar Diálogo
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }

                        // 5. Notificar éxito en la pantalla principal
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Perfil actualizado correctamente'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        setDialogState(() => isSaving = false);
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(
                            content: Text('Error al actualizar en la base de datos'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar'),
            ),
          ],
        );
      },
    ),
  ).then((_) {
    controllerNombre.dispose();
    controllerTel.dispose();
  });
}

  void _dialogoSoporte(BuildContext context) {
    final controllerReporte = TextEditingController();
    bool isSending = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Reportar un Problema'),
            content: TextField(
              controller: controllerReporte,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Ejemplo: La ubicación del restaurante X no coincide en el mapa...',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSending ? null : () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: isSending
                    ? null
                    : () async {
                        final texto = controllerReporte.text.trim();
                        if (texto.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Por favor escribe una descripción del problema')),
                          );
                          return;
                        }

                        setDialogState(() => isSending = true);

                        await Future.delayed(const Duration(seconds: 1));

                        if (mounted) {
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reporte enviado con éxito. Gracias por contribuir.'),
                            ),
                          );
                        }
                      },
                child: isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enviar'),
              ),
            ],
          );
        },
      ),
    ).then((_) {
      controllerReporte.dispose();
    });
  }
}
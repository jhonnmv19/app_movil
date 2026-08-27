import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/usuario_model.dart';
import '../../../data/services/establecimiento_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final EstablecimientoService _service = EstablecimientoService();
  UsuarioModel? _usuario;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final user = await _service.obtenerPerfilUsuarioActual();
    if (mounted) {
      setState(() {
        _usuario = user;
        _isLoading = false;
      });
    }
  }

  Future<void> _cerrarSesion() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        // Elimina todo el historial de navegación y regresa a la bienvenida
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cargando lista de favoritos guardados...'),
                        ),
                      );
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('El nombre no puede estar vacío')),
                          );
                          return;
                        }

                        if (_usuario != null) {
                          setDialogState(() => isSaving = true);
                          try {
                            await _service.actualizarPerfil(
                              _usuario!.id,
                              nuevoNombre,
                              nuevoTel,
                            );
                            if (mounted) {
                              await _cargarUsuario();
                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Perfil actualizado correctamente'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error al actualizar: $e'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setDialogState(() => isSaving = false);
                            }
                          }
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
      // Liberación de recursos para prevenir fugas de memoria
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

                        if (_usuario != null) {
                          setDialogState(() => isSending = true);
                          try {
                            await _service.enviarReporteSoporte(_usuario!.id, texto);
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
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error al enviar el reporte: $e'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setDialogState(() => isSending = false);
                            }
                          }
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
      // Liberación de recursos para prevenir fugas de memoria
      controllerReporte.dispose();
    });
  }
}
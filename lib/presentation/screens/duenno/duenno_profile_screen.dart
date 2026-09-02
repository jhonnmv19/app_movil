import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/session_service.dart';
import '../../../data/services/usuarios_service.dart';

class DuennoProfileScreen extends StatefulWidget {
  const DuennoProfileScreen({super.key});

  @override
  State<DuennoProfileScreen> createState() => _DuennoProfileScreenState();
}

class _DuennoProfileScreenState extends State<DuennoProfileScreen> {
  late Future<Map<String, dynamic>?> _perfilFuture;
  final UsuariosService _usuariosService = UsuariosService();

  @override
  void initState() {
    super.initState();
    _perfilFuture = _cargarPerfil();
  }

  Future<Map<String, dynamic>?> _cargarPerfil() async {
    final usuarioActual = SessionService().usuarioActual;
    if (usuarioActual == null) return null;

    return await _usuariosService.obtenerPerfilDueno(usuarioActual.id);
  }

  Future<void> _recargarPerfil() async {
    setState(() {
      _perfilFuture = _cargarPerfil();
    });
    await _perfilFuture;
  }

  Future<void> _cerrarSesion() async {
    SessionService().cerrarSesion();

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  Map<String, dynamic>? _normalizarEstablecimiento(dynamic data) {
    if (data == null) return null;

    if (data is List && data.isNotEmpty) {
      return Map<String, dynamic>.from(data.first as Map);
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return null;
  }

  String _obtenerCategoria(Map<String, dynamic>? establecimiento) {
    final categoriaRaw = establecimiento?['categorias_negocio_r_sabor'];

    if (categoriaRaw is List && categoriaRaw.isNotEmpty) {
      final first = categoriaRaw.first;
      if (first is Map) {
        return (first['nombre'] ?? 'Sin categoría').toString();
      }
    }

    if (categoriaRaw is Map) {
      return (categoriaRaw['nombre'] ?? 'Sin categoría').toString();
    }

    return 'Sin categoría';
  }

  String _obtenerEstadoLocal(Map<String, dynamic>? establecimiento) {
    final estado = establecimiento?['estado_local'];
    if (estado == null || estado.toString().trim().isEmpty) {
      return 'Sin estado';
    }
    return estado.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Mi Perfil de Negocio'),
        elevation: 0,
        backgroundColor: const Color(0xFFF7F7F7),
        surfaceTintColor: Colors.transparent,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _perfilFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryOrange,
              ),
            );
          }

          if (snapshot.hasError || snapshot.data == null) {
            return _ErrorView(onRetry: _recargarPerfil);
          }

          final data = snapshot.data!;
          final establecimiento = _normalizarEstablecimiento(
            data['establecimientos_r_sabor'],
          );

          final categoria = _obtenerCategoria(establecimiento);
          final usuarioActivo = data['estado'] == 'activo';
          final verificado = establecimiento?['verificado'] == true;
          final nombreNegocio =
              establecimiento?['nombre_comercial'] ?? 'Sin nombre';
          final descripcion = establecimiento?['descripcion'] ??
              'Aún no agregaste una descripción del negocio.';
          final direccion =
              establecimiento?['direccion_texto'] ?? 'No especificada';
          final estadoLocal = _obtenerEstadoLocal(establecimiento);
          final calificacion =
              ((establecimiento?['calificacion_promedio'] as num?) ?? 0)
                  .toDouble();

          return RefreshIndicator(
            color: AppTheme.primaryOrange,
            onRefresh: _recargarPerfil,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                _OwnerHeader(
                  nombre: data['nombre_completo'] ?? 'Sin Nombre',
                  rol: (data['rol'] ?? 'dueño').toString().toUpperCase(),
                  usuarioActivo: usuarioActivo,
                ),
                const SizedBox(height: 22),
                if (establecimiento != null)
                  _BusinessProfileCard(
                    nombreNegocio: nombreNegocio,
                    categoria: categoria,
                    estadoLocal: estadoLocal,
                    verificado: verificado,
                    descripcion: descripcion,
                    direccion: direccion,
                    calificacion: calificacion,
                  )
                else
                  Card(
                    color: Colors.amber.shade50,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.amber.shade200),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.amber),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Todavía no tienes un restaurante registrado.',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 26),
                const _SectionTitle(title: 'Datos personales'),
                const SizedBox(height: 10),
                _InfoCard(
                  children: [
                    _InfoTile(
                      icon: Icons.email_outlined,
                      title: 'Correo electrónico',
                      value: data['email'] ?? 'No registrado',
                    ),
                    _InfoTile(
                      icon: Icons.phone_outlined,
                      title: 'Teléfono de contacto',
                      value: data['telefono'] ?? 'No registrado',
                      showDivider: false,
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                const _SectionTitle(title: 'Acciones'),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _cerrarSesion,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text(
                      'Cerrar sesión',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: BorderSide(color: Colors.red.shade200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OwnerHeader extends StatelessWidget {
  final String nombre;
  final String rol;
  final bool usuarioActivo;

  const _OwnerHeader({
    required this.nombre,
    required this.rol,
    required this.usuarioActivo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 44,
            backgroundColor: AppTheme.accentLightOrange,
            child: Icon(
              Icons.storefront_rounded,
              size: 42,
              color: AppTheme.primaryOrange,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            nombre,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: usuarioActivo
                  ? AppTheme.primaryOrange
                  : Colors.orange.shade100,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  usuarioActivo ? Icons.check_circle : Icons.timelapse_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  rol,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
}

class _BusinessProfileCard extends StatelessWidget {
  final String nombreNegocio;
  final String categoria;
  final String estadoLocal;
  final bool verificado;
  final String descripcion;
  final String direccion;
  final double calificacion;

  const _BusinessProfileCard({
    required this.nombreNegocio,
    required this.categoria,
    required this.estadoLocal,
    required this.verificado,
    required this.descripcion,
    required this.direccion,
    required this.calificacion,
  });

  @override
  Widget build(BuildContext context) {
    final estadoColor = verificado ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  nombreNegocio,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: estadoColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      verificado
                          ? Icons.verified_rounded
                          : Icons.pending_rounded,
                      size: 16,
                      color: estadoColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      verificado ? 'Verificado' : 'Pendiente',
                      style: TextStyle(
                        color: estadoColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _MiniPill(icon: Icons.category_outlined, label: categoria),
              const SizedBox(width: 8),
              _MiniPill(icon: Icons.circle, label: estadoLocal),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
              const SizedBox(width: 6),
              Text(
                calificacion.toStringAsFixed(1),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'calificación',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Descripción',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            descripcion,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Dirección',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 18, color: AppTheme.primaryOrange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  direccion,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.accentLightOrange,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryOrange),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryOrange,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool showDivider;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppTheme.primaryOrange),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          subtitle: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppTheme.primaryOrange,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              'No se pudo cargar el perfil.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
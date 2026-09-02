import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/establecimiento_model.dart';
import '../../../data/services/establecimiento_service.dart';
import '../../../data/services/session_service.dart';
import '../../../data/services/solicitudes_service.dart';

class DuennoHomeScreen extends StatefulWidget {
  const DuennoHomeScreen({super.key});

  @override
  State<DuennoHomeScreen> createState() => _DuennoHomeScreenState();
}

class _DuennoHomeScreenState extends State<DuennoHomeScreen> {
  final EstablecimientoService _establecimientoService = EstablecimientoService();
  final SolicitudesService _solicitudesService = SolicitudesService();

  bool _isLoading = true;
  bool _estaAbierto = false;
  bool _actualizandoEstado = false;

  EstablecimientoModel? _establecimiento;
  String _estadoSolicitud = 'SIN SOLICITUD';

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  Future<void> _cargarDatosIniciales() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final usuario = SessionService().usuarioActual;

      if (usuario != null) {
        debugPrint('[DuennoHomeScreen] Cargando datos para usuario ID: ${usuario.id}');

        // 1. Obtener estado de la solicitud enviada por el usuario
        final estadoSol = await _solicitudesService.obtenerEstadoSolicitudUsuario(usuario.id);

        // 2. Obtener el establecimiento asociado al dueño (Paso posicional del ID)
        final estab = await _establecimientoService.obtenerEstablecimientoDelUsuario(usuario.id);

        if (mounted) {
          setState(() {
            _establecimiento = estab;
            _estaAbierto = (estab?.estadoLocal?.toLowerCase() == 'abierto');
            _estadoSolicitud = estadoSol;
          });
        }
      } else {
        debugPrint('[DuennoHomeScreen] Advertencia: No se encontró sesión activa.');
      }
    } catch (e) {
      debugPrint('[DuennoHomeScreen] Error al cargar datos: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleEstadoLocal(bool nuevoEstado) async {
    if (_establecimiento == null) return;

    setState(() {
      _actualizandoEstado = true;
      _estaAbierto = nuevoEstado;
    });

    try {
      final estadoStr = nuevoEstado ? 'abierto' : 'cerrado';
      await _establecimientoService.actualizarEstadoLocal(_establecimiento!.id, estadoStr);
    } catch (e) {
      if (mounted) {
        setState(() => _estaAbierto = !nuevoEstado);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cambiar el estado del local.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _actualizandoEstado = false);
      }
    }
  }

  void _abrirMenuDigital() {
    if (_establecimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes tener un local asignado para gestionar el menú.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.duennoMenu,
      arguments: {'establecimientoId': _establecimiento!.id},
    );
  }

  void _abrirSolicitudes() {
    Navigator.pushNamed(
      context,
      AppRoutes.duennoRequests,
      arguments: {
        'establecimientoId': _establecimiento?.id,
        'estadoSolicitud': _estadoSolicitud,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryOrange),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primaryOrange,
          onRefresh: _cargarDatosIniciales,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              if (_establecimiento != null) ...[
                _buildBusinessStatus(),
                const SizedBox(height: 24),
              ] else ...[
                _buildBannerSinEstablecimiento(),
                const SizedBox(height: 24),
              ],
              _buildOfferCard(),
              const SizedBox(height: 26),
              const Text(
                'Gestión del Negocio',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Menú Digital',
                      value: _establecimiento != null ? 'Ver Platos' : 'Sin Local',
                      icon: Icons.menu_book_rounded,
                      color: Colors.blue,
                      onTap: _abrirMenuDigital,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Estado Solicitud',
                      value: _estadoSolicitud.toUpperCase(),
                      icon: Icons.assignment_turned_in_rounded,
                      color: _getColorEstadoSolicitud(_estadoSolicitud),
                      onTap: _abrirSolicitudes,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorEstadoSolicitud(String estado) {
    switch (estado.toLowerCase()) {
      case 'aprobado':
        return Colors.green;
      case 'pendiente':
        return Colors.orange;
      case 'rechazado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildBannerSinEstablecimiento() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.amber.shade900, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Local no asignado',
                  style: TextStyle(
                    color: Colors.amber.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _estadoSolicitud == 'pendiente'
                      ? 'Tu solicitud está en revisión por un administrador.'
                      : 'Envía tu solicitud para dar de alta tu restaurante.',
                  style: TextStyle(color: Colors.amber.shade800, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final nombreLocal = _establecimiento?.nombreComercial ?? 'Sin Registro de Local';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Panel de Control',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                nombreLocal,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const CircleAvatar(
          radius: 25,
          backgroundColor: AppTheme.accentLightOrange,
          child: Icon(
            Icons.store_rounded,
            color: AppTheme.primaryOrange,
            size: 27,
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessStatus() {
    final color = _estaAbierto ? Colors.green : Colors.red;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.shade300),
      ),
      child: Row(
        children: [
          Icon(
            _estaAbierto
                ? Icons.check_circle_rounded
                : Icons.do_not_disturb_on_rounded,
            color: color.shade700,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _estaAbierto ? 'Local Abierto' : 'Local Cerrado',
                  style: TextStyle(
                    color: color.shade900,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _estaAbierto
                      ? 'Visible para comensales'
                      : 'Oculto en búsquedas',
                  style: TextStyle(
                    color: color.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _actualizandoEstado
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Switch.adaptive(
                  value: _estaAbierto,
                  activeTrackColor: Colors.green,
                  onChanged: _toggleEstadoLocal,
                ),
        ],
      ),
    );
  }

  Widget _buildOfferCard() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      color: AppTheme.primaryOrange,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.restaurant_rounded, color: Colors.white, size: 28),
                SizedBox(width: 10),
                Text(
                  'Plato del Día',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Publica la oferta gastronómica de hoy para atraer más comensales a tu local.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _abrirSolicitudes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Publicar / Actualizar Oferta',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withValues(alpha: 0.1),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
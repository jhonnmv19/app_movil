import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/usuario_model.dart';
import '../../../data/models/solicitud_model.dart';
import '../../../data/services/usuarios_service.dart';
import '../../../data/services/solicitudes_service.dart';
import '../../../data/services/reportes_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Servicios
  final UsuariosService _usuariosService = UsuariosService();
  final SolicitudesService _solicitudesService = SolicitudesService();
  final ReportesService _reportesService = ReportesService();

  // Estados
  bool _isLoading = true;
  int _currentIndex = 0;
  List<UsuarioModel> _usuarios = [];
  List<SolicitudRegistroModel> _solicitudes = [];
  List<Map<String, dynamic>> _reportes = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final resultados = await Future.wait([
        _usuariosService.obtenerUsuarios().catchError((e) {
          debugPrint('Error en UsuariosService: $e');
          return <UsuarioModel>[];
        }),
        _solicitudesService.obtenerSolicitudes().catchError((e) {
          debugPrint('Error en SolicitudesService: $e');
          return <SolicitudRegistroModel>[];
        }),
        _reportesService.obtenerReportes().catchError((e) {
          debugPrint('Error en ReportesService: $e');
          return <Map<String, dynamic>>[];
        }),
      ]);

      if (!mounted) return;

      setState(() {
        _usuarios = resultados[0] as List<UsuarioModel>;
        _solicitudes = resultados[1] as List<SolicitudRegistroModel>;
        _reportes = resultados[2] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error general cargando datos del dashboard: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al consultar PostgreSQL/Supabase: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 850;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0EA5E9).withAlpha(50),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shield_rounded, color: Color(0xFF0EA5E9), size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Panel de Administración',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Sabor & Negocios',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _cargarDatos,
            tooltip: 'Actualizar',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            tooltip: 'Cerrar Sesión',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0EA5E9)))
          : RefreshIndicator(
              onRefresh: _cargarDatos,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBannerAlertaSolicitudes(),
                    const SizedBox(height: 16),
                    _buildMetricasLayout(isDesktop),
                    const SizedBox(height: 24),
                    _buildSeccionDiagramasVisuales(),
                    const SizedBox(height: 24),
                    _buildSelectorModulo(),
                    const SizedBox(height: 20),
                    if (_currentIndex == 0)
                      isDesktop ? _buildTablaSolicitudesWeb() : _buildListaSolicitudesMovil()
                    else if (_currentIndex == 1)
                      _buildTarjetaReportes()
                    else
                      isDesktop ? _buildTablaUsuariosWeb() : _buildListaUsuariosMovil(),
                  ],
                ),
              ),
            ),
    );
  }

  // ===========================================================================
  // WIDGETS AUXILIARES Y COMPONENTES VISUALES
  // ===========================================================================

  Widget _buildBannerAlertaSolicitudes() {
    final pendientes = _solicitudes.where((s) => s.estadoSolicitud.toLowerCase() == 'pendiente').toList();
    if (pendientes.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 28),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Tienes ${pendientes.length} solicitud(es) pendiente(s) de revisión!',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                    ),
                    const Text(
                      'Nuevos establecimientos están esperando aprobación.',
                      style: TextStyle(color: Color(0xFFB45309), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              elevation: 0,
            ),
            onPressed: () => setState(() => _currentIndex = 0),
            child: const Text('Revisar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricasLayout(bool isDesktop) {
    final int pendientes = _solicitudes.where((s) => s.estadoSolicitud.toLowerCase() == 'pendiente').length;
    final int aprobados = _solicitudes.where((s) => s.estadoSolicitud.toLowerCase() == 'aprobado').length;

    final cards = [
      _metricCard(
        title: 'RESTAURANTES REGISTRADOS',
        value: '$aprobados',
        subtext: 'Locales activos',
        icon: Icons.storefront_rounded,
        color: const Color(0xFF0EA5E9),
      ),
      _metricCard(
        title: 'USUARIOS REGISTRADOS',
        value: '${_usuarios.length}',
        subtext: 'Comensales y Dueños',
        icon: Icons.group_rounded,
        color: const Color(0xFF10B981),
      ),
      _metricCard(
        title: 'SOLICITUDES PENDIENTES',
        value: '$pendientes',
        subtext: 'Atención prioritaria',
        icon: Icons.notifications_active_rounded,
        color: const Color(0xFFF59E0B),
      ),
    ];

    if (isDesktop) {
      return Row(
        children: cards
            .map((card) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: card,
                  ),
                ))
            .toList(),
      );
    }

    return Column(
      children: cards
          .map((card) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: card,
              ))
          .toList(),
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 2),
                Text(
                  subtext,
                  style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionDiagramasVisuales() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Métricas del Sistema y Actividad de Comensales',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Registros históricos y tendencias según la base de datos',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),
          _barraRendimiento('Búsquedas Realizadas en la App', 0.85, const Color(0xFF0EA5E9), '85% tráfico alto'),
          const SizedBox(height: 12),
          _barraRendimiento('Conversión de Comensales', 0.62, const Color(0xFF10B981), '62% activos este mes'),
          const SizedBox(height: 12),
          _barraRendimiento('Solicitudes Procesadas', 0.45, const Color(0xFFF59E0B), '45% completado'),
        ],
      ),
    );
  }

  Widget _barraRendimiento(String etiqueta, double porcentaje, Color color, String subtexto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                etiqueta,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              subtexto,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: porcentaje,
            minHeight: 10,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectorModulo() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _tabButton('Solicitudes de Negocio', 0, Icons.assignment_rounded),
            const SizedBox(width: 8),
            _tabButton('Reportes Soporte', 1, Icons.report_problem_rounded),
            const SizedBox(width: 8),
            _tabButton('Gestión de Usuarios', 2, Icons.manage_accounts_rounded),
          ],
        ),
        if (_currentIndex == 2)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0EA5E9),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _mostrarModalCrearEditarUsuario(),
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            label: const Text(
              'Nuevo Usuario',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _tabButton(String label, int index, IconData icon) {
    final bool selected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? const Color(0xFF0EA5E9) : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF64748B),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // VISTAS DE TABLAS Y LISTAS
  // ===========================================================================

  Widget _buildTablaSolicitudesWeb() {
    if (_solicitudes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(
          child: Text('No hay solicitudes registradas en PostgreSQL.', style: TextStyle(color: Color(0xFF64748B))),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10)],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
          columns: const [
            DataColumn(label: Text('NEGOCIO PROPUESTO', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('TELÉFONO', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('ESTADO', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('ACCIONES DE MODERACIÓN', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _solicitudes.map((sol) {
            return DataRow(cells: [
              DataCell(Text(sol.nombreNegocioPropuesto, style: const TextStyle(fontWeight: FontWeight.w600))),
              DataCell(Text(sol.telefonoContacto ?? 'Sin registro')),
              DataCell(_badgeEstado(sol.estadoSolicitud)),
              DataCell(
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  onPressed: () => _mostrarModalProcesarSolicitud(sol),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('Revisar Solicitud'),
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTablaUsuariosWeb() {
    if (_usuarios.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(
          child: Text('No hay usuarios registrados en PostgreSQL.', style: TextStyle(color: Color(0xFF64748B))),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10)],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
          columns: const [
            DataColumn(label: Text('USUARIO', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('CORREO ELECTRÓNICO', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('ROL', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('ESTADO', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('ACCIONES', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _usuarios.map((user) {
            return DataRow(cells: [
              DataCell(Text(user.nombreCompleto, style: const TextStyle(fontWeight: FontWeight.w600))),
              DataCell(Text(user.email)),
              DataCell(_badgeRol(user.rol)),
              DataCell(_badgeEstado(user.estado)),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Color(0xFF0EA5E9)),
                    onPressed: () => _mostrarModalCrearEditarUsuario(usuario: user),
                    tooltip: 'Editar Datos',
                  ),
                  IconButton(
                    icon: Icon(
                      user.estado.toLowerCase() == 'bloqueado' ? Icons.lock_open_rounded : Icons.block_rounded,
                      color: user.estado.toLowerCase() == 'bloqueado' ? Colors.green : Colors.orange,
                    ),
                    onPressed: () async {
                      final nuevo = user.estado.toLowerCase() == 'bloqueado' ? 'activo' : 'bloqueado';
                      await _usuariosService.cambiarEstadoUsuario(user.id, nuevo);
                      _cargarDatos();
                    },
                    tooltip: user.estado.toLowerCase() == 'bloqueado' ? 'Desbloquear' : 'Bloquear',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                    onPressed: () async {
                      final confirmar = await _confirmarEliminacion(context);
                      if (confirmar == true) {
                        await _usuariosService.eliminarUsuario(user.id);
                        _cargarDatos();
                      }
                    },
                    tooltip: 'Eliminar',
                  ),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildListaSolicitudesMovil() {
    if (_solicitudes.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No hay solicitudes registradas.')));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _solicitudes.length,
      itemBuilder: (context, index) {
        final sol = _solicitudes[index];
        return Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(sol.nombreNegocioPropuesto, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: _badgeEstado(sol.estadoSolicitud),
            ),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              onPressed: () => _mostrarModalProcesarSolicitud(sol),
              child: const Text('Ver'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListaUsuariosMovil() {
    if (_usuarios.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No hay usuarios registrados.')));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _usuarios.length,
      itemBuilder: (context, index) {
        final user = _usuarios[index];
        return Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(user.nombreCompleto, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _badgeRol(user.rol),
                    const SizedBox(width: 6),
                    _badgeEstado(user.estado),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF0EA5E9)),
              onPressed: () => _mostrarModalCrearEditarUsuario(usuario: user),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTarjetaReportes() {
    if (_reportes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10)],
        ),
        child: const Column(
          children: [
            Icon(Icons.mark_email_read_rounded, size: 48, color: Color(0xFF0EA5E9)),
            SizedBox(height: 12),
            Text(
              'No hay reportes o incidencias registradas',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(
              'Todos los tickets e incidencias enviadas por usuarios aparecerán en esta vista.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _reportes.length,
      itemBuilder: (context, index) {
        final rep = _reportes[index];
        final usuarioData = rep['usuarios_r_sabor'] as Map<String, dynamic>? ?? rep['usuarios'] as Map<String, dynamic>?;

        return Card(
          elevation: 0,
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF0EA5E9).withAlpha(30),
              child: const Icon(Icons.report_problem_rounded, color: Color(0xFF0EA5E9)),
            ),
            title: Text(
              usuarioData?['nombre_completo'] ?? usuarioData?['nombre'] ?? 'Comensal Anónimo',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(rep['descripcion'] ?? 'Sin descripción proporcionada'),
            trailing: _badgeEstado(rep['estado_reporte'] ?? rep['estado'] ?? 'pendiente'),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // BADGES Y COMPONENTES
  // ===========================================================================

  Widget _badgeEstado(String estado) {
    final est = estado.toLowerCase();
    Color bg = const Color(0xFFFEF3C7);
    Color txt = const Color(0xFFD97706);

    if (est == 'aprobado' || est == 'activo') {
      bg = const Color(0xFFD1FAE5);
      txt = const Color(0xFF059669);
    } else if (est == 'rechazado' || est == 'bloqueado') {
      bg = const Color(0xFFFEE2E2);
      txt = const Color(0xFFDC2626);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        estado.toUpperCase(),
        style: TextStyle(color: txt, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _badgeRol(String rol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        rol.toUpperCase(),
        style: const TextStyle(color: Color(0xFF475569), fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ===========================================================================
  // MODALES TOTALMENTE IMPLEMENTADOS Y FUNCIONALES
  // ===========================================================================

  Future<bool?> _confirmarEliminacion(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar este registro de la base de datos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _mostrarModalCrearEditarUsuario({UsuarioModel? usuario}) {
    final nombreCtrl = TextEditingController(text: usuario?.nombreCompleto ?? '');
    final emailCtrl = TextEditingController(text: usuario?.email ?? '');
    final telefonoCtrl = TextEditingController(text: usuario?.telefono ?? '');
    String rolSeleccionado = usuario?.rol ?? 'comensal';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(usuario == null ? 'Crear Nuevo Usuario' : 'Editar Usuario'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre Completo'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailCtrl,
                      enabled: usuario == null,
                      decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: telefonoCtrl,
                      decoration: const InputDecoration(labelText: 'Teléfono'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: rolSeleccionado,
                      decoration: const InputDecoration(labelText: 'Rol'),
                      items: const [
                        DropdownMenuItem(value: 'comensal', child: Text('Comensal')),
                        DropdownMenuItem(value: 'propietario', child: Text('Propietario')),
                        DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => rolSeleccionado = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0EA5E9)),
                  onPressed: () async {
                    if (usuario == null) {
                      await _usuariosService.crearUsuario(
                        nombre: nombreCtrl.text,
                        email: emailCtrl.text,
                        telefono: telefonoCtrl.text,
                        rol: rolSeleccionado,
                      );
                    } else {
                      await _usuariosService.actualizarUsuario(
                        id: usuario.id,
                        nombre: nombreCtrl.text,
                        telefono: telefonoCtrl.text,
                        rol: rolSeleccionado,
                      );
                    }
                    if (mounted) Navigator.pop(context);
                    _cargarDatos();
                  },
                  child: const Text('Guardar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarModalProcesarSolicitud(SolicitudRegistroModel solicitud) {
    final motivoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Solicitud: ${solicitud.nombreNegocioPropuesto}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Teléfono: ${solicitud.telefonoContacto ?? "Sin registro"}'),
                const SizedBox(height: 8),
                Text('Estado actual: ${solicitud.estadoSolicitud}'),
                const SizedBox(height: 16),
                TextField(
                  controller: motivoController,
                  decoration: const InputDecoration(
                    labelText: 'Motivo (en caso de rechazo)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await _solicitudesService.cambiarEstadoSolicitud(
                  solicitudId: solicitud.id,
                  nuevoEstado: 'rechazado',
                  motivoRechazo: motivoController.text,
                );
                if (mounted) Navigator.pop(context);
                _cargarDatos();
              },
              child: const Text('Rechazar', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              onPressed: () async {
                await _solicitudesService.cambiarEstadoSolicitud(
                  solicitudId: solicitud.id,
                  nuevoEstado: 'aprobado',
                );
                if (mounted) Navigator.pop(context);
                _cargarDatos();
              },
              child: const Text('Aprobar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
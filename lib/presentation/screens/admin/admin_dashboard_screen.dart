import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/usuario_model.dart';
import '../../../data/models/solicitud_model.dart';
import '../../../data/services/usuarios_service.dart';
import '../../../data/services/solicitudes_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final UsuariosService _usuariosService = UsuariosService();
  final SolicitudesService _solicitudesService = SolicitudesService();

  int _currentIndex = 0;
  bool _isLoading = true;

  List<UsuarioModel> _usuarios = [];
  List<SolicitudRegistroModel> _solicitudes = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      final usuariosFuture = _usuariosService.obtenerUsuarios();
      final solicitudesFuture = _solicitudesService.obtenerSolicitudes();

      final resultados = await Future.wait([usuariosFuture, solicitudesFuture]);

      setState(() {
        _usuarios = resultados[0] as List<UsuarioModel>;
        _solicitudes = resultados[1] as List<SolicitudRegistroModel>;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando información: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Detectar si estamos en escritorio o móvil según el ancho
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
                color: const Color(0xFF0EA5E9).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shield_rounded, color: Color(0xFF0EA5E9), size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Panel Admin',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Control total del sistema',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _cargarDatos,
            tooltip: 'Actualizar datos',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            tooltip: 'Cerrar Sesión',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0EA5E9)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Tarjetas de Métricas Directas (Kpis)
                  _buildMetricasGrid(isDesktop),
                  const SizedBox(height: 24),

                  // 2. Navegación / Selector de Módulo
                  _buildSelectorModulo(),
                  const SizedBox(height: 20),

                  // 3. Renderizado Adaptativo (Móvil -> Cards | Desktop -> Tabla CRUD)
                  isDesktop
                      ? (_currentIndex == 0 ? _buildTablaSolicitudesWeb() : _buildTablaUsuariosWeb())
                      : (_currentIndex == 0 ? _buildListaSolicitudesMovil() : _buildListaUsuariosMovil()),
                ],
              ),
            ),
      bottomNavigationBar: isDesktop
          ? null
          : BottomNavigationBar(
              currentIndex: _currentIndex,
              backgroundColor: const Color(0xFF0F172A),
              selectedItemColor: const Color(0xFF0EA5E9),
              unselectedItemColor: const Color(0xFF64748B),
              onTap: (index) => setState(() => _currentIndex = index),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment_turned_in_outlined),
                  activeIcon: Icon(Icons.assignment_turned_in),
                  label: 'Solicitudes',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_alt_outlined),
                  activeIcon: Icon(Icons.people_alt),
                  label: 'Usuarios',
                ),
              ],
            ),
    );
  }

  // --- SECCIÓN 1: MÉTRICAS GENERALES DE IMPACOS ---
  Widget _buildMetricasGrid(bool isDesktop) {
    final int pendientes = _solicitudes.where((s) => s.estadoSolicitud == 'pendiente').length;

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = isDesktop ? 3 : (constraints.maxWidth > 500 ? 3 : 1);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isDesktop ? 2.5 : 2.8,
          children: [
            _metricCard(
              title: 'RESTAURANTES / NEGOCIOS',
              value: '${_solicitudes.where((s) => s.estadoSolicitud == 'aprobado').length}',
              subtext: '+12% este mes',
              icon: Icons.storefront_rounded,
              color: const Color(0xFF0EA5E9),
            ),
            _metricCard(
              title: 'USUARIOS ACTIVOS',
              value: '${_usuarios.length}',
              subtext: 'Comensales & Dueños',
              icon: Icons.group_rounded,
              color: const Color(0xFF10B981),
            ),
            _metricCard(
              title: 'SOLICITUDES / PROMOS',
              value: '$pendientes Nuevas',
              subtext: 'Atención requerida',
              icon: Icons.notifications_active_rounded,
              color: const Color(0xFFF59E0B),
            ),
          ],
        );
      },
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
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
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ],
      ),
    );
  }

  // --- SECCIÓN 2: TABS / SELECTOR ---
  Widget _buildSelectorModulo() {
    return Row(
      children: [
        Expanded(
          child: _tabButton('Solicitudes de Negocio / Promos', 0, Icons.assignment_rounded),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _tabButton('Gestión Integral de Usuarios', 1, Icons.manage_accounts_rounded),
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: selected ? const Color(0xFF0EA5E9) : const Color(0xFF64748B)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SECCIÓN 3.A: VISTA WEB EN TABLAS (CRUD PROFESIONAL) ---
  Widget _buildTablaSolicitudesWeb() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
        columns: const [
          DataColumn(label: Text('NEGOCIO / PROPUESTA', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('TELÉFONO DE CONTACTO', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('ESTADO', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('ACCIONES DE MODERACIÓN', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: _solicitudes.map((sol) {
          return DataRow(cells: [
            DataCell(Text(sol.nombreNegocioPropuesto, style: const TextStyle(fontWeight: FontWeight.w600))),
            DataCell(Text(sol.telefonoContacto ?? 'Sin registro')),
            DataCell(_badgeEstado(sol.estadoSolicitud)),
            DataCell(Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                  onPressed: () async {
                    await _solicitudesService.cambiarEstadoSolicitud(solicitudId: sol.id, nuevoEstado: 'aprobado');
                    _cargarDatos();
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text('Aprobar / Destacar'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent),
                  onPressed: () async {
                    await _solicitudesService.cambiarEstadoSolicitud(solicitudId: sol.id, nuevoEstado: 'rechazado');
                    _cargarDatos();
                  },
                  icon: const Icon(Icons.cancel_outlined, size: 16),
                  label: const Text('Rechazar'),
                ),
              ],
            )),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildTablaUsuariosWeb() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
        columns: const [
          DataColumn(label: Text('USUARIOS', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('CORREO ELECTRÓNICO', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('ROL ASIGNADO', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('ESTADO', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('ACCIONES DE CONTROL', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: _usuarios.map((user) {
          return DataRow(cells: [
            DataCell(Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFF0EA5E9),
                  child: Text(user.nombreCompleto[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Text(user.nombreCompleto, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            )),
            DataCell(Text(user.email)),
            DataCell(_badgeRol(user.rol)),
            DataCell(_badgeEstado(user.estado)),
            DataCell(Row(
              children: [
                IconButton(
                  icon: Icon(user.estado == 'bloqueado' ? Icons.lock_open_rounded : Icons.block_rounded,
                      color: user.estado == 'bloqueado' ? Colors.green : Colors.orange),
                  onPressed: () async {
                    final nuevo = user.estado == 'bloqueado' ? 'activo' : 'bloqueado';
                    await _usuariosService.cambiarEstadoUsuario(user.id, nuevo);
                    _cargarDatos();
                  },
                  tooltip: user.estado == 'bloqueado' ? 'Desbloquear' : 'Bloquear',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                  onPressed: () async {
                    await _usuariosService.eliminarUsuario(user.id);
                    _cargarDatos();
                  },
                  tooltip: 'Eliminar usuario',
                ),
              ],
            )),
          ]);
        }).toList(),
      ),
    );
  }

  // --- SECCIÓN 3.B: VISTA MÓVIL EN TARJETAS ESTILIZADAS ---
  Widget _buildListaSolicitudesMovil() {
    if (_solicitudes.isEmpty) return const Center(child: Text('No hay solicitudes disponibles'));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _solicitudes.length,
      itemBuilder: (context, index) {
        final sol = _solicitudes[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      sol.nombreNegocioPropuesto,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  _badgeEstado(sol.estadoSolicitud),
                ],
              ),
              const SizedBox(height: 8),
              Text('Teléfono: ${sol.telefonoContacto ?? 'N/A'}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      await _solicitudesService.cambiarEstadoSolicitud(solicitudId: sol.id, nuevoEstado: 'rechazado');
                      _cargarDatos();
                    },
                    icon: const Icon(Icons.close, color: Colors.red, size: 16),
                    label: const Text('Rechazar', style: TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0EA5E9), foregroundColor: Colors.white),
                    onPressed: () async {
                      await _solicitudesService.cambiarEstadoSolicitud(solicitudId: sol.id, nuevoEstado: 'aprobado');
                      _cargarDatos();
                    },
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Aprobar'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListaUsuariosMovil() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _usuarios.length,
      itemBuilder: (context, index) {
        final user = _usuarios[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF0F172A),
              child: Icon(user.rol == 'admin' ? Icons.security : Icons.person, color: const Color(0xFF0EA5E9)),
            ),
            title: Text(user.nombreCompleto, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${user.email}\nRol: ${user.rol.toUpperCase()}'),
            trailing: PopupMenuButton<String>(
              onSelected: (accion) async {
                if (accion == 'bloquear') {
                  await _usuariosService.cambiarEstadoUsuario(user.id, 'bloqueado');
                } else if (accion == 'activar') {
                  await _usuariosService.cambiarEstadoUsuario(user.id, 'activo');
                } else if (accion == 'eliminar') {
                  await _usuariosService.eliminarUsuario(user.id);
                }
                _cargarDatos();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: user.estado == 'bloqueado' ? 'activar' : 'bloquear',
                  child: Text(user.estado == 'bloqueado' ? 'Activar Usuario' : 'Bloquear Usuario'),
                ),
                const PopupMenuItem(value: 'eliminar', child: Text('Eliminar', style: TextStyle(color: Colors.red))),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- COMPONENTES VISUALES ---
  Widget _badgeEstado(String estado) {
    Color bg = const Color(0xFFFEF3C7);
    Color txt = const Color(0xFFD97706);

    if (estado == 'aprobado' || estado == 'activo') {
      bg = const Color(0xFFD1FAE5);
      txt = const Color(0xFF059669);
    } else if (estado == 'rechazado' || estado == 'bloqueado') {
      bg = const Color(0xFFFEE2E2);
      txt = const Color(0xFFDC2626);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
}
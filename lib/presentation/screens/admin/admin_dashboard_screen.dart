import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/usuario_model.dart';
import '../../../data/models/solicitud_model.dart';
import '../../../data/services/usuarios_service.dart';
import '../../../data/services/solicitudes_service.dart';
import '../../../data/services/reportes_service.dart';

import 'tabs/admin_metricas_tab.dart';
import 'tabs/admin_solicitudes_tab.dart';
import 'tabs/admin_usuarios_tab.dart';

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

  // Estado principal
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
      // Uso correcto de Future.wait con manejo seguro por cada servicio
      final resultados = await Future.wait<dynamic>([
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

  // ===========================================================================
  // MODALES TOTALMENTE IMPLEMENTADOS (CREAR / EDITAR / REVISAR)
  // ===========================================================================

  void _mostrarModalCrearEditarUsuario({UsuarioModel? usuario}) {
    final bool esEdicion = usuario != null;
    final nombreCtrl = TextEditingController(text: usuario?.nombreCompleto);
    final emailCtrl = TextEditingController(text: usuario?.email);
    final telefonoCtrl = TextEditingController(text: usuario?.telefono);
    String rolSeleccionado = usuario?.rol.toLowerCase() ?? 'comensal';
    String estadoSeleccionado = usuario?.estado.toLowerCase() ?? 'activo';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(esEdicion ? 'Editar Usuario' : 'Crear Nuevo Usuario'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre Completo'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                enabled: !esEdicion,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: telefonoCtrl,
                decoration: const InputDecoration(labelText: 'Teléfono (Opcional)'),
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
                onChanged: (v) => rolSeleccionado = v ?? 'comensal',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: estadoSeleccionado,
                decoration: const InputDecoration(labelText: 'Estado'),
                items: const [
                  DropdownMenuItem(value: 'activo', child: Text('Activo')),
                  DropdownMenuItem(value: 'bloqueado', child: Text('Bloqueado')),
                ],
                onChanged: (v) => estadoSeleccionado = v ?? 'activo',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0EA5E9),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              
              if (esEdicion) {
                await _usuariosService.actualizarUsuario(
                  id: usuario.id,
                  nombre: nombreCtrl.text.trim(),
                  telefono: telefonoCtrl.text.trim(),
                  rol: rolSeleccionado,
                );
              } else {
                await _usuariosService.crearUsuario(
                  nombre: nombreCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  telefono: telefonoCtrl.text.trim(),
                  rol: rolSeleccionado,
                  estado: estadoSeleccionado,
                );
              }
              
              _cargarDatos();
            },
            child: Text(
              esEdicion ? 'Guardar' : 'Crear',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarModalProcesarSolicitud(int solicitudId, String nuevoEstado, {String? motivo}) async {
    await _solicitudesService.procesarSolicitud(solicitudId, nuevoEstado, motivo: motivo);
    _cargarDatos();
  }

  Future<void> _eliminarUsuario(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar usuario?'),
        content: const Text('Esta acción desvinculará permanentemente al usuario del sistema.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _usuariosService.eliminarUsuario(id);
      _cargarDatos();
    }
  }

  // ===========================================================================
  // INTERFAZ DE NAVEGACIÓN Y ESTRUCTURA GENERAL
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final pendientesCount = _solicitudes.where((s) => s.estadoSolicitud.toLowerCase() == 'pendiente').length;
    final aprobadosCount = _solicitudes.where((s) => s.estadoSolicitud.toLowerCase() == 'aprobado').length;

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
                    _buildBannerAlertaSolicitudes(pendientesCount),
                    const SizedBox(height: 16),
                    _buildSelectorModulo(),
                    const SizedBox(height: 20),
                    
                    // Renderizado de pestañas independientes
                    if (_currentIndex == 0)
                      AdminMetricasTab(
                        totalUsuarios: _usuarios.length,
                        solicitudesAprobadas: aprobadosCount,
                        solicitudesPendientes: pendientesCount,
                        reportes: _reportes,
                      )
                    else if (_currentIndex == 1)
                      AdminSolicitudesTab(
                        solicitudes: _solicitudes,
                        onProcesarSolicitud: _mostrarModalProcesarSolicitud,
                      )
                    else
                      AdminUsuariosTab(
                        usuarios: _usuarios,
                        onEditarUsuario: (u) => _mostrarModalCrearEditarUsuario(usuario: u),
                        onCambiarEstado: (id, nuevoEstado) async {
                          await _usuariosService.cambiarEstadoUsuario(id, nuevoEstado);
                          _cargarDatos();
                        },
                        onEliminarUsuario: _eliminarUsuario,
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBannerAlertaSolicitudes(int pendientes) {
    if (pendientes == 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
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
                      '¡Tienes $pendientes solicitud(es) pendiente(s) de revisión!',
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
            onPressed: () => setState(() => _currentIndex = 1),
            child: const Text('Revisar Solicitud', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
            _tabButton('Métricas y Reportes', 0, Icons.bar_chart_rounded),
            const SizedBox(width: 8),
            _tabButton('Solicitudes de Negocio', 1, Icons.assignment_rounded),
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
              color: selected ? const Color(0xFF0EA5E9) : const Color(0xFF64748B), // Ajustado de color seguro
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
}
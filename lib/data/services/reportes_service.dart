import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reporte_model.dart';

class ReportesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Obtiene el ID numérico (`BIGINT`) del usuario actual desde la tabla usuarios_r_sabor
  Future<int> _obtenerComensalIdActual() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _supabase
        .from('usuarios_r_sabor')
        .select('id')
        .eq('email', authUser.email!)
        .maybeSingle();

    if (response == null || response['id'] == null) {
      throw Exception('No se encontró el registro de usuario en la base de datos');
    }

    return response['id'] as int;
  }

  /// Crear un reporte enviado por el comensal
  Future<void> crearReporte({
    required String descripcion,
    int? establecimientoId,
  }) async {
    final int comensalId = await _obtenerComensalIdActual();

    final reporte = ReporteProblema(
      comensalId: comensalId,
      establecimientoId: establecimientoId,
      descripcion: descripcion,
    );

    await _supabase
        .from('reportes_problemas_r_sabor')
        .insert(reporte.toJson());
  }

  /// Obtener todos los reportes aclarando la Foreign Key explícita (!fk_reporte_comensal)
  Future<List<Map<String, dynamic>>> obtenerReportes() async {
    final response = await _supabase
        .from('reportes_problemas_r_sabor')
        .select('*, usuarios_r_sabor!fk_reporte_comensal(nombre_completo, foto_url, email)')
        .order('fecha_reporte', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Actualizar estado y respuesta del reporte por el administrador
  Future<void> actualizarEstadoReporte({
    required int reporteId,
    required String nuevoEstado,
    String? respuestaAdmin,
  }) async {
    int? adminId;
    try {
      adminId = await _obtenerComensalIdActual();
    } catch (_) {
      adminId = null;
    }

    final Map<String, dynamic> datosActualizacion = {
      'estado': nuevoEstado,
      'respuesta_admin': respuestaAdmin,
      'atendido_por_admin_id': adminId,
      'fecha_resolucion': nuevoEstado == 'resuelto'
          ? DateTime.now().toIso8601String()
          : null,
    };

    await _supabase
        .from('reportes_problemas_r_sabor')
        .update(datosActualizacion)
        .eq('id', reporteId);
  }
}
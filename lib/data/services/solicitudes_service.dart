import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/solicitud_model.dart';

class SolicitudesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<SolicitudRegistroModel>> obtenerSolicitudes() async {
    final response = await _supabase
        .from('solicitudes_registro_r_sabor')
        .select()
        .order('fecha_envio', ascending: false);

    return (response as List)
        .map((json) => SolicitudRegistroModel.fromJson(json))
        .toList();
  }

  Future<void> cambiarEstadoSolicitud({
    required int solicitudId,
    required String nuevoEstado,
    String? motivoRechazo,
  }) async {
    await _supabase.from('solicitudes_registro_r_sabor').update({
      'estado_solicitud': nuevoEstado,
      'motivo_rechazo': motivoRechazo,
      'fecha_respuesta': DateTime.now().toIso8601String(),
    }).eq('id', solicitudId);
  }
}
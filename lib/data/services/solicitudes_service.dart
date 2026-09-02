import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/solicitud_model.dart';

class SolicitudesService {
  final SupabaseClient _supabase;

  SolicitudesService({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  static const String _tablaSolicitudes = 'solicitudes_registro_r_sabor';

  // ===========================================================================
  // 1. CONSULTAS Y LECTURA DE SOLICITUDES
  // ===========================================================================

  Future<List<SolicitudRegistroModel>> obtenerSolicitudes() async {
    try {
      final response = await _supabase
          .from(_tablaSolicitudes)
          .select('*, usuarios_r_sabor(nombre_completo)')
          .order('fecha_envio', ascending: false);

      final data = response as List<dynamic>;
      return data
          .map((json) => SolicitudRegistroModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      debugPrint('[SolicitudesService] Error Postgrest al obtener solicitudes: ${e.message}');
      throw Exception('Error al cargar la lista de solicitudes: ${e.message}');
    } catch (e) {
      debugPrint('[SolicitudesService] Error inesperado al obtener solicitudes: $e');
      throw Exception('No se pudieron obtener las solicitudes de registro.');
    }
  }

  Future<List<SolicitudRegistroModel>> obtenerSolicitudesPorEstado(String estado) async {
    try {
      final response = await _supabase
          .from(_tablaSolicitudes)
          .select('*, usuarios_r_sabor(nombre_completo)')
          .eq('estado_solicitud', estado)
          .order('fecha_envio', ascending: false);

      final data = response as List<dynamic>;
      return data
          .map((json) => SolicitudRegistroModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      debugPrint('[SolicitudesService] Error al obtener solicitudes por estado ($estado): ${e.message}');
      throw Exception('Error al filtrar solicitudes por estado.');
    } catch (e) {
      debugPrint('[SolicitudesService] Error inesperado: $e');
      throw Exception('No se pudieron obtener las solicitudes filtradas.');
    }
  }

  Future<List<SolicitudRegistroModel>> obtenerSolicitudesPorUsuario(int usuarioId) async {
    try {
      final response = await _supabase
          .from(_tablaSolicitudes)
          .select()
          .eq('usuario_id', usuarioId)
          .order('fecha_envio', ascending: false);

      final data = response as List<dynamic>;
      return data
          .map((json) => SolicitudRegistroModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      debugPrint('[SolicitudesService] Error al obtener solicitudes del usuario ($usuarioId): ${e.message}');
      throw Exception('Error al obtener el historial de solicitudes del usuario.');
    } catch (e) {
      debugPrint('[SolicitudesService] Error inesperado: $e');
      throw Exception('No se pudo verificar el historial del usuario.');
    }
  }

  Future<SolicitudRegistroModel?> obtenerSolicitudPorId(int solicitudId) async {
    try {
      final response = await _supabase
          .from(_tablaSolicitudes)
          .select('*, usuarios_r_sabor(nombre_completo)')
          .eq('id', solicitudId)
          .maybeSingle();

      if (response == null) return null;

      return SolicitudRegistroModel.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      debugPrint('[SolicitudesService] Error al buscar solicitud ID ($solicitudId): ${e.message}');
      throw Exception('Error al recuperar los detalles de la solicitud.');
    } catch (e) {
      debugPrint('[SolicitudesService] Error inesperado: $e');
      throw Exception('Ocurrió un error al buscar la solicitud.');
    }
  }

  // ===========================================================================
  // 2. CREACIÓN DE NUEVAS SOLICITUDES
  // ===========================================================================

  Future<SolicitudRegistroModel> crearSolicitud({
    required int usuarioId,
    required String nombreNegocioPropuesto,
    String? descripcionNegocio,
    String? direccionPropuesta,
    String? telefonoContacto,
    String? documentoIdentidadUrl,
    String? fotoEstablecimientoUrl,
    double? latitud,
    double? longitud,
  }) async {
    try {
      final payload = {
        'usuario_id': usuarioId,
        'nombre_negocio_propuesto': nombreNegocioPropuesto.trim(),
        'descripcion_negocio': descripcionNegocio?.trim(),
        'direccion_propuesta': direccionPropuesta?.trim(),
        'telefono_contacto': telefonoContacto?.trim(),
        'documento_identidad_url': documentoIdentidadUrl,
        'foto_establecimiento_url': fotoEstablecimientoUrl,
        'latitud': latitud,
        'longitud': longitud,
        'estado_solicitud': 'pendiente',
        'fecha_envio': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from(_tablaSolicitudes)
          .insert(payload)
          .select()
          .single();

      debugPrint('[SolicitudesService] Solicitud creada con éxito. ID: ${response['id']}');
      return SolicitudRegistroModel.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      debugPrint('[SolicitudesService] Error al crear solicitud: ${e.message}');
      throw Exception('No se pudo enviar la solicitud de registro: ${e.message}');
    } catch (e) {
      debugPrint('[SolicitudesService] Error inesperado al crear solicitud: $e');
      throw Exception('Error al procesar la creación de la solicitud.');
    }
  }

  // ===========================================================================
  // 3. CAMBIO DE ESTADO Y ACCIONES DE ADMINISTRACIÓN
  // ===========================================================================

  /// Método puente compatible con tu AdminDashboardScreen actual
  Future<void> procesarSolicitud(int solicitudId, String nuevoEstado, {String? motivo}) async {
    if (nuevoEstado == 'aprobado') {
      final solicitud = await obtenerSolicitudPorId(solicitudId);
      if (solicitud != null) {
        await aprobarSolicitudCompleta(solicitud);
      } else {
        throw Exception('No se encontró la solicitud con ID $solicitudId');
      }
    } else {
      await rechazarSolicitud(
        solicitudId: solicitudId, 
        motivoRechazo: motivo ?? 'Sin motivos especificados',
      );
    }
  }

  /// Aprueba la solicitud, promueve al usuario a 'dueno' y registra el nuevo establecimiento.
  Future<void> aprobarSolicitudCompleta(SolicitudRegistroModel solicitud) async {
    try {
      // 1. Actualizar estado de la solicitud
      await _supabase
          .from(_tablaSolicitudes)
          .update({
            'estado_solicitud': 'aprobado',
            'fecha_respuesta': DateTime.now().toIso8601String(),
          })
          .eq('id', solicitud.id);

      // 2. Promover al usuario al rol 'dueno'
      await _supabase
          .from('usuarios_r_sabor')
          .update({'rol': 'dueno'})
          .eq('id', solicitud.usuarioId);

      // 3. Insertar el establecimiento aprobado
      await _supabase.from('establecimientos_r_sabor').insert({
        'dueno_id': solicitud.usuarioId,
        'categoria_id': 1, // Categoría general predeterminada
        'nombre_comercial': solicitud.nombreNegocioPropuesto,
        'descripcion': solicitud.descripcionNegocio,
        'direccion_texto': solicitud.direccionPropuesta,
        'latitud': solicitud.latitud,
        'longitud': solicitud.longitud,
        'imagen_portada': solicitud.fotoEstablecimientoUrl,
        'verificado': true,
        'estado_local': 'cerrado',
      });

      debugPrint('[SolicitudesService] Solicitud ${solicitud.id} aprobada e integrada con éxito.');
    } on PostgrestException catch (e) {
      debugPrint('[SolicitudesService] Error al aprobar solicitud: ${e.message}');
      throw Exception('Error al procesar la aprobación: ${e.message}');
    } catch (e) {
      debugPrint('[SolicitudesService] Error inesperado en aprobación: $e');
      throw Exception('No se pudo completar la aprobación.');
    }
  }

  /// Rechaza la solicitud con motivo explicativo.
  Future<void> rechazarSolicitud({
    required int solicitudId,
    required String motivoRechazo,
  }) async {
    try {
      await _supabase
          .from(_tablaSolicitudes)
          .update({
            'estado_solicitud': 'rechazado',
            'motivo_rechazo': motivoRechazo.trim(),
            'fecha_respuesta': DateTime.now().toIso8601String(),
          })
          .eq('id', solicitudId);

      debugPrint('[SolicitudesService] Solicitud $solicitudId rechazada.');
    } on PostgrestException catch (e) {
      debugPrint('[SolicitudesService] Error al rechazar solicitud: ${e.message}');
      throw Exception('Error al rechazar la solicitud: ${e.message}');
    }
  }

  Future<void> cambiarEstadoSolicitud({
    required int solicitudId,
    required String nuevoEstado,
    String? motivoRechazo,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'estado_solicitud': nuevoEstado,
        'motivo_rechazo': motivoRechazo,
        'fecha_respuesta': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from(_tablaSolicitudes)
          .update(updateData)
          .eq('id', solicitudId);
    } on PostgrestException catch (e) {
      debugPrint('[SolicitudesService] Error al cambiar estado: ${e.message}');
      throw Exception('Error al actualizar el estado de la solicitud.');
    }
  }

  // ===========================================================================
  // 4. ELIMINACIÓN Y ESTADOS
  // ===========================================================================

  Future<void> eliminarSolicitud(int solicitudId) async {
    try {
      await _supabase
          .from(_tablaSolicitudes)
          .delete()
          .eq('id', solicitudId);
    } on PostgrestException catch (e) {
      debugPrint('[SolicitudesService] Error al eliminar solicitud: ${e.message}');
      throw Exception('No se pudo eliminar la solicitud.');
    }
  }

  Future<String> obtenerEstadoSolicitudUsuario(int usuarioId) async {
    try {
      final response = await _supabase
          .from(_tablaSolicitudes)
          .select('estado_solicitud')
          .eq('usuario_id', usuarioId)
          .order('fecha_envio', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return 'SIN SOLICITUD';
      return response['estado_solicitud'] as String? ?? 'SIN SOLICITUD';
    } catch (e) {
      debugPrint('[SolicitudesService] Error al consultar estado: $e');
      return 'ERROR';
    }
  }
}
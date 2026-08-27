import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/establecimiento_model.dart';
import '../models/plato_dia_item.dart';
import '../models/usuario_model.dart';

class EstablecimientoService {
  final SupabaseClient client = Supabase.instance.client;

  /// Obtiene el usuario autenticado actual desde usuarios_r_sabor
  Future<UsuarioModel?> obtenerPerfilUsuarioActual() async {
    try {
      final authUser = client.auth.currentUser;
      if (authUser == null || authUser.email == null) return null;

      final data = await client
          .from('usuarios_r_sabor')
          .select('*')
          .eq('email', authUser.email!)
          .maybeSingle();

      if (data == null) return null;
      return UsuarioModel.fromJson(data);
    } catch (e) {
      debugPrint('Error obteniendo perfil: $e');
      return null;
    }
  }

  /// Actualiza datos personales del usuario
  Future<void> actualizarPerfil(int userId, String nuevoNombre, String nuevoTelefono) async {
    try {
      await client.from('usuarios_r_sabor').update({
        'nombre_completo': nuevoNombre,
        'telefono': nuevoTelefono,
      }).eq('id', userId);
    } catch (e) {
      debugPrint('Error actualizando perfil: $e');
      rethrow;
    }
  }

  /// Obtiene platillos populares filtrados por texto, categoría y/o precio máximo
  Future<List<Map<String, dynamic>>> obtenerPlatosPopulares({
    String query = '', 
    String? categoria,
    double? precioMaximo,
  }) async {
    try {
      // Se utiliza PostgrestFilterBuilder explícito para permitir encadenamiento dinámico
      PostgrestFilterBuilder builder = client.from('platillos_r_sabor').select('''
        *,
        establecimientos_r_sabor (
          id, nombre_comercial, latitud, longitud, direccion_texto, calificacion_promedio, dueno_id
        )
      ''').eq('disponible', true);

      if (query.isNotEmpty) {
        builder = builder.ilike('nombre', '%$query%');
      }

      if (categoria != null && categoria.isNotEmpty && categoria != 'Todos') {
        builder = builder.eq('categoria', categoria);
      }

      if (precioMaximo != null && precioMaximo > 0) {
        builder = builder.lte('precio_bs', precioMaximo);
      }

      final response = await builder;
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('Error obteniendo platos populares: $e');
      return [];
    }
  }

  /// Gestión de Favoritos: Obtener lista de IDs
  Future<List<int>> obtenerIdsFavoritos(int comensalId) async {
    try {
      final res = await client
          .from('favoritos_r_sabor')
          .select('establecimiento_id')
          .eq('comensal_id', comensalId);

      final list = res as List<dynamic>;
      return list
          .map((e) => e['establecimiento_id'] is int
              ? e['establecimiento_id'] as int
              : int.parse(e['establecimiento_id'].toString()))
          .toList();
    } catch (e) {
      debugPrint('Error obteniendo favoritos: $e');
      return [];
    }
  }

  /// Alternar estado de favorito (Agregar / Eliminar)
  Future<void> toggleFavorito(int comensalId, int establecimientoId, bool esFavorito) async {
    try {
      if (esFavorito) {
        await client.from('favoritos_r_sabor').insert({
          'comensal_id': comensalId,
          'establecimiento_id': establecimientoId,
        });
      } else {
        await client
            .from('favoritos_r_sabor')
            .delete()
            .eq('comensal_id', comensalId)
            .eq('establecimiento_id', establecimientoId);
      }
    } catch (e) {
      debugPrint('Error alternando favorito: $e');
      rethrow;
    }
  }

  /// Enviar reporte de soporte/incidencia
  Future<void> enviarReporteSoporte(int usuarioId, String descripcion) async {
    try {
      await client.from('solicitudes_registro_r_sabor').insert({
        'usuario_id': usuarioId,
        'nombre_negocio_propuesto': 'REPORTE_SOPORTE',
        'descripcion_negocio': descripcion,
        'estado_solicitud': 'pendiente',
      });
    } catch (e) {
      debugPrint('Error enviando reporte de soporte: $e');
      rethrow;
    }
  }

  /// 1. Obtener lista de locales/establecimientos abiertos
  Future<List<EstablecimientoModel>> obtenerEstablecimientosAbiertos() async {
    try {
      final response = await client
          .from('establecimientos_r_sabor')
          .select('*')
          .eq('estado_local', 'abierto');

      final list = List<Map<String, dynamic>>.from(response as List);
      return list.map((e) => EstablecimientoModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error obteniendo establecimientos abiertos: $e');
      return [];
    }
  }

  /// 2. Obtener lista de platos del día disponibles
  Future<List<PlatoDiaItem>> obtenerPlatosDelDiaDisponibles() async {
    try {
      final response = await client
          .from('platos_dia_r_sabor')
          .select('''
            *,
            establecimientos_r_sabor (
              nombre_comercial,
              latitud,
              longitud
            )
          ''')
          .eq('disponible', true);

      final list = List<Map<String, dynamic>>.from(response as List);
      return list.map((e) => PlatoDiaItem.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error obteniendo platos del día: $e');
      return [];
    }
  }
}
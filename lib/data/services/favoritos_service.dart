import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritosService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // OBTENER FAVORITOS DEL USUARIO (Establecimientos y Platillos)
  Future<List<Map<String, dynamic>>> obtenerFavoritos(int usuarioId) async {
    try {
      final response = await _supabase
          .from('favoritos_r_sabor')
          .select('''
            id,
            fecha_agregado,
            establecimientos_r_sabor (
              id,
              nombre_comercial,
              descripcion,
              imagen_portada,
              calificacion_promedio
            ),
            platillos_r_sabor (
              id,
              nombre,
              precio_bs,
              imagen_url
            )
          ''')
          .eq('usuario_id', usuarioId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error al obtener favoritos: $e');
      return [];
    }
  }

  // AGREGAR FAVORITO
  Future<bool> agregarFavorito({
    required int usuarioId,
    int? establecimientoId,
    int? platilloId,
  }) async {
    try {
      await _supabase.from('favoritos_r_sabor').insert({
        'usuario_id': usuarioId,
        'establecimiento_id': establecimientoId,
        'platillo_id': platilloId,
      });
      return true;
    } catch (e) {
      debugPrint('Error al guardar favorito: $e');
      return false;
    }
  }

  // ELIMINAR FAVORITO
  Future<bool> eliminarFavorito(int favoritoId) async {
    try {
      await _supabase.from('favoritos_r_sabor').delete().eq('id', favoritoId);
      return true;
    } catch (e) {
      debugPrint('Error al eliminar favorito: $e');
      return false;
    }
  }
}
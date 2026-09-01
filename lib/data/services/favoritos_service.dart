import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritosService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Obtiene la lista detallada de favoritos (platillos y/o establecimientos)
  Future<List<Map<String, dynamic>>> obtenerFavoritos(int comensalId) async {
    try {
      final response = await _supabase
          .from('favoritos_r_sabor')
          .select('''
            id,
            comensal_id,
            platillo_id,
            establecimiento_id,
            platillos_r_sabor (*),
            establecimientos_r_sabor (*)
          ''')
          .eq('comensal_id', comensalId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error al obtener la lista completa de favoritos: $e');
      return [];
    }
  }

  /// Obtiene los IDs de los establecimientos favoritos del comensal
  Future<Set<int>> obtenerIdsEstablecimientosFavoritos(int comensalId) async {
    try {
      final response = await _supabase
          .from('favoritos_r_sabor')
          .select('establecimiento_id')
          .eq('comensal_id', comensalId)
          .not('establecimiento_id', 'is', null);

      final List data = response as List;
      return data
          .map((item) => item['establecimiento_id'] is int
              ? item['establecimiento_id'] as int
              : int.parse(item['establecimiento_id'].toString()))
          .toSet();
    } catch (e) {
      debugPrint('Error al obtener IDs de establecimientos favoritos: $e');
      return {};
    }
  }

  /// Obtiene los IDs de los platillos favoritos del comensal
  Future<Set<int>> obtenerIdsPlatillosFavoritos(int comensalId) async {
    try {
      final response = await _supabase
          .from('favoritos_r_sabor')
          .select('platillo_id')
          .eq('comensal_id', comensalId)
          .not('platillo_id', 'is', null);

      final List data = response as List;
      return data
          .map((item) => item['platillo_id'] is int
              ? item['platillo_id'] as int
              : int.parse(item['platillo_id'].toString()))
          .toSet();
    } catch (e) {
      debugPrint('Error al obtener IDs de platillos favoritos: $e');
      return {};
    }
  }

  /// Agrega o elimina un establecimiento de la lista de favoritos
  Future<bool> toggleFavoritoEstablecimiento({
    required int comensalId,
    required int establecimientoId,
    required bool esFavorito,
  }) async {
    try {
      if (esFavorito) {
        await _supabase
            .from('favoritos_r_sabor')
            .delete()
            .eq('comensal_id', comensalId)
            .eq('establecimiento_id', establecimientoId);
      } else {
        await _supabase.from('favoritos_r_sabor').insert({
          'comensal_id': comensalId,
          'establecimiento_id': establecimientoId,
        });
      }
      return true;
    } catch (e) {
      debugPrint('Error en toggleFavoritoEstablecimiento: $e');
      return false;
    }
  }

  /// Agrega o elimina un platillo de la lista de favoritos
  Future<bool> toggleFavoritoPlatillo({
    required int comensalId,
    required int platilloId,
    required bool esFavorito,
  }) async {
    try {
      if (esFavorito) {
        await _supabase
            .from('favoritos_r_sabor')
            .delete()
            .eq('comensal_id', comensalId)
            .eq('platillo_id', platilloId);
      } else {
        await _supabase.from('favoritos_r_sabor').insert({
          'comensal_id': comensalId,
          'platillo_id': platilloId,
        });
      }
      return true;
    } catch (e) {
      debugPrint('Error en toggleFavoritoPlatillo: $e');
      return false;
    }
  }
}
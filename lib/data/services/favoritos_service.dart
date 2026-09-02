import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/favorito_model.dart';

class FavoritosService {
  final SupabaseClient _client;

  /// Constructor con cliente opcional inyectado (por defecto usa el Singleton de Supabase)
  FavoritosService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  // ===========================================================================
  // 1. CONSULTA DE FAVORITOS (LISTAS Y OBJETOS TIPADOS)
  // ===========================================================================

  /// Obtiene la lista completa de favoritos mapeados directamente a [FavoritoModel]
  /// Incluye la relación anidada con el establecimiento si está disponible.
  Future<List<FavoritoModel>> obtenerFavoritosModel(int comensalId) async {
    try {
      final response = await _client
          .from('favoritos_r_sabor')
          .select('''
            id,
            comensal_id,
            establecimiento_id,
            fecha_agregado,
            establecimientos_r_sabor (*)
          ''')
          .eq('comensal_id', comensalId)
          .order('fecha_agregado', ascending: false);

      final dataList = List<Map<String, dynamic>>.from(response as List);
      return dataList.map((json) => FavoritoModel.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      debugPrint('[PostgrestException] Error obteniendo lista de FavoritoModel: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('[FavoritosService] Error inesperado en obtenerFavoritosModel: $e');
      return [];
    }
  }

  /// Obtiene la lista en formato dinámico de Raw JSON (Útil para vistas heterogéneas con Platillos y Locales)
  Future<List<Map<String, dynamic>>> obtenerFavoritosRaw(int comensalId) async {
    try {
      final response = await _client
          .from('favoritos_r_sabor')
          .select('''
            id,
            comensal_id,
            platillo_id,
            establecimiento_id,
            fecha_agregado,
            platillos_r_sabor (*),
            establecimientos_r_sabor (*)
          ''')
          .eq('comensal_id', comensalId)
          .order('id', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } on PostgrestException catch (e) {
      debugPrint('[PostgrestException] Error obteniendo favoritos raw: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('[FavoritosService] Error inesperado en obtenerFavoritosRaw: $e');
      return [];
    }
  }

  // ===========================================================================
  // 2. OBTENCIÓN DE CONJUNTOS DE IDs (SETS DE BÚSQUEDA RÁPIDA)
  // ===========================================================================

  /// Obtiene un Set con los IDs de los establecimientos favoritos del comensal
  Future<Set<int>> obtenerIdsEstablecimientosFavoritos(int comensalId) async {
    try {
      final response = await _client
          .from('favoritos_r_sabor')
          .select('establecimiento_id')
          .eq('comensal_id', comensalId)
          .not('establecimiento_id', 'is', null);

      final List data = response as List;
      return data.map((item) {
        final rawId = item['establecimiento_id'];
        return rawId is int ? rawId : int.parse(rawId.toString());
      }).toSet();
    } on PostgrestException catch (e) {
      debugPrint('[PostgrestException] Error obteniendo IDs de establecimientos: ${e.message}');
      return {};
    } catch (e) {
      debugPrint('[FavoritosService] Error obteniendo IDs de establecimientos favoritos: $e');
      return {};
    }
  }

  /// Obtiene un Set con los IDs de los platillos favoritos del comensal
  Future<Set<int>> obtenerIdsPlatillosFavoritos(int comensalId) async {
    try {
      final response = await _client
          .from('favoritos_r_sabor')
          .select('platillo_id')
          .eq('comensal_id', comensalId)
          .not('platillo_id', 'is', null);

      final List data = response as List;
      return data.map((item) {
        final rawId = item['platillo_id'];
        return rawId is int ? rawId : int.parse(rawId.toString());
      }).toSet();
    } on PostgrestException catch (e) {
      debugPrint('[PostgrestException] Error obteniendo IDs de platillos: ${e.message}');
      return {};
    } catch (e) {
      debugPrint('[FavoritosService] Error obteniendo IDs de platillos favoritos: $e');
      return {};
    }
  }

  // ===========================================================================
  // 3. OPERACIONES DE CONMUTACIÓN (TOGGLE FAVORITOS)
  // ===========================================================================

  /// Alterna (agrega o elimina) un establecimiento en la lista de favoritos
  Future<bool> toggleFavoritoEstablecimiento({
    required int comensalId,
    required int establecimientoId,
    required bool esFavoritoActualmente,
  }) async {
    try {
      if (esFavoritoActualmente) {
        await _client
            .from('favoritos_r_sabor')
            .delete()
            .eq('comensal_id', comensalId)
            .eq('establecimiento_id', establecimientoId);
      } else {
        await _client.from('favoritos_r_sabor').insert({
          'comensal_id': comensalId,
          'establecimiento_id': establecimientoId,
        });
      }
      return true;
    } on PostgrestException catch (e) {
      debugPrint('[PostgrestException] Error alternando favorito establecimiento: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[FavoritosService] Error inesperado en toggleFavoritoEstablecimiento: $e');
      return false;
    }
  }

  /// Alterna (agrega o elimina) un platillo en la lista de favoritos
  Future<bool> toggleFavoritoPlatillo({
    required int comensalId,
    required int platilloId,
    required bool esFavoritoActualmente,
  }) async {
    try {
      if (esFavoritoActualmente) {
        await _client
            .from('favoritos_r_sabor')
            .delete()
            .eq('comensal_id', comensalId)
            .eq('platillo_id', platilloId);
      } else {
        await _client.from('favoritos_r_sabor').insert({
          'comensal_id': comensalId,
          'platillo_id': platilloId,
        });
      }
      return true;
    } on PostgrestException catch (e) {
      debugPrint('[PostgrestException] Error alternando favorito platillo: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[FavoritosService] Error inesperado en toggleFavoritoPlatillo: $e');
      return false;
    }
  }
}
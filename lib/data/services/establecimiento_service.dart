import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/establecimiento_model.dart';
import '../models/home_data_model.dart';
import '../models/place_model.dart';

class EstablecimientoService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Obtiene las categorías de negocios desde PostgreSQL (requerido por HomeScreen)
  Future<List<CategoriaItem>> fetchCategorias() async {
    try {
      final response = await _client
          .from('categorias_negocio_r_sabor')
          .select('id, nombre, descripcion, icono_url')
          .order('nombre', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((map) => CategoriaItem.fromJson(map as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error al obtener categorías: $e');
      return [];
    }
  }

  /// Obtiene los platos del día activos
  Future<List<PlatoDiaItem>> fetchPlatosDelDia() async {
    try {
      final response = await _client
          .from('plato_del_dia_r_sabor')
          .select('''
            id,
            titulo_oferta,
            descripcion_oferta,
            precio_oferta_bs,
            disponible_ahora,
            platillos_r_sabor (
              imagen_url
            ),
            establecimientos_r_sabor (
              nombre_comercial,
              direccion_texto
            )
          ''')
          .eq('disponible_ahora', true)
          .order('fecha_creacion', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((map) => PlatoDiaItem.fromJson(map as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error al obtener platos del día: $e');
      return [];
    }
  }

  /// Obtiene los establecimientos formateados como PlaceModel para mostrar en el mapa
  Future<List<PlaceModel>> fetchEstablecimientosMapa() async {
    try {
      final response = await _client
          .from('establecimientos_r_sabor')
          .select('id, nombre_comercial, direccion_texto, latitud, longitud, estado_local, categoria_id')
          .not('latitud', 'is', null)
          .not('longitud', 'is', null);

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((e) => PlaceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error cargando puntos en mapa: $e');
      return [];
    }
  }

  /// Obtiene los establecimientos en formato de mapa dinámico (por si otra pantalla lo requiere)
  Future<List<Map<String, dynamic>>> obtenerEstablecimientosParaMapa() async {
    try {
      final response = await _client
          .from('establecimientos_r_sabor')
          .select('id, nombre_comercial, latitud, longitud, calificacion_promedio, estado_local, imagen_portada')
          .eq('estado_local', 'abierto');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error al obtener datos del mapa: $e');
      return [];
    }
  }

  /// Alternar estado de favorito para un comensal
  Future<bool> toggleFavorito(int comensalId, int establecimientoId, bool esFavorito) async {
    try {
      if (esFavorito) {
        await _client
            .from('favoritos_r_sabor')
            .delete()
            .match({'comensal_id': comensalId, 'establecimiento_id': establecimientoId});
        return false;
      } else {
        await _client
            .from('favoritos_r_sabor')
            .insert({'comensal_id': comensalId, 'establecimiento_id': establecimientoId});
        return true;
      }
    } catch (e) {
      print('Error al actualizar favorito: $e');
      return esFavorito;
    }
  }
}
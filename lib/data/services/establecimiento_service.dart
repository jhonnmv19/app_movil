import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/establecimiento_model.dart';

class EstablecimientoService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Obtiene la lista completa de establecimientos registrados
  Future<List<EstablecimientoModel>> obtenerEstablecimientos() async {
    final response = await _client
        .from('establecimientos_r_sabor')
        .select();

    final List<dynamic> data = response as List<dynamic>;
    return data
        .map((e) => EstablecimientoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene los platos del día activos junto con el nombre del establecimiento
  Future<List<Map<String, dynamic>>> obtenerPlatosDelDia() async {
    final response = await _client
        .from('plato_del_dia_r_sabor')
        .select('*, establecimientos_r_sabor(nombre_comercial)')
        .eq('disponible_ahora', true);

    return List<Map<String, dynamic>>.from(response as List);
  }
}
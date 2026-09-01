import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/establecimiento_model.dart';
import '../models/plato_dia_item.dart';
import '../models/usuario_model.dart';

class EstablecimientoService {
  final SupabaseClient client = Supabase.instance.client;

  // --- MÓDULO SUPABASE STORAGE ---

  Future<String?> subirImagen({
    File? fileBytes,
    Uint8List? fileDataWeb,
    required String bucket,
    required String path,
  }) async {
    try {
      if (kIsWeb) {
        if (fileDataWeb == null) return null;
        await client.storage.from(bucket).uploadBinary(
              path,
              fileDataWeb,
              fileOptions: const FileOptions(upsert: true, cacheControl: '3600'),
            );
      } else {
        if (fileBytes == null) return null;
        await client.storage.from(bucket).upload(
              path,
              fileBytes,
              fileOptions: const FileOptions(upsert: true, cacheControl: '3600'),
            );
      }
      return client.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      debugPrint('Error subiendo archivo a Storage: $e');
      return null;
    }
  }

  // --- MÓDULO USUARIOS Y PERFIL ---

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

  Future<String> obtenerEstadoSolicitudUsuario(int usuarioId) async {
    try {
      final response = await client
          .from('solicitudes_registro_r_sabor')
          .select('estado_solicitud')
          .eq('usuario_id', usuarioId)
          .order('fecha_envio', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return 'sin_solicitud';
      return response['estado_solicitud'] ?? 'pendiente';
    } catch (e) {
      debugPrint('Error obteniendo estado de solicitud: $e');
      return 'pendiente';
    }
  }

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

  // --- MÓDULO ESTABLECIMIENTOS ---

  Future<EstablecimientoModel?> obtenerEstablecimientoPorDueno(int duenoId) async {
    try {
      final response = await client
          .from('establecimientos_r_sabor')
          .select('*')
          .eq('dueno_id', duenoId)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return EstablecimientoModel.fromJson(response);
    } catch (e) {
      debugPrint('Error obteniendo establecimiento del dueño: $e');
      return null;
    }
  }

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

  Future<void> actualizarEstadoLocal(int establecimientoId, String nuevoEstado) async {
    try {
      await client
          .from('establecimientos_r_sabor')
          .update({'estado_local': nuevoEstado})
          .eq('id', establecimientoId);
    } catch (e) {
      debugPrint('Error actualizando estado del local: $e');
      rethrow;
    }
  }

  // --- MÓDULO PLATILLOS (MENÚ Y CONSULTAS) ---

  Future<void> crearPlatillo({
    required int establecimientoId,
    required int categoriaPlatilloId,
    required String nombre,
    required String descripcion,
    required double precioBs,
    String? imagenUrl,
    bool disponible = true,
  }) async {
    try {
      await client.from('platillos_r_sabor').insert({
        'establecimiento_id': establecimientoId,
        'categoria_platillo_id': categoriaPlatilloId,
        'nombre': nombre,
        'descripcion': descripcion,
        'precio_bs': precioBs,
        'imagen_url': imagenUrl,
        'disponible': disponible,
      });
    } catch (e) {
      debugPrint('Error creando platillo: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> obtenerPlatillosPorEstablecimiento(int establecimientoId) async {
    try {
      final response = await client
          .from('platillos_r_sabor')
          .select('''
            id,
            nombre,
            descripcion,
            precio_bs,
            imagen_url,
            disponible,
            categorias_platillos_r_sabor(id, nombre)
          ''')
          .eq('establecimiento_id', establecimientoId)
          .order('id', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('Error obteniendo platillos del establecimiento: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> obtenerPlatosPopulares({
    String query = '',
    String? categoria,
    double? precioMaximo,
  }) async {
    try {
      dynamic builder = client.from('platillos_r_sabor').select('''
        id,
        nombre,
        descripcion,
        precio_bs,
        imagen_url,
        disponible,
        categorias_platillos_r_sabor!inner(nombre),
        establecimientos_r_sabor!inner(
          id,
          nombre_comercial,
          direccion_texto,
          calificacion_promedio,
          latitud,
          longitud,
          dueno_id
        )
      ''').eq('disponible', true);

      if (query.isNotEmpty) {
        builder = builder.ilike('nombre', '%$query%');
      }

      if (categoria != null && categoria.isNotEmpty && categoria != 'Todos') {
        builder = builder.eq('categorias_platillos_r_sabor.nombre', categoria);
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

  Future<List<Map<String, dynamic>>> obtenerCategorias() async {
    try {
      final response = await client
          .from('categorias_platillos_r_sabor')
          .select('id, nombre')
          .order('nombre', ascending: true);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('Error obteniendo categorías: $e');
      return [];
    }
  }

  // --- MÓDULO FOTOS GALERÍA ---

  Future<void> agregarFotoEstablecimiento({
    required int establecimientoId,
    required String imagenUrl,
    bool esPrincipal = false,
  }) async {
    try {
      await client.from('fotos_establecimiento_r_sabor').insert({
        'establecimiento_id': establecimientoId,
        'imagen_url': imagenUrl,
        'es_principal': esPrincipal,
      });
    } catch (e) {
      debugPrint('Error agregando foto del establecimiento: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> obtenerFotosEstablecimiento(int establecimientoId) async {
    try {
      final response = await client
          .from('fotos_establecimiento_r_sabor')
          .select('id, imagen_url, es_principal')
          .eq('establecimiento_id', establecimientoId)
          .order('id', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('Error obteniendo fotos del establecimiento: $e');
      return [];
    }
  }

  // --- MÓDULO PLATO DEL DÍA ---

  Future<void> publicarPlatoDelDia({
    required int establecimientoId,
    required String tituloOferta,
    required String descripcionOferta,
    required double precioOfertaBs,
    required bool disponibleAhora,
    int? platilloId,
  }) async {
    try {
      await client.from('plato_del_dia_r_sabor').insert({
        'establecimiento_id': establecimientoId,
        'titulo_oferta': tituloOferta,
        'descripcion_oferta': descripcionOferta,
        'precio_oferta_bs': precioOfertaBs,
        'disponible_ahora': disponibleAhora,
        'platillo_id': platilloId,
      });
    } catch (e) {
      debugPrint('Error publicando plato del día: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> obtenerPlatosDelDiaPorEstablecimiento(int establecimientoId) async {
    try {
      final response = await client
          .from('plato_del_dia_r_sabor')
          .select('*')
          .eq('establecimiento_id', establecimientoId)
          .order('id', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('Error obteniendo ofertas del día del establecimiento: $e');
      return [];
    }
  }

  Future<List<PlatoDiaItem>> obtenerPlatosDelDiaDisponibles() async {
    try {
      final response = await client
          .from('plato_del_dia_r_sabor')
          .select('''
            id,
            establecimiento_id,
            titulo_oferta,
            descripcion_oferta,
            precio_oferta_bs,
            disponible_ahora,
            platillos_r_sabor (
              imagen_url
            ),
            establecimientos_r_sabor (
              nombre_comercial,
              direccion_texto,
              latitud,
              longitud
            )
          ''')
          .eq('disponible_ahora', true);

      final list = List<Map<String, dynamic>>.from(response as List);
      return list.map((e) => PlatoDiaItem.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error obteniendo platos del día: $e');
      return [];
    }
  }

  // --- MÓDULO FAVORITOS ---

  Future<List<int>> obtenerIdsFavoritos(int comensalId) async {
    try {
      final res = await client
          .from('favoritos_r_sabor')
          .select('establecimiento_id')
          .eq('comensal_id', comensalId)
          .not('establecimiento_id', 'is', null);

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

  Future<bool> toggleFavorito(int comensalId, int establecimientoId, bool esFavorito) async {
    try {
      if (esFavorito) {
        await client
            .from('favoritos_r_sabor')
            .delete()
            .eq('comensal_id', comensalId)
            .eq('establecimiento_id', establecimientoId);
      } else {
        await client.from('favoritos_r_sabor').insert({
          'comensal_id': comensalId,
          'establecimiento_id': establecimientoId,
        });
      }
      return true;
    } catch (e) {
      debugPrint('Error alternando favorito: $e');
      return false;
    }
  }
}
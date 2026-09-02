import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/establecimiento_model.dart';
import '../models/plato_dia_item.dart';
import '../models/usuario_model.dart';
import 'session_service.dart';

class EstablecimientoService {
  final SupabaseClient _client;

  /// Constructor con cliente Supabase inyectado o por defecto
  EstablecimientoService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  static const String _tablaEstablecimientos = 'establecimientos_r_sabor';

  // ===========================================================================
  // 1. SUPABASE STORAGE (SUBIDA Y GESTIÓN DE ARCHIVOS)
  // ===========================================================================

  /// Subida de imágenes compatible con Web y Móvil (Android/iOS)
  Future<String?> subirImagen({
    File? fileBytes,
    Uint8List? fileDataWeb,
    required String bucket,
    required String path,
  }) async {
    try {
      if (kIsWeb) {
        if (fileDataWeb == null) throw Exception('fileDataWeb no puede ser nulo en Web');
        await _client.storage.from(bucket).uploadBinary(
              path,
              fileDataWeb,
              fileOptions: const FileOptions(upsert: true, cacheControl: '3600'),
            );
      } else {
        if (fileBytes == null) throw Exception('fileBytes no puede ser nulo en plataformas nativas');
        await _client.storage.from(bucket).upload(
              path,
              fileBytes,
              fileOptions: const FileOptions(upsert: true, cacheControl: '3600'),
            );
      }
      return _client.storage.from(bucket).getPublicUrl(path);
    } on StorageException catch (e) {
      debugPrint('[StorageException] Error subiendo imagen: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('[EstablecimientoService] Error inesperado en subirImagen: $e');
      return null;
    }
  }

  // ===========================================================================
  // 2. USUARIOS Y PERFILES DE USUARIO
  // ===========================================================================

  /// Obtiene los datos completos del usuario autenticado actualmente
  Future<UsuarioModel?> obtenerPerfilUsuarioActual() async {
    try {
      final sessionEmail = SessionService().emailUsuario;
      final userEmail = sessionEmail.isNotEmpty ? sessionEmail : _client.auth.currentUser?.email;
      
      if (userEmail == null || userEmail.isEmpty) {
        debugPrint('[EstablecimientoService] ⚠️ No hay email de sesión activo.');
        return null;
      }

      final response = await _client
          .from('usuarios_r_sabor')
          .select('*')
          .eq('email', userEmail)
          .maybeSingle();

      if (response == null) {
        debugPrint('[EstablecimientoService] ⚠️ No se encontró usuario en usuarios_r_sabor con email: $userEmail');
        return null;
      }
      return UsuarioModel.fromJson(response);
    } on PostgrestException catch (e) {
      debugPrint('[PostgrestException] Error obteniendo perfil: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('[EstablecimientoService] Error en obtenerPerfilUsuarioActual: $e');
      return null;
    }
  }

  /// Actualiza los datos del perfil (Nombre y Teléfono)
  Future<void> actualizarPerfil(int userId, String nuevoNombre, String nuevoTelefono) async {
    try {
      await _client.from('usuarios_r_sabor').update({
        'nombre_completo': nuevoNombre.trim(),
        'telefono': nuevoTelefono.trim(),
      }).eq('id', userId);
    } catch (e) {
      debugPrint('[EstablecimientoService] Error actualizando perfil: $e');
      rethrow;
    }
  }

  /// Consulta el último estado de la solicitud de registro del usuario
  Future<String> obtenerEstadoSolicitudUsuario(int usuarioId) async {
    try {
      final response = await _client
          .from('solicitudes_registro_r_sabor')
          .select('estado_solicitud')
          .eq('usuario_id', usuarioId)
          .order('fecha_envio', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return 'sin_solicitud';
      return response['estado_solicitud'] as String? ?? 'pendiente';
    } catch (e) {
      debugPrint('[EstablecimientoService] Error en obtenerEstadoSolicitudUsuario: $e');
      return 'pendiente';
    }
  }

  /// Envía una solicitud o reporte a soporte técnico
  Future<void> enviarReporteSoporte(int usuarioId, String descripcion) async {
    try {
      await _client.from('solicitudes_registro_r_sabor').insert({
        'usuario_id': usuarioId,
        'nombre_negocio_propuesto': 'REPORTE_SOPORTE',
        'descripcion_negocio': descripcion.trim(),
        'estado_solicitud': 'pendiente',
      });
    } catch (e) {
      debugPrint('[EstablecimientoService] Error enviando reporte de soporte: $e');
      rethrow;
    }
  }

  // ===========================================================================
  // 3. GESTIÓN DE ESTABLECIMIENTOS (CREACIÓN, CONSULTA Y ACTUALIZACIÓN)
  // ===========================================================================

  /// Obtiene el establecimiento perteneciente al dueño actual.
  /// Acepta [usuarioId] opcional. Si no se pasa, busca la sesión activa o por email.
  Future<EstablecimientoModel?> obtenerEstablecimientoDelUsuario([int? usuarioId]) async {
    try {
      int duenoId = usuarioId ?? SessionService().usuarioId;

      // Si el ID de usuario sigue siendo 0 o nulo, intentamos resolverlo vía email de sesión
      if (duenoId == 0) {
        final userEmail = SessionService().emailUsuario.isNotEmpty 
            ? SessionService().emailUsuario 
            : _client.auth.currentUser?.email;

        if (userEmail != null && userEmail.isNotEmpty) {
          final usuarioRes = await _client
              .from('usuarios_r_sabor')
              .select('id')
              .eq('email', userEmail)
              .maybeSingle();
              
          if (usuarioRes != null) {
            duenoId = usuarioRes['id'] as int;
            SessionService().usuarioId = duenoId; // Sincronizamos SessionService
          }
        }
      }

      if (duenoId == 0) {
        debugPrint('[EstablecimientoService] ⚠️ No hay ID de usuario/dueño disponible para buscar.');
        return null;
      }

      debugPrint('[EstablecimientoService] 🔍 Buscando establecimiento apuntando a la columna dueno_id: $duenoId');

      // Consulta apuntando explícitamente a la columna `dueno_id`
      final response = await _client
          .from(_tablaEstablecimientos)
          .select()
          .eq('dueno_id', duenoId)
          .order('id', ascending: true)
          .limit(1);

      final list = response as List<dynamic>;

      if (list.isEmpty) {
        debugPrint('[EstablecimientoService] ⚠️ No hay establecimientos vinculados a dueno_id $duenoId en $_tablaEstablecimientos.');
        return null;
      }

      final estabData = list.first as Map<String, dynamic>;
      debugPrint('[EstablecimientoService] ✅ Establecimiento encontrado: ${estabData['nombre_comercial']} (ID: ${estabData['id']})');

      return EstablecimientoModel.fromJson(estabData);
    } on PostgrestException catch (e) {
      debugPrint('[EstablecimientoService] Error Postgrest al obtener el establecimiento: ${e.message} - ${e.details}');
      return null;
    } catch (e) {
      debugPrint('[EstablecimientoService] Error inesperado al obtener el establecimiento: $e');
      return null;
    }
  }

  /// Obtiene TODOS los establecimientos pertenecientes a un dueño específico
  Future<List<EstablecimientoModel>> obtenerEstablecimientosDelDueno(int duenoId) async {
    try {
      final response = await _client
          .from(_tablaEstablecimientos)
          .select()
          .eq('dueno_id', duenoId)
          .order('id', ascending: true);

      final data = response as List<dynamic>;
      return data
          .map((json) => EstablecimientoModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[EstablecimientoService] Error al obtener locales del dueño: $e');
      return [];
    }
  }

  /// Obtiene la lista completa de todos los establecimientos registrados
  Future<List<EstablecimientoModel>> obtenerEstablecimientos() async {
    try {
      final response = await _client
          .from(_tablaEstablecimientos)
          .select()
          .order('id', ascending: true);

      final data = response as List<dynamic>;
      return data
          .map((json) => EstablecimientoModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      debugPrint('[EstablecimientoService] Error al obtener establecimientos: ${e.message}');
      throw Exception('Error al cargar la lista de establecimientos.');
    } catch (e) {
      debugPrint('[EstablecimientoService] Error inesperado al obtener establecimientos: $e');
      return [];
    }
  }

  /// Retorna todos los establecimientos con estado local 'abierto'
  Future<List<EstablecimientoModel>> obtenerEstablecimientosAbiertos() async {
    try {
      final response = await _client
          .from(_tablaEstablecimientos)
          .select('*')
          .eq('estado_local', 'abierto');

      final list = List<Map<String, dynamic>>.from(response as List);
      return list.map((e) => EstablecimientoModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('[EstablecimientoService] Error obteniendo locales abiertos: $e');
      return [];
    }
  }

  /// Crea o registra un nuevo establecimiento para un dueño
  Future<EstablecimientoModel?> crearEstablecimiento({
    required int duenoId,
    required String nombreComercial,
    required String descripcion,
    required String direccionTexto,
    int? categoriaId,
  }) async {
    try {
      final payload = {
        'dueno_id': duenoId,
        'nombre_comercial': nombreComercial.trim(),
        'descripcion': descripcion.trim(),
        'direccion_texto': direccionTexto.trim(),
        if (categoriaId != null) 'categoria_id': categoriaId,
        'estado_local': 'abierto',
        'verificado': false,
      };

      final response = await _client
          .from(_tablaEstablecimientos)
          .insert(payload)
          .select()
          .single();

      debugPrint('[EstablecimientoService] Establecimiento creado con ID: ${response['id']}');
      return EstablecimientoModel.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      debugPrint('[EstablecimientoService] Error al crear establecimiento: ${e.message}');
      throw Exception('No se pudo registrar el establecimiento.');
    } catch (e) {
      debugPrint('[EstablecimientoService] Error inesperado al crear establecimiento: $e');
      rethrow;
    }
  }

  /// Actualiza la información del establecimiento
  Future<bool> actualizarEstablecimiento({
    required int establecimientoId,
    required String nombreComercial,
    required String descripcion,
    required String direccionTexto,
    String? estadoLocal,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'nombre_comercial': nombreComercial.trim(),
        'descripcion': descripcion.trim(),
        'direccion_texto': direccionTexto.trim(),
        if (estadoLocal != null) 'estado_local': estadoLocal,
      };

      await _client
          .from(_tablaEstablecimientos)
          .update(updateData)
          .eq('id', establecimientoId);

      debugPrint('[EstablecimientoService] Establecimiento ID $establecimientoId actualizado correctamente.');
      return true;
    } on PostgrestException catch (e) {
      debugPrint('[EstablecimientoService] Error Postgrest al actualizar establecimiento: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[EstablecimientoService] Error inesperado al actualizar establecimiento: $e');
      return false;
    }
  }

  /// Actualiza el estado actual del establecimiento (ej: 'abierto', 'cerrado')
  Future<void> actualizarEstadoLocal(int establecimientoId, String nuevoEstado) async {
    try {
      await _client
          .from(_tablaEstablecimientos)
          .update({'estado_local': nuevoEstado})
          .eq('id', establecimientoId);
    } catch (e) {
      debugPrint('[EstablecimientoService] Error actualizando estado del local: $e');
      rethrow;
    }
  }

  // ===========================================================================
  // 4. PLATILLOS Y CATÁLOGO / MENÚ
  // ===========================================================================

  /// Crea un nuevo platillo en la base de datos
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
      await _client.from('platillos_r_sabor').insert({
        'establecimiento_id': establecimientoId,
        'categoria_platillo_id': categoriaPlatilloId,
        'nombre': nombre.trim(),
        'descripcion': descripcion.trim(),
        'precio_bs': precioBs,
        'imagen_url': imagenUrl,
        'disponible': disponible,
      });
    } catch (e) {
      debugPrint('[EstablecimientoService] Error creando platillo: $e');
      rethrow;
    }
  }

  /// Obtiene los platillos pertenecientes a un establecimiento en particular
  Future<List<Map<String, dynamic>>> obtenerPlatillosPorEstablecimiento(int establecimientoId) async {
    try {
      final response = await _client
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
      debugPrint('[EstablecimientoService] Error obteniendo platillos por local: $e');
      return [];
    }
  }

  /// Búsqueda y filtrado avanzado de platillos disponibles
  Future<List<Map<String, dynamic>>> obtenerPlatosPopulares({
    String query = '',
    String? categoria,
    double? precioMaximo,
  }) async {
    try {
      dynamic builder = _client.from('platillos_r_sabor').select('''
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

      if (query.trim().isNotEmpty) {
        builder = builder.ilike('nombre', '%${query.trim()}%');
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
      debugPrint('[EstablecimientoService] Error en búsqueda de platos populares: $e');
      return [];
    }
  }

  /// Obtiene el listado completo de categorías de platillos
  Future<List<Map<String, dynamic>>> obtenerCategorias() async {
    try {
      final response = await _client
          .from('categorias_platillos_r_sabor')
          .select('id, nombre')
          .order('nombre', ascending: true);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('[EstablecimientoService] Error obteniendo categorías: $e');
      return [];
    }
  }

  // ===========================================================================
  // 5. GALERÍA DE FOTOS
  // ===========================================================================

  /// Asocia una nueva imagen en la galería del establecimiento
  Future<void> agregarFotoEstablecimiento({
    required int establecimientoId,
    required String imagenUrl,
    bool esPrincipal = false,
  }) async {
    try {
      await _client.from('fotos_establecimiento_r_sabor').insert({
        'establecimiento_id': establecimientoId,
        'imagen_url': imagenUrl,
        'es_principal': esPrincipal,
      });
    } catch (e) {
      debugPrint('[EstablecimientoService] Error agregando foto a la galería: $e');
      rethrow;
    }
  }

  /// Obtiene la lista de fotos de un establecimiento
  Future<List<Map<String, dynamic>>> obtenerFotosEstablecimiento(int establecimientoId) async {
    try {
      final response = await _client
          .from('fotos_establecimiento_r_sabor')
          .select('id, imagen_url, es_principal')
          .eq('establecimiento_id', establecimientoId)
          .order('id', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('[EstablecimientoService] Error obteniendo galería del establecimiento: $e');
      return [];
    }
  }

  // ===========================================================================
  // 6. PLATO DEL DÍA / OFERTAS
  // ===========================================================================

  /// Publica un plato del día u oferta especial
  Future<void> publicarPlatoDelDia({
    required int establecimientoId,
    required String tituloOferta,
    required String descripcionOferta,
    required double precioOfertaBs,
    required bool disponibleAhora,
    int? platilloId,
  }) async {
    try {
      await _client.from('plato_del_dia_r_sabor').insert({
        'establecimiento_id': establecimientoId,
        'titulo_oferta': tituloOferta.trim(),
        'descripcion_oferta': descripcionOferta.trim(),
        'precio_oferta_bs': precioOfertaBs,
        'disponible_ahora': disponibleAhora,
        'platillo_id': platilloId,
      });
    } catch (e) {
      debugPrint('[EstablecimientoService] Error publicando plato del día: $e');
      rethrow;
    }
  }

  /// Obtiene los platos del día asociados a un establecimiento específico
  Future<List<Map<String, dynamic>>> obtenerPlatosDelDiaPorEstablecimiento(int establecimientoId) async {
    try {
      final response = await _client
          .from('plato_del_dia_r_sabor')
          .select('*')
          .eq('establecimiento_id', establecimientoId)
          .order('id', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('[EstablecimientoService] Error obteniendo ofertas del establecimiento: $e');
      return [];
    }
  }

  /// Obtiene todas las ofertas disponibles activas actualmente en la app
  Future<List<PlatoDiaItem>> obtenerPlatosDelDiaDisponibles() async {
    try {
      final response = await _client
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
      debugPrint('[EstablecimientoService] Error obteniendo platos del día disponibles: $e');
      return [];
    }
  }

  // ===========================================================================
  // 7. FAVORITOS
  // ===========================================================================

  /// Retorna los IDs de establecimientos marcados como favoritos por el usuario
  Future<List<int>> obtenerIdsFavoritos(int comensalId) async {
    try {
      final res = await _client
          .from('favoritos_r_sabor')
          .select('establecimiento_id')
          .eq('comensal_id', comensalId)
          .not('establecimiento_id', 'is', null);

      final list = res as List<dynamic>;
      return list.map((e) => e['establecimiento_id'] as int).toList();
    } catch (e) {
      debugPrint('[EstablecimientoService] Error obteniendo favoritos: $e');
      return [];
    }
  }

  /// Agrega o quita un establecimiento de los favoritos del usuario
  Future<bool> toggleFavorito(int comensalId, int establecimientoId, bool esFavorito) async {
    try {
      if (esFavorito) {
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
    } catch (e) {
      debugPrint('[EstablecimientoService] Error alternando estado de favorito: $e');
      return false;
    }
  }
}
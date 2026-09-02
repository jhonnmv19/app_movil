import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/usuario_model.dart';
import 'session_service.dart';

class UsuariosService {
  final SupabaseClient _supabase;

  /// Constructor con cliente Supabase inyectado o por defecto
  UsuariosService({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  static const String _tablaUsuarios = 'usuarios_r_sabor';

  // ===========================================================================
  // 1. AUTENTICACIÓN Y CONTROL DE SESIÓN
  // ===========================================================================

  /// Inicia sesión consultando directamente la tabla 'usuarios_r_sabor' por email.
  /// Si la consulta es exitosa, inicia automáticamente la sesión en [SessionService].
  Future<UsuarioModel?> login(String email, String password) async {
    try {
      final response = await _supabase
          .from(_tablaUsuarios)
          .select()
          .eq('email', email.trim().toLowerCase())
          .maybeSingle();

      if (response == null) {
        debugPrint('[UsuariosService] No se encontró usuario con el correo: $email');
        return null;
      }

      final usuario = UsuarioModel.fromJson(response as Map<String, dynamic>);

      // Validar si la cuenta se encuentra activa antes de iniciar sesión
      if (usuario.estado.toLowerCase() != 'activo') {
        throw Exception('La cuenta se encuentra inactiva o bloqueada.');
      }

      // Guardar en la sesión global en memoria
      SessionService().iniciarSesion(usuario);
      return usuario;
    } on PostgrestException catch (e) {
      debugPrint('[UsuariosService] Error Postgrest en login: ${e.message}');
      throw Exception('Error al conectar con la base de datos durante el login.');
    } catch (e) {
      debugPrint('[UsuariosService] Error inesperado en login: $e');
      rethrow;
    }
  }

  // ===========================================================================
  // 2. CONSULTAS Y LECTURA (READ)
  // ===========================================================================

  /// Obtiene la lista completa de todos los usuarios registrados.
  Future<List<UsuarioModel>> obtenerUsuarios() async {
    try {
      final response = await _supabase
          .from(_tablaUsuarios)
          .select()
          .order('id', ascending: true);

      final data = response as List<dynamic>;
      return data
          .map((json) => UsuarioModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      debugPrint('[UsuariosService] Error al obtener usuarios: ${e.message}');
      throw Exception('Error al cargar la lista de usuarios.');
    } catch (e) {
      debugPrint('[UsuariosService] Error inesperado al obtener usuarios: $e');
      return [];
    }
  }

  /// Obtiene un usuario por su ID.
  Future<UsuarioModel?> obtenerUsuarioPorId(int usuarioId) async {
    try {
      final response = await _supabase
          .from(_tablaUsuarios)
          .select()
          .eq('id', usuarioId)
          .maybeSingle();

      if (response == null) return null;

      return UsuarioModel.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      debugPrint('[UsuariosService] Error al obtener usuario $usuarioId: ${e.message}');
      throw Exception('Error al buscar la información del usuario.');
    } catch (e) {
      debugPrint('[UsuariosService] Error inesperado al obtener usuario por ID: $e');
      return null;
    }
  }

  /// Obtiene el perfil relacional completo del Dueño, incluyendo sus establecimientos y categorías enlazadas.
  Future<Map<String, dynamic>?> obtenerPerfilDueno(int usuarioId) async {
    try {
      final response = await _supabase
          .from(_tablaUsuarios)
          .select('''
            id,
            nombre_completo,
            email,
            telefono,
            rol,
            estado,
            establecimientos_r_sabor!fk_establ_dueno (
              id,
              nombre_comercial,
              descripcion,
              direccion_texto,
              estado_local,
              verificado,
              calificacion_promedio,
              categorias_negocio_r_sabor!fk_establ_categoria ( nombre )
            )
          ''')
          .eq('id', usuarioId)
          .maybeSingle();

      return response as Map<String, dynamic>?;
    } on PostgrestException catch (e) {
      debugPrint('[UsuariosService] Error Postgrest obteniendo perfil del dueño: ${e.message}');
      throw Exception('Error al cargar los datos del establecimiento del dueño.');
    } catch (e) {
      debugPrint('[UsuariosService] Error inesperado en obtenerPerfilDueno: $e');
      return null;
    }
  }

  // ===========================================================================
  // 3. CREACIÓN (CREATE)
  // ===========================================================================

  /// Crea un nuevo usuario desde el Panel de Administración o flujo de registro.
  Future<UsuarioModel> crearUsuario({
    required String nombre,
    required String email,
    required String telefono,
    required String rol,
    String estado = 'activo',
  }) async {
    try {
      final payload = {
        'nombre_completo': nombre.trim(),
        'email': email.trim().toLowerCase(),
        'telefono': telefono.trim(),
        'rol': rol.trim(),
        'estado': estado,
      };

      final response = await _supabase
          .from(_tablaUsuarios)
          .insert(payload)
          .select()
          .single();

      debugPrint('[UsuariosService] Usuario creado exitosamente con ID: ${response['id']}');
      return UsuarioModel.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      debugPrint('[UsuariosService] Error al crear usuario: ${e.message}');
      throw Exception('No se pudo registrar el usuario: ${e.message}');
    } catch (e) {
      debugPrint('[UsuariosService] Error inesperado al crear usuario: $e');
      rethrow;
    }
  }

  // ===========================================================================
  // 4. ACTUALIZACIÓN (UPDATE)
  // ===========================================================================

  /// Actualiza los datos generales de un usuario (para Administradores).
  Future<void> actualizarUsuario({
    required int id,
    required String nombre,
    required String telefono,
    required String rol,
  }) async {
    try {
      final updateData = {
        'nombre_completo': nombre.trim(),
        'telefono': telefono.trim(),
        'rol': rol.trim(),
      };

      await _supabase
          .from(_tablaUsuarios)
          .update(updateData)
          .eq('id', id);

      // Si el usuario actualizado es el mismo que tiene la sesión activa, se actualiza el SessionService
      final usuarioSesion = SessionService().usuarioActual;
      if (usuarioSesion != null && usuarioSesion.id == id) {
        final usuarioActualizado = usuarioSesion.copyWith(
          nombreCompleto: nombre.trim(),
          telefono: telefono.trim(),
          rol: rol.trim(),
        );
        SessionService().actualizarUsuarioActual(usuarioActualizado);
      }

      debugPrint('[UsuariosService] Usuario ID $id actualizado correctamente.');
    } on PostgrestException catch (e) {
      debugPrint('[UsuariosService] Error al actualizar usuario: ${e.message}');
      throw Exception('Error al guardar los cambios del usuario.');
    } catch (e) {
      debugPrint('[UsuariosService] Error inesperado al actualizar usuario: $e');
      rethrow;
    }
  }

  /// Actualiza el perfil personal del usuario activo (Nombre y Teléfono).
  Future<bool> actualizarPerfil(
    int usuarioId,
    String nuevoNombre,
    String? nuevoTelefono,
  ) async {
    try {
      final updateData = <String, dynamic>{
        'nombre_completo': nuevoNombre.trim(),
        'telefono': nuevoTelefono?.trim(),
      };

      await _supabase
          .from(_tablaUsuarios)
          .update(updateData)
          .eq('id', usuarioId);

      // Sincronizar cambios en tiempo real con la sesión en memoria
      final usuarioSesion = SessionService().usuarioActual;
      if (usuarioSesion != null && usuarioSesion.id == usuarioId) {
        final usuarioActualizado = usuarioSesion.copyWith(
          nombreCompleto: nuevoNombre.trim(),
          telefono: nuevoTelefono?.trim(),
        );
        SessionService().actualizarUsuarioActual(usuarioActualizado);
      }

      debugPrint('[UsuariosService] Perfil del usuario ID $usuarioId actualizado exitosamente.');
      return true;
    } on PostgrestException catch (e) {
      debugPrint('[UsuariosService] Error Postgrest al actualizar perfil: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[UsuariosService] Error inesperado al actualizar perfil: $e');
      return false;
    }
  }

  /// Cambia el estado de la cuenta (ej: 'activo', 'inactivo', 'bloqueado').
  Future<void> cambiarEstadoUsuario(int usuarioId, String nuevoEstado) async {
    try {
      await _supabase
          .from(_tablaUsuarios)
          .update({'estado': nuevoEstado})
          .eq('id', usuarioId);

      // Actualizar la sesión en memoria si aplica
      final usuarioSesion = SessionService().usuarioActual;
      if (usuarioSesion != null && usuarioSesion.id == usuarioId) {
        final usuarioActualizado = usuarioSesion.copyWith(estado: nuevoEstado);
        SessionService().actualizarUsuarioActual(usuarioActualizado);
      }

      debugPrint('[UsuariosService] Estado del usuario $usuarioId cambiado a: $nuevoEstado');
    } on PostgrestException catch (e) {
      debugPrint('[UsuariosService] Error al cambiar estado del usuario: ${e.message}');
      throw Exception('No se pudo cambiar el estado del usuario.');
    } catch (e) {
      debugPrint('[UsuariosService] Error inesperado al cambiar estado: $e');
      rethrow;
    }
  }

  /// Cambia el rol del usuario (ej: 'comensal', 'dueno', 'admin').
  Future<void> actualizarRolUsuario(int usuarioId, String nuevoRol) async {
    try {
      await _supabase
          .from(_tablaUsuarios)
          .update({'rol': nuevoRol})
          .eq('id', usuarioId);

      // Actualizar la sesión en memoria si aplica
      final usuarioSesion = SessionService().usuarioActual;
      if (usuarioSesion != null && usuarioSesion.id == usuarioId) {
        final usuarioActualizado = usuarioSesion.copyWith(rol: nuevoRol);
        SessionService().actualizarUsuarioActual(usuarioActualizado);
      }

      debugPrint('[UsuariosService] Rol del usuario $usuarioId actualizado a: $nuevoRol');
    } on PostgrestException catch (e) {
      debugPrint('[UsuariosService] Error al cambiar rol del usuario: ${e.message}');
      throw Exception('No se pudo actualizar el rol del usuario.');
    } catch (e) {
      debugPrint('[UsuariosService] Error inesperado al actualizar rol: $e');
      rethrow;
    }
  }

  // ===========================================================================
  // 5. ELIMINACIÓN (DELETE)
  // ===========================================================================

  /// Elimina un usuario por su ID de la base de datos.
  Future<void> eliminarUsuario(int usuarioId) async {
    try {
      await _supabase
          .from(_tablaUsuarios)
          .delete()
          .eq('id', usuarioId);

      // Si se eliminó el usuario que estaba usando la app, se cierra su sesión
      if (SessionService().usuarioId == usuarioId) {
        SessionService().cerrarSesion();
      }

      debugPrint('[UsuariosService] Usuario $usuarioId eliminado con éxito.');
    } on PostgrestException catch (e) {
      debugPrint('[UsuariosService] Error al eliminar usuario: ${e.message}');
      throw Exception('Error al intentar borrar el registro del usuario.');
    } catch (e) {
      debugPrint('[UsuariosService] Error inesperado al eliminar usuario: $e');
      rethrow;
    }
  }
}
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario_model.dart';
import 'session_service.dart';

class UsuariosService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// AUTH / LOGIN DIRECTO EN TABLA
  Future<UsuarioModel?> login(String email, String password) async {
    try {
      final response = await _supabase
          .from('usuarios_r_sabor')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (response == null) return null;

      final usuario = UsuarioModel.fromJson(response);
      SessionService().iniciarSesion(usuario);
      return usuario;
    } catch (e) {
      debugPrint('Error en login: $e');
      return null;
    }
  }

  /// OBTENER PERFIL COMPLETO DEL DUEÑO
  Future<Map<String, dynamic>?> obtenerPerfilDuenno(int usuarioId) async {
    try {
      final response = await _supabase
          .from('usuarios_r_sabor')
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

      return response;
    } catch (e) {
      debugPrint('Error obteniendo perfil del dueño: $e');
      return null;
    }
  }

  /// READ - Listar todos los usuarios
  Future<List<UsuarioModel>> obtenerUsuarios() async {
    try {
      final response = await _supabase
          .from('usuarios_r_sabor')
          .select()
          .order('fecha_registro', ascending: false);

      return (response as List)
          .map((json) => UsuarioModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error al obtener usuarios: $e');
      return [];
    }
  }

  /// CREATE - Crear un nuevo usuario desde el Admin Dashboard
  Future<void> crearUsuario({
    required String nombre,
    required String email,
    required String telefono,
    required String rol,
  }) async {
    try {
      await _supabase.from('usuarios_r_sabor').insert({
        'nombre_completo': nombre,
        'email': email,
        'telefono': telefono,
        'rol': rol,
        'estado': 'activo',
      });
    } catch (e) {
      debugPrint('Error al crear usuario: $e');
      rethrow;
    }
  }

  /// UPDATE - Actualizar datos completos de un usuario existente
  Future<void> actualizarUsuario({
    required int id,
    required String nombre,
    required String telefono,
    required String rol,
  }) async {
    try {
      await _supabase.from('usuarios_r_sabor').update({
        'nombre_completo': nombre,
        'telefono': telefono,
        'rol': rol,
      }).eq('id', id);
    } catch (e) {
      debugPrint('Error al actualizar usuario: $e');
      rethrow;
    }
  }

  /// UPDATE ESTADO (Inactivar / Bloquear / Activar)
  Future<void> cambiarEstadoUsuario(int usuarioId, String nuevoEstado) async {
    try {
      await _supabase
          .from('usuarios_r_sabor')
          .update({'estado': nuevoEstado})
          .eq('id', usuarioId);
    } catch (e) {
      debugPrint('Error al cambiar estado del usuario: $e');
    }
  }

  /// UPDATE ROL
  Future<void> actualizarRolUsuario(int usuarioId, String nuevoRol) async {
    try {
      await _supabase
          .from('usuarios_r_sabor')
          .update({'rol': nuevoRol})
          .eq('id', usuarioId);
    } catch (e) {
      debugPrint('Error al actualizar rol del usuario: $e');
    }
  }

  /// DELETE
  Future<void> eliminarUsuario(int usuarioId) async {
    try {
      await _supabase.from('usuarios_r_sabor').delete().eq('id', usuarioId);
    } catch (e) {
      debugPrint('Error al eliminar usuario: $e');
    }
  }

  /// UPDATE PERFIL DE USUARIO
  Future<bool> actualizarPerfil(
      int usuarioId, String nuevoNombre, String? nuevoTelefono) async {
    try {
      await _supabase
          .from('usuarios_r_sabor')
          .update({
            'nombre_completo': nuevoNombre,
            'telefono': nuevoTelefono,
          })
          .eq('id', usuarioId);
      return true;
    } catch (e) {
      debugPrint('Error actualizando perfil: $e');
      return false;
    }
  }
}
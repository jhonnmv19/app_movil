import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario_model.dart';
import 'session_service.dart';

class UsuariosService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // AUTH / LOGIN DIRECTO EN TABLA
  Future<UsuarioModel?> login(String email, String password) async {
    try {
      final response = await _supabase
          .from('usuarios_r_sabor')
          .select()
          .eq('email', email)
          .single();

      final usuario = UsuarioModel.fromJson(response);
      SessionService().iniciarSesion(usuario);
      return usuario;
    } catch (e) {
      print('Error en login: $e');
      return null;
    }
  }

  // READ
  Future<List<UsuarioModel>> obtenerUsuarios() async {
    final response = await _supabase
        .from('usuarios_r_sabor')
        .select()
        .order('fecha_registro', ascending: false);

    return (response as List)
        .map((json) => UsuarioModel.fromJson(json))
        .toList();
  }

  // UPDATE ESTADO (Inactivar / Bloquear / Activar)
  Future<void> cambiarEstadoUsuario(int usuarioId, String nuevoEstado) async {
    await _supabase
        .from('usuarios_r_sabor')
        .update({'estado': nuevoEstado})
        .eq('id', usuarioId);
  }

  // UPDATE ROL
  Future<void> actualizarRolUsuario(int usuarioId, String nuevoRol) async {
    await _supabase
        .from('usuarios_r_sabor')
        .update({'rol': nuevoRol})
        .eq('id', usuarioId);
  }

  // DELETE
  Future<void> eliminarUsuario(int usuarioId) async {
    await _supabase.from('usuarios_r_sabor').delete().eq('id', usuarioId);
  }
}
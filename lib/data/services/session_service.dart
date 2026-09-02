import 'package:flutter/foundation.dart';
import '../models/usuario_model.dart';

class SessionService {
  // Patrón Singleton
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  // Estado interno del usuario
  UsuarioModel? _usuarioActual;

  /// Notificador reactivo para escuchar cambios de sesión en la interfaz de Flutter
  final ValueNotifier<UsuarioModel?> usuarioNotifier = ValueNotifier<UsuarioModel?>(null);

  // ===========================================================================
  // 1. GETTERS, SETTERS Y ESTADO DE SESIÓN
  // ===========================================================================

  /// Retorna la instancia del usuario autenticado actualmente
  UsuarioModel? get usuarioActual => _usuarioActual;

  /// Retorna true si existe un usuario autenticado en la sesión actual
  bool get estaAutenticado => _usuarioActual != null;

  /// Retorna el nombre a mostrar en la interfaz (Fallback a 'Invitado')
  String get nombreMostrar => _usuarioActual?.nombreCompleto.isNotEmpty == true 
      ? _usuarioActual!.nombreCompleto 
      : 'Invitado';

  /// Retorna el correo electrónico del usuario activo
  String get emailUsuario => _usuarioActual?.email ?? '';

  /// Retorna el ID del usuario activo (0 si no está autenticado)
  int get usuarioId => _usuarioActual?.id ?? 0;

  /// Permite actualizar/forzar el ID del usuario actual si es necesario resincronizar el modelo
  set usuarioId(int id) {
    if (_usuarioActual != null) {
      _usuarioActual = _usuarioActual!.copyWith(id: id);
      usuarioNotifier.value = _usuarioActual;
      debugPrint('[SessionService] ID de usuario actualizado dinámicamente a: $id');
    }
  }

  // ===========================================================================
  // 2. CONTROL DE ROLES Y PERMISOS DE ACCESO
  // ===========================================================================

  /// Verifica si el usuario tiene rol de Administrador
  bool get esAdmin => _usuarioActual?.rol.toLowerCase() == 'admin';

  /// Verifica si el usuario tiene rol de Dueño de establecimiento
  bool get esDueno => 
      _usuarioActual?.rol.toLowerCase() == 'dueno' || 
      _usuarioActual?.rol.toLowerCase() == 'dueño';

  /// Verifica si el usuario tiene rol de Comensal / Cliente
  bool get esComensal => _usuarioActual?.rol.toLowerCase() == 'comensal';

  /// Verifica si la cuenta del usuario se encuentra en estado activo
  bool get esCuentaActiva => _usuarioActual?.estado.toLowerCase() == 'activo';

  // ===========================================================================
  // 3. GESTIÓN DE CICLO DE VIDA DE LA SESIÓN
  // ===========================================================================

  /// Establece el usuario autenticado e inicializa la sesión en memoria
  void iniciarSesion(UsuarioModel usuario) {
    _usuarioActual = usuario;
    usuarioNotifier.value = usuario;
    debugPrint('[SessionService] Sesión iniciada para el usuario: ${usuario.email} (ID: ${usuario.id})');
  }

  /// Actualiza los datos del usuario en memoria (ej: tras editar el perfil)
  void actualizarUsuarioActual(UsuarioModel nuevosDatos) {
    if (_usuarioActual != null && _usuarioActual!.id == nuevosDatos.id) {
      _usuarioActual = nuevosDatos;
      usuarioNotifier.value = nuevosDatos;
      debugPrint('[SessionService] Perfil de usuario actualizado en memoria.');
    }
  }

  /// Limpia la sesión actual y resetea los notificadores
  void cerrarSesion() {
    debugPrint('[SessionService] Cerrando sesión del usuario: ${_usuarioActual?.email}');
    _usuarioActual = null;
    usuarioNotifier.value = null;
  }
}
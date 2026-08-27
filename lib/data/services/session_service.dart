import '../models/usuario_model.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  UsuarioModel? _usuarioActual;

  UsuarioModel? get usuarioActual => _usuarioActual;
  bool get estaAutenticado => _usuarioActual != null;
  String get nombreMostrar => _usuarioActual?.nombreCompleto ?? 'Invitado';

  void iniciarSesion(UsuarioModel usuario) {
    _usuarioActual = usuario;
  }

  void cerrarSesion() {
    _usuarioActual = null;
  }
}
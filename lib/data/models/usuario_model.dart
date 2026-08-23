class UsuarioModel {
  final int id;
  final String nombreCompleto;
  final String email;
  final String? telefono;
  final String rol; // comensal, dueno, admin
  final String estado; // activo, inactivo, bloqueado
  final DateTime fechaRegistro;

  UsuarioModel({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    this.telefono,
    required this.rol,
    required this.estado,
    required this.fechaRegistro,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nombreCompleto: json['nombre_completo'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'],
      rol: json['rol'] ?? 'comensal',
      estado: json['estado'] ?? 'activo',
      fechaRegistro: json['fecha_registro'] != null
          ? DateTime.parse(json['fecha_registro'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre_completo': nombreCompleto,
      'email': email,
      'telefono': telefono,
      'rol': rol,
      'estado': estado,
    };
  }
}
class UsuarioModel {
  final int id;
  final String nombreCompleto;
  final String email;
  final String? telefono;
  final String rol;
  final String estado;

  const UsuarioModel({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    this.telefono,
    required this.rol,
    required this.estado,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] is int 
          ? json['id'] 
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nombreCompleto: json['nombre_completo']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      telefono: json['telefono']?.toString(),
      rol: json['rol']?.toString() ?? 'comensal',
      estado: json['estado']?.toString() ?? 'activo',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_completo': nombreCompleto,
      'email': email,
      'telefono': telefono,
      'rol': rol,
      'estado': estado,
    };
  }

  UsuarioModel copyWith({
    int? id,
    String? nombreCompleto,
    String? email,
    String? telefono,
    String? rol,
    String? estado,
  }) {
    return UsuarioModel(
      id: id ?? this.id,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      rol: rol ?? this.rol,
      estado: estado ?? this.estado,
    );
  }
}
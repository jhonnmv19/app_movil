class SolicitudRegistroModel {
  final int id;
  final int usuarioId;
  final String nombreNegocioPropuesto;
  final String? descripcionNegocio;
  final String? direccionPropuesta;
  final String? telefonoContacto;
  final String? documentoIdentidadUrl;
  final String? fotoEstablecimientoUrl; // <- Nuevo campo
  final double? latitud;                 // <- Nuevo campo
  final double? longitud;                // <- Nuevo campo
  String estadoSolicitud; 
  String? motivoRechazo;
  final DateTime fechaEnvio;
  final String? nombreUsuario;

  SolicitudRegistroModel({
    required this.id,
    required this.usuarioId,
    required this.nombreNegocioPropuesto,
    this.descripcionNegocio,
    this.direccionPropuesta,
    this.telefonoContacto,
    this.documentoIdentidadUrl,
    this.fotoEstablecimientoUrl,
    this.latitud,
    this.longitud,
    required this.estadoSolicitud,
    this.motivoRechazo,
    required this.fechaEnvio,
    this.nombreUsuario,
  });

  factory SolicitudRegistroModel.fromJson(Map<String, dynamic> json) {
    final usuarioMap = json['usuarios_r_sabor'] as Map<String, dynamic>?;

    return SolicitudRegistroModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      usuarioId: json['usuario_id'] is int ? json['usuario_id'] : int.tryParse(json['usuario_id']?.toString() ?? '0') ?? 0,
      nombreNegocioPropuesto: json['nombre_negocio_propuesto']?.toString() ?? '',
      descripcionNegocio: json['descripcion_negocio']?.toString(),
      direccionPropuesta: json['direccion_propuesta']?.toString(),
      telefonoContacto: json['telefono_contacto']?.toString(),
      documentoIdentidadUrl: json['documento_identidad_url']?.toString(),
      fotoEstablecimientoUrl: json['foto_establecimiento_url']?.toString(), // <- Mapeo
      latitud: json['latitud'] != null ? double.tryParse(json['latitud'].toString()) : null,   // <- Mapeo
      longitud: json['longitud'] != null ? double.tryParse(json['longitud'].toString()) : null, // <- Mapeo
      estadoSolicitud: json['estado_solicitud']?.toString() ?? 'pendiente',
      motivoRechazo: json['motivo_rechazo']?.toString(),
      fechaEnvio: json['fecha_envio'] != null
          ? DateTime.tryParse(json['fecha_envio'].toString()) ?? DateTime.now()
          : DateTime.now(),
      nombreUsuario: usuarioMap != null 
          ? usuarioMap['nombre_completo']?.toString() 
          : json['nombre_completo']?.toString(),
    );
  }

  // ... (mantén el resto de tus métodos toJson, copyWith, etc.)
}
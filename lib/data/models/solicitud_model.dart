class SolicitudRegistroModel {
  final int id;
  final int usuarioId;
  final String nombreNegocioPropuesto;
  final String? descripcionNegocio;
  final String? direccionPropuesta;
  final String? telefonoContacto;
  final String? documentoIdentidadUrl;
  String estadoSolicitud; // pendiente, aprobado, rechazado
  String? motivoRechazo;
  final DateTime fechaEnvio;

  SolicitudRegistroModel({
    required this.id,
    required this.usuarioId,
    required this.nombreNegocioPropuesto,
    this.descripcionNegocio,
    this.direccionPropuesta,
    this.telefonoContacto,
    this.documentoIdentidadUrl,
    required this.estadoSolicitud,
    this.motivoRechazo,
    required this.fechaEnvio,
  });

  factory SolicitudRegistroModel.fromJson(Map<String, dynamic> json) {
    return SolicitudRegistroModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      usuarioId: json['usuario_id'] is int
          ? json['usuario_id']
          : int.parse(json['usuario_id'].toString()),
      nombreNegocioPropuesto: json['nombre_negocio_propuesto'] ?? '',
      descripcionNegocio: json['descripcion_negocio'],
      direccionPropuesta: json['direccion_propuesta'],
      telefonoContacto: json['telefono_contacto'],
      documentoIdentidadUrl: json['documento_identidad_url'],
      estadoSolicitud: json['estado_solicitud'] ?? 'pendiente',
      motivoRechazo: json['motivo_rechazo'],
      fechaEnvio: json['fecha_envio'] != null
          ? DateTime.parse(json['fecha_envio'])
          : DateTime.now(),
    );
  }
}
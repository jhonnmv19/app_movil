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
    id: json['id'] is int 
        ? json['id'] 
        : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
    usuarioId: json['usuario_id'] is int
        ? json['usuario_id']
        : int.tryParse(json['usuario_id']?.toString() ?? '0') ?? 0,
    nombreNegocioPropuesto: json['nombre_negocio_propuesto']?.toString() ?? '',
    descripcionNegocio: json['descripcion_negocio']?.toString(),
    direccionPropuesta: json['direccion_propuesta']?.toString(),
    telefonoContacto: json['telefono_contacto']?.toString(),
    documentoIdentidadUrl: json['documento_identidad_url']?.toString(),
    estadoSolicitud: json['estado_solicitud']?.toString() ?? 'pendiente',
    motivoRechazo: json['motivo_rechazo']?.toString(),
    fechaEnvio: json['fecha_envio'] != null
        ? DateTime.tryParse(json['fecha_envio'].toString()) ?? DateTime.now()
        : DateTime.now(),
  );
}
}
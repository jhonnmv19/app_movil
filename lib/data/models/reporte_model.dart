class ReporteProblema {
  final int? id;
  final int comensalId;
  final int? establecimientoId;
  final String descripcion;
  final String estado;
  final String? respuestaAdmin;
  final int? atendidoPorAdminId;
  final DateTime? fechaReporte;
  final DateTime? fechaResolucion;

  ReporteProblema({
    this.id,
    required this.comensalId,
    this.establecimientoId,
    required this.descripcion,
    this.estado = 'pendiente',
    this.respuestaAdmin,
    this.atendidoPorAdminId,
    this.fechaReporte,
    this.fechaResolucion,
  });

  Map<String, dynamic> toJson() {
    return {
      'comensal_id': comensalId,
      if (establecimientoId != null) 'establecimiento_id': establecimientoId,
      'descripcion': descripcion,
      'estado': estado,
      if (respuestaAdmin != null) 'respuesta_admin': respuestaAdmin,
      if (atendidoPorAdminId != null) 'atendido_por_admin_id': atendidoPorAdminId,
    };
  }

  factory ReporteProblema.fromJson(Map<String, dynamic> json) {
    return ReporteProblema(
      id: json['id'],
      comensalId: json['comensal_id'],
      establecimientoId: json['establecimiento_id'],
      descripcion: json['descripcion'] ?? '',
      estado: json['estado'] ?? 'pendiente',
      respuestaAdmin: json['respuesta_admin'],
      atendidoPorAdminId: json['atendido_por_admin_id'],
      fechaReporte: json['fecha_reporte'] != null
          ? DateTime.parse(json['fecha_reporte'])
          : null,
      fechaResolucion: json['fecha_resolucion'] != null
          ? DateTime.parse(json['fecha_resolucion'])
          : null,
    );
  }
}
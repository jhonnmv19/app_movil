class EstablecimientoModel {
  final int id;
  final int duenoId;
  final int categoriaId;
  final String nombreComercial;
  final String? descripcion;
  final String? direccionTexto;
  final double? latitud;
  final double? longitud;
  final String? imagenPortada;
  final double calificacionPromedio;
  final String estadoLocal;

  EstablecimientoModel({
    required this.id,
    required this.duenoId,
    required this.categoriaId,
    required this.nombreComercial,
    this.descripcion,
    this.direccionTexto,
    this.latitud,
    this.longitud,
    this.imagenPortada,
    required this.calificacionPromedio,
    required this.estadoLocal,
  });

  factory EstablecimientoModel.fromJson(Map json) {
    return EstablecimientoModel(
      id: json['id'],
      duenoId: json['dueno_id'],
      categoriaId: json['categoria_id'],
      nombreComercial: json['nombre_comercial'],
      descripcion: json['descripcion'],
      direccionTexto: json['direccion_texto'],
      latitud: json['latitud'] != null ? (json['latitud'] as num).toDouble() : null,
      longitud: json['longitud'] != null ? (json['longitud'] as num).toDouble() : null,
      imagenPortada: json['imagen_portada'],
      calificacionPromedio: (json['calificacion_promedio'] as num).toDouble(),
      estadoLocal: json['estado_local'] ?? 'cerrado',
    );
  }
}
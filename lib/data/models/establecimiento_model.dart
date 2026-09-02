class EstablecimientoModel {
  final int id;
  final int duenoId;
  final int categoriaId;
  final String nombreComercial;
  final String? descripcion;
  final String? direccionTexto;
  final double latitud;
  final double longitud;
  final String? imagenPortada;
  final double calificacionPromedio;
  final String estadoLocal;
  final bool verificado;

  EstablecimientoModel({
    required this.id,
    required this.duenoId,
    required this.categoriaId,
    required this.nombreComercial,
    this.descripcion,
    this.direccionTexto,
    required this.latitud,
    required this.longitud,
    this.imagenPortada,
    required this.calificacionPromedio,
    required this.estadoLocal,
    required this.verificado,
  });

  factory EstablecimientoModel.fromJson(Map<String, dynamic> json) {
    return EstablecimientoModel(
      id: json['id'] is int 
          ? json['id'] 
          : int.parse(json['id']?.toString() ?? '0'),
      duenoId: json['dueno_id'] is int 
          ? json['dueno_id'] 
          : int.parse(json['dueno_id']?.toString() ?? '0'),
      categoriaId: json['categoria_id'] is int 
          ? json['categoria_id'] 
          : int.parse(json['categoria_id']?.toString() ?? '0'),
      nombreComercial: json['nombre_comercial'] ?? '',
      descripcion: json['descripcion'],
      direccionTexto: json['direccion_texto'],
      latitud: (json['latitud'] as num?)?.toDouble() ?? 0.0,
      longitud: (json['longitud'] as num?)?.toDouble() ?? 0.0,
      imagenPortada: json['imagen_portada'],
      calificacionPromedio: (json['calificacion_promedio'] as num?)?.toDouble() ?? 0.0,
      estadoLocal: json['estado_local'] ?? 'cerrado',
      verificado: json['verificado'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dueno_id': duenoId,
      'categoria_id': categoriaId,
      'nombre_comercial': nombreComercial,
      'descripcion': descripcion,
      'direccion_texto': direccionTexto,
      'latitud': latitud,
      'longitud': longitud,
      'imagen_portada': imagenPortada,
      'calificacion_promedio': calificacionPromedio,
      'estado_local': estadoLocal,
      'verificado': verificado,
    };
  }

  // Método de conveniencia para inserciones (omite el id autonumérico)
  Map<String, dynamic> toInsertJson() {
    return {
      'dueno_id': duenoId,
      'categoria_id': categoriaId,
      'nombre_comercial': nombreComercial,
      'descripcion': descripcion,
      'direccion_texto': direccionTexto,
      'latitud': latitud,
      'longitud': longitud,
      'imagen_portada': imagenPortada,
      'calificacion_promedio': calificacionPromedio,
      'estado_local': estadoLocal,
      'verificado': verificado,
    };
  }

  // Permite actualizar estados o datos sin reconstruir toda la instancia manualmente
  EstablecimientoModel copyWith({
    int? id,
    int? duenoId,
    int? categoriaId,
    String? nombreComercial,
    String? descripcion,
    String? direccionTexto,
    double? latitud,
    double? longitud,
    String? imagenPortada,
    double? calificacionPromedio,
    String? estadoLocal,
    bool? verificado,
  }) {
    return EstablecimientoModel(
      id: id ?? this.id,
      duenoId: duenoId ?? this.duenoId,
      categoriaId: categoriaId ?? this.categoriaId,
      nombreComercial: nombreComercial ?? this.nombreComercial,
      descripcion: descripcion ?? this.descripcion,
      direccionTexto: direccionTexto ?? this.direccionTexto,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      imagenPortada: imagenPortada ?? this.imagenPortada,
      calificacionPromedio: calificacionPromedio ?? this.calificacionPromedio,
      estadoLocal: estadoLocal ?? this.estadoLocal,
      verificado: verificado ?? this.verificado,
    );
  }
}
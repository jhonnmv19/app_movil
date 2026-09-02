class PlatoDiaItem {
  final int id;
  final String tituloOferta;
  final String? descripcionOferta;
  final double precioOfertaBs;
  final bool disponibleAhora;
  final String? imagenUrl;
  final String nombreEstablecimiento;
  final String? direccion;

  PlatoDiaItem({
    required this.id,
    required this.tituloOferta,
    this.descripcionOferta,
    required this.precioOfertaBs,
    this.disponibleAhora = true,
    this.imagenUrl,
    required this.nombreEstablecimiento,
    this.direccion,
  });

  // Getters de compatibilidad para evitar romper UI previa
  String get titulo => tituloOferta;
  String? get descripcion => descripcionOferta;
  double get precio => precioOfertaBs;

  factory PlatoDiaItem.fromJson(Map<String, dynamic> json) {
    final est = json['establecimientos_r_sabor'] as Map<String, dynamic>?;
    final platillo = json['platillos_r_sabor'] as Map<String, dynamic>?;

    return PlatoDiaItem(
      id: json['id'] is int ? json['id'] : int.parse(json['id']?.toString() ?? '0'),
      tituloOferta: json['titulo_oferta'] ?? json['nombre'] ?? '',
      descripcionOferta: json['descripcion_oferta'] ?? json['descripcion'],
      precioOfertaBs: ((json['precio_oferta_bs'] ?? json['precio_bs'] ?? 0) as num).toDouble(),
      disponibleAhora: json['disponible_ahora'] ?? true,
      imagenUrl: platillo != null ? platillo['imagen_url'] : json['imagen_url'],
      nombreEstablecimiento: est != null 
          ? (est['nombre_comercial'] ?? 'Restaurante') 
          : (json['nombre_comercial'] ?? 'Restaurante'),
      direccion: est != null ? est['direccion_texto'] : json['direccion_texto'],
    );
  }

  factory PlatoDiaItem.fromMap(Map<String, dynamic> map) => PlatoDiaItem.fromJson(map);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo_oferta': tituloOferta,
      'descripcion_oferta': descripcionOferta,
      'precio_oferta_bs': precioOfertaBs,
      'disponible_ahora': disponibleAhora,
      'imagen_url': imagenUrl,
      'nombre_comercial': nombreEstablecimiento,
      'direccion_texto': direccion,
    };
  }

  PlatoDiaItem copyWith({
    int? id,
    String? tituloOferta,
    String? descripcionOferta,
    double? precioOfertaBs,
    bool? disponibleAhora,
    String? imagenUrl,
    String? nombreEstablecimiento,
    String? direccion,
  }) {
    return PlatoDiaItem(
      id: id ?? this.id,
      tituloOferta: tituloOferta ?? this.tituloOferta,
      descripcionOferta: descripcionOferta ?? this.descripcionOferta,
      precioOfertaBs: precioOfertaBs ?? this.precioOfertaBs,
      disponibleAhora: disponibleAhora ?? this.disponibleAhora,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      nombreEstablecimiento: nombreEstablecimiento ?? this.nombreEstablecimiento,
      direccion: direccion ?? this.direccion,
    );
  }
}

class CategoriaItem {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? iconoUrl;

  CategoriaItem({
    required this.id, 
    required this.nombre, 
    this.descripcion,
    this.iconoUrl,
  });

  factory CategoriaItem.fromJson(Map<String, dynamic> json) {
    return CategoriaItem(
      id: json['id'] is int ? json['id'] : int.parse(json['id']?.toString() ?? '0'),
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      iconoUrl: json['imagen_icono'] ?? json['icono_url'],
    );
  }

  factory CategoriaItem.fromMap(Map<String, dynamic> map) => CategoriaItem.fromJson(map);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'icono_url': iconoUrl,
    };
  }
}

// Alias de clase para máxima flexibilidad en tu proyecto
typedef CategoriaModel = CategoriaItem;
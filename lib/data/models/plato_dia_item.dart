class PlatoDiaItem {
  final int id;
  final int establecimientoId;
  final String tituloOferta;
  final String? descripcionOferta;
  final double precioOfertaBs;
  final bool disponibleAhora;
  final String? imagenUrl;
  final String nombreRestaurante;
  final String? direccion;
  final double? latitud;
  final double? longitud;

  PlatoDiaItem({
    required this.id,
    required this.establecimientoId,
    required this.tituloOferta,
    this.descripcionOferta,
    required this.precioOfertaBs,
    required this.disponibleAhora,
    this.imagenUrl,
    required this.nombreRestaurante,
    this.direccion,
    this.latitud,
    this.longitud,
  });

  // Getters de compatibilidad para evitar romper código legacy en UI
  String get titulo => tituloOferta;
  String? get descripcion => descripcionOferta;
  double get precio => precioOfertaBs;
  String get nombreEstablecimiento => nombreRestaurante;

  factory PlatoDiaItem.fromJson(Map<String, dynamic> json) {
    final est = json['establecimientos_r_sabor'] as Map<String, dynamic>?;
    final platillo = json['platillos_r_sabor'] as Map<String, dynamic>?;

    return PlatoDiaItem(
      id: json['id'] is int 
          ? json['id'] 
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      establecimientoId: json['establecimiento_id'] is int
          ? json['establecimiento_id']
          : int.tryParse(json['establecimiento_id']?.toString() ?? '0') ?? 0,
      tituloOferta: json['titulo_oferta']?.toString() ?? json['nombre']?.toString() ?? '',
      descripcionOferta: json['descripcion_oferta']?.toString() ?? json['descripcion']?.toString(),
      precioOfertaBs: ((json['precio_oferta_bs'] ?? json['precio_bs'] ?? 0) as num).toDouble(),
      disponibleAhora: json['disponible_ahora'] ?? true,
      imagenUrl: platillo != null ? platillo['imagen_url'] : json['imagen_url'],
      nombreRestaurante: est != null 
          ? (est['nombre_comercial'] ?? 'Restaurante') 
          : (json['nombre_comercial'] ?? 'Restaurante'),
      direccion: est != null ? est['direccion_texto'] : json['direccion_texto'],
      latitud: est?['latitud'] != null 
          ? (est!['latitud'] as num).toDouble() 
          : (json['latitud'] != null ? (json['latitud'] as num).toDouble() : null),
      longitud: est?['longitud'] != null 
          ? (est!['longitud'] as num).toDouble() 
          : (json['longitud'] != null ? (json['longitud'] as num).toDouble() : null),
    );
  }

  factory PlatoDiaItem.fromMap(Map<String, dynamic> map) => PlatoDiaItem.fromJson(map);
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
      id: json['id'] is int 
          ? json['id'] 
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
      iconoUrl: json['imagen_icono']?.toString() ?? json['icono_url']?.toString(),
    );
  }

  factory CategoriaItem.fromMap(Map<String, dynamic> map) => CategoriaItem.fromJson(map);
}

typedef CategoriaModel = CategoriaItem;
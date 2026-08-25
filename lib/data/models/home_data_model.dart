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

  // --- GETTERS DE COMPATIBILIDAD (Evitan errores si tus pantallas usan los nombres antiguos) ---
  String get titulo => tituloOferta;
  String? get descripcion => descripcionOferta;
  double get precio => precioOfertaBs;

  factory PlatoDiaItem.fromJson(Map<String, dynamic> json) {
    // Mapeo seguro de relaciones de Supabase
    final est = json['establecimientos_r_sabor'] as Map<String, dynamic>?;
    final platillo = json['platillos_r_sabor'] as Map<String, dynamic>?;

    return PlatoDiaItem(
      // Parsing seguro de ID (int o String)
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      
      // Mapeo flexible de títulos
      tituloOferta: json['titulo_oferta'] ?? json['nombre'] ?? '',
      
      // Mapeo flexible de descripción
      descripcionOferta: json['descripcion_oferta'] ?? json['descripcion'],
      
      // Casting seguro de precio
      precioOfertaBs: ((json['precio_oferta_bs'] ?? json['precio_bs'] ?? 0) as num).toDouble(),
      
      // Estado de disponibilidad
      disponibleAhora: json['disponible_ahora'] ?? true,
      
      // Mapeo seguro de imagen
      imagenUrl: platillo != null ? platillo['imagen_url'] : json['imagen_url'],
      
      // Obtención del establecimiento desde la relación o campo plano
      nombreEstablecimiento: est != null 
          ? (est['nombre_comercial'] ?? 'Restaurante') 
          : (json['nombre_comercial'] ?? 'Restaurante'),
          
      // Dirección del establecimiento
      direccion: est != null ? est['direccion_texto'] : json['direccion_texto'],
    );
  }

  // Compatibilidad con código que use fromMap
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
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      iconoUrl: json['imagen_icono'] ?? json['icono_url'],
    );
  }

  factory CategoriaItem.fromMap(Map<String, dynamic> map) => CategoriaItem.fromJson(map);
}

// Aliases por si alguna parte del código busca CategoriaModel en lugar de CategoriaItem
typedef CategoriaModel = CategoriaItem;
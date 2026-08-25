class PlatoDiaItem {
  final int id;
  final String tituloOferta;
  final String? descripcionOferta;
  final double precioOfertaBs;
  final bool disponibleAhora;
  final String? imagenUrl;
  final String nombreEstablecimiento;
  final String? direccionEstablecimiento;

  PlatoDiaItem({
    required this.id,
    required this.tituloOferta,
    this.descripcionOferta,
    required this.precioOfertaBs,
    required this.disponibleAhora,
    this.imagenUrl,
    required this.nombreEstablecimiento,
    this.direccionEstablecimiento,
  });

  factory PlatoDiaItem.fromJson(Map<String, dynamic> json) {
    // Extracción de datos con JOIN relacional
    final platillo = json['platillos_r_sabor'] as Map<String, dynamic>?;
    final establecimiento = json['establecimientos_r_sabor'] as Map<String, dynamic>?;

    return PlatoDiaItem(
      id: json['id'] as int,
      tituloOferta: json['titulo_oferta'] as String? ?? '',
      descripcionOferta: json['descripcion_oferta'] as String?,
      precioOfertaBs: (json['precio_oferta_bs'] as num).toDouble(),
      disponibleAhora: json['disponible_ahora'] as bool? ?? true,
      imagenUrl: platillo != null ? platillo['imagen_url'] as String? : null,
      nombreEstablecimiento: establecimiento != null ? establecimiento['nombre_comercial'] as String? ?? '' : '',
      direccionEstablecimiento: establecimiento != null ? establecimiento['direccion_texto'] as String? : null,
    );
  }
}
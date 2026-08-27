class PlatoDiaItem {
  final int id;
  final int establecimientoId;
  final String tituloOferta;
  final String? descripcionOferta;
  final double precioOfertaBs;
  final bool disponibleAhora;
  final String nombreRestaurante;
  final double? latitud;
  final double? longitud;

  PlatoDiaItem({
    required this.id,
    required this.establecimientoId,
    required this.tituloOferta,
    this.descripcionOferta,
    required this.precioOfertaBs,
    required this.disponibleAhora,
    required this.nombreRestaurante,
    this.latitud,
    this.longitud,
  });

  factory PlatoDiaItem.fromJson(Map<String, dynamic> json) {
    final estab = json['establecimientos_r_sabor'];
    return PlatoDiaItem(
      id: json['id'] as int,
      establecimientoId: json['establecimiento_id'] as int,
      tituloOferta: json['titulo_oferta'] ?? '',
      descripcionOferta: json['descripcion_oferta'],
      precioOfertaBs: (json['precio_oferta_bs'] as num).toDouble(),
      disponibleAhora: json['disponible_ahora'] ?? true,
      nombreRestaurante: estab?['nombre_comercial'] ?? 'Restaurante',
      latitud: estab?['latitud'] != null ? (estab['latitud'] as num).toDouble() : null,
      longitud: estab?['longitud'] != null ? (estab['longitud'] as num).toDouble() : null,
    );
  }
}
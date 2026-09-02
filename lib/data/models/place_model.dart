import 'package:latlong2/latlong.dart';

class PlaceModel {
  final int id;
  final String name;
  final String address;
  final LatLng location;
  final String? estadoLocal;
  final int? categoriaId;

  PlaceModel({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    this.estadoLocal,
    this.categoriaId,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    final lat = (json['latitud'] as num?)?.toDouble() ?? 0.0;
    final lng = (json['longitud'] as num?)?.toDouble() ?? 0.0;

    return PlaceModel(
      id: json['id'] is int 
          ? json['id'] 
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['nombre_comercial']?.toString() ?? '',
      address: json['direccion_texto']?.toString() ?? '',
      location: LatLng(lat, lng),
      estadoLocal: json['estado_local']?.toString(),
      categoriaId: json['categoria_id'] is int 
          ? json['categoria_id'] 
          : int.tryParse(json['categoria_id']?.toString() ?? ''),
    );
  }

  factory PlaceModel.fromMap(Map<String, dynamic> map) => PlaceModel.fromJson(map);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_comercial': name,
      'direccion_texto': address,
      'latitud': location.latitude,
      'longitud': location.longitude,
      'estado_local': estadoLocal,
      'categoria_id': categoriaId,
    };
  }

  PlaceModel copyWith({
    int? id,
    String? name,
    String? address,
    LatLng? location,
    String? estadoLocal,
    int? categoriaId,
  }) {
    return PlaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      location: location ?? this.location,
      estadoLocal: estadoLocal ?? this.estadoLocal,
      categoriaId: categoriaId ?? this.categoriaId,
    );
  }
}
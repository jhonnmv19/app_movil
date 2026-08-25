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
    return PlaceModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['nombre_comercial'] ?? '',
      address: json['direccion_texto'] ?? '',
      location: LatLng(
        (json['latitud'] as num).toDouble(),
        (json['longitud'] as num).toDouble(),
      ),
      estadoLocal: json['estado_local'],
      categoriaId: json['categoria_id'],
    );
  }
}
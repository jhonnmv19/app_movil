import 'package:latlong2/latlong.dart';

class PlaceModel {
  final String id;
  final String name;
  final String address;
  final LatLng location;
  final String category;

  const PlaceModel({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.category,
  });
}
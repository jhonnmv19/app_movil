import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/place_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final LatLng _cochabambaCenter = const LatLng(-17.3895, -66.1568);

  // Lista de lugares gastronómicos de prueba
  final List<PlaceModel> _spots = const [
    PlaceModel(
      id: '1',
      name: 'Feria del Silpancho',
      address: 'Av. Las Heroínas - Abierto ahora',
      location: LatLng(-17.3895, -66.1568),
      category: 'Tradicional',
    ),
    PlaceModel(
      id: '2',
      name: 'Trancapechos Doña Pola',
      address: 'C. San Martín - Abierto ahora',
      location: LatLng(-17.3940, -66.1500),
      category: 'Piqueos',
    ),
  ];

  late PlaceModel _selectedSpot;

  @override
  void initState() {
    super.initState();
    _selectedSpot = _spots.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa Gastronómico'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              _mapController.move(_cochabambaCenter, 14.5);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _cochabambaCenter,
              initialZoom: 14.0,
              minZoom: 5.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app_movil',
              ),
              MarkerLayer(
                markers: _spots.map((spot) {
                  final isSelected = _selectedSpot.id == spot.id;
                  return Marker(
                    point: spot.location,
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSpot = spot;
                        });
                      },
                      child: Icon(
                        Icons.location_on,
                        color: isSelected ? Colors.redAccent : AppTheme.primaryOrange,
                        size: isSelected ? 48 : 38,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Tarjeta inferior
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.restaurant_menu,
                    color: AppTheme.primaryOrange,
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedSpot.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _selectedSpot.address,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/place_model.dart'; // Importación correcta
import '../../../data/services/establecimiento_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final LatLng _cochabambaCenter = const LatLng(-17.3895, -66.1568);
  final EstablecimientoService _service = EstablecimientoService();

  late Future<List<PlaceModel>> _futureSpots;
  PlaceModel? _selectedSpot;

  @override
  void initState() {
    super.initState();
    _cargarLugares();
  }

  void _cargarLugares() {
    _futureSpots = _service.fetchEstablecimientosMapa().then((spots) {
      if (spots.isNotEmpty && mounted) {
        setState(() {
          _selectedSpot = spots.first;
        });
      }
      return spots;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa Gastronómico'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _cargarLugares();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (_selectedSpot != null) {
                _mapController.move(_selectedSpot!.location, 15.0);
              } else {
                _mapController.move(_cochabambaCenter, 14.5);
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<PlaceModel>>(
        future: _futureSpots,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error al obtener el mapa: ${snapshot.error}'),
            );
          }

          final spots = snapshot.data ?? [];

          if (spots.isEmpty) {
            return const Center(
              child: Text('No hay establecimientos registrados con coordenadas.'),
            );
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _selectedSpot?.location ?? _cochabambaCenter,
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
                    markers: spots.map((spot) {
                      final isSelected = _selectedSpot?.id == spot.id;
                      return Marker(
                        point: spot.location,
                        width: 50,
                        height: 50,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSpot = spot;
                            });
                            _mapController.move(spot.location, _mapController.camera.zoom);
                          },
                          child: Icon(
                            Icons.location_on,
                            color: isSelected
                                ? Colors.redAccent
                                : (spot.estadoLocal == 'abierto'
                                    ? AppTheme.primaryOrange
                                    : Colors.grey),
                            size: isSelected ? 48 : 38,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              if (_selectedSpot != null)
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
                                _selectedSpot!.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                _selectedSpot!.address,
                                style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _selectedSpot!.estadoLocal == 'abierto'
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _selectedSpot!.estadoLocal?.toUpperCase() ?? '',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _selectedSpot!.estadoLocal == 'abierto'
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
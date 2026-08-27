import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/establecimiento_model.dart';
import '../../../data/services/establecimiento_service.dart';

class MapScreen extends StatefulWidget {
  final double? destinoLat;
  final double? destinoLng;
  final String? nombreLugar;

  const MapScreen({
    super.key,
    this.destinoLat,
    this.destinoLng,
    this.nombreLugar,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final EstablecimientoService _service = EstablecimientoService();
  final MapController _mapController = MapController();

  LatLng _posicionActual = const LatLng(-17.3895, -66.1568); // Cochabamba
  List<EstablecimientoModel> _locales = [];
  List<LatLng> _puntosRuta = [];

  bool _loading = true;
  bool _cargandoRuta = false;
  EstablecimientoModel? _localSeleccionado;

  @override
  void initState() {
    super.initState();
    _obtenerUbicacionYLocales();
  }

  /// 1. Obtiene ubicación actual del usuario, descarga los locales y
  /// traza la ruta al destino especificado en el constructor (si existe).
  Future<void> _obtenerUbicacionYLocales() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        _posicionActual = LatLng(position.latitude, position.longitude);
      }
    } catch (e) {
      debugPrint('Error al obtener la ubicación: $e');
    }

    final locales = await _service.obtenerEstablecimientosAbiertos();

    if (mounted) {
      setState(() {
        _locales = locales;
        _loading = false;
      });

      // Si se recibieron parámetros de destino desde la navegación
      if (widget.destinoLat != null && widget.destinoLng != null) {
        final destino = LatLng(widget.destinoLat!, widget.destinoLng!);
        _trazarRuta(_posicionActual, destino);
      }
    }
  }

  /// 2. Traza la ruta llamando a la API gratuita de OSRM
  Future<void> _trazarRuta(LatLng origen, LatLng destino) async {
    setState(() => _cargandoRuta = true);

    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${origen.longitude},${origen.latitude};${destino.longitude},${destino.latitude}'
      '?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List coordinates = data['routes'][0]['geometry']['coordinates'];

        setState(() {
          _puntosRuta = coordinates
              .map((coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
              .toList();
        });

        // Encuadrar la vista en el mapa hacia el destino
        _mapController.move(destino, 15.5);
      } else {
        _mostrarMensaje('No se pudo calcular la ruta');
      }
    } catch (e) {
      _mostrarMensaje('Error al conectar con el servicio de rutas');
    } finally {
      if (mounted) {
        setState(() => _cargandoRuta = false);
      }
    }
  }

  /// Selecciona un local y calcula la ruta hacia él
  void _seleccionarYNavegarA(EstablecimientoModel local) {
    setState(() {
      _localSeleccionado = local;
    });
    _trazarRuta(
      _posicionActual,
      LatLng(local.latitud, local.longitud),
    );
  }

  double _calcularDistanciaMeters(double lat, double lng) {
    return Geolocator.distanceBetween(
      _posicionActual.latitude,
      _posicionActual.longitude,
      lat,
      lng,
    );
  }

  void _mostrarMensaje(String msj) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msj)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nombreLugar ?? 'Mapa Gastronómico Cochabamba'),
        backgroundColor: AppTheme.primaryOrange,
        foregroundColor: Colors.white,
        actions: [
          if (_puntosRuta.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Limpiar Ruta',
              onPressed: () {
                setState(() {
                  _puntosRuta.clear();
                  _localSeleccionado = null;
                });
              },
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Mapa principal
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: (widget.destinoLat != null && widget.destinoLng != null)
                        ? LatLng(widget.destinoLat!, widget.destinoLng!)
                        : _posicionActual,
                    initialZoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.rutadelsabor.app',
                    ),

                    // LÍNEA DE RUTA TRAZADA (OSRM)
                    if (_puntosRuta.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _puntosRuta,
                            strokeWidth: 5.0,
                            color: AppTheme.primaryOrange,
                          ),
                        ],
                      ),

                    // MARCADORES
                    MarkerLayer(
                      markers: [
                        // Marcador Ubicación Actual
                        Marker(
                          point: _posicionActual,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.blue,
                            size: 32,
                          ),
                        ),

                        // Marcador de Destino Específico (si viene por constructor)
                        if (widget.destinoLat != null && widget.destinoLng != null)
                          Marker(
                            point: LatLng(widget.destinoLat!, widget.destinoLng!),
                            width: 45,
                            height: 45,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.redAccent,
                              size: 48,
                            ),
                          ),

                        // Marcadores de Establecimientos
                        ..._locales.map((local) {
                          final esElSeleccionado =
                              _localSeleccionado?.id == local.id;

                          return Marker(
                            point: LatLng(local.latitud, local.longitud),
                            width: 45,
                            height: 45,
                            child: GestureDetector(
                              onTap: () => _mostrarDetalleLocal(local),
                              child: Icon(
                                Icons.location_on,
                                color: esElSeleccionado
                                    ? Colors.redAccent
                                    : AppTheme.primaryOrange,
                                size: esElSeleccionado ? 48 : 38,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),

                // Indicador de carga de la ruta
                if (_cargandoRuta)
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Calculando ruta...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Carrusel Inferior de Locales
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _locales.length,
                      itemBuilder: (context, index) {
                        final local = _locales[index];
                        final distMeters = _calcularDistanciaMeters(
                            local.latitud, local.longitud);
                        final distKm =
                            (distMeters / 1000).toStringAsFixed(1);

                        return Container(
                          width: 260,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 6)
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                local.nombreComercial,
                                style: Theme.of(context).textTheme.titleLarge,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '📍 a $distKm km de ti',
                                style: const TextStyle(
                                  color: AppTheme.primaryOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                local.direccionTexto ?? 'Sin dirección',
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                ),
                                icon: const Icon(Icons.directions, size: 16),
                                label: const Text('Cómo Llegar'),
                                onPressed: () => _seleccionarYNavegarA(local),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 150),
        child: FloatingActionButton(
          backgroundColor: AppTheme.primaryOrange,
          child: const Icon(Icons.my_location, color: Colors.white),
          onPressed: () {
            _mapController.move(_posicionActual, 16.0);
          },
        ),
      ),
    );
  }

  /// Muestra el modal desplegable con los detalles del negocio
  void _mostrarDetalleLocal(EstablecimientoModel local) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                local.nombreComercial,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                local.descripcion ?? 'Gastronomía variada en Cochabamba',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  Text(' ${local.calificacionPromedio} Calificación'),
                  const SizedBox(width: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      local.estadoLocal.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.navigation),
                  label: const Text('Navegar hacia el puesto'),
                  onPressed: () {
                    Navigator.pop(context);
                    _seleccionarYNavegarA(local);
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/establecimiento_model.dart';
import '../../../data/services/establecimiento_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final EstablecimientoService _service = EstablecimientoService();
  late Future<List<EstablecimientoModel>> _puntosMapaFuture;
  
  // Se declara con EstablecimientoModel en lugar de PlaceModel
  EstablecimientoModel? _selectedSpot;

  @override
  void initState() {
    super.initState();
    _puntosMapaFuture = _cargarEstablecimientos();
  }

  Future<List<EstablecimientoModel>> _cargarEstablecimientos() async {
    final spots = await _service.obtenerEstablecimientosAbiertos();
    if (spots.isNotEmpty) {
      setState(() {
        _selectedSpot = spots.first;
      });
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa Gastronómico'),
        backgroundColor: AppTheme.primaryOrange,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<EstablecimientoModel>>(
        future: _puntosMapaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final locales = snapshot.data ?? [];

          return Stack(
            children: [
              // Área del Mapa
              Container(
                color: const Color(0xFFE5E3DF),
                child: const Center(
                  child: Icon(Icons.map, size: 100, color: AppTheme.textMuted),
                ),
              ),
              
              // Tarjetas inferiores
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: locales.length,
                    itemBuilder: (context, index) {
                      final local = locales[index];
                      final isSelected = _selectedSpot?.id == local.id;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSpot = local;
                          });
                        },
                        child: Container(
                          width: 250,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: isSelected
                                ? Border.all(color: AppTheme.primaryOrange, width: 2)
                                : null,
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 6)
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
                              const SizedBox(height: 4),
                              Text(
                                local.direccionTexto ?? 'Sin dirección',
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                ),
                                child: const Text('Cómo llegar',
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
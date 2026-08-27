import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/plato_dia_item.dart';
import '../../../data/services/establecimiento_service.dart';
import 'map_screen.dart'; // Ajusta esta ruta según la ubicación exacta de tu map_screen.dart

class PlatoDiaScreen extends StatefulWidget {
  const PlatoDiaScreen({super.key});

  @override
  State<PlatoDiaScreen> createState() => _PlatoDiaScreenState();
}

class _PlatoDiaScreenState extends State<PlatoDiaScreen> {
  final EstablecimientoService _service = EstablecimientoService();
  late Future<List<PlatoDiaItem>> _platosFuture;

  @override
  void initState() {
    super.initState();
    _platosFuture = _service.obtenerPlatosDelDiaDisponibles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platos del Día'),
      ),
      body: FutureBuilder<List<PlatoDiaItem>>(
        future: _platosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final platos = snapshot.data ?? [];

          if (platos.isEmpty) {
            return const Center(
              child: Text('No hay platos del día disponibles hoy.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: platos.length,
            itemBuilder: (context, index) {
              final plato = platos[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información principal del plato
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plato.nombreRestaurante,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  plato.tituloOferta,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                if (plato.descripcionOferta != null &&
                                    plato.descripcionOferta!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    plato.descripcionOferta!,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Bs. ${plato.precioOfertaBs.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryOrange,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Botón para trazar la ruta hacia el restaurante
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.directions),
                          label: const Text(
                            'Cómo llegar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            if (plato.latitud != null && plato.longitud != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MapScreen(
                                    destinoLat: plato.latitud!,
                                    destinoLng: plato.longitud!,
                                    nombreLugar: plato.nombreRestaurante,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'El restaurante no tiene ubicación registrada.',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
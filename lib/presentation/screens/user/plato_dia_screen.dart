import 'package:flutter/material.dart';
import '../../../data/services/establecimiento_service.dart';

class PlatoDelDiaScreen extends StatefulWidget {
  const PlatoDelDiaScreen({super.key});

  @override
  State<PlatoDelDiaScreen> createState() => _PlatoDelDiaScreenState();
}

class _PlatoDelDiaScreenState extends State<PlatoDelDiaScreen> {
  final _service = EstablecimientoService();
  late Future<List<Map<String, dynamic>>> _platosFuture;

  @override
  void initState() {
    super.initState();
    // Guardamos la referencia del Future al iniciar el Estado
    _platosFuture = _service.obtenerPlatosDelDia();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Platos del Día Activos')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _platosFuture,
        builder: (context, snapshot) {
          // 1. Estado de Carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // 2. Estado de Error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error al cargar los platos: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final platos = snapshot.data ?? [];

          // 3. Estado Vacío (Sin registros)
          if (platos.isEmpty) {
            return const Center(
              child: Text(
                'No hay platos del día disponibles en este momento.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // 4. Renderizado de la Lista
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: platos.length,
            itemBuilder: (context, index) {
              final plato = platos[index];

              // Obtenemos el nombre del establecimiento si viene como relación/join
              final nombreEstablecimiento = plato['establecimientos'] != null
                  ? plato['establecimientos']['nombre'] ?? 'Establecimiento'
                  : 'Establecimiento';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              plato['titulo_oferta'] ?? 'Sin título',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF2EE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Bs. ${plato['precio_oferta_bs'] ?? '0.00'}',
                              style: const TextStyle(
                                color: Color(0xFFD64E28),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Establecimiento: $nombreEstablecimiento'),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.location_on, size: 18),
                          label: const Text('Ver Ubicación'),
                          onPressed: () {
                            // Acción para abrir mapa o ver detalles de ubicación
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
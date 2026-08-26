import 'package:flutter/material.dart';
import '../../../data/services/establecimiento_service.dart';
import '../../../data/models/home_data_model.dart';

class PlatoDiaScreen extends StatefulWidget {
  const PlatoDiaScreen({Key? key}) : super(key: key);

  @override
  State<PlatoDiaScreen> createState() => _PlatoDiaScreenState();
}

class _PlatoDiaScreenState extends State<PlatoDiaScreen> {
  final EstablecimientoService _service = EstablecimientoService();
  late Future<List<PlatoDiaItem>> _futurePlatos;

  @override
  void initState() {
    super.initState();
    _futurePlatos = _service.fetchPlatosDelDia();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platos del Día'),
      ),
      body: FutureBuilder<List<PlatoDiaItem>>(
        future: _futurePlatos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar datos: ${snapshot.error}'));
          }
          final platos = snapshot.data ?? [];
          if (platos.isEmpty) {
            return const Center(child: Text('No hay platos del día disponibles hoy.'));
          }

          return ListView.builder(
            itemCount: platos.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, index) {
              final plato = platos[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: ListTile(
                  leading: plato.imagenUrl != null
                      ? Image.network(
                          plato.imagenUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, size: 40),
                        )
                      : const Icon(Icons.fastfood, size: 40),
                  title: Text(plato.tituloOferta, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${plato.nombreEstablecimiento}\n${plato.descripcionOferta ?? ""}'),
                  trailing: Text(
                    'Bs. ${plato.precioOfertaBs.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
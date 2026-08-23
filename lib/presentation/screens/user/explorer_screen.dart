import 'package:flutter/material.dart';

class ExplorerScreen extends StatelessWidget {
  const ExplorerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar Ferias y Puestos'),
      ),
      body: const Center(
        child: Text(
          'Módulo de Geolocalización y Mapas en construcción...',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
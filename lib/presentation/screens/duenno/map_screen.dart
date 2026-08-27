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
  EstablecimientoModel? _selectedSpot;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    _puntosMapaFuture = _service.obtenerEstablecimientosAbiertos();
  }

  Future<void> _recargarMapa() async {
    setState(_cargarDatos);
    await _puntosMapaFuture;
  }

  void _seleccionarLocal(EstablecimientoModel local) {
    setState(() => _selectedSpot = local);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa Gastronómico'),
        backgroundColor: AppTheme.primaryOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Actualizar mapa',
            onPressed: _recargarMapa,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<EstablecimientoModel>>(
        future: _puntosMapaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryOrange,
              ),
            );
          }

          if (snapshot.hasError) {
            return _MapMessage(
              icon: Icons.cloud_off_rounded,
              message: 'No se pudieron cargar los establecimientos.',
              actionLabel: 'Reintentar',
              onAction: _recargarMapa,
            );
          }

          final locales = snapshot.data ?? [];

          if (locales.isEmpty) {
            return const _MapMessage(
              icon: Icons.location_off_rounded,
              message: 'No hay establecimientos abiertos disponibles.',
            );
          }

          _selectedSpot ??= locales.first;

          return RefreshIndicator(
            color: AppTheme.primaryOrange,
            onRefresh: _recargarMapa,
            child: Stack(
              children: [
                Container(
                  color: const Color(0xFFE5E3DF),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.map_rounded,
                    size: 100,
                    color: AppTheme.textMuted,
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: SizedBox(
                    height: 142,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: locales.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final local = locales[index];
                        final isSelected = _selectedSpot?.id == local.id;

                        return _LocalCard(
                          local: local,
                          isSelected: isSelected,
                          onTap: () => _seleccionarLocal(local),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LocalCard extends StatelessWidget {
  final EstablecimientoModel local;
  final bool isSelected;
  final VoidCallback onTap;

  const _LocalCard({
    required this.local,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 260,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryOrange
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 7,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                local.nombreComercial,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 5),
              Text(
                local.direccionTexto ?? 'Sin dirección',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              SizedBox(
                height: 34,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.directions_rounded, size: 16),
                  label: const Text(
                    'Cómo llegar',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final Future<void> Function()? onAction;

  const _MapMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 52,
              color: AppTheme.primaryOrange,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
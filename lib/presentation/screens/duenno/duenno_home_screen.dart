import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';

class DuennoHomeScreen extends StatefulWidget {
  const DuennoHomeScreen({super.key});

  @override
  State<DuennoHomeScreen> createState() => _DuennoHomeScreenState();
}

class _DuennoHomeScreenState extends State<DuennoHomeScreen> {
  bool _estaAbierto = true;

  final String _nombreLocal = 'Restaurante Don Sabor';
  final String _estadoSolicitud = 'aprobado';

  void _abrirSolicitudes() {
    Navigator.pushNamed(
      context,
      AppRoutes.duennoRequests,
      arguments: const {'establecimientoId': 1},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primaryOrange,
          onRefresh: () async {
            await Future<void>.delayed(const Duration(milliseconds: 500));
            if (mounted) setState(() {});
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildBusinessStatus(),
              const SizedBox(height: 24),
              _buildOfferCard(),
              const SizedBox(height: 26),
              const Text(
                'Gestión del Negocio',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Menú Digital',
                      value: '12 Platos',
                      icon: Icons.menu_book_rounded,
                      color: Colors.blue,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Solicitud',
                      value: _estadoSolicitud.toUpperCase(),
                      icon: Icons.assignment_turned_in_rounded,
                      color: Colors.orange,
                      onTap: _abrirSolicitudes,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Panel de Control',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _nombreLocal,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          radius: 25,
          backgroundColor: AppTheme.accentLightOrange,
          child: const Icon(
            Icons.store_rounded,
            color: AppTheme.primaryOrange,
            size: 27,
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessStatus() {
    final color = _estaAbierto ? Colors.green : Colors.red;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.shade300),
      ),
      child: Row(
        children: [
          Icon(
            _estaAbierto
                ? Icons.check_circle_rounded
                : Icons.do_not_disturb_on_rounded,
            color: color.shade700,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _estaAbierto ? 'Local Abierto' : 'Local Cerrado',
                  style: TextStyle(
                    color: color.shade900,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _estaAbierto
                      ? 'Visible para comensales'
                      : 'Oculto en búsquedas',
                  style: TextStyle(
                    color: color.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _estaAbierto,
            activeColor: Colors.green,
            onChanged: (value) {
              setState(() => _estaAbierto = value);
              // TODO: Actualizar estado_local en Supabase.
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      color: AppTheme.primaryOrange,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.restaurant_rounded, color: Colors.white, size: 28),
                SizedBox(width: 10),
                Text(
                  'Plato del Día',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Publica la oferta gastronómica de hoy para atraer más comensales a tu local.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _abrirSolicitudes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Publicar / Actualizar Oferta',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
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
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withOpacity(.1),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
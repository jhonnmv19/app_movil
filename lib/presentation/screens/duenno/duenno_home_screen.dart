import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';

class DuennoHomeScreen extends StatefulWidget {
  const DuennoHomeScreen({super.key});

  @override
  State<DuennoHomeScreen> createState() => _DuennoHomeScreenState();
}

class _DuennoHomeScreenState extends State<DuennoHomeScreen> {
  // Simulación de datos del local (puedes conectar con tu service de Supabase)
  bool _estaAbierto = true;
  final String _nombreLocal = "Restaurante Don Sabor";
  final String _estadoSolicitud = "aprobado"; // 'pendiente', 'aprobado', 'rechazado'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. ENCABEZADO DEL DUEÑO
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Panel de Control',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _nombreLocal,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.accentLightOrange,
                    child: const Icon(Icons.store_rounded, color: AppTheme.primaryOrange, size: 26),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. SWITCH ESTADO DEL LOCAL (abierto / cerrado)
              Card(
                elevation: 0,
                color: _estaAbierto ? Colors.green.shade50 : Colors.red.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: _estaAbierto ? Colors.green.shade300 : Colors.red.shade300,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _estaAbierto ? Icons.check_circle : Icons.do_not_disturb_on,
                            color: _estaAbierto ? Colors.green.shade700 : Colors.red.shade700,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _estaAbierto ? 'Local Abierto' : 'Local Cerrado',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: _estaAbierto ? Colors.green.shade900 : Colors.red.shade900,
                                ),
                              ),
                              Text(
                                _estaAbierto ? 'Visible para comensales' : 'Oculto en búsquedas',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _estaAbierto ? Colors.green.shade700 : Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: _estaAbierto,
                        activeColor: Colors.green,
                        onChanged: (val) {
                          setState(() {
                            _estaAbierto = val;
                          });
                          // TODO: Llamar servicio Supabase para actualizar estado_local
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 3. ACCIÓN RÁPIDA: PUBLICAR PLATO DEL DÍA (plato_del_dia_r_sabor)
              Card(
                elevation: 2,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: AppTheme.primaryOrange,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.restaurant, color: Colors.white, size: 28),
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
                      const SizedBox(height: 8),
                      const Text(
                        'Publica la oferta gastronómica de hoy para atraer más comensales a tu local.',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primaryOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.duennoRequests,
                              arguments: {'establecimientoId': 1}, // Pasa el ID real
                            );
                          },
                          child: const Text(
                            'Publicar / Actualizar Oferta',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 4. RESUMEN Y GESTIÓN
              const Text(
                'Gestión del Negocio',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Menú Digital',
                      value: '12 Platos',
                      icon: Icons.menu_book,
                      color: Colors.blue,
                      onTap: () {
                        // Navegar a gestión de menú
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Solicitud',
                      value: _estadoSolicitud.toUpperCase(),
                      icon: Icons.assignment_turned_in,
                      color: Colors.orange,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.duennoRequests,
                          arguments: {'establecimientoId': 1},
                        );
                      },
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
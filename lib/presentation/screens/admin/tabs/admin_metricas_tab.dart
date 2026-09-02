import 'package:flutter/material.dart';

class AdminMetricasTab extends StatelessWidget {
  final int totalUsuarios;
  final int solicitudesAprobadas;
  final int solicitudesPendientes;
  final List<Map<String, dynamic>> reportes;

  const AdminMetricasTab({
    Key? key,
    required this.totalUsuarios,
    required this.solicitudesAprobadas,
    required this.solicitudesPendientes,
    required this.reportes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 850;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetricasLayout(isDesktop),
          const SizedBox(height: 24),
          _buildSeccionRendimiento(),
          const SizedBox(height: 24),
          _buildTarjetaReportes(),
        ],
      ),
    );
  }

  Widget _buildMetricasLayout(bool isDesktop) {
    final cards = [
      _metricCard(
        title: 'RESTAURANTES REGISTRADOS',
        value: '$solicitudesAprobadas',
        subtext: 'Locales activos',
        icon: Icons.storefront_rounded,
        color: const Color(0xFF0EA5E9),
      ),
      _metricCard(
        title: 'USUARIOS REGISTRADOS',
        value: '$totalUsuarios',
        subtext: 'Comensales y Dueños',
        icon: Icons.group_rounded,
        color: const Color(0xFF10B981),
      ),
      _metricCard(
        title: 'SOLICITUDES PENDIENTES',
        value: '$solicitudesPendientes',
        subtext: 'Atención prioritaria',
        icon: Icons.notifications_active_rounded,
        color: const Color(0xFFF59E0B),
      ),
    ];

    if (isDesktop) {
      return Row(
        children: cards
            .map((card) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: card,
                  ),
                ))
            .toList(),
      );
    }

    return Column(
      children: cards
          .map((card) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: card,
              ))
          .toList(),
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtext,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionRendimiento() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Métricas del Sistema y Actividad de Comensales',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Registros históricos y tendencias según la base de datos',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),
          _barraRendimiento('Búsquedas Realizadas en la App', 0.85,
              const Color(0xFF0EA5E9), '85% tráfico alto'),
          const SizedBox(height: 14),
          _barraRendimiento('Conversión de Comensales', 0.62,
              const Color(0xFF10B981), '62% activos este mes'),
          const SizedBox(height: 14),
          _barraRendimiento('Solicitudes Procesadas', 0.45,
              const Color(0xFFF59E0B), '45% completado'),
        ],
      ),
    );
  }

  Widget _barraRendimiento(
      String etiqueta, double porcentaje, Color color, String subtexto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                etiqueta,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              subtexto,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: porcentaje,
            minHeight: 10,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildTarjetaReportes() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reportes e Incidencias Recientes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          if (reportes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.mark_email_read_rounded,
                      size: 40,
                      color: Color(0xFF0EA5E9),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No hay reportes de soporte pendientes',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reportes.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final rep = reportes[index];
                final usuarioData = rep['usuarios_r_sabor']
                        as Map<String, dynamic>? ??
                    rep['usuarios'] as Map<String, dynamic>?;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF0EA5E9).withAlpha(30),
                    child: const Icon(
                      Icons.report_problem_rounded,
                      color: Color(0xFF0EA5E9),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    usuarioData?['nombre_completo'] ??
                        usuarioData?['nombre'] ??
                        'Comensal Anónimo',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    rep['descripcion'] ?? 'Sin descripción proporcionada',
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
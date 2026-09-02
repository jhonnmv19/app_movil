import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../data/models/solicitud_model.dart';

class AdminSolicitudesTab extends StatelessWidget {
  final List<SolicitudRegistroModel> solicitudes;
  final Function(int solicitudId, String nuevoEstado, {String? motivo}) onProcesarSolicitud;

  const AdminSolicitudesTab({
    Key? key,
    required this.solicitudes,
    required this.onProcesarSolicitud,
  }) : super(key: key);

  // Definición correcta del estilo como getter para evitar conflictos con const
  TextStyle get _estiloEncabezado => const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
        color: Color(0xFF475569),
      );

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 850;

    if (solicitudes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ), 
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.inbox_outlined, size: 48, color: Color(0xFF94A3B8)),
            SizedBox(height: 12),
            Text(
              'No hay solicitudes registradas en PostgreSQL.',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // 🟢 AQUÍ PASAMOS EL CONTEXTO CORRECTAMENTE A AMBAS FUNCIONES
    return isDesktop ? _buildTablaWeb(context) : _buildListaMovil(context);
  }

  // ===========================================================================
  // TABLA WEB / DESKTOP
  // ===========================================================================
  Widget _buildTablaWeb(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
            dataRowMinHeight: 60,
            dataRowMaxHeight: 70,
            horizontalMargin: 24,
            columnSpacing: 32,
            columns: [
              DataColumn(label: Text('NEGOCIO PROPUESTO', style: _estiloEncabezado)),
              DataColumn(label: Text('SOLICITANTE', style: _estiloEncabezado)),
              DataColumn(label: Text('TELÉFONO', style: _estiloEncabezado)),
              DataColumn(label: Text('ESTADO', style: _estiloEncabezado)),
              DataColumn(label: Text('ACCIONES DE MODERACIÓN', style: _estiloEncabezado)),
            ],
            rows: solicitudes.map((sol) {
              return DataRow(cells: [
                DataCell(
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.store_outlined, size: 20, color: Color(0xFF334155)),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        sol.nombreNegocioPropuesto,
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontSize: 14),
                      ),
                    ],
                  ),
                ),
                DataCell(Text(sol.nombreUsuario ?? 'Desconocido', style: const TextStyle(color: Color(0xFF475569), fontSize: 13))),
                DataCell(Text(sol.telefonoContacto ?? 'Sin registro', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13))),
                DataCell(_badgeEstado(sol.estadoSolicitud)),
                DataCell(
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _mostrarModalDetalle(context, sol),
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('Revisar Solicitud', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // LISTA MÓVIL
  // ===========================================================================
  Widget _buildListaMovil(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: solicitudes.length,
      itemBuilder: (contextIndex, index) {
        final sol = solicitudes[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        sol.nombreNegocioPropuesto,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                      ),
                    ),
                    _badgeEstado(sol.estadoSolicitud),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(sol.nombreUsuario ?? 'Usuario ID: ${sol.usuarioId}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(sol.telefonoContacto ?? 'Sin teléfono registrado', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _mostrarModalDetalle(context, sol),
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('Revisar Solicitud', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // MODAL DE DETALLE (VER PDF, FOTO Y APROBAR/RECHAZAR)
  // ===========================================================================
  void _mostrarModalDetalle(BuildContext context, SolicitudRegistroModel sol) {
    final TextEditingController motivoController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.description, color: Color(0xFF0F172A)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Detalle: ${sol.nombreNegocioPropuesto}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _itemInfo('Solicitante:', sol.nombreUsuario ?? 'No especificado'),
                  _itemInfo('Teléfono de Contacto:', sol.telefonoContacto ?? 'No registrado'),
                  _itemInfo('Dirección Propuesta:', sol.direccionPropuesta ?? 'No especificada'),
                  _itemInfo('Descripción del Negocio:', sol.descripcionNegocio ?? 'Sin descripción proporcionada'),
                  const Divider(height: 24),
                  
                  const Text('Documentación y Respaldos:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),

                  if (sol.documentoIdentidadUrl != null && sol.documentoIdentidadUrl!.isNotEmpty)
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue[700],
                        side: BorderSide(color: Colors.blue[300]!),
                      ),
                      onPressed: () async {
                        final Uri url = Uri.parse(sol.documentoIdentidadUrl!);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No se pudo abrir el documento PDF')),
                          );
                        }
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Ver Documento de Identidad (PDF)'),
                    )
                  else
                    const Text('⚠️ El usuario no adjuntó un documento de identidad.', style: TextStyle(color: Colors.orange, fontSize: 12)),

                  const SizedBox(height: 12),

                  if (sol.fotoEstablecimientoUrl != null && sol.fotoEstablecimientoUrl!.isNotEmpty) ...[
                    const Text('Foto del Establecimiento:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        sol.fotoEstablecimientoUrl!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Text('Error al cargar la imagen'),
                      ),
                    ),
                  ],

                  const Divider(height: 24),
                  const Text('Motivo de rechazo (Obligatorio si se rechaza):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: motivoController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Ej. Documento ilegible o datos incorrectos...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cerrar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () {
                if (motivoController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Debe especificar un motivo para rechazar la solicitud.')),
                  );
                  return;
                }
                Navigator.pop(dialogContext);
                onProcesarSolicitud(sol.id, 'rechazado', motivo: motivoController.text.trim());
              },
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Rechazar'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(dialogContext);
                onProcesarSolicitud(sol.id, 'aprobado');
              },
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Aprobar'),
            ),
          ],
        );
      },
    );
  }

  Widget _itemInfo(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
          Expanded(child: Text(valor, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)))),
        ],
      ),
    );
  }

  Widget _badgeEstado(String estado) {
    final est = estado.toLowerCase();
    Color bg = const Color(0xFFFEF3C7);
    Color txt = const Color(0xFFD97706);

    if (est == 'aprobado' || est == 'activo') {
      bg = const Color(0xFFD1FAE5);
      txt = const Color(0xFF059669);
    } else if (est == 'rechazado' || est == 'bloqueado') {
      bg = const Color(0xFFFEE2E2);
      txt = const Color(0xFFDC2626);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        estado.toUpperCase(),
        style: TextStyle(color: txt, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}
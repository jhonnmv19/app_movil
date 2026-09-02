import 'package:flutter/material.dart';
import '../../../../data/models/usuario_model.dart';

class AdminUsuariosTab extends StatelessWidget {
  final List<UsuarioModel> usuarios;
  final Function(UsuarioModel?) onEditarUsuario;
  final Function(int id, String nuevoEstado) onCambiarEstado;
  final Function(int id) onEliminarUsuario;

  const AdminUsuariosTab({
    Key? key,
    required this.usuarios,
    required this.onEditarUsuario,
    required this.onCambiarEstado,
    required this.onEliminarUsuario,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 850;

    if (usuarios.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(
          child: Text(
            'No hay usuarios registrados en PostgreSQL.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    return isDesktop ? _buildTablaWeb() : _buildListaMovil();
  }

  Widget _buildTablaWeb() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
          columns: const [
            DataColumn(
              label: Text(
                'USUARIO',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'CORREO ELECTRÓNICO',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'ROL',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'ESTADO',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'ACCIONES',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: usuarios.map((user) {
            final esBloqueado = user.estado.toLowerCase() == 'bloqueado';
            return DataRow(cells: [
              DataCell(Text(
                user.nombreCompleto,
                style: const TextStyle(fontWeight: FontWeight.w600),
              )),
              DataCell(Text(user.email)),
              DataCell(_badgeRol(user.rol)),
              DataCell(_badgeEstado(user.estado)),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Color(0xFF0EA5E9),
                    ),
                    onPressed: () => onEditarUsuario(user),
                    tooltip: 'Editar Datos',
                  ),
                  IconButton(
                    icon: Icon(
                      esBloqueado
                          ? Icons.lock_open_rounded
                          : Icons.block_rounded,
                      color: esBloqueado ? Colors.green : Colors.orange,
                    ),
                    onPressed: () {
                      final nuevoEstado = esBloqueado ? 'activo' : 'bloqueado';
                      onCambiarEstado(user.id, nuevoEstado);
                    },
                    tooltip: esBloqueado ? 'Desbloquear' : 'Bloquear',
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_forever_rounded,
                      color: Colors.redAccent,
                    ),
                    onPressed: () => onEliminarUsuario(user.id),
                    tooltip: 'Eliminar',
                  ),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildListaMovil() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: usuarios.length,
      itemBuilder: (context, index) {
        final user = usuarios[index];
        return Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              user.nombreCompleto,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _badgeRol(user.rol),
                    const SizedBox(width: 6),
                    _badgeEstado(user.estado),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF0EA5E9)),
              onPressed: () => onEditarUsuario(user),
            ),
          ),
        );
      },
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado.toUpperCase(),
        style: TextStyle(
          color: txt,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _badgeRol(String rol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        rol.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF475569),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
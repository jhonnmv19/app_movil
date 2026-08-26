import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';

class DuennoProfileScreen extends StatelessWidget {
  // CORRECCIÓN AQUÍ: super(key: key) en minúscula
  const DuennoProfileScreen({super.key});

  /// Consulta relacional: Obtiene los datos del usuario dueño
  /// y los datos asociados a su establecimiento en `establecimientos_r_sabor`
  Future<Map<String, dynamic>?> _obtenerPerfilDuenno() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || user.email == null) return null;

    final response = await Supabase.instance.client
        .from('usuarios_r_sabor')
        .select('''
          id,
          nombre_completo,
          email,
          telefono,
          rol,
          estado,
          establecimientos_r_sabor (
            id,
            nombre_comercial,
            direccion_texto,
            estado_local,
            verificado,
            categorias_negocio_r_sabor ( nombre )
          )
        ''')
        .eq('email', user.email!)
        .maybeSingle();

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Mi Perfil de Negocio'),
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _obtenerPerfilDuenno(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data;
          if (data == null) {
            return const Center(
              child: Text('No se pudo cargar la información del usuario.'),
            );
          }

          final listaEstablecimientos = data['establecimientos_r_sabor'] as List<dynamic>?;
          final establecimiento = (listaEstablecimientos != null && listaEstablecimientos.isNotEmpty)
              ? listaEstablecimientos.first as Map<String, dynamic>
              : null;

          final categoriaNombre = establecimiento?['categorias_negocio_r_sabor']?['nombre'] ?? 'Sin categoría';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: AppTheme.accentLightOrange,
                        child: const Icon(
                          Icons.storefront_rounded,
                          size: 48,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        data['nombre_completo'] ?? 'Sin Nombre',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Chip(
                        avatar: Icon(
                          data['estado'] == 'activo' ? Icons.check_circle : Icons.warning,
                          color: Colors.white,
                          size: 16,
                        ),
                        label: Text(
                          'Rol: ${(data['rol'] ?? 'dueno').toString().toUpperCase()}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: AppTheme.primaryOrange,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Datos Personales',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.email_outlined, color: AppTheme.primaryOrange),
                        title: const Text('Correo Electrónico', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        subtitle: Text(data['email'] ?? 'No registrado', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.phone_outlined, color: AppTheme.primaryOrange),
                        title: const Text('Teléfono de Contacto', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        subtitle: Text(data['telefono'] ?? 'No registrado', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Mi Establecimiento',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                if (establecimiento != null)
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.restaurant, color: AppTheme.primaryOrange),
                          title: const Text('Nombre Comercial', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          subtitle: Text(
                            establecimiento['nombre_comercial'] ?? 'Sin Nombre',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          trailing: Icon(
                            establecimiento['verificado'] == true
                                ? Icons.verified_rounded
                                : Icons.hourglass_top_rounded,
                            color: establecimiento['verificado'] == true ? Colors.blue : Colors.amber,
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.category_outlined, color: AppTheme.primaryOrange),
                          title: const Text('Categoría', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          subtitle: Text(categoriaNombre, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.location_on_outlined, color: AppTheme.primaryOrange),
                          title: const Text('Dirección', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          subtitle: Text(
                            establecimiento['direccion_texto'] ?? 'No especificada',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Card(
                    color: Colors.amber.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.amber.shade200),
                    ),
                    child: const ListTile(
                      leading: Icon(Icons.info_outline, color: Colors.amber),
                      title: Text('Sin establecimiento asignado', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Aún no tienes un negocio verificado registrado.'),
                    ),
                  ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      elevation: 0,
                      side: BorderSide(color: Colors.red.shade200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(fontWeight: FontWeight.bold),
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
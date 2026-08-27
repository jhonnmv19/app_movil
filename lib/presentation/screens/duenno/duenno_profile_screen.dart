import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_theme.dart';

class DuennoProfileScreen extends StatefulWidget {
  const DuennoProfileScreen({super.key});

  @override
  State<DuennoProfileScreen> createState() => _DuennoProfileScreenState();
}

class _DuennoProfileScreenState extends State<DuennoProfileScreen> {
  late Future<Map<String, dynamic>?> _perfilFuture;

  @override
  void initState() {
    super.initState();
    _perfilFuture = _obtenerPerfilDuenno();
  }

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

  Future<void> _recargarPerfil() async {
    setState(() {
      _perfilFuture = _obtenerPerfilDuenno();
    });

    await _perfilFuture;
  }

  Future<void> _cerrarSesion() async {
    await Supabase.instance.client.auth.signOut();

    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Mi Perfil de Negocio'),
        elevation: 0,
        backgroundColor: Colors.grey.shade50,
        surfaceTintColor: Colors.transparent,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _perfilFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryOrange,
              ),
            );
          }

          if (snapshot.hasError) {
            return _ErrorView(
              onRetry: _recargarPerfil,
            );
          }

          final data = snapshot.data;

          if (data == null) {
            return const Center(
              child: Text('No se pudo cargar la información del usuario.'),
            );
          }

          final establecimientos =
              data['establecimientos_r_sabor'] as List<dynamic>?;

          final establecimiento =
              establecimientos != null && establecimientos.isNotEmpty
                  ? establecimientos.first as Map<String, dynamic>
                  : null;

          final categoria = establecimiento?[
                  'categorias_negocio_r_sabor']?['nombre'] ??
              'Sin categoría';

          final usuarioActivo = data['estado'] == 'activo';
          final verificado = establecimiento?['verificado'] == true;

          return RefreshIndicator(
            color: AppTheme.primaryOrange,
            onRefresh: _recargarPerfil,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
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
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        avatar: Icon(
                          usuarioActivo
                              ? Icons.check_circle
                              : Icons.warning_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        label: Text(
                          'Rol: ${(data['rol'] ?? 'dueno').toString().toUpperCase()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: AppTheme.primaryOrange,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                _SectionTitle(title: 'Datos Personales'),
                const SizedBox(height: 10),
                _InfoCard(
                  children: [
                    _InfoTile(
                      icon: Icons.email_outlined,
                      title: 'Correo Electrónico',
                      value: data['email'] ?? 'No registrado',
                    ),
                    _InfoTile(
                      icon: Icons.phone_outlined,
                      title: 'Teléfono de Contacto',
                      value: data['telefono'] ?? 'No registrado',
                      showDivider: false,
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                _SectionTitle(title: 'Mi Establecimiento'),
                const SizedBox(height: 10),
                if (establecimiento != null)
                  _InfoCard(
                    children: [
                      _InfoTile(
                        icon: Icons.restaurant_rounded,
                        title: 'Nombre Comercial',
                        value: establecimiento['nombre_comercial'] ??
                            'Sin Nombre',
                        trailing: Icon(
                          verificado
                              ? Icons.verified_rounded
                              : Icons.hourglass_top_rounded,
                          color: verificado ? Colors.blue : Colors.amber,
                        ),
                      ),
                      _InfoTile(
                        icon: Icons.category_outlined,
                        title: 'Categoría',
                        value: categoria,
                      ),
                      _InfoTile(
                        icon: Icons.location_on_outlined,
                        title: 'Dirección',
                        value: establecimiento['direccion_texto'] ??
                            'No especificada',
                        showDivider: false,
                      ),
                    ],
                  )
                else
                  Card(
                    color: Colors.amber.shade50,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.amber.shade200),
                    ),
                    child: const ListTile(
                      leading: Icon(
                        Icons.info_outline,
                        color: Colors.amber,
                      ),
                      title: Text(
                        'Sin establecimiento asignado',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Aún no tienes un negocio verificado registrado.',
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _cerrarSesion,
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.red.shade200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Widget? trailing;
  final bool showDivider;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    this.trailing,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppTheme.primaryOrange),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          subtitle: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: trailing,
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppTheme.primaryOrange,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              'No se pudo cargar el perfil.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
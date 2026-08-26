import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  Future<Map<String, dynamic>?> _obtenerPerfilUsuario() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || user.email == null) return null;

    final response = await Supabase.instance.client
        .from('usuarios_r_sabor')
        .select()
        .eq('email', user.email!)
        .maybeSingle();

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _obtenerPerfilUsuario(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final userData = snapshot.data;
          if (userData == null) {
            return const Center(child: Text('No se pudo cargar la información del usuario.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 40,
                  child: Icon(Icons.person, size: 40),
                ),
                const SizedBox(height: 16),
                Text('Nombre: ${userData['nombre_completo']}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Email: ${userData['email']}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Rol: ${userData['rol']}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Teléfono: ${userData['telefono'] ?? 'No registrado'}', style: const TextStyle(fontSize: 16)),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    await Supabase.instance.client.auth.signOut();
                  },
                  child: const Text('Cerrar Sesión'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
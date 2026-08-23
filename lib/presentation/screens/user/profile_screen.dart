import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Datos editables del usuario
  String _userName = 'Jhonn Meneses';
  String _userCity = 'Cochabamba, Bolivia';

  // 1. Modal para Platos Favoritos
  void _showFavoritesModal() {
    final favoritos = [
      {'nombre': 'Silpancho Cochabambino', 'lugar': 'Casera Doña Rosa'},
      {'nombre': 'Pique Macho', 'lugar': 'El Palacio del Sabor'},
      {'nombre': 'Sopa de Maní', 'lugar': 'Puesto Tradicional N° 4'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Platos Favoritos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: favoritos.length,
                  itemBuilder: (context, index) {
                    final item = favoritos[index];
                    return ListTile(
                      leading: const Icon(Icons.restaurant, color: AppTheme.primaryOrange),
                      title: Text(item['nombre']!),
                      subtitle: Text(item['lugar']!),
                      trailing: const Icon(Icons.favorite, color: Colors.red),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 2. Diálogo para Historial de Visitas
  void _showHistoryDialog() {
    final historial = [
      {'lugar': 'Mercado Central', 'fecha': 'Ayer - 14:30'},
      {'lugar': 'Feria Gastronómica', 'fecha': '12 de Agosto'},
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.history, color: AppTheme.primaryOrange),
              SizedBox(width: 8),
              Text('Historial de Visitas'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: historial.map((item) {
              return ListTile(
                dense: true,
                leading: const Icon(Icons.place_outlined),
                title: Text(item['lugar']!),
                subtitle: Text(item['fecha']!),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar', style: TextStyle(color: AppTheme.primaryOrange)),
            ),
          ],
        );
      },
    );
  }

  // 3. Formulario para Editar Perfil (Configuración)
  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _userName);
    final cityController = TextEditingController(text: _userCity);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Editar Perfil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: 'Ubicación / Ciudad',
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _userName = nameController.text;
                  _userCity = cityController.text;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Perfil actualizado correctamente')),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  // 4. Formulario de Ayuda y Soporte / Reporte de Errores
  void _showSupportModal() {
    String selectedCategory = 'Error de ubicación / mapa';
    final reportController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ayuda y Soporte Técnico',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '¿Tienes problemas con imágenes, mapa o reseñas?',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de inconveniente',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Error de ubicación / mapa',
                        child: Text('Error de ubicación / mapa'),
                      ),
                      DropdownMenuItem(
                        value: 'Fotos de platos no cargan',
                        child: Text('Fotos de platos no cargan'),
                      ),
                      DropdownMenuItem(
                        value: 'Problema en reseñas',
                        child: Text('Problema en reseñas'),
                      ),
                      DropdownMenuItem(
                        value: 'Otro problema',
                        child: Text('Otro problema'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() => selectedCategory = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reportController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Describe el problema con detalle',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reporte enviado a soporte técnico. ¡Gracias!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: const Text('Enviar Reporte'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=32'),
            ),
            const SizedBox(height: 12),
            Text(
              _userName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              _userCity,
              style: const TextStyle(color: AppTheme.textMuted),
            ),
            const SizedBox(height: 24),

            _buildProfileOption(
              Icons.favorite_outline,
              'Platos Favoritos',
              _showFavoritesModal,
            ),
            _buildProfileOption(
              Icons.history,
              'Historial de Visitas',
              _showHistoryDialog,
            ),
            _buildProfileOption(
              Icons.settings_outlined,
              'Configuración',
              _showEditProfileDialog,
            ),
            _buildProfileOption(
              Icons.help_outline,
              'Ayuda y Soporte',
              _showSupportModal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryOrange),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textMuted),
        onTap: onTap,
      ),
    );
  }
}
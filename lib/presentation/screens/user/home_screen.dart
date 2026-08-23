import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Encabezado de bienvenida y Foto del usuario (Row + Column)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '¡Bienvenido!',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '¿Qué quieres comer\nhoy?',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 22,
                              height: 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=32'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Barra de Búsqueda (Row + Container + TextField)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: AppTheme.textMuted),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Buscar plato, feria o restaurante...',
                                hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.accentLightOrange,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.tune,
                      color: AppTheme.primaryOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. Banner Promocional / Módulo Destacado (Card + Row + Column)
              Card(
                elevation: 0,
                color: const Color(0xFFFFF2EE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppTheme.primaryOrange.withOpacity(0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.local_offer, size: 36, color: AppTheme.primaryOrange),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Plato del Día',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Explora las ofertas gastronómicas de hoy.',
                              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 18, color: AppTheme.primaryOrange),
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.platoDelDia);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 4. Sección Categorías (Row + ListView Horizontal)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Categorías', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('VER TODAS', style: TextStyle(color: AppTheme.primaryOrange, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    _CategoryCard(label: 'Chicharrón', icon: Icons.lunch_dining),
                    _CategoryCard(label: 'Silpancho', icon: Icons.flatware),
                    _CategoryCard(label: 'Saice', icon: Icons.soup_kitchen),
                    _CategoryCard(label: 'Pique Macho', icon: Icons.local_fire_department),
                    _CategoryCard(label: 'Sopas', icon: Icons.ramen_dining),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 5. Sección Platos Destacados (Row + Card personalizada)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Platos destacados', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('POPULARES', style: TextStyle(color: AppTheme.primaryOrange, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Tarjeta de Plato destacada usando Card
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.platoDelDia);
                },
                child: const _DishCard(
                  title: 'Pique Macho Especial',
                  price: 'Bs. 45',
                  location: 'Doña Elvira - El Prado, Cbba.',
                  rating: '4.9',
                  imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=500',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Sub-widget: Tarjeta de Categoría
class _CategoryCard extends StatelessWidget {
  final String label;
  final IconData icon;

  const _CategoryCard({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.primaryOrange, size: 28),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark),
          ),
        ],
      ),
    );
  }
}

// Sub-widget: Tarjeta de Plato Destacado (Basado en el widget Card de Flutter)
class _DishCard extends StatelessWidget {
  final String title;
  final String price;
  final String location;
  final String rating;
  final String imageUrl;

  const _DishCard({
    required this.title,
    required this.price,
    required this.location,
    required this.rating,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 160,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.fastfood, size: 50, color: Colors.grey),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Plato del día',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(rating, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      price,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.primaryOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Text(location, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'DISPONIBLE',
                        style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Icon(Icons.favorite_border, color: AppTheme.textMuted, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
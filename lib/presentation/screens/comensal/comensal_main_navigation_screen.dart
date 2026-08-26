import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import '../../../core/theme/app_theme.dart';

class ComensalMainNavigationScreen extends StatefulWidget {
  const ComensalMainNavigationScreen({super.key});

  @override
  State<ComensalMainNavigationScreen> createState() => _ComensalMainNavigationScreenState();
}

class _ComensalMainNavigationScreenState extends State<ComensalMainNavigationScreen> {
  int _currentIndex = 0;

  // 4 pantallas para 4 ítems del menú
  final List<Widget> _screens = [
    const HomeScreen(),
    const MapScreen(),
 // Se añade para cubrir el 3er ítem
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryOrange,
        unselectedItemColor: AppTheme.textMuted,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explorar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'plato_dia_screen.dart';
import 'profile_screen.dart';

class ComensalMainNavigationScreen extends StatefulWidget {
  const ComensalMainNavigationScreen({super.key});

  @override
  State<ComensalMainNavigationScreen> createState() => _ComensalMainNavigationScreenState();
}

class _ComensalMainNavigationScreenState extends State<ComensalMainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    MapScreen(),
    PlatoDiaScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppTheme.primaryOrange,
        unselectedItemColor: AppTheme.textMuted,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Plato del Día'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
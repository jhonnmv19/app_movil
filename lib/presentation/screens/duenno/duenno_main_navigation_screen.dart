import 'package:flutter/material.dart';
import 'duenno_home_screen.dart';
import 'map_screen.dart';
import 'requests_screen.dart';
import 'duenno_profile_screen.dart';
import '../../../core/theme/app_theme.dart';

class DuennoMainNavigationScreen extends StatefulWidget {
  const DuennoMainNavigationScreen({super.key});

  @override
  State<DuennoMainNavigationScreen> createState() => _DuennoMainNavigationScreenState();
}

class _DuennoMainNavigationScreenState extends State<DuennoMainNavigationScreen> {
  int _currentIndex = 0;

  // Corregido: 4 pantallas correspondientes a las 4 pestañas del dueño
  final List<Widget> _screens = [
    const DuennoHomeScreen(),
    const MapScreen(),
    const RequestsScreen(establecimientoId: 0), // O pasa el ID correspondiente
    const DuennoProfileScreen(),
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
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Solicitudes',
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
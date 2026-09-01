import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'plato_dia_screen.dart';
import 'profile_screen.dart';

class ComensalMainNavigationScreen extends StatefulWidget {
  const ComensalMainNavigationScreen({super.key});

  @override
  State<ComensalMainNavigationScreen> createState() =>
      _ComensalMainNavigationScreenState();
}

class _ComensalMainNavigationScreenState
    extends State<ComensalMainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    MapScreen(),
    PlatoDiaScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              if (_currentIndex != index) {
                setState(() => _currentIndex = index);
              }
            },
            height: 70,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            indicatorColor: AppTheme.accentLightOrange,
            labelBehavior:
                NavigationDestinationLabelBehavior.onlyShowSelected,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(
                  Icons.home_rounded,
                  color: AppTheme.primaryOrange,
                ),
                label: 'Inicio',
              ),
              NavigationDestination(
                icon: Icon(Icons.map_outlined),
                selectedIcon: Icon(
                  Icons.map_rounded,
                  color: AppTheme.primaryOrange,
                ),
                label: 'Mapa',
              ),
              NavigationDestination(
                icon: Icon(Icons.restaurant_menu_outlined),
                selectedIcon: Icon(
                  Icons.restaurant_menu_rounded,
                  color: AppTheme.primaryOrange,
                ),
                label: 'Plato del Día',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(
                  Icons.person_rounded,
                  color: AppTheme.primaryOrange,
                ),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
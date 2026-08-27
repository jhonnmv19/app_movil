import 'package:flutter/material.dart';

import 'duenno_home_screen.dart';
import 'duenno_profile_screen.dart';
import 'map_screen.dart';
import 'requests_screen.dart';
import '../../../core/theme/app_theme.dart';

class DuennoMainNavigationScreen extends StatefulWidget {
  const DuennoMainNavigationScreen({super.key});

  @override
  State<DuennoMainNavigationScreen> createState() =>
      _DuennoMainNavigationScreenState();
}

class _DuennoMainNavigationScreenState
    extends State<DuennoMainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DuennoHomeScreen(),
    MapScreen(),
    RequestsScreen(establecimientoId: 0),
    DuennoProfileScreen(),
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
                icon: Icon(Icons.assignment_outlined),
                selectedIcon: Icon(
                  Icons.assignment_rounded,
                  color: AppTheme.primaryOrange,
                ),
                label: 'Solicitudes',
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
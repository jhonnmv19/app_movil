import 'package:flutter/material.dart';
import 'duenno_home_screen.dart';
import 'duenno_profile_screen.dart';
import 'requests_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/establecimiento_service.dart';
import '../../../data/services/session_service.dart';

class DuennoMainNavigationScreen extends StatefulWidget {
  const DuennoMainNavigationScreen({super.key});

  @override
  State<DuennoMainNavigationScreen> createState() =>
      _DuennoMainNavigationScreenState();
}

class _DuennoMainNavigationScreenState
    extends State<DuennoMainNavigationScreen> {
  int _currentIndex = 0;
  int? _establecimientoId;
  bool _isLoading = true;

  final EstablecimientoService _establecimientoService =
      EstablecimientoService();

  @override
  void initState() {
    super.initState();
    _cargarEstablecimiento();
  }

  /// Obtiene el perfil del usuario autenticado y su establecimiento asignado
  Future<void> _cargarEstablecimiento() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // 1. Intentar obtener perfil por servicio de establecimiento
      var perfil = await _establecimientoService.obtenerPerfilUsuarioActual();

      // 2. Fallback: Usar la sesión guardada localmente si el llamado remoto falla
      perfil ??= SessionService().usuarioActual;

      if (perfil != null) {
        final estab = await _establecimientoService
            .obtenerEstablecimientoPorDueno(perfil.id);

        if (estab != null && mounted) {
          setState(() {
            _establecimientoId = estab.id;
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Error cargando datos del dueño: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryOrange,
          ),
        ),
      );
    }

    if (_establecimientoId == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.storefront_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No se encontró un establecimiento asignado a tu cuenta.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Verifica en la base de datos que exista un registro en la tabla "establecimientos_r_sabor" vinculado a tu dueno_id.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _cargarEstablecimiento,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final List<Widget> screens = [
      const DuennoHomeScreen(),
      RequestsScreen(establecimientoId: _establecimientoId!),
      const DuennoProfileScreen(),
    ];

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
          children: screens,
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
                icon: Icon(Icons.add_circle_outline_rounded),
                selectedIcon: Icon(
                  Icons.add_circle_rounded,
                  color: AppTheme.primaryOrange,
                ),
                label: 'Publicar Oferta',
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
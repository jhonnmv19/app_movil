// lib/presentation/screens/duenno/duenno_main_navigation_screen.dart
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
  String? _errorMessage;

  final EstablecimientoService _establecimientoService =
      EstablecimientoService();

  @override
  void initState() {
    super.initState();
    _cargarEstablecimiento();
  }

  /// Obtiene de forma segura el establecimiento vinculado al dueño actual en sesión
  Future<void> _cargarEstablecimiento() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final session = SessionService();
      final usuarioActual = session.usuarioActual;

      if (usuarioActual == null) {
        debugPrint('⚠️ [DuennoMainNavigation] No hay usuario registrado en SessionService.');
        if (mounted) {
          setState(() {
            _errorMessage = 'No hay una sesión activa de usuario.';
            _isLoading = false;
          });
        }
        return;
      }

      final dynamic idUsuario = usuarioActual.id;
      debugPrint('🔍 [DuennoMainNavigation] Buscando establecimiento para el usuario ID: $idUsuario');

      // Consultamos el establecimiento vinculado
      final estab = await _establecimientoService.obtenerEstablecimientoDelUsuario();

      if (estab != null && mounted) {
        debugPrint('✅ [DuennoMainNavigation] Establecimiento encontrado -> ID: ${estab.id}');
        setState(() {
          _establecimientoId = estab.id;
          _isLoading = false;
        });
        return;
      } else {
        debugPrint('❌ [DuennoMainNavigation] El servicio retornó nulo. No existe un registro en "establecimientos" vinculado a este usuario.');
      }
    } catch (e, stackTrace) {
      debugPrint('💥 [DuennoMainNavigation] Excepción al cargar datos del dueño: $e');
      debugPrint('Stacktrace: $stackTrace');
      _errorMessage = e.toString();
    }

    if (mounted) {
      setState(() {
        _establecimientoId = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppTheme.primaryOrange,
              ),
              SizedBox(height: 16),
              Text(
                'Cargando información del establecimiento...',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // Pantalla de error/advertencia si no se encuentra el establecimiento vinculado
    if (_establecimientoId == null) {
      final usuario = SessionService().usuarioActual;
      final nombreUsuario = SessionService().nombreMostrar;
      final idUsuario = SessionService().usuarioId ?? usuario?.id ?? 'Desconocido';

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.grey),
              tooltip: 'Cerrar sesión',
              onPressed: () {
                SessionService().cerrarSesion();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.storefront_outlined,
                  size: 72,
                  color: Colors.orangeAccent,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No se encontró un establecimiento asignado a tu cuenta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Usuario en sesión: $nombreUsuario\nID de Usuario: $idUsuario',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (_errorMessage != null) ...[
                        const Divider(),
                        Text(
                          'Detalle del error: $_errorMessage',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Verifica en la base de datos (Supabase) que exista un registro en la tabla "establecimientos" donde el campo del dueño o usuario sea igual al ID mostrado arriba.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        SessionService().cerrarSesion();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed('/login');
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Salir'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _cargarEstablecimiento,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reintentar'),
                    ),
                  ],
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
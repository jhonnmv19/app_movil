import 'package:flutter/material.dart';

// Autenticación
import '../../presentation/screens/auth/welcome_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';

// Administración
import '../../presentation/screens/admin/admin_dashboard_screen.dart';

// Flujo Dueño de Local
import '../../presentation/screens/duenno/duenno_main_navigation_screen.dart';
import '../../presentation/screens/duenno/duenno_home_screen.dart';
import '../../presentation/screens/duenno/requests_screen.dart';
import '../../presentation/screens/duenno/duenno_profile_screen.dart';

// Flujo Comensal / Cliente
import '../../presentation/screens/comensal/comensal_main_navigation_screen.dart';
import '../../presentation/screens/comensal/home_screen.dart';
import '../../presentation/screens/comensal/map_screen.dart';
import '../../presentation/screens/comensal/plato_dia_screen.dart';
import '../../presentation/screens/comensal/profile_screen.dart';

class AppRoutes {
  // --- Nombres de Rutas Estáticas y Dinámicas ---
  static const String welcome = '/';
  static const String login = '/login';
  static const String register = '/register';

  static const String adminDashboard = '/admin-dashboard';

  // Rutas - Dueño
  static const String duennoMainNav = '/duenno-main-nav';
  static const String duennoHome = '/duenno-home';
  static const String duennoRequests = '/duenno-requests'; // Publicador de Plato del Día (Ruta dinámica)
  static const String duennoProfile = '/duenno-profile';

  // Rutas - Comensal
  static const String comensalMainNav = '/comensal-main-nav';
  static const String home = '/home';
  static const String explorer = '/explorer';
  static const String map = '/map';
  static const String platoDelDia = '/plato-del-dia';
  static const String profile = '/profile';

  // --- Mapa de Rutas Estáticas ---
  static Map<String, WidgetBuilder> get routes => {
        // Auth
        welcome: (context) => const WelcomeScreen(),
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),

        // Admin
        adminDashboard: (context) => const AdminDashboardScreen(),

        // Dueño
        duennoMainNav: (context) => const DuennoMainNavigationScreen(),
        duennoHome: (context) => const DuennoHomeScreen(),
        duennoProfile: (context) => const DuennoProfileScreen(),

        // Comensal
        comensalMainNav: (context) => const ComensalMainNavigationScreen(),
        home: (context) => const HomeScreen(),
        explorer: (context) => const HomeScreen(),
        map: (context) => const MapScreen(),
        platoDelDia: (context) => const PlatoDiaScreen(),
        profile: (context) => const ProfileScreen(),
      };

  // --- Rutas Dinámicas con Argumentos ---
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == duennoRequests) {
      final args = settings.arguments as Map<String, dynamic>?;
      final int establecimientoId = args?['establecimientoId'] ?? 0;

      return MaterialPageRoute(
        builder: (_) => RequestsScreen(establecimientoId: establecimientoId),
      );
    }
    return null;
  }
}
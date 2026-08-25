// lib/core/routes/app_routes.dart
import 'package:flutter/material.dart';

import '../../presentation/screens/auth/welcome_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/admin_login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';

import '../../presentation/screens/user/home_screen.dart';
import '../../presentation/screens/user/main_navigation_screen.dart';
import '../../presentation/screens/user/explorer_screen.dart';
import '../../presentation/screens/user/map_screen.dart';
import '../../presentation/screens/user/plato_dia_screen.dart';
import '../../presentation/screens/user/profile_screen.dart';
import '../../presentation/screens/user/solicitud_registro_screen.dart';
import '../../presentation/screens/user/publish_daily_dish_screen.dart';

import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/admin/requests_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String adminLogin = '/admin-login';
  static const String register = '/register';

  static const String mainNav = '/main-nav';
  static const String home = '/home';
  static const String explorer = '/explorer';
  static const String map = '/map';
  static const String platoDelDia = '/plato-del-dia';
  static const String profile = '/profile';
  static const String solicitarRegistro = '/solicitar-registro';
  static const String publicarPlato = '/publicar-plato';

  static const String adminDashboard = '/admin-dashboard';
  static const String requests = '/requests';

  static Map<String, WidgetBuilder> get routes => {
        welcome: (context) => const WelcomeScreen(),
        login: (context) => const LoginScreen(),
        adminLogin: (context) => const AdminLoginScreen(),
        register: (context) => const RegisterScreen(),

        mainNav: (context) => const MainNavigationScreen(),
        home: (context) => const HomeScreen(),
        explorer: (context) => const ExplorerScreen(),
        map: (context) => const MapScreen(),
        platoDelDia: (context) => const PlatoDiaScreen(),
        profile: (context) => const ProfileScreen(),
        solicitarRegistro: (context) => const SolicitudRegistroScreen(),

        adminDashboard: (context) => const AdminDashboardScreen(),
        requests: (context) => const RequestsScreen(),
      };

  // Manejo de rutas dinámicas con argumentos (ej. ID de establecimiento)
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == publicarPlato) {
      final args = settings.arguments as Map<String, dynamic>?;
      final int establecimientoId = args?['establecimientoId'] ?? 0;

      return MaterialPageRoute(
        builder: (_) => PublishDailyDishScreen(establecimientoId: establecimientoId),
      );
    }
    return null;
  }
}
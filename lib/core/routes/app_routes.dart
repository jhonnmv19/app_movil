import 'package:flutter/material.dart';

// Pantallas de Autenticación (auth/)
import '../../presentation/screens/auth/welcome_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/admin_login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';

// Pantallas de Usuario / Comensal (user/)
import '../../presentation/screens/user/home_screen.dart';
import '../../presentation/screens/user/main_navigation_screen.dart';
import '../../presentation/screens/user/explorer_screen.dart';
import '../../presentation/screens/user/map_screen.dart';
import '../../presentation/screens/user/plato_dia_screen.dart';
import '../../presentation/screens/user/profile_screen.dart';

// Pantallas de Administración y Dueño de Local (admin/)
import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/admin/requests_screen.dart';

class AppRoutes {
  // Constantes de rutas
  static const String welcome = '/';
  static const String login = '/login';
  static const String adminLogin = '/admin-login';
  static const String register = '/register';
  
  // Usuario / Comensal
  static const String home = '/home';
  static const String mainNav = '/main-nav';
  static const String explorer = '/explorer';
  static const String map = '/map';
  static const String platoDelDia = '/plato-del-dia';
  static const String profile = '/profile';

  // Administración / Dueños
  static const String adminDashboard = '/admin-dashboard';
  static const String requests = '/requests';

  // Mapa de rutas para MaterialApp
  static Map<String, WidgetBuilder> get routes => {
        welcome: (context) => const WelcomeScreen(),
        login: (context) => const LoginScreen(),
        adminLogin: (context) => const AdminLoginScreen(),
        register: (context) => const RegisterScreen(),
        
        mainNav: (context) => const MainNavigationScreen(),
        home: (context) => const HomeScreen(),
        explorer: (context) => const ExplorerScreen(),
        map: (context) => const MapScreen(),
        platoDelDia: (context) => const PlatoDelDiaScreen(),
        profile: (context) => const ProfileScreen(),

        adminDashboard: (context) => const AdminDashboardScreen(),
        requests: (context) => const RequestsScreen(),
      };
}
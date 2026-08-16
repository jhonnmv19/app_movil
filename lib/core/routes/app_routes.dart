import 'package:flutter/material.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/explorer_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String explorer = '/explorer';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const HomeScreen(),
      explorer: (context) => const ExplorerScreen(),
    };
  }
}
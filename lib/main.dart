import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';

void main() {
  runApp(const RutaDelSaborApp());
}

class RutaDelSaborApp extends StatelessWidget {
  const RutaDelSaborApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'La Ruta del Sabor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
    );
  }
}
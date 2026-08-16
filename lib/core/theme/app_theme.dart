import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de colores profesionales
  static const Color primaryBlue = Color(0xFF2596BE);
  static const Color secondaryCyan = Color(0xFF0EB6C2);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF1E293B);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: secondaryCyan,
        surface: backgroundLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: textDark,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
        bodyMedium: TextStyle(
          color: textDark,
          fontSize: 16,
        ),
      ),
    );
  }
}
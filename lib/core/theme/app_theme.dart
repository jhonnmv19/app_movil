import 'package:flutter/material.dart';

class AppTheme {
  // ----------------------------------------------------
  // PALETA COMENSAL / VISITANTE (Terracota / Gastronómico)
  // ----------------------------------------------------
  static const Color primaryOrange = Color(0xFFD64E28); 
  static const Color secondaryOrange = Color(0xFFE05326);
  static const Color accentLightOrange = Color(0xFFFFF2EE); 
  static const Color backgroundLight = Color(0xFFFAFAFA);

  // ----------------------------------------------------
  // PALETA MÓDULO ADMINISTRADOR / MODERADOR (Slate / Cyan)
  // ----------------------------------------------------
  static const Color adminPrimary = Color(0xFF1E293B);   // Azul Oscuro Slate
  static const Color adminAccent = Color(0xFF0EA5E9);    // Cyan Corporativo
  static const Color adminBackground = Color(0xFFF8FAFC); // Fondo Slate claro

  // Textos y Colores Neutros Generales
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color cardSurface = Colors.white;

  // ----------------------------------------------------
  // TEMA COMENSAL / VISITANTE
  // ----------------------------------------------------
  static ThemeData get comensalTheme {
    return _buildBaseTheme(
      primary: primaryOrange,
      secondary: secondaryOrange,
      background: backgroundLight,
      buttonColor: primaryOrange,
    );
  }

  // Alias para mantener compatibilidad con tu código previo
  static ThemeData get lightTheme => comensalTheme;

  // ----------------------------------------------------
  // TEMA ADMINISTRADOR / MODERADOR
  // ----------------------------------------------------
  static ThemeData get adminTheme {
    return _buildBaseTheme(
      primary: adminPrimary,
      secondary: adminAccent,
      background: adminBackground,
      buttonColor: adminPrimary,
    );
  }

  // ----------------------------------------------------
  // GENERADOR BASE DE TEMAS (Evita duplicar código)
  // ----------------------------------------------------
  static ThemeData _buildBaseTheme({
    required Color primary,
    required Color secondary,
    required Color background,
    required Color buttonColor,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: background,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textDark,
        centerTitle: false,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: textDark,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
        titleLarge: TextStyle(
          color: textDark,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        bodyMedium: TextStyle(
          color: textDark,
          fontSize: 15,
        ),
        bodySmall: TextStyle(
          color: textMuted,
          fontSize: 13,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
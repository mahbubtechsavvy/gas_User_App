import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF0D47A1), // A deep blue for a professional feel
      primary: const Color(0xFF1976D2),
      secondary: const Color(0xFF42A5F5),
      background: const Color(0xFFF5F5F5),
      surface: Colors.white,
      error: const Color(0xFFD32F2F),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: const Color(0xFF212121),
      onSurface: const Color(0xFF212121),
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 57.0, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 45.0, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500),
      titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontSize: 16.0),
      bodyMedium: TextStyle(fontSize: 14.0),
      bodySmall: TextStyle(fontSize: 12.0),
      labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(fontSize: 11.0, fontWeight: FontWeight.w500),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      filled: true,
      fillColor: Colors.grey[200],
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
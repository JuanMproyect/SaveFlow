import 'package:flutter/material.dart';

class TemaSaveFlow {
  // ── Colores base de la marca ──────────────────────────────────────────
  static const Color verdeEsmeralda = Color(0xFF0F9D58);
  static const Color azulMarino = Color(0xFF1A2B4C);
  static const Color doradoAcento = Color(0xFFF5A623);

  // Colores semánticos (mismos en ambos modos, para consistencia)
  static const Color colorIngreso = Color(0xFF2E7D32); // verde para +
  static const Color colorGasto = Color(0xFFD32F2F);   // rojo para -

  // ── Tema claro ───────────────────────────────────────────────────────
  static ThemeData get temaClaro {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: verdeEsmeralda,
        brightness: Brightness.light,
        primary: verdeEsmeralda,
        secondary: azulMarino,
        tertiary: doradoAcento,
      ),
      scaffoldBackgroundColor: const Color(0xFFF7F9FA),
      appBarTheme: AppBarTheme(
        backgroundColor: verdeEsmeralda,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: verdeEsmeralda,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: verdeEsmeralda,
        unselectedItemColor: Colors.grey,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  // ── Tema oscuro ──────────────────────────────────────────────────────
  static ThemeData get temaOscuro {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: verdeEsmeralda,
        brightness: Brightness.dark,
        primary: const Color(0xFF4CD787), // verde más claro para contraste en oscuro
        secondary: const Color(0xFF8CA3C7),
        tertiary: doradoAcento,
      ),
      scaffoldBackgroundColor: const Color(0xFF0D1421),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0F5C3D), // verde oscuro para modo noche
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF162236),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CD787),
          foregroundColor: const Color(0xFF0D1421),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF13203A),
        selectedItemColor: Color(0xFF4CD787),
        unselectedItemColor: Colors.grey,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: const Color(0xFF162236),
      ),
    );
  }
}
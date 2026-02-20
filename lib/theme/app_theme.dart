import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF0D0D1A);
  static const Color card = Color(0xFF1A1A2E);
  static const Color primary = Color(0xFF7C3AED);
  static const Color secondary = Color(0xFFA78BFA);
  static const Color accent = Color(0xFFF59E0B);
  static const Color textColor = Color(0xFFF1F5F9);
  static const Color muted = Color(0xFF94A3B8);
  static const Color success = Color(0xFF10B981);
  static const Color danger = Color(0xFFEF4444);
  static const Color cardBorder = Color(0xFF2D2D44);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: secondary,
          surface: card,
          background: background,
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ).apply(bodyColor: textColor, displayColor: textColor),
        appBarTheme: AppBarTheme(
          backgroundColor: background,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.inter(
            color: textColor,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
          iconTheme: const IconThemeData(color: textColor),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: card,
          selectedItemColor: primary,
          unselectedItemColor: muted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      );
}

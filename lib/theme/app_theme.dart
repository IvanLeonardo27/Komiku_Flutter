import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF2D6A4F);
  static const Color secondaryGreen = Color(0xFF40916C);
  static const Color accentGreen = Color(0xFF52B788);
  static const Color lightGreen = Color(0xFF95D5B2);
  static const Color surfaceGreen = Color(0xFFD8F3DC);
  static const Color cream = Color(0xFFFFFBF0);
  static const Color creamLight = Color(0xFFF8F4E8);
  static const Color background = Color(0xFFFAF7EE);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1B1B1B);
  static const Color textMedium = Color(0xFF4A4A4A);
  static const Color textLight = Color(0xFF9E9E9E);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color starYellow = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);

  static Color hexToColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  static ThemeData get theme => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: primaryGreen),
    scaffoldBackgroundColor: background,
    fontFamily: 'SF Pro Display',
  );
}
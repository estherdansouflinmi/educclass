// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF1A73E8);
  static const Color primaryLight = Color(0xFF4A9FFF);
  static const Color primaryDark = Color(0xFF0D47A1);

  // Secondary
  static const Color secondary = Color(0xFF34A853);
  static const Color secondaryLight = Color(0xFF66BB6A);

  // Accent
  static const Color accent = Color(0xFFFBBC04);
  static const Color error = Color(0xFFEA4335);
  static const Color warning = Color(0xFFFF9800);
  static const Color success = Color(0xFF34A853);

  // Neutral
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Surface
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color background = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF121212);

  // Classroom cover colors
  static const List<Color> classroomColors = [
    Color(0xFF1A73E8),
    Color(0xFF34A853),
    Color(0xFFEA4335),
    Color(0xFFFBBC04),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
    Color(0xFFFF5722),
    Color(0xFF607D8B),
  ];

  static Color classroomColorFromHex(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return primary;
    }
  }
}

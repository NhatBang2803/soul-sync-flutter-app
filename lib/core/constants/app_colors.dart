import 'package:flutter/material.dart';

/// App Color Constants - Centralized color definitions
class AppColors {
  AppColors._();
  
  // Primary Colors
  static const Color primary = Color(0xFF23DD5B);
  static const Color primaryDark = Color(0xFF1DB954);
  
  // Background Colors
  static const Color background = Colors.black;
  static const Color surface = Color(0xFF222222);
  static const Color surfaceLight = Color(0xFF333333);
  
  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textMuted = Color(0xFF757575);
  
  // Accent Colors
  static const Color error = Colors.red;
  static const Color success = Color(0xFF23DD5B);
  static const Color warning = Colors.orange;
  
  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF23DD5B),
    Color(0xFF00C9FF),
  ];
  
  static const List<Color> purpleGradient = [
    Color(0xFF7E22CE),
    Color(0xFF9333EA),
  ];
}

import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const primary = Color(0xFF1B3B2B);       // Forest Green
  static const primaryDark = Color(0xFF12281D);
  static const secondary = Color(0xFFD96B43);     // Terracotta Warm
  static const accent = Color(0xFFE89A3C);        // Amber Soft

  // Surface & Neutrals
  static const background = Color(0xFFF7F8F6);   // Off-white Warm
  static const surface = Colors.white;
  static const border = Color(0xFFE2E8F0);       // Slate 200
  static const borderDark = Color(0xFFCBD5E1);

  // Typography
  static const textPrimary = Color(0xFF0F172A);   // Slate 900
  static const textSecondary = Color(0xFF475569); // Slate 600
  static const textMuted = Color(0xFF94A3B8);     // Slate 400

  // Status & Badges
  static const alertBg = Color(0xFFFEF2F2);      // Red 50
  static const alertFg = Color(0xFFDC2626);      // Red 600
  static const statusError = Color(0xFFDC2626);
  static const statusWarning = Color(0xFFD97706);
  static const warnBg = Color(0xFFFFFBEB);       // Amber 50
  static const warnFg = Color(0xFFD97706);       // Amber 600
  static const successBg = Color(0xFFF0FDF4);    // Green 50
  static const successFg = Color(0xFF16A34A);    // Green 600
}

class AppConstants {
  static const String baseUrl = 'https://warungku-brown.vercel.app/api';
  static const String appName = 'Warungku';
}

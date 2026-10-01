import 'package:flutter/material.dart';

class AppColors {
  // Brand - Luxury Emerald & Champagne Palette
  static const primary = Color(0xFF0F3826);       // Deep Royal Emerald
  static const primaryDark = Color(0xFF092217);
  static const secondary = Color(0xFFC99700);     // Champagne Gold Accent
  static const accent = Color(0xFF10B981);        // Mint Emerald

  // Surface & Neutrals
  static const background = Color(0xFFF8FAFC);   // Slate 50 ultra clean
  static const surface = Colors.white;
  static const border = Color(0xFFE2E8F0);       // Slate 200
  static const borderLight = Color(0xFFF1F5F9);  // Slate 100
  static const borderDark = Color(0xFFCBD5E1);

  // Typography
  static const textPrimary = Color(0xFF0F172A);   // Slate 900
  static const textSecondary = Color(0xFF64748B); // Slate 500
  static const textMuted = Color(0xFF94A3B8);     // Slate 400

  // Status & Badges
  static const alertBg = Color(0xFFFEF2F2);      // Red 50
  static const alertFg = Color(0xFFDC2626);      // Red 600
  static const statusError = Color(0xFFDC2626);
  static const statusWarning = Color(0xFFD97706);
  static const warnBg = Color(0xFFFFFBEB);       // Amber 50
  static const warnFg = Color(0xFFB45309);       // Amber 700
  static const successBg = Color(0xFFECFDF5);    // Emerald 50
  static const successFg = Color(0xFF059669);    // Emerald 600
}

class AppConstants {
  static const String baseUrl = 'https://warungku-brown.vercel.app/api';
  static const String appName = 'Warungku';
}

import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette (Inspired by Reference Design)
  static const Color primaryDark = Color(0xFF1B4332);       // Deep Forest Green
  static const Color primaryMedium = Color(0xFF2D6A4F);     // Emerald Forest
  static const Color primaryLight = Color(0xFF40916C);      // Sage Green Accent
  
  // Backgrounds & Surface
  static const Color background = Color(0xFFEAF4ED);        // Soft Mint / Sage Tint
  static const Color surface = Color(0xFFFFFFFF);           // Pure White Cards
  static const Color surfaceAlt = Color(0xFFF3F8F5);        // Subtle Pill / Input Fill
  static const Color surfaceVariant = Color(0xFFF3F8F5);    // Consistent input & chip surface fill
  
  // Accents & Indicators
  static const Color accentGold = Color(0xFFE5A93C);        // Wheat / Harvest Gold
  static const Color accentLime = Color(0xFF74C69D);        // Fresh Sprout Lime
  static const Color alertSoftRed = Color(0xFFE65C5C);      // Disease / Warning Tag
  static const Color successGreen = Color(0xFF2E7D32);      // Confirmed / Profit
  
  // Text Colors
  static const Color textDark = Color(0xFF192A20);          // Primary Deep Slate Green
  static const Color textMuted = Color(0xFF6B7280);         // Secondary Body Text
  static const Color textLight = Color(0xFF9CA3AF);         // Hint / Disabled Text
  
  // Borders & Dividers
  static const Color borderLight = Color(0xFFDCE7DF);
  
  // Gradients
  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryMedium, primaryDark],
  );

  static const LinearGradient heroCardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2D6A4F), Color(0xFF1B4332)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF6BD60), Color(0xFFE5A93C)],
  );
}

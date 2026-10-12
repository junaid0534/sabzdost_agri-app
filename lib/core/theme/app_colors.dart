import 'package:flutter/material.dart';

class AppColors {
  // --- Hybrid Agricultural Palette ---
  // 1. Anchor Deep Tones (Navbars, Headers, High Contrast Text, Primary Base)
  static const Color primaryDark = Color(0xFF1B4332);       // Deep Forest Green (Solid contrast base)
  
  // 2. Fresh Leaf Green Tones (Vibrant Crops, Modern Agro Look, Live Badges & Highlights)
  static const Color primaryMedium = Color(0xFF257538);     // Rich Fresh Leaf Green
  static const Color primaryLight = Color(0xFF38974D);      // Lush Grass Green
  static const Color freshLeafGreen = Color(0xFF2E7D32);    // Pure Agricultural Field Green
  static const Color freshLeafBright = Color(0xFF4CAE5F);   // Vibrant Sunlit Sprout Green
  
  // 3. Backgrounds & Surface (Crisp, clean, natural light tones)
  static const Color background = Color(0xFFF3F7F4);        // Clean Soft Mint Tint
  static const Color surface = Color(0xFFFFFFFF);           // Pure White Cards
  static const Color surfaceAlt = Color(0xFFEDF5F0);        // Subtle Pill / Input Fill
  static const Color surfaceVariant = Color(0xFFEDF5F0);    // Consistent input & chip surface fill
  
  // 4. Accents & Indicators
  static const Color accentGold = Color(0xFFE5A93C);        // Wheat / Harvest Gold
  static const Color accentLime = Color(0xFF4CAE5F);        // Fresh Sprout Lime Accent
  static const Color alertSoftRed = Color(0xFFE65C5C);      // Disease / Warning Tag
  static const Color successGreen = Color(0xFF2E7D32);      // Confirmed / Profit
  
  // 5. Text Colors
  static const Color textDark = Color(0xFF14241B);          // Primary Deep Slate Green
  static const Color textMuted = Color(0xFF5B6960);         // Secondary Body Text
  static const Color textLight = Color(0xFF8D9A92);         // Hint / Disabled Text
  
  // 6. Borders & Dividers
  static const Color borderLight = Color(0xFFD6E4DA);
  
  // 7. Gradients (The signature Hybrid Gradients)
  // Signature Hybrid Gradient: Fresh Crop Green blending into Deep Forest Anchor
  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF257538), Color(0xFF1B4332)],
  );

  // Fresh Leaf Agro Gradient: Matches the vibrant mockup
  static const LinearGradient freshLeafGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF257538), Color(0xFF38974D), Color(0xFF4CAE5F)],
  );

  // Hero Card Gradient (Uses the Fresh Leaf Gradient)
  static const LinearGradient heroCardGradient = freshLeafGradient;

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF6BD60), Color(0xFFE5A93C)],
  );
}

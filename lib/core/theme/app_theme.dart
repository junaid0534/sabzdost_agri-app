import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // Ultra-Modern Digital Urdu Typography (Noto Nastaliq Urdu - authentic, contemporary, beautiful Nastaliq font)
  static TextStyle urdu({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.textDark,
    double height = 1.6,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.notoNastaliqUrdu(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    ).copyWith(
      fontFamilyFallback: const [
        'Noto Nastaliq Urdu',
        'Jameel Noori Nastaleeq',
        'Urdu Typesetting',
        'Gulzar',
        'Tahoma',
      ],
    );
  }

  // Modern English Typography (Plus Jakarta Sans with Modern Urdu Fallback)
  static TextStyle english({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.textDark,
    double height = 1.3,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    ).copyWith(
      fontFamilyFallback: [
        GoogleFonts.notoNastaliqUrdu().fontFamily!,
        GoogleFonts.notoSansArabic().fontFamily!,
      ],
    );
  }

  static ThemeData get lightTheme {
    final urduFallback = [
      GoogleFonts.notoNastaliqUrdu().fontFamily!,
      GoogleFonts.notoSansArabic().fontFamily!,
    ];
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryMedium,
        primary: AppColors.primaryDark,
        secondary: AppColors.freshLeafGreen,
        surface: AppColors.surface,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme().apply(
        fontFamilyFallback: urduFallback,
      ),
    );
  }
}

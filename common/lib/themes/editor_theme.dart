import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditorTheme {
  static final Color backgroundLight = const Color(0xFFF9FAFB);
  static final Color backgroundDark = const Color(0xFF0D1117);
  static final Color surfaceLight = const Color(0xFFFFFFFF);
  static final Color surfaceDark = const Color(0xFF161B22);
  static final Color primary = const Color(0xFF3B82F6);
  static final Color primaryContent = const Color(0xFFFFFFFF);
  static final Color secondary = const Color(0xFFA855F7);
  static final Color textLight = const Color(0xFF1F2937);
  static final Color textDark = const Color(0xFFE5E7EB);
  static final Color subtleLight = const Color(0xFF6B7280);
  static final Color subtleDark = const Color(0xFF8B949E);
  static final Color borderLight = const Color(0xFFD1D5DB);
  static final Color borderDark = const Color(0xFF30363D);

  static TextTheme _buildTextTheme(TextTheme base, Color textColor, Color subtleColor) {
    return base.copyWith(
      headlineSmall: GoogleFonts.notoSansSc(textStyle: base.headlineSmall?.copyWith(fontWeight: FontWeight.w600, color: textColor)),
      titleLarge: GoogleFonts.notoSansSc(textStyle: base.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: textColor)),
      titleMedium: GoogleFonts.notoSansSc(textStyle: base.titleMedium?.copyWith(fontWeight: FontWeight.w500, color: textColor)),
      bodyLarge: GoogleFonts.inter(textStyle: base.bodyLarge?.copyWith(color: textColor)),
      bodyMedium: GoogleFonts.inter(textStyle: base.bodyMedium?.copyWith(color: textColor)),
      bodySmall: GoogleFonts.inter(textStyle: base.bodySmall?.copyWith(color: subtleColor)),
      labelLarge: GoogleFonts.notoSansSc(textStyle: base.labelLarge?.copyWith(fontWeight: FontWeight.w500, color: textColor)),
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return base.copyWith(
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundLight,
      cardColor: surfaceLight,
      dividerColor: borderLight,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surfaceLight,
        background: backgroundLight,
        onPrimary: primaryContent,
        onSurface: textLight,
        onBackground: textLight,
        outline: borderLight,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceLight,
        foregroundColor: textLight,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: borderLight, width: 1)),
      ),
      textTheme: _buildTextTheme(base.textTheme, textLight, subtleLight),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return base.copyWith(
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundDark,
      cardColor: surfaceDark,
      dividerColor: borderDark,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surfaceDark,
        background: backgroundDark,
        onPrimary: primaryContent,
        onSurface: textDark,
        onBackground: textDark,
        outline: borderDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: textDark,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: borderDark, width: 1)),
      ),
      textTheme: _buildTextTheme(base.textTheme, textDark, subtleDark),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color bg = Color(0xFFFFF7ED);
  static const Color card = Color(0xCCFFFFFF);
  static const Color primary = Color(0xFFEA580C);
  static const Color orange = Color(0xFFEA580C);
  static const Color orangeLight = Color(0xFFFB923C);
  static const Color darkOrange = Color(0xFF9A3412); // #9a3412
  static const Color yellow = Color(0xFFF59E0B);
  static const Color red = Color(0xFFDC2626);
  static const Color muted = Color(0xFF64748B);
  static const Color text = Color(0xFF111827);
  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFDC2626);
  static const Color warning = Color(0xFFD97706);
  static const Color white = Colors.white;

  static final Map<String, IconData> moduleIcons = {
    'abcde': Icons.list_alt_outlined,
    'bls': Icons.favorite_border_rounded,
    'airway': Icons.air_outlined,
    'adv_airway': Icons.medical_services_outlined,
    'choking': Icons.warning_amber_rounded,
    'ecg': Icons.monitor_heart_outlined,
    'rhythms': Icons.show_chart_outlined,
    'cardiac_alg': Icons.electric_bolt_outlined,
    'stroke': Icons.psychology_outlined,
    'delivery': Icons.child_care_outlined,
    'poisoning': Icons.shield_outlined,
    'disaster': Icons.error_outline_rounded,
    'h5t5': Icons.check_circle_outline_outlined,
    'acls': Icons.health_and_safety_outlined,
  };

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
  );

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5), Color(0xFFFED7AA)],
  );

  static Color fromLabel(String label) {
    switch (label) {
      case 'primary':
        return orange;
      case 'success':
        return success;
      case 'danger':
        return danger;
      case 'warning':
        return warning;
      case 'white':
        return white;
      default:
        return orange;
    }
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData(
      colorSchemeSeed: AppColors.orange,
      scaffoldBackgroundColor: AppColors.bg,
      useMaterial3: true,
      brightness: Brightness.light,
    );

    return _buildTheme(base, AppColors.text, Colors.white.withValues(alpha: 0.9));
  }

  static ThemeData get darkTheme {
    final base = ThemeData(
      colorSchemeSeed: AppColors.orange,
      scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
      useMaterial3: true,
      brightness: Brightness.dark,
    );

    return _buildTheme(base, const Color(0xFFF8FAFC), const Color(0xFF1E293B)); // Slate 50 text, Slate 800 surface
  }

  static ThemeData _buildTheme(ThemeData base, Color textColor, Color surfaceColor) {
    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: GoogleFonts.inter(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: _elevatedButtonTheme(AppColors.orange),
      inputDecorationTheme: _inputDecorationTheme(surfaceColor),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: base.brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme(Color color) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(Color fillColor) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor.withValues(alpha: 0.9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.orange, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  // Backward compatibility
  static ThemeData get theme => lightTheme;
}

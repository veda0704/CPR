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
      case 'primary':   return orange;
      case 'success':   return success;
      case 'danger':    return danger;
      case 'warning':   return warning;
      case 'white':     return white;
      default:          return orange;
    }
  }
}

class AppTheme {
  static ThemeData get theme {
    final base = ThemeData(
      colorSchemeSeed: AppColors.orange,
      scaffoldBackgroundColor: AppColors.bg,
      useMaterial3: true,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
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
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.9),
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  /* Clinical Precision Design System - Elite Web Parity */
  static const Color eliteTeal = Color(0xFF005B41);
  static const Color eliteDarkTeal = Color(0xFF004431);
  static const Color eliteSlate = Color(0xFF0F172A);
  static const Color eliteGrey = Color(0xFF64748B);
  static const Color eliteOrange = Color(0xFFF97316);
  
  static const Color slate = eliteSlate;
  static const Color skyBlue = eliteTeal; // Primary Elite Branding
  static const Color skyBlueHover = eliteDarkTeal;
  static const Color skyBlueSoft = Color(0xFFECFDF5);
  static const Color slateLight = Color(0xFF1E293B);
  static const Color softGrey = Color(0xFFF1F5F9);
  static const Color pastelGreen = Color(0xFFD1FAE5);
  static const Color teal = eliteTeal;
  static const Color tealDark = eliteDarkTeal;

  // Main Tokens
  static const Color primary = eliteTeal;
  static const Color accent = eliteTeal;
  static const Color bg = Color(0xFFF8FAFC);
  static const Color card = Colors.white;
  static const Color subCard = Color(0xFFF1F5F9);

  static const Color orange = eliteOrange;
  static const Color darkOrange = Color(0xFFEA580C);
  static const Color yellow = Color(0xFFF59E0B);
  static const Color red = Color(0xFFEF4444);
  static const Color muted = eliteGrey;
  static const Color text = Color(0xFF0F172A);
  static const Color success = Color(0xFF10B981);
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color white = Colors.white;

  static final Map<String, IconData> moduleIcons = {
    'abcde': Icons.list_alt_outlined,
    'bls': Icons.favorite_border_rounded,
    'airway': Icons.air_outlined,
    'adv_airway': Icons.medical_services_outlined,
    'choking': Icons.warning_amber_rounded,
    'ecg_rhythms': Icons.monitor_heart_outlined,
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
    colors: [Color(0xFF005B41), Color(0xFF004431)],
  );

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
  );

  static Color fromLabel(String label) {
    switch (label) {
      case 'primary':
        return skyBlue;
      case 'secondary':
        return softGrey;
      case 'success':
        return success;
      case 'danger':
        return danger;
      case 'warning':
        return warning;
      case 'white':
        return white;
      default:
        return skyBlue;
    }
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData(
      colorSchemeSeed: AppColors.skyBlue, // Elite Teal
      scaffoldBackgroundColor: AppColors.bg,
      useMaterial3: true,
      brightness: Brightness.light,
    );

    return _buildTheme(
        base, AppColors.text, Colors.white.withValues(alpha: 0.9));
  }

  static ThemeData get darkTheme => _buildTheme(
        ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F172A),
          colorSchemeSeed: AppColors.skyBlue, // Elite Teal
          useMaterial3: true,
        ),
        const Color(0xFFF8FAFC),
        const Color(0xFF1E293B),
      );

  static ThemeData _buildTheme(
      ThemeData base, Color textColor, Color surfaceColor) {
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
      elevatedButtonTheme: _elevatedButtonTheme(AppColors.eliteTeal),
      inputDecorationTheme: _inputDecorationTheme(surfaceColor),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
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
          borderRadius: BorderRadius.circular(20),
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
        borderSide: const BorderSide(color: AppColors.eliteTeal, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  // Backward compatibility
  static ThemeData get theme => lightTheme;
}

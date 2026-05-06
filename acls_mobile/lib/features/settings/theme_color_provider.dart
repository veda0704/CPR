import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeColorKey = 'acls_theme_color';

// We define sharedPrefsProvider here to avoid circular dependency
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize sharedPrefsProvider in main.dart');
});

class ThemeColorNotifier extends StateNotifier<Color> {
  final SharedPreferences _prefs;

  ThemeColorNotifier(this._prefs) : super(const Color(0xFF005B41)) {
    _load();
  }

  void _load() {
    final hex = _prefs.getString(_kThemeColorKey);
    if (hex != null) {
      try {
        state = Color(int.parse(hex.replaceFirst('#', '0xFF')));
      } catch (e) {
        state = const Color(0xFF005B41);
      }
    }
  }

  Future<void> setColor(Color color) async {
    state = color;
    final hex = '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
    await _prefs.setString(_kThemeColorKey, hex);
  }
}

final themeColorProvider = StateNotifierProvider<ThemeColorNotifier, Color>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return ThemeColorNotifier(prefs);
});

final availableThemes = {
  'teal': const Color(0xFF005B41),
  'maroon': const Color(0xFF8B0000),
  'orange': const Color(0xFFF57C00),
  'brown': const Color(0xFF6D4C41),
  'charcoal': const Color(0xFF1F2937),
  'indigo': const Color(0xFF4F46E5),
};

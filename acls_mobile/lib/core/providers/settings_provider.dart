import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/theme_color_provider.dart';
import '../../core/theme/theme_provider.dart';
import '../../features/settings/language_provider.dart';

class SettingsState {
  final Color primaryColor;
  final ThemeMode themeMode;
  final String languageCode;

  SettingsState({
    required this.primaryColor,
    required this.themeMode,
    required this.languageCode,
  });
}

final settingsProvider = Provider<SettingsState>((ref) {
  final primaryColor = ref.watch(themeColorProvider);
  final themeMode = ref.watch(themeModeProvider);
  final languageCode = ref.watch(languageProvider);

  return SettingsState(
    primaryColor: primaryColor,
    themeMode: themeMode,
    languageCode: languageCode,
  );
});

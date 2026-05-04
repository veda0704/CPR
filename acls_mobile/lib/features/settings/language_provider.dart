import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/local_storage.dart';

/// Holds the current UI language: 'en' or 'te'
class LanguageNotifier extends Notifier<String> {
  @override
  String build() => LocalStorage.getLanguage();

  Future<void> setLanguage(String lang) async {
    await LocalStorage.setLanguage(lang);
    state = lang;
  }

  bool get isTelugu => state == 'te';
}

final languageProvider = NotifierProvider<LanguageNotifier, String>(
  LanguageNotifier.new,
);


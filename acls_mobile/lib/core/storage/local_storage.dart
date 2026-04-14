import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- JWT Tokens ---
  static Future<void> saveTokens(String access, String refresh) async {
    await _prefs?.setString('access_token', access);
    await _prefs?.setString('refresh_token', refresh);
  }

  static String? getAccessToken() => _prefs?.getString('access_token');
  static String? getRefreshToken() => _prefs?.getString('refresh_token');

  static Future<void> clearTokens() async {
    await _prefs?.remove('access_token');
    await _prefs?.remove('refresh_token');
  }

  // --- Language ---
  static Future<void> setLanguage(String lang) async {
    await _prefs?.setString('language', lang);
  }

  static String getLanguage() => _prefs?.getString('language') ?? 'en';

  // --- Auth State ---
  static bool get isLoggedIn => getAccessToken() != null;
}

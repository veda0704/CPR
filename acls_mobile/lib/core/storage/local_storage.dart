import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorage {
  static SharedPreferences? _prefs;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  static const String _rememberMeKey = 'remember_me';
  static const String _backendUrlKey = 'backend_url';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- JWT Tokens (Secure Storage) ---
  static Future<void> saveTokens(String access, String? refresh) async {
    await _secureStorage.write(key: 'access_token', value: access);
    if (refresh != null) {
      await _secureStorage.write(key: 'refresh_token', value: refresh);
    }
  }

  static Future<String?> getAccessToken() async =>
      await _secureStorage.read(key: 'access_token');
  static Future<String?> getRefreshToken() async =>
      await _secureStorage.read(key: 'refresh_token');

  static Future<void> clearTokens() async {
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
  }

  // --- Backend URL ---
  static Future<void> setBackendUrl(String url) async {
    await _prefs?.setString(_backendUrlKey, url);
  }

  static String getBackendUrl() => _prefs?.getString(_backendUrlKey) ?? '';

  static Future<void> clearBackendUrl() async {
    await _prefs?.remove(_backendUrlKey);
  }

  // --- Language ---
  static Future<void> setLanguage(String lang) async {
    await _prefs?.setString('language', lang);
  }

  static String getLanguage() => _prefs?.getString('language') ?? 'en';

  // --- Sync Metadata ---
  static Future<void> setLastSyncTime(DateTime time) async {
    await _prefs?.setString('last_sync_time', time.toIso8601String());
  }

  static DateTime? getLastSyncTime() {
    final timeStr = _prefs?.getString('last_sync_time');
    return timeStr != null ? DateTime.parse(timeStr) : null;
  }

  // --- Auth State ---
  static Future<bool> get isLoggedIn async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // --- Remember Me ---
  static Future<void> setRememberMe(bool value) async {
    await _prefs?.setBool(_rememberMeKey, value);
  }

  static bool getRememberMe() => _prefs?.getBool(_rememberMeKey) ?? false;

  // --- Module Progress ---
  static String _progressKey(String userId, String moduleId) => 'progress_${userId}_$moduleId';
  static String _moduleProgressKey(String userId, String moduleId) =>
      'module_progress_${userId}_$moduleId';

  static Future<void> setModuleStatus(String userId, String moduleId, String status) async {
    await _prefs?.setString(_progressKey(userId, moduleId), status);
    if (status == 'completed') {
      await _prefs?.setDouble(_moduleProgressKey(userId, moduleId), 100.0);
    }
  }

  static String getModuleStatus(String userId, String moduleId) =>
      _prefs?.getString(_progressKey(userId, moduleId)) ?? 'not_started';

  static double getModuleProgress(String userId, String moduleId) =>
      _prefs?.getDouble(_moduleProgressKey(userId, moduleId)) ??
      (getModuleStatus(userId, moduleId) == 'completed' ? 100.0 : 0.0);

  static Future<void> setModuleProgress(
      String userId, String moduleId, double progress) async {
    final current = getModuleProgress(userId, moduleId);
    final next = progress.clamp(current, 100.0).toDouble();
    await _prefs?.setDouble(_moduleProgressKey(userId, moduleId), next);

    final status = getModuleStatus(userId, moduleId);
    if (next >= 100) {
      await setModuleStatus(userId, moduleId, 'completed');
    } else if (next > 0 && status != 'completed') {
      await setModuleStatus(userId, moduleId, 'in_progress');
    }
  }

  static Future<void> setFirstName(String name) async {
    await _prefs?.setString('user_first_name', name);
  }

  static String getFirstName() => _prefs?.getString('user_first_name') ?? '';

  static double getLevelProgress(String userId, List<dynamic> modules) {
    if (modules.isEmpty) return 0.0;
    int completed = modules.where((m) => getModuleStatus(userId, m['id']) == 'completed').length;
    return completed / modules.length;
  }
}

import 'api_client.dart';
import '../storage/local_storage.dart';

class AuthApi {
  static Future<Map<String, dynamic>> login(
      String email, String password, bool rememberMe) async {
    final res = await ApiClient.dio.post(
      'accounts/login/',
      data: {
        'email': email,
        'password': password,
        'remember_me': rememberMe,
      },
    );
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
  }) async {
    final res = await ApiClient.dio.post(
      'accounts/signup/',
      data: {
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
        'first_name': firstName,
        'last_name': lastName,
      },
    );
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getMe() async {
    final res = await ApiClient.dio.get('accounts/me/');
    return res.data as Map<String, dynamic>;
  }

  static Future<bool> logout() async {
    try {
      await ApiClient.dio.post('accounts/logout/');
    } catch (_) {
      // Ignore logout errors.
    }
    return true;
  }

  static Future<bool> refreshToken() async {
    try {
      final res = await ApiClient.dio.post('accounts/refresh/');
      final newAccess = res.data['access'] as String;
      await LocalStorage.saveTokens(newAccess, null);
      return true;
    } catch (_) {
      return false;
    }
  }
}

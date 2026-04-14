import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/api/auth_api.dart';
import '../../core/storage/local_storage.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error, signupSuccess }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  const AuthState({this.status = AuthStatus.initial, this.errorMessage});
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    if (LocalStorage.isLoggedIn) {
      return const AuthState(status: AuthStatus.authenticated);
    }
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> login(String email, String password) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      final data = await AuthApi.login(email, password);
      final tokens = data['tokens'] as Map<String, dynamic>;
      await LocalStorage.saveTokens(
        tokens['access'] as String,
        tokens['refresh'] as String,
      );
      state = const AuthState(status: AuthStatus.authenticated);
    } on DioException catch (e) {
      final data = e.response?.data;
      String msg = 'Login failed.';
      if (data is Map) {
        msg = data['error']?.toString() ?? 
              data['detail']?.toString() ?? 
              data.values.firstWhere((v) => v != null, orElse: () => 'Invalid request').toString();
      } else if (data != null) {
        msg = data.toString();
      }
      state = AuthState(status: AuthStatus.error, errorMessage: msg);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
  }) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      await AuthApi.signup(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        firstName: firstName,
        lastName: lastName,
      );
      state = const AuthState(status: AuthStatus.signupSuccess);
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? 'Signup failed. Try again.';
      state = AuthState(status: AuthStatus.error, errorMessage: msg);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> logout() async {
    await LocalStorage.clearTokens();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

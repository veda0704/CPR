import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/api/auth_api.dart';
import '../../core/storage/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
  signupSuccess
}

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final String? email;
  final String? userName;
  final String? firstName;
  const AuthState({
    this.status = AuthStatus.initial, 
    this.errorMessage, 
    this.email, 
    this.userName,
    this.firstName,
  });
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final rememberMe = LocalStorage.getRememberMe();
    final loggedIn = await LocalStorage.isLoggedIn;
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    
    if (loggedIn && rememberMe) {
      String? firstName = LocalStorage.getFirstName();
      String? savedEmail = prefs.getString('user_email');
      
      // If we only have 'User' or empty, try to fetch the real name from the API
      if (firstName.isEmpty || firstName == 'User') {
        try {
          final userData = await AuthApi.getMe();
          final String fetchedName = userData['first_name'] as String? ?? 
                                     userData['firstName'] as String? ?? 
                                     userData['username'] as String? ?? '';
                                     
          if (fetchedName.isNotEmpty && fetchedName != 'User') {
            firstName = fetchedName;
            await LocalStorage.setFirstName(fetchedName);
          }
        } catch (_) {}
      }
      
      return AuthState(
        status: AuthStatus.authenticated, 
        email: savedEmail,
        userName: (firstName != null && firstName.isNotEmpty) ? firstName : savedEmail?.split('@').first ?? 'User',
        firstName: (firstName != null && firstName.isNotEmpty) ? firstName : null,
      );
    }

    // If not remembered, clear existing tokens on startup
    if (loggedIn && !rememberMe) {
      await LocalStorage.clearTokens();
    }

    return AuthState(status: AuthStatus.unauthenticated, email: email);
  }

  Future<void> login(String email, String password, bool rememberMe) async {
    state = const AsyncLoading<AuthState>().copyWithPrevious(state);
    try {
      final data = await AuthApi.login(email, password, rememberMe);
      final accessToken = data['access'] as String? ?? (data['tokens'] is Map ? data['tokens']['access'] as String? : null);
      final refreshToken = data['refresh'] as String? ?? (data['tokens'] is Map ? data['tokens']['refresh'] as String? : null);
      if (accessToken == null || refreshToken == null) {
        throw Exception('Bad Server Reply: $data');
      }

      await LocalStorage.saveTokens(accessToken, refreshToken);
      await LocalStorage.setRememberMe(rememberMe);
      
      if (email.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', email);
      }

      String? firstName;
      try {
        final userData = await AuthApi.getMe();
        firstName = userData['first_name'] as String? ?? 
                    userData['firstName'] as String? ?? 
                    userData['username'] as String? ?? '';
      } catch (_) {}
      
      if (firstName != null && firstName.isNotEmpty && firstName != 'User') {
        await LocalStorage.setFirstName(firstName);
      }
      
      final String finalName = (firstName != null && firstName.isNotEmpty && firstName != 'User')
          ? firstName
          : email.split('@').first;

      state = AsyncData(AuthState(
        status: AuthStatus.authenticated, 
        email: email,
        userName: finalName,
        firstName: firstName?.isNotEmpty == true ? firstName : null,
      ));
    } on DioException catch (e) {
      String msg = 'Unable to reach the server. Please check your network connection.';
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        msg = 'Connection timed out. The server might be unreachable.';
      } else if (e.response?.data is Map) {
        final data = e.response!.data as Map;
        msg = data['error']?.toString() ?? data['detail']?.toString() ?? 'Invalid credentials. Please try again.';
      }
      state = AsyncData(AuthState(status: AuthStatus.error, errorMessage: msg));
    } catch (e) {
      state = const AsyncData(AuthState(status: AuthStatus.error, errorMessage: 'An unexpected error occurred.'));
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
  }) async {
    state = const AsyncLoading<AuthState>().copyWithPrevious(state);
    try {
      final data = await AuthApi.signup(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        firstName: firstName,
        lastName: lastName,
      );
      final accessToken = data['access'] as String? ?? (data['tokens'] is Map ? data['tokens']['access'] as String? : null);
      final refreshToken = data['refresh'] as String? ?? (data['tokens'] is Map ? data['tokens']['refresh'] as String? : null);
      if (accessToken == null || refreshToken == null) {
        throw Exception('Missing access or refresh token in signup response');
      }

      // Set signupSuccess status to trigger navigation to login screen
      state = const AsyncData(AuthState(status: AuthStatus.signupSuccess));
    } on DioException catch (e) {
      final data = e.response?.data;
      String msg = 'Signup failed.';
      if (data is Map) {
        msg = data['error']?.toString() ??
            data['detail']?.toString() ??
            data.values
                .firstWhere((v) => v != null, orElse: () => 'Invalid request')
                .toString();
      } else if (data != null) {
        msg = data.toString();
      } else {
        msg = e.message ?? 'Signup failed. Check your network.';
      }
      state = AsyncData(AuthState(status: AuthStatus.error, errorMessage: msg));
    } catch (e) {
      state = AsyncData(
          AuthState(status: AuthStatus.error, errorMessage: e.toString()));
    }
  }

  void clearError() {
    state.whenData((data) {
      if (data.status == AuthStatus.error) {
        state = AsyncData(AuthState(status: AuthStatus.unauthenticated, email: data.email));
      }
    });
  }

  Future<void> logout() async {
    await LocalStorage.clearTokens();
    state = const AsyncData(AuthState(status: AuthStatus.unauthenticated));
  }

  void updateUser(String name) async {
    final current = state.value;
    final firstName = name.split(' ').first;
    await LocalStorage.setFirstName(firstName);
    if (current != null) {
      state = AsyncData(AuthState(
        status: current.status,
        email: current.email,
        errorMessage: current.errorMessage,
        userName: name,
        firstName: firstName,
      ));
    }
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

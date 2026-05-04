import 'package:flutter/foundation.dart';


import 'package:dio/dio.dart';

import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import 'package:cookie_jar/cookie_jar.dart';

import 'package:path_provider/path_provider.dart';

import '../storage/local_storage.dart';

class ApiClient {
  static late String baseUrl;

  static late Dio dio;
  static VoidCallback? onUnauthorized;


  static Future<void> setup() async {
    // Physical device / WiFi IP (Host Machine IP)
    baseUrl = 'http://10.2.1.15:8002/api/';

    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ));

    // 1. Debug Logging
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint(
            '🌐 [API] Request: ${options.method} ${options.path}');
        return handler.next(options);
      },
    ));

    // 2. Setup cookie manager
    final appDocDir = await getApplicationDocumentsDirectory();
    final cookieJar = PersistCookieJar(
      ignoreExpires: true,
      storage: FileStorage('${appDocDir.path}/.cookies/'),
    );
    dio.interceptors.add(CookieManager(cookieJar));

    // 3. Language & Auth Interceptor (Must be before Cache to ensure headers are in the key)
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await LocalStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          final lang = LocalStorage.getLanguage();
          if (lang.isNotEmpty) {
            options.headers['Accept-Language'] = lang;
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          final path = error.requestOptions.path;
          final isAuthPath = path.contains('accounts/login/') || path.contains('accounts/signup/');

          if (error.response?.statusCode == 401 && !isAuthPath) {
            try {
              final refreshToken = await LocalStorage.getRefreshToken();
              if (refreshToken != null) {
                final response =
                    await Dio(BaseOptions(baseUrl: dio.options.baseUrl)).post(
                  'accounts/refresh/',
                  data: {'refresh': refreshToken},
                );
                if (response.statusCode == 200) {
                  final newAccess = response.data['access'] as String?;
                  if (newAccess != null) {
                    await LocalStorage.saveTokens(newAccess, null);
                    return handler.resolve(await _retry(error.requestOptions));
                  }
                }
              }
            } catch (_) {
              await LocalStorage.clearTokens();
              onUnauthorized?.call();
            }
            await LocalStorage.clearTokens();
            onUnauthorized?.call();
            return handler.next(error);
          }
          return handler.next(error);
        },
      ),
    );


  }


  static Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  static Future<void> setBaseUrl(String url) async {
    baseUrl = _normalizeBaseUrl(url);
    dio.options.baseUrl = baseUrl;
    await LocalStorage.setBackendUrl(baseUrl);
  }

  static String _normalizeBaseUrl(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return '';
    final url = trimmed.endsWith('/api/') ? trimmed : '$trimmed/api/';
    return url;
  }
}

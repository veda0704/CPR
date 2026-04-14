import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import '../storage/local_storage.dart';
import '../services/cache_service.dart';

class ApiClient {
  static late String baseUrl;
  static final Dio dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 120),
    receiveTimeout: const Duration(seconds: 120),
    headers: {'Content-Type': 'application/json'},
  ));

  static Future<void> setup() async {
    // Detect environment
    if (kIsWeb) {
      baseUrl = 'http://localhost:8002/api/';
    } else {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        // Check for specific emulator patterns
        final isEmulator = androidInfo.model.contains('sdk_gphone') || 
                          androidInfo.model.contains('Emulator') ||
                          !androidInfo.isPhysicalDevice;
        
        baseUrl = isEmulator 
            ? 'http://10.0.2.2:8002/api/' 
            : 'http://10.2.1.117:8002/api/';
      } else {
        baseUrl = 'http://10.2.1.117:8002/api/';
      }
    }
    
    dio.options.baseUrl = baseUrl;
    dio.interceptors.clear();
    
    // 1. Auth and Metadata Interceptor (MUST BE FIRST to set headers for cache key)
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = LocalStorage.getAccessToken();
          final lang = LocalStorage.getLanguage();
          
          options.headers['Accept-Language'] = lang;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          debugPrint('🌐 Request: ${options.path} | Lang: $lang');
          handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshToken = LocalStorage.getRefreshToken();
            if (refreshToken != null) {
              try {
                final res = await Dio(BaseOptions(baseUrl: dio.options.baseUrl)).post(
                  'accounts/refresh/',
                  data: {'refresh': refreshToken},
                );
                final newAccess = res.data['access'];
                await LocalStorage.saveTokens(newAccess, refreshToken);
                error.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
                final retryResponse = await dio.fetch(error.requestOptions);
                return handler.resolve(retryResponse);
              } catch (_) {
                await LocalStorage.clearTokens();
              }
            }
          }
          handler.next(error);
        },
      ),
    );

    // 2. Cache Interceptor (Now correctly sees the Accept-Language header)
    dio.interceptors.add(DioCacheInterceptor(options: CacheService.apiCacheOptions));

    // Logging (helps identify connection issues)
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (o) => debugPrint(o.toString()),
    ));
  }
}

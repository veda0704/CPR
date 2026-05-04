import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class CacheService {
  static late CacheOptions apiCacheOptions;
  static late CacheManager fileCacheManager;

  static Future<void> init() async {
    await Hive.initFlutter();
    final dir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${dir.path}/api_cache');
    if (!await cacheDir.exists()) await cacheDir.create(recursive: true);

    apiCacheOptions = CacheOptions(
      store: HiveCacheStore(cacheDir.path),
      policy: CachePolicy.refreshForceCache,
      hitCacheOnErrorExcept: [401, 403],
      maxStale: const Duration(days: 30),
      priority: CachePriority.high,
      keyBuilder: (RequestOptions request) {
        // Include language in cache key so en/te don't collide
        final lang = request.headers['Accept-Language'] ?? 'en';
        final uri = request.uri;
        final key =
            '${uri.path}${uri.query.isNotEmpty ? '?${uri.query}' : ''}_$lang';
        return key;
      },
    );

    fileCacheManager = DefaultCacheManager();
  }

  /// Manually pre-cache a file (video, image, or audio)
  static Future<void> preCacheFile(String url) async {
    try {
      await fileCacheManager.downloadFile(url);
    } catch (_) {
      // Ignore download errors
    }
  }

  static Future<File?> getCachedFile(String url) async {
    try {
      final fileInfo = await fileCacheManager.getFileFromCache(url);
      return fileInfo?.file;
    } catch (_) {
      return null;
    }
  }

  static Future<void> cacheApiResponse({
    required String baseUrl,
    required String path,
    required Map<String, dynamic> data,
    String? lang,
    String method = 'GET',
  }) async {
    final requestOptions = RequestOptions(
      baseUrl: baseUrl,
      path: path,
      method: method,
      responseType: ResponseType.json,
      headers: {
        if (lang != null) 'Accept-Language': lang,
      },
    );

    final key = apiCacheOptions.keyBuilder(requestOptions);
    debugPrint('💾 [Cache] Manually Injecting: $path ($lang) | Key: $key');

    final cacheResponse = CacheResponse(
      key: key,
      url: requestOptions.uri.toString(),
      date: DateTime.now(),
      requestDate: DateTime.now(),
      responseDate: DateTime.now(),
      content: Uint8List.fromList(utf8.encode(jsonEncode(data))),
      headers: null,
      priority: apiCacheOptions.priority,
      maxStale: apiCacheOptions.maxStale != null
          ? DateTime.now().add(apiCacheOptions.maxStale!)
          : null,
      cacheControl: CacheControl(),
      eTag: null,
      expires: null,
      lastModified: null,
    );

    await apiCacheOptions.store?.set(cacheResponse);
  }
}

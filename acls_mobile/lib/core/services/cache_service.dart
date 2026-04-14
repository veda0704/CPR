import 'dart:io';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class CacheService {
  static late CacheOptions apiCacheOptions;
  static late BaseCacheManager fileCacheManager;

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
      keyBuilder: (request) {
        // Include language in cache key so en/te don't collide
        final lang = request.headers['Accept-Language'] ?? 'en';
        return '${request.uri}_$lang';
      },
    );

    fileCacheManager = DefaultCacheManager();
  }

  /// Manually pre-cache a file (video or audio)
  static Future<void> preCacheFile(String url) async {
    try {
      if (url.startsWith('/static')) {
        // Backend relative path
        return; 
      }
      await fileCacheManager.downloadFile(url);
    } catch (_) {
      // Ignore download errors
    }
  }
}

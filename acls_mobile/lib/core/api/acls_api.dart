import 'package:dio/dio.dart';
import 'api_client.dart';
import '../services/cache_service.dart';

class AclsApi {
  static Future<Map<String, dynamic>> getDashboard() async {
    final res = await ApiClient.dio.get('acls/dashboard/');
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getStep(String stepId, {String? lang}) async {
    final res = await ApiClient.dio.get(
      'acls/step/$stepId/?tts=true',
      options: lang != null ? Options(headers: {'Accept-Language': lang}) : null,
    );
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getSpeechFromText(String text, String lang) async {
    final res = await ApiClient.dio.post('acls/tts-text/', data: {'text': text, 'lang': lang});
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getBulkSync({String? lang}) async {
    // Clear cache before sync to ensure fresh data
    await CacheService.apiCacheOptions.store?.clean();
    final res = await ApiClient.dio.get(
      'acls/sync-all/',
      options: lang != null ? Options(headers: {'Accept-Language': lang}) : null,
    );
    return res.data as Map<String, dynamic>;
  }
}

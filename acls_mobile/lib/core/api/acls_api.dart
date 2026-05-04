import 'package:dio/dio.dart';
import 'api_client.dart';

class AclsApi {
  static Options _requestOptions({String? lang}) {
    final headers = <String, dynamic>{};
    if (lang != null) {
      headers['Accept-Language'] = lang;
    }
    return Options(headers: headers);
  }

  static Future<Map<String, dynamic>> getDashboard({String? lang}) async {
    final res = await ApiClient.dio.get(
      'acls/dashboard/',
      queryParameters: lang != null ? {'lang': lang} : null,
      options: _requestOptions(lang: lang),
    );
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getStep(String stepId,
      {String? lang}) async {
    final res = await ApiClient.dio.get(
      'acls/step/$stepId/',
      queryParameters: {
        'tts': 'true',
        if (lang != null) 'lang': lang,
      },
      options: _requestOptions(lang: lang),
    );
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getSpeechFromText(
      String text, String lang) async {
    final res = await ApiClient.dio
        .post('acls/tts-text/', data: {'text': text, 'lang': lang});
    return res.data as Map<String, dynamic>;
  }

}

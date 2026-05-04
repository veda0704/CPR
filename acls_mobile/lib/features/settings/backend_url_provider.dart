import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/storage/local_storage.dart';

/// Holds the current backend base URL and persists the user's override.
class BackendUrlNotifier extends Notifier<String> {
  @override
  String build() => ApiClient.baseUrl;

  Future<void> updateUrl(String url) async {
    await ApiClient.setBaseUrl(url);
    state = ApiClient.baseUrl;
  }

  Future<void> resetToDefault() async {
    await LocalStorage.clearBackendUrl();
    await ApiClient.setup();
    state = ApiClient.baseUrl;
  }
}

final backendUrlProvider = NotifierProvider<BackendUrlNotifier, String>(
  BackendUrlNotifier.new,
);

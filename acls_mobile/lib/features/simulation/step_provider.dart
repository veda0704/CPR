import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/language_provider.dart';
import '../../core/api/acls_api.dart';

// ---- Dashboard Provider ----
final dashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final lang = ref.watch(languageProvider);
  return await AclsApi.getDashboard(lang: lang);
});

// ---- Step Provider ----
final stepProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, stepId) async {
  final lang = ref.watch(languageProvider);
  return await AclsApi.getStep(stepId, lang: lang);
});

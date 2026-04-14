import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/language_provider.dart';
import '../../core/api/acls_api.dart';

// ---- Dashboard Provider ----
final dashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  ref.watch(languageProvider); // Trigger refetch on language change
  return await AclsApi.getDashboard();
});

// ---- Step Provider ----
final stepProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, stepId) async {
  ref.watch(languageProvider); // Trigger refetch on language change
  return await AclsApi.getStep(stepId);
});

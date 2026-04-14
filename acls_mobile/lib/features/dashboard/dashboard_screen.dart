import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:acls_mobile/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/animated_ecg.dart';
import '../auth/auth_provider.dart';
import '../settings/language_provider.dart';
import '../simulation/step_provider.dart';
import '../../core/api/acls_api.dart';
import '../../core/api/api_client.dart';
import '../../core/services/cache_service.dart';

String _l(BuildContext context, String key) {
  final l10n = AppLocalizations.of(context);
  if (l10n == null) return key;
  switch (key) {
    case 'scene_safety_module':
      return l10n.scene_safety_module;
    case 'abcde_module':
      return l10n.abcde_module;
    case 'bls_cpr_module':
      return l10n.bls_cpr_module;
    case 'airway_module':
      return l10n.airway_module;
    case 'adv_airway_module':
      return l10n.adv_airway_module;
    case 'choking_module':
      return l10n.choking_module;
    case 'ecg_basics_module':
      return l10n.ecg_basics_module;
    case 'rhythms_blocks_module':
      return l10n.rhythms_blocks_module;
    case 'cardiac_alg_module':
      return l10n.cardiac_alg_module;
    case 'stroke_assessment':
      return l10n.stroke_assessment;
    case 'delivery_module':
      return l10n.delivery_module;
    case 'poisoning_module':
      return l10n.poisoning_module;
    case 'snake_bite_module':
      return l10n.snake_bite_module;
    case 'disaster_module':
      return l10n.disaster_module;
    case 'h5t5_module':
      return l10n.h5t5_module;
    case 'start_acls':
      return l10n.start_acls;
    case 'scene_safety':
      return l10n.scene_safety_desc;
    case 'abcde':
      return l10n.abcde_desc;
    case 'bls':
      return l10n.bls_desc;
    case 'airway':
      return l10n.airway_desc;
    case 'adv_airway':
      return l10n.adv_airway_desc;
    case 'choking':
      return l10n.choking_desc;
    case 'ecg':
      return l10n.ecg_desc;
    case 'rhythms':
      return l10n.rhythms_desc;
    case 'cardiac_alg':
      return l10n.cardiac_alg_desc;
    case 'stroke':
      return l10n.stroke_desc;
    case 'delivery':
      return l10n.delivery_desc;
    case 'poisoning':
      return l10n.poisoning_desc;
    case 'snake_bite':
      return l10n.snake_bite_desc;
    case 'disaster':
      return l10n.disaster_desc;
    case 'h5t5':
      return l10n.h5t5_desc;
    case 'acls':
      return l10n.acls_desc;
    default:
      return key;
  }
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  static final _moduleIcons = {
    'scene_safety': Icons.security_outlined,
    'abcde': Icons.fact_check_outlined,
    'bls': Icons.favorite_border_rounded,
    'airway': Icons.air_outlined,
    'adv_airway': Icons.thermostat_outlined,
    'choking': Icons.warning_amber_rounded,
    'ecg': Icons.monitor_outlined,
    'rhythms': Icons.monitor_heart_outlined,
    'cardiac_alg': Icons.electric_bolt_outlined,
    'stroke': Icons.psychology_outlined,
    'delivery': Icons.child_care_outlined,
    'poisoning': Icons.shield_outlined,
    'snake_bite': Icons.warning_amber_rounded,
    'disaster': Icons.emergency_outlined,
    'h5t5': Icons.checklist_rtl_outlined,
    'acls': Icons.favorite_rounded,
  };

  bool _isSyncing = false;

  Widget _buildSyncBtn(WidgetRef ref) {
    return InkWell(
      onTap: _isSyncing ? null : () => _syncAll(ref),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _isSyncing
              ? AppColors.orange
              : AppColors.orange.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: _isSyncing
            ? Text(
                '${(_syncProgress * 100).toInt()}%',
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.white),
              )
            : const Icon(Icons.cloud_download_rounded,
                color: AppColors.orange, size: 20),
      ),
    );
  }

  double _syncProgress = 0;

  void _syncAll(WidgetRef ref) async {
    final isTe = ref.read(languageProvider) == 'te';

    setState(() {
      _isSyncing = true;
      _syncProgress = 0;
    });

    try {
      final languages = ['en', 'te'];
      int totalSyncs = 0;

      for (String lang in languages) {
        final allSteps = await AclsApi.getBulkSync(lang: lang);
        final stepIds = allSteps.keys.toList();
        final totalSteps = stepIds.length;

        for (int i = 0; i < totalSteps; i++) {
          final stepId = stepIds[i];
          final stepData = allSteps[stepId];

          // Fetch individual step with explicit language
          final freshStep = await AclsApi.getStep(stepId, lang: lang);

          // Pre-cache audio (both languages handled by loop)
          final audioUrl = freshStep['audio_url'] as String?;
          if (audioUrl != null) {
            final base = ApiClient.baseUrl.replaceAll('/api/', '');
            final fullAudioUrl =
                audioUrl.startsWith('http') ? audioUrl : '$base$audioUrl';
            await CacheService.preCacheFile(fullAudioUrl);
          }

          // Pre-cache media only once (video is same for both)
          if (lang == 'en') {
            final videoUrl = stepData['video'] as String?;
            if (videoUrl != null) {
              final base = ApiClient.baseUrl.replaceAll('/api/', '');
              final fullUrl =
                  videoUrl.startsWith('http') ? videoUrl : '$base$videoUrl';
              await CacheService.preCacheFile(fullUrl);
            }
          }

          totalSyncs++;
          if (mounted) {
            setState(() => _syncProgress = totalSyncs / (totalSteps * 2));
          }
          
          // Throttling to prevent 'Software caused connection abort'
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                isTe ? 'ద్విభాషా ఆఫ్‌లైన్ సమకాలీకరణ పూర్తయింది! ఇంగ్లీష్ మరియు తెలుగు సిద్ధంగా ఉన్నాయి.' : 'Bilingual Offline Sync Complete! English and Telugu are ready.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(isTe ? 'సమకాలీకరణ విఫలమైంది: $e' : 'Bilingual Sync failed: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _syncProgress = 0;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Silent auto-sync on startup ONLY if authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ref.read(authProvider).status == AuthStatus.authenticated) {
        _silentRefresh();
      }
    });
  }

  Future<void> _silentRefresh() async {
    // Only refresh the dashboard and dictionary data (fast)
    // Don't pre-cache videos (slow) unless the user manually syncs.
    try {
      await CacheService.apiCacheOptions.store?.clean();
      ref.invalidate(dashboardProvider);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final dashAsync = ref.watch(dashboardProvider);
    final curLang = ref.watch(languageProvider);
    final isTe = curLang == 'te';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: AnimatedECGBackground(
        child: Container(
          decoration: const BoxDecoration(gradient: AppColors.bgGradient),
          child: SafeArea(
            bottom: false,
            child: dashAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.orange)),
              error: (e, _) => Center(
                child: ElevatedButton(
                  onPressed: () => ref.invalidate(dashboardProvider),
                  child: const Text('Retry'),
                ),
              ),
              data: (data) {
                final levelsList = (data['levels'] as List<dynamic>?) ?? [];
                final userName =
                    data['user']?['first_name'] as String? ?? 'Practitioner';
                final l10n = AppLocalizations.of(context)!;

                return CustomScrollView(
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.6)),
                                boxShadow: [
                                  BoxShadow(
                                      color: AppColors.darkOrange
                                          .withValues(alpha: 0.08),
                                      blurRadius: 24,
                                      offset: const Offset(0, 12))
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Image.asset(
                                        'assets/images/iacls-logo.png',
                                        height: 60,
                                        alignment: Alignment.centerLeft,
                                        fit: BoxFit.contain),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildLanguageSwitcher(ref, curLang),
                                  const SizedBox(width: 12),
                                  _buildSyncBtn(ref),
                                  const SizedBox(width: 12),
                                  _buildUserArea(userName, isTe, ref),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (_isSyncing)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: _syncProgress,
                              backgroundColor:
                                  AppColors.orange.withValues(alpha: 0.1),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.orange),
                              minHeight: 8,
                            ),
                          ),
                        ),
                      ),

                    // Level sections
                    ...levelsList.asMap().entries.map((lvlEntry) {
                      final lIdx = lvlEntry.key;
                      final lvl = lvlEntry.value as Map<String, dynamic>;
                      final modules = (lvl['modules'] as List<dynamic>?) ?? [];
                      return SliverMainAxisGroup(
                        slivers: [
                          // Level header
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(24, 40, 24, 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(lvl['name'] ?? '',
                                            style: GoogleFonts.inter(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.text)),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: lIdx == 0
                                              ? AppColors.orange
                                              : Colors.black12,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(lvl['tag'] ?? '',
                                            style: GoogleFonts.inter(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                                color: lIdx == 0
                                                    ? Colors.white
                                                    : AppColors.muted,
                                                letterSpacing: 1)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(lvl['description'] ?? '',
                                      style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: AppColors.muted)),
                                ],
                              ),
                            ),
                          ),
                          // Module grid
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 220,
                                mainAxisSpacing: 24,
                                crossAxisSpacing: 24,
                                childAspectRatio: 0.8,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final m =
                                      modules[index] as Map<String, dynamic>;
                                  return _ModuleCard(
                                    id: m['id'],
                                    title: _l(context, m['name'] ?? m['id']),
                                    description: _l(context, m['id']),
                                    startStep: m['start_step'],
                                    index: index,
                                    icon: _moduleIcons[m['id']] ??
                                        Icons.monitor_heart_rounded,
                                    l10n: l10n,
                                  );
                                },
                                childCount: modules.length,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 64),
                        child: _FooterWidget(isTe: isTe),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSwitcher(WidgetRef ref, String curLang) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _langBtn(ref, 'EN', 'en', curLang == 'en'),
          _langBtn(ref, 'తె', 'te', curLang == 'te'),
        ],
      ),
    );
  }

  Widget _langBtn(WidgetRef ref, String label, String code, bool active) {
    return GestureDetector(
      onTap: () => ref.read(languageProvider.notifier).setLanguage(code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppColors.orange : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: active ? Colors.white : AppColors.muted,
          ),
        ),
      ),
    );
  }

  Widget _buildUserArea(String name, bool isTe, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(name,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkOrange,
                    height: 1.1)),
            Text(isTe ? 'ప్రాక్టీషనర్' : 'PRACTITIONER',
                style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.orange,
                    letterSpacing: 0.5,
                    height: 1.1)),
          ],
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            ref.read(authProvider.notifier).logout();
            context.go('/login');
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.darkOrange,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: AppColors.darkOrange.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child:
                const Icon(Icons.logout_rounded, color: Colors.white, size: 16),
          ),
        ),
      ],
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final String startStep;
  final int index;
  final IconData icon;
  final AppLocalizations l10n;

  const _ModuleCard({
    required this.id,
    required this.title,
    required this.description,
    required this.startStep,
    required this.index,
    required this.icon,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/acls/$startStep'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 8))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.circular(16)),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                Text('${l10n.module_prefix} 0${index + 1}',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.orange)),
              ],
            ),
            const SizedBox(height: 16),
            Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text)),
            const SizedBox(height: 8),
            Expanded(
                child: Text(description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                        height: 1.4))),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(l10n.play,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                        letterSpacing: 1.2)),
                const SizedBox(width: 6),
                const Icon(Icons.play_arrow_rounded, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterWidget extends StatelessWidget {
  final bool isTe;
  const _FooterWidget({required this.isTe});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "© 2025 | Powered by",
              style: GoogleFonts.inter(
                  color: AppColors.muted,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            Image.asset('assets/images/bavya-logo.png',
                height: 24, fit: BoxFit.contain),
          ],
        ),
      ],
    );
  }
}

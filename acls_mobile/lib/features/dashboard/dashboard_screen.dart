import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:acls_mobile/generated/app_localizations.dart';
import '../../core/widgets/loading_spinner.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/animated_ecg.dart';
import '../auth/auth_provider.dart';
import '../settings/language_provider.dart';
import '../simulation/step_provider.dart';

import '../../core/api/api_client.dart';
import '../../core/storage/local_storage.dart';

String _l(BuildContext context, String key) {
  final l10n = AppLocalizations.of(context);
  if (l10n == null) return key;
  switch (key) {
    case 'scene_safety':
      return l10n.scene_safety_module;
    case 'abcde':
      return l10n.abcde_module;
    case 'bls':
      return l10n.bls_cpr_module;
    case 'airway':
      return l10n.airway_module;
    case 'adv_airway':
      return l10n.adv_airway_module;
    case 'choking':
      return l10n.choking_module;
    case 'ecg':
    case 'ecg_rhythms':
      return l10n.ecg_rhythms_module;
    case 'cardiac_alg':
      return l10n.cardiac_alg_module;
    case 'stroke':
      return l10n.stroke_assessment;
    case 'delivery':
      return l10n.delivery_module;
    case 'poisoning':
      return l10n.poisoning_module;
    case 'snake_bite':
      return l10n.snake_bite_module;
    case 'disaster':
      return l10n.disaster_module;
    case 'h5t5':
      return l10n.h5t5_module;
    case 'trauma':
      return l10n.trauma_module;
    case 'acls':
      return l10n.start_acls;
    default:
      return key;
  }
}


IconData _getIcon(String key) {
  switch (key) {
    case 'scene_safety':
      return Icons.security;
    case 'abcde':
      return Icons.assignment_outlined;
    case 'bls':
      return Icons.monitor_heart_rounded;
    case 'choking':
      return Icons.warning_amber_rounded;
    case 'airway':
      return Icons.air_rounded;
    case 'adv_airway':
      return Icons.monitor_heart_rounded; 
    case 'trauma':
      return Icons.emergency_rounded;
    case 'poisoning':
      return Icons.thermostat_rounded;
    case 'snake_bite':
      return Icons.shield_outlined;
    case 'stroke':
      return Icons.psychology_rounded;
    case 'disaster':
      return Icons.list_alt_rounded;
    case 'intro':
      return Icons.desktop_windows_rounded;
    case 'delivery':
      return Icons.child_care_rounded;
    case 'ecg':
    case 'ecg_rhythms':
      return Icons.monitor_heart;
    case 'cardiac_alg':
      return Icons.bolt_rounded;
    case 'h5t5':
      return Icons.check_circle_outline_rounded;
    case 'acls':
      return Icons.play_arrow_rounded;
    default:
      return Icons.menu_book_rounded;
  }
}

Color _getLevelColor(BuildContext context, String? levelId) {
  switch (levelId) {
    case 'level1':
      return Theme.of(context).primaryColor; // Teal
    case 'level2':
      return Theme.of(context).primaryColor; // Emerald
    case 'level3':
      return Theme.of(context).primaryColor; // Teal-Cyan
    default:
      return Theme.of(context).primaryColor;
  }
}

String _getModuleImage(String modId) {
  const mapping = {
    'scene_safety': 'scenesafetym1.png',
    'abcde': 'abcdem2.png',
    'bls': 'blscprm3.png',
    'choking': 'chokingm4.png',
    'airway': 'airwayanatomy.png',
    'adv_airway': 'advancedairway.png',
    'trauma': 'trauma.png',
    'poisoning': 'poisionmanagement.png',
    'snake_bite': 'snakebite.png',
    'stroke': 'strokemanagement.png',
    'disaster': 'diastermanagement.png',
    'intro': 'abcdem2.png',
    'ecg': 'ecgm13.png',
    'ecg_rhythms': 'ecgm13.png',
    'cardiac_alg': 'blscprm3.png',
    'h5t5': 'scenesafetym1.png',
    'acls': 'abcdem2.png'
  };
  final filename = mapping[modId] ?? 'abcdem2.png';
  final base = ApiClient.baseUrl.split('/api/').first;
  return '$base/static/images/module-bgs/$filename';
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (_searchController.text.isNotEmpty && !_isSearching) {
        setState(() => _isSearching = true);
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) setState(() => _isSearching = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashAsync = ref.watch(dashboardProvider);
    final curLang = ref.watch(languageProvider);
    final isTe = curLang == 'te';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AnimatedECGBackground(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardProvider),
          color: Theme.of(context).primaryColor,
          child: Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF120C08), // Midnight Espresso
                        Color(0xFF1A120B), // Roasted Bean
                      ],
                    )
                  : AppColors.bgGradient,
            ),
            child: SafeArea(
              bottom: false,
              child: dashAsync.when(
                loading: () => const Center(
                    child: LoadingSpinner.fullScreen(message: 'Loading Dashboard...')),
                error: (e, _) {
                  final isAuthError = e.toString().contains('401') ||
                      e.toString().contains('Unauthorized') ||
                      e.toString().contains('Authentication credentials');

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isAuthError ? 'Session Expired' : 'Failed to Load',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isAuthError
                                ? 'Your session has expired. Please login again.'
                                : 'Failed to load dashboard. Please try again.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: isAuthError
                                ? () {
                                    ref.read(authProvider.notifier).logout();
                                    context.go('/login');
                                  }
                                : () => ref.invalidate(dashboardProvider),
                            child: Text(isAuthError ? 'Login' : 'Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                data: (data) {
                   final levelsList = (data['levels'] as List<dynamic>?) ?? [];
                   final userMap = data['user'] as Map<String, dynamic>?;
                   
                   final String email = userMap?['email'] as String? ?? 
                                        data['email'] as String? ?? '';

                   final String fName = userMap?['first_name'] as String? ?? 
                                        userMap?['firstName'] as String? ?? 
                                        data['first_name'] as String? ?? 
                                        data['firstName'] as String? ?? '';
                                        
                   final String lName = userMap?['last_name'] as String? ?? 
                                        userMap?['lastName'] as String? ?? 
                                        data['last_name'] as String? ?? 
                                        data['lastName'] as String? ?? '';
                                        
                   final String uName = userMap?['username'] as String? ?? 
                                        userMap?['name'] as String? ?? 
                                        data['username'] as String? ?? 
                                        data['name'] as String? ?? '';

                   final String fullName = (fName.isNotEmpty || lName.isNotEmpty)
                       ? '$fName $lName'.trim()
                       : (uName.isNotEmpty ? uName : (email.isNotEmpty ? email.split('@').first : 'User'));

                   final String effectiveFirstName = (fName.trim().isNotEmpty && fName != 'User')
                       ? fName.trim() 
                       : (uName.isNotEmpty && uName != 'User' ? uName.split(' ').first : 
                          (email.isNotEmpty ? email.split('@').first : 'User'));

                   if (fName.isNotEmpty || lName.isNotEmpty || (uName.isNotEmpty && uName != 'User')) {
                     WidgetsBinding.instance.addPostFrameCallback((_) {
                       final currentAuth = ref.read(authProvider).value;
                       if (currentAuth?.firstName != effectiveFirstName) {
                         ref.read(authProvider.notifier).updateUser(effectiveFirstName);
                       }
                     });
                   }

                   final l10n = AppLocalizations.of(context);
                   if (l10n == null) {
                     return const CustomScrollView(
                       slivers: [
                         SliverFillRemaining(child: Center(child: LoadingSpinner.fullScreen(message: 'Initializing...'))),
                       ],
                     );
                   }

                  if (levelsList.isEmpty) {
                    return const CustomScrollView(
                      slivers: [
                        SliverFillRemaining(
                          child: Center(child: LoadingSpinner.fullScreen(message: 'Preparing Modules...')),
                        ),
                      ],
                    );
                  }

                  final filteredLevels = levelsList.asMap().entries.where((lvlEntry) {
                    final lvl = lvlEntry.value as Map<String, dynamic>;
                    final modules = (lvl['modules'] as List<dynamic>?) ?? [];
                    if (_searchQuery.isEmpty) return true;
                    return modules.any((m) {
                      final title = _l(context, m['id']).toLowerCase();
                      return title.contains(_searchQuery.toLowerCase());
                    });
                  }).toList();

                  if (_searchQuery.isNotEmpty && filteredLevels.isEmpty) {
                    return CustomScrollView(
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off_rounded, size: 64, color: AppColors.muted),
                                const SizedBox(height: 16),
                                Text(isTe ? "ఫలితాలు లేవు" : "No results found",
                                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.muted)),
                                const SizedBox(height: 8),
                                Text(isTe ? "'$_searchQuery' కి సరిపోలే మాడ్యూల్స్ లేవు" : "No modules match '$_searchQuery'",
                                    style: GoogleFonts.inter(color: AppColors.muted)),
                                const SizedBox(height: 24),
                                TextButton(
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      setState(() {
                                        _searchController.clear();
                                        _searchQuery = '';
                                      });
                                    },
                                    child: Text(isTe ? "శోధనను క్లియర్ చేయండి" : "Clear search",
                                        style: GoogleFonts.inter(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w700))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                          child: Container(
                            height: 85,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isDark 
                                ? const Color(0xFF0F172A) 
                                : Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Hero(
                                  tag: 'app_logo',
                                  child: Image.asset(
                                    'assets/images/iacls-logo.png',
                                    height: 48,
                                    color: Colors.white,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SizedBox(
                                    height: 42,
                                    child: TextField(
                                      controller: _searchController,
                                      onChanged: (val) => setState(() => _searchQuery = val),
                                      style: GoogleFonts.inter(fontSize: 13, color: Colors.black, fontWeight: FontWeight.w600),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        hintText: isTe ? 'వెతకండి...' : 'Search...',
                                        hintStyle: GoogleFonts.inter(color: Colors.black38, fontSize: 12),
                                        prefixIcon: Icon(Icons.search_rounded, size: 18, color: Theme.of(context).primaryColor),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _buildMenuArea(fullName, isTe, ref),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Level sections - Filtered by Search
                      ...filteredLevels.expand((lvlEntry) {
                        final dynamic rawLvl = lvlEntry.value;
                        if (rawLvl == null || rawLvl is! Map<String, dynamic>) return <Widget>[];
                        
                        final lvl = rawLvl;
                        final lvlId = lvl['id'] as String? ?? 'level1';
                        final rawModules = (lvl['modules'] as List<dynamic>?) ?? [];
                        
                        // Pre-filter modules for this level
                        final filteredModules = rawModules.where((m) {
                          if (m == null || m is! Map<String, dynamic>) return false;
                          if (_searchQuery.isEmpty) return true;
                          final modId = m['id'] as String? ?? '';
                          final title = _l(context, modId).toLowerCase();
                          return title.contains(_searchQuery.toLowerCase());
                        }).map((m) => m as Map<String, dynamic>).toList();

                        if (filteredModules.isEmpty) return <Widget>[];

                        return <Widget>[
                          // Premium Level Hero - Match Web
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(32),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isDark
                                            ? [
                                                const Color(0xFF1E293B).withValues(alpha: 0.8),
                                                const Color(0xFF0F172A).withValues(alpha: 0.9),
                                              ]
                                            : [
                                                _getLevelColor(context, lvlId).withValues(alpha: 0.12),
                                                _getLevelColor(context, lvlId).withValues(alpha: 0.05),
                                              ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(32),
                                      border: Border.all(
                                        color: isDark 
                                          ? Colors.white.withValues(alpha: 0.1) 
                                          : _getLevelColor(context, lvlId).withValues(alpha: 0.2),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 42,
                                              height: 42,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: _getLevelColor(context, lvlId).withValues(alpha: 0.1),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: _getLevelColor(context, lvlId).withValues(alpha: 0.2), width: 1.5),
                                                ),
                                                child: Icon(
                                                  Icons.emoji_events_rounded,
                                                  color: _getLevelColor(context, lvlId),
                                                  size: 24,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(isTe ? "లెర్నింగ్ జర్నీ" : "LEARNING JOURNEY", 
                                                    style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: _getLevelColor(context, lvlId).withValues(alpha: 0.7), letterSpacing: 1.5)),
                                                  const SizedBox(height: 2),
                                                  Text(isTe ? (lvl['name_te'] ?? lvl['name'] ?? '') : (lvl['name'] ?? ''), 
                                                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : _getLevelColor(context, lvlId), letterSpacing: -0.5, height: 1.1)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.5),
                                            borderRadius: BorderRadius.circular(24),
                                            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : _getLevelColor(context, lvlId).withValues(alpha: 0.1), width: 1.5),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: _buildCompactStat(
                                                  context,
                                                  isTe ? "క్రియాశీల" : "ACTIVE", 
                                                  rawModules.isNotEmpty 
                                                    ? _l(context, (rawModules.firstWhere((m) => m != null && LocalStorage.getModuleStatus(userMap?['email'] ?? '', m['id'] ?? '') == 'in_progress', orElse: () => rawModules[0])?['id'] ?? ''))
                                                    : (isTe ? "ఏదీ లేదు" : "NONE"),
                                                  status: isTe ? "పురోగతి" : "RUNNING",
                                                  icon: Icons.play_circle_filled_rounded,
                                                  onTap: () {
                                                    if (rawModules.isEmpty) return;
                                                    final mod = rawModules.firstWhere((m) => m != null && LocalStorage.getModuleStatus(userMap?['email'] ?? '', m['id'] ?? '') == 'in_progress', orElse: () => rawModules[0]);
                                                    if (mod != null && mod['start_step'] != null) {
                                                      context.push('/acls/${mod['start_step']}');
                                                    }
                                                  },
                                                ),
                                              ),
                                              Container(width: 1, height: 40, color: isDark ? Colors.white.withValues(alpha: 0.1) : _getLevelColor(context, lvlId).withValues(alpha: 0.1)),
                                              Expanded(
                                                child: _buildCompactStat(
                                                  context,
                                                  isTe ? "తదుపరి" : "NEXT", 
                                                  rawModules.isNotEmpty
                                                    ? _l(context, (rawModules.firstWhere((m) => m != null && LocalStorage.getModuleStatus(userMap?['email'] ?? '', m['id'] ?? '') == 'locked', orElse: () => rawModules[0])?['id'] ?? ''))
                                                    : (isTe ? "ఏదీ లేదు" : "NONE"),
                                                  status: isTe ? "కొనసాగించు" : "CONTINUE",
                                                  icon: Icons.arrow_circle_right_rounded,
                                                  onTap: () {
                                                    if (rawModules.isEmpty) return;
                                                    final mod = rawModules.firstWhere((m) => m != null && LocalStorage.getModuleStatus(userMap?['email'] ?? '', m['id'] ?? '') == 'locked', orElse: () => rawModules[0]);
                                                    if (mod != null && mod['start_step'] != null) {
                                                      context.push('/acls/${mod['start_step']}');
                                                    }
                                                  },
                                                ),
                                              ),
                                              Container(width: 1, height: 40, color: isDark ? Colors.white.withValues(alpha: 0.1) : _getLevelColor(context, lvlId).withValues(alpha: 0.1)),
                                              Expanded(
                                                child: _buildCompactStat(
                                                  context,
                                                  isTe ? "చివరిది" : "LAST", 
                                                  _l(context, "scene_safety"),
                                                  status: "TODAY",
                                                  icon: Icons.history_rounded,
                                                  onTap: () {},
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          height: 4,
                                          width: double.infinity,
                                          decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.1) : _getLevelColor(context, lvlId).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2)),
                                          child: FractionallySizedBox(
                                            alignment: Alignment.centerLeft,
                                            widthFactor: LocalStorage.getLevelProgress(userMap?['email'] ?? '', rawModules).clamp(0.01, 1.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: _getLevelColor(context, lvlId),
                                                borderRadius: BorderRadius.circular(2), 
                                                boxShadow: [
                                                  BoxShadow(color: _getLevelColor(context, lvlId).withValues(alpha: 0.3), blurRadius: 4)
                                                ]
                                              )
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Module grid
                          SliverPadding(
                            padding:
                                const EdgeInsets.fromLTRB(24, 8, 24, 24),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.8,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final mod = filteredModules[index];
                                    return _ModuleCard(
                                      id: mod['id'],
                                      title: _l(context, mod['id']),
                                      startStep: mod['start_step'],
                                      image: mod['image'],
                                      index: filteredModules.indexOf(mod),
                                      icon: _getIcon(mod['id']),
                                      l10n: l10n,
                                      userEmail: userMap?['email'] ?? '',
                                    );
                                  },
                                  childCount: filteredModules.length,
                                ),
                              ),
                            ),
                        ];
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
      ),
    );
  }

  Widget _buildCompactStat(BuildContext context, String title, String value, {required IconData icon, required VoidCallback onTap, String? status}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isDark ? Colors.white : primaryColor, size: 14),
            ),
            const SizedBox(height: 6),
            Text(title, 
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 7, fontWeight: FontWeight.w900, color: isDark ? Colors.white.withValues(alpha: 0.7) : primaryColor.withValues(alpha: 0.7), letterSpacing: 0.5)),
            const SizedBox(height: 2),
            Text(value, 
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: isDark ? Colors.white : primaryColor, height: 1.1)),
            if (status != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.15) : primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(status.toUpperCase(), 
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 7.5, fontWeight: FontWeight.w900, color: isDark ? Colors.white : primaryColor)),
              ),
            ],
          ],
        ),
      ),
    );
  }



  Widget _buildMenuArea(String name, bool isTe, WidgetRef ref) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.push('/settings'),
          icon: const Icon(Icons.settings_rounded, color: Colors.white, size: 24),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            ref.read(authProvider.notifier).logout();
            context.go('/login');
          },
          icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 24),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String id;
  final String title;
  final String startStep;
  final String? image;
  final int index;
  final IconData icon;
  final AppLocalizations l10n;
  final String userEmail;

  const _ModuleCard({
    required this.id,
    required this.title,
    required this.startStep,
    this.image,
    required this.index,
    required this.icon,
    required this.l10n,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    final status = LocalStorage.getModuleStatus(userEmail, id);
    final isLocked = status == 'locked';
    final isCompleted = status == 'completed';
    final isInProgress = status == 'in_progress';

    final statusLabel = isCompleted
        ? l10n.completed
        : isInProgress
            ? l10n.in_progress
            : l10n.locked;
    final actionLabel = isCompleted
        ? l10n.review
        : isInProgress
            ? l10n.continue_label
            : l10n.start;
    final statusColor = isCompleted
        ? AppColors.success
        : isInProgress
            ? Theme.of(context).primaryColor
            : AppColors.muted;
    final statusIcon = isCompleted
        ? Icons.check_circle_rounded
        : isInProgress
            ? Icons.show_chart_rounded
            : Icons.lock_rounded;
    final imageWidget = Image.network(
      _getModuleImage(id),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        child: Icon(icon, size: 40, color: Theme.of(context).primaryColor),
      ),
    );
    final moduleImage = isLocked
        ? ColorFiltered(
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
            child: Opacity(opacity: 0.8, child: imageWidget),
          )
        : imageWidget;

    return Semantics(
      button: true,
      label: '$title $actionLabel',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (isLocked) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.module_locked),
                backgroundColor: AppColors.slate,
              ),
            );
            return;
          }
          if (!isCompleted) {
            LocalStorage.setModuleStatus(userEmail, id, 'in_progress');
          }
          context.push('/acls/$startStep');
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E293B)
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF334155)
                    : Colors.white),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 12),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      moduleImage,
                      // Gradient overlay for better text contrast if needed
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(context).primaryColor.withValues(alpha: 0.25),
                                Colors.transparent,
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.3),
                              ],
                              stops: const [0.0, 0.3, 0.7, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF0F172A).withValues(alpha: 0.92)
                                : Colors.white.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 12, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                statusLabel,
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '0${index + 1}',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      if (isLocked)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.38),
                            child: const Center(
                              child: Icon(
                                Icons.lock_rounded,
                                color: Colors.white,
                                size: 38,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : AppColors.slate,
                        ),
                      ),
                       const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 36,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    actionLabel,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
              "© 2026 | ${isTe ? 'పవర్డ్ బై' : 'Powered by'}",
              style: GoogleFonts.inter(
                  color: AppColors.muted,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            Image.asset('assets/images/bavya-logo.png',
                height: 24, fit: BoxFit.fitHeight),
          ],
        ),
      ],
    );
  }
}

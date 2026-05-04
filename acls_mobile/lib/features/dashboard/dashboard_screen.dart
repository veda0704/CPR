import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:acls_mobile/generated/app_localizations.dart';
import '../../core/widgets/loading_spinner.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
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

Color _getLevelColor(String? levelId) {
  switch (levelId) {
    case 'level1':
      return const Color(0xFF00796B); // Teal
    case 'level2':
      return const Color(0xFF059669); // Emerald
    case 'level3':
      return const Color(0xFF0D9488); // Teal-Cyan
    default:
      return const Color(0xFF00796B);
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
          color: AppColors.skyBlue,
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
                                        style: GoogleFonts.inter(color: AppColors.skyBlue, fontWeight: FontWeight.w700))),
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
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: isDark 
                                ? const Color(0xFF0F172A) 
                                : const Color(0xFF004D39),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: const Alignment(0, -0.1),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 4, right: 2), // Shift logo left, maintain proper edge padding
                                      child: Row(
                                        children: [
                                          Hero(
                                            tag: 'app_logo',
                                            child: Image.asset(
                                              'assets/images/iacls-logo.png',
                                              height: 54, // Standardized Elite branding
                                              color: Colors.white,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          const SizedBox(width: 12), // Equal spacing before search
                                          Expanded(
                                            child: SizedBox(
                                              height: 42,
                                              child: TextField(
                                                controller: _searchController,
                                                onChanged: (val) => setState(() => _searchQuery = val),
                                                cursorColor: AppColors.skyBlue,
                                                style: GoogleFonts.inter(
                                                  fontSize: 13, 
                                                  color: const Color(0xFF0F172A),
                                                  fontWeight: FontWeight.w600
                                                ),
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  hintText: isTe ? 'సెర్చ్ మాడ్యూల్స్...' : 'Search modules...',
                                                  hintStyle: GoogleFonts.inter(
                                                    color: Colors.black38, 
                                                    fontSize: 13
                                                  ),
                                                  prefixIcon: const Icon(Icons.search_rounded, 
                                                    size: 18, 
                                                    color: Color(0xFF005B41)),
                                                  suffixIcon: _isSearching 
                                                    ? const Padding(
                                                        padding: EdgeInsets.all(12),
                                                        child: SizedBox(
                                                          width: 16,
                                                          height: 16,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF005B41)),
                                                          ),
                                                        ),
                                                      )
                                                    : null,
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6), // Equal spacing after search (compensating for PopupMenuButton's innate padding)
                                          _buildMenuArea(fullName, isTe, ref),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Glowing Bottom Line
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 3,
                                      color: const Color(0xFF059669),
                                    ),
                                  ),
                                ],
                              ),
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
                              padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFF1E293B)
                                      : _getLevelColor(lvlId).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(
                                      color: _getLevelColor(lvlId).withValues(alpha: 0.1)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 32,
                                      offset: const Offset(0, 16),
                                    )
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 54,
                                          height: 54,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: _getLevelColor(lvlId).withValues(alpha: 0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.emoji_events_rounded,
                                              color: _getLevelColor(lvlId),
                                              size: 28,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(isTe ? "లెర్నింగ్ జర్నీ" : "LEARNING JOURNEY", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: _getLevelColor(lvlId), letterSpacing: 1.5)),
                                              const SizedBox(height: 2),
                                              Text(isTe ? (lvl['name_te'] ?? lvl['name'] ?? '') : (lvl['name'] ?? ''), style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.slate, letterSpacing: -0.5, height: 1.1)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    // Three cards like Web
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 170,
                                            child: _buildQuickStat(
                                              isTe ? "క్రియాశీల మాడ్యూల్" : "Active Module", 
                                              rawModules.isNotEmpty 
                                                ? _l(context, (rawModules.firstWhere((m) => m != null && LocalStorage.getModuleStatus(userMap?['email'] ?? '', m['id'] ?? '') == 'in_progress', orElse: () => rawModules[0])?['id'] ?? ''))
                                                : (isTe ? "ఏదీ లేదు" : "None"),
                                              color: _getLevelColor(lvlId),
                                              status: isTe ? "పురోగతిలో ఉంది" : "In Progress",
                                              onTap: () {
                                                if (rawModules.isEmpty) return;
                                                final mod = rawModules.firstWhere((m) => m != null && LocalStorage.getModuleStatus(userMap?['email'] ?? '', m['id'] ?? '') == 'in_progress', orElse: () => rawModules[0]);
                                                if (mod != null && mod['start_step'] != null) {
                                                  context.push('/acls/${mod['start_step']}');
                                                }
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          SizedBox(
                                            width: 170,
                                            child: _buildQuickStat(
                                              isTe ? "తదుపరి దశ" : "Next Step", 
                                              rawModules.isNotEmpty
                                                ? _l(context, (rawModules.firstWhere((m) => m != null && LocalStorage.getModuleStatus(userMap?['email'] ?? '', m['id'] ?? '') == 'locked', orElse: () => rawModules[0])?['id'] ?? ''))
                                                : (isTe ? "ఏదీ లేదు" : "None"),
                                              color: _getLevelColor(lvlId),
                                              status: isTe ? "కొనసాగించండి →" : "Continue →",
                                              onTap: () {
                                                if (rawModules.isEmpty) return;
                                                final mod = rawModules.firstWhere((m) => m != null && LocalStorage.getModuleStatus(userMap?['email'] ?? '', m['id'] ?? '') == 'locked', orElse: () => rawModules[0]);
                                                if (mod != null && mod['start_step'] != null) {
                                                  context.push('/acls/${mod['start_step']}');
                                                }
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          SizedBox(
                                            width: 170,
                                            child: _buildQuickStat(
                                              isTe ? "చివరిగా చూసినది" : "Last Accessed", 
                                              _l(context, "scene_safety"),
                                              color: _getLevelColor(lvlId),
                                              status: "Today, 10:30 AM",
                                              onTap: () {},
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Container(
                                      height: 6,
                                      width: double.infinity,
                                      decoration: BoxDecoration(color: _getLevelColor(lvlId).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(3)),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: LocalStorage.getLevelProgress(userMap?['email'] ?? '', rawModules).clamp(0.01, 1.0),
                                        child: Container(decoration: BoxDecoration(color: _getLevelColor(lvlId), borderRadius: BorderRadius.circular(3), boxShadow: [BoxShadow(color: _getLevelColor(lvlId).withValues(alpha: 0.3), blurRadius: 8)])),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Module grid
                          SliverPadding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24),
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

  Widget _buildQuickStat(String title, String value, {required Color color, required VoidCallback onTap, String? status}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
          ],
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bolt_rounded, color: color, size: 14),
                const SizedBox(width: 4),
                Text(title.toUpperCase(),
                    style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: color,
                        letterSpacing: 0.5)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                height: 1.2,
                color: isDark ? Colors.white : AppColors.slate,
              ),
            ),
            if (status != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (status.contains('→'))
                    Text(status, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color))
                  else ...[
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text(status, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
                  ]
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildMenuArea(String name, bool isTe, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);
    
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert_rounded,
        color: Colors.white,
        size: 28,
      ),
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 12,
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      onSelected: (value) {
        HapticFeedback.lightImpact();
        if (value == 'logout') {
          ref.read(authProvider.notifier).logout();
          context.go('/login');
        } else if (value == 'toggle_lang') {
          ref.read(languageProvider.notifier).setLanguage(isTe ? 'en' : 'te');
        } else if (value == 'toggle_theme') {
          ref.read(themeModeProvider.notifier).toggle();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) {
                      final String? authFirstName = ref.watch(authProvider).value?.firstName;
                      final String? authEmail = ref.watch(authProvider).value?.email;
                      final String emailPrefix = authEmail != null ? authEmail.split('@').first : 'User';

                      final String displayName = (authFirstName != null && authFirstName.trim().isNotEmpty && authFirstName != 'User')
                          ? authFirstName
                          : (name.isNotEmpty && name != 'User' ? name.split(' ').first : emailPrefix);
                      
                      return Text(
                        displayName,
                        style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : AppColors.slate,
                            letterSpacing: -0.5),
                      );
                    },
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF005B41),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'toggle_lang',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.skyBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.translate_rounded, color: AppColors.skyBlue, size: 18),
              ),
              const SizedBox(width: 14),
              Text(
                isTe ? "English Mode" : "తెలుగు మోడ్",
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, 
                    color: isDark ? Colors.white : AppColors.slate),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'toggle_theme',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.skyBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, 
                    color: AppColors.skyBlue, size: 18),
              ),
              const SizedBox(width: 14),
              Text(
                isTe 
                  ? (isDark ? 'లైట్ మోడ్' : 'డార్క్ మోడ్')
                  : (isDark ? 'Light Mode' : 'Dark Mode'),
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, 
                    color: isDark ? Colors.white : AppColors.slate),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
              ),
              const SizedBox(width: 14),
              Text(
                isTe ? 'లాగ్ అవుట్' : 'Logout',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, color: Colors.redAccent),
              ),
            ],
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
            ? AppColors.skyBlue
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
        color: AppColors.skyBlueSoft,
        child: Icon(icon, size: 40, color: AppColors.skyBlue),
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
                                const Color(0xFF00796B).withValues(alpha: 0.25),
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
                                color: AppColors.skyBlue,
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

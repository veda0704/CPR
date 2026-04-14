import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:acls_mobile/generated/app_localizations.dart';

import 'core/services/cache_service.dart';
import 'core/api/api_client.dart';
import 'core/storage/local_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/auth/splash_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/simulation/step_screen.dart';
import 'features/settings/language_provider.dart';
import 'core/services/connectivity_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();
  await CacheService.init(); 
  await ApiClient.setup();
  runApp(const ProviderScope(child: AclsApp()));
}

final _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    if (state.matchedLocation == '/') return null; // Allow splash screen
    
    final loggedIn = LocalStorage.isLoggedIn;
    final isAuth = state.matchedLocation.startsWith('/login') ||
        state.matchedLocation.startsWith('/signup');
    if (!loggedIn && !isAuth) return '/login';
    if (loggedIn && isAuth) return '/dashboard';
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (_, __) => const SignupScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (_, __) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/acls/:stepId',
      builder: (_, state) => StepScreen(
        stepId: state.pathParameters['stepId']!,
      ),
    ),
  ],
);

class AclsApp extends ConsumerWidget {
  const AclsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curLang = ref.watch(languageProvider);

    // Rebuild router when auth state changes
    ref.listen(authProvider, (_, next) {
      if (next.status == AuthStatus.unauthenticated) {
        _router.go('/login');
      }
    });

    return MaterialApp.router(
      title: 'ACLS Trainer',
      theme: AppTheme.theme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      locale: Locale(curLang),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('te'),
      ],
      builder: (context, child) {
        return _ConnectivityBannerWrapper(child: SessionTimeoutTracker(child: child!));
      },
    );
  }
}

class _ConnectivityBannerWrapper extends ConsumerWidget {
  final Widget child;
  const _ConnectivityBannerWrapper({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectivityProvider);
    final isTe = ref.watch(languageProvider) == 'te';
    
    if (status == ConnectivityStatus.isDisconnected) {
      return Column(
        children: [
          Material(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: const Color(0xFFEA580C), // Orange-600
              child: SafeArea(
                bottom: false,
                child: Center(
                  child: Text(
                    isTe ? 'ఆఫ్‌లైన్‌లో పని చేస్తోంది' : 'Working Offline',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      );
    }
    return child;
  }
}

class SessionTimeoutTracker extends ConsumerStatefulWidget {
  final Widget child;
  const SessionTimeoutTracker({super.key, required this.child});

  @override
  ConsumerState<SessionTimeoutTracker> createState() => _SessionTimeoutTrackerState();
}

class _SessionTimeoutTrackerState extends ConsumerState<SessionTimeoutTracker> with WidgetsBindingObserver {
  Timer? _timer;
  DateTime _lastActivity = DateTime.now();

  void _resetTimer() {
    _lastActivity = DateTime.now();
    _timer?.cancel();
    _timer = Timer(const Duration(minutes: 30), _handleTimeout);
  }

  void _handleTimeout() {
    debugPrint('Session timeout reached after 30 minutes of inactivity.');
    if (LocalStorage.isLoggedIn) {
      ref.read(authProvider.notifier).logout();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resetTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final diff = DateTime.now().difference(_lastActivity);
      if (diff.inMinutes >= 30) {
        debugPrint('Session expired while in background (${diff.inMinutes} mins).');
        _handleTimeout();
      } else {
        // App resumed before timeout, restart timer with remaining time
        _timer?.cancel();
        _timer = Timer(const Duration(minutes: 30) - diff, _handleTimeout);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetTimer(),
      onPointerMove: (_) => _resetTimer(),
      onPointerUp: (_) => _resetTimer(),
      child: widget.child,
    );
  }
}

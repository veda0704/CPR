import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:acls_mobile/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/api/api_client.dart';
import 'core/storage/local_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/auth/splash_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/simulation/step_screen.dart';
import 'features/settings/language_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('🎬 [Main] App starting...');
  await LocalStorage.init();
  debugPrint('📦 [Main] LocalStorage initialized.');
  await ApiClient.setup();
  debugPrint('🌐 [Main] ApiClient setup complete.');
  
  final container = ProviderContainer();
  ApiClient.onUnauthorized = () {
    container.read(authProvider.notifier).logout();
  };

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AclsApp(),
    ),
  );
}

final _messengerKey = GlobalKey<ScaffoldMessengerState>();

final _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    if (state.matchedLocation == '/') return null; // Allow splash screen

    final loggedIn = await LocalStorage.isLoggedIn;
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
    final themeMode = ref.watch(themeModeProvider);

    // Rebuild router when auth state changes
    ref.listen(authProvider, (prev, next) {
      final isTe = ref.read(languageProvider) == 'te';
      final prevStatus = prev?.value?.status;
      
      next.whenData((authState) {
        if (authState.status == AuthStatus.authenticated && prevStatus != AuthStatus.authenticated) {
          _messengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(isTe ? 'లాగిన్ విజయవంతమైంది!' : 'Login Successful!', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                ],
              ),
              backgroundColor: const Color(0xFF005B41),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }

        if (authState.status == AuthStatus.signupSuccess) {
          _messengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.how_to_reg_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(isTe ? 'ఖాతా విజయవంతంగా సృష్టించబడింది!' : 'Account Created Successfully!', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                ],
              ),
              backgroundColor: const Color(0xFF059669),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }

        if (authState.status == AuthStatus.unauthenticated && prevStatus == AuthStatus.authenticated) {
          _messengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(isTe ? 'విజయవంతంగా లాగ్ అవుట్ అయ్యారు' : 'Logged out successfully', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                ],
              ),
              backgroundColor: const Color(0xFF334155), // Lighter slate for better contrast in dark mode
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
          debugPrint('🔐 User logged out. Redirecting to login...');
          _router.go('/login');
        }
      });
    });

    return Listener(
      onPointerDown: (_) => _resetInactivityTimer(ref),
      child: MaterialApp.router(
        title: 'ACLS Trainer',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        routerConfig: _router,
        scaffoldMessengerKey: _messengerKey,
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
      ),
    );
  }

  void _resetInactivityTimer(WidgetRef ref) {
    _inactivityTimer?.cancel();
    if (ref.read(authProvider).value?.status == AuthStatus.authenticated) {
      _inactivityTimer = Timer(const Duration(minutes: 10), () {
        debugPrint('🔒 Mobile Inactivity Timeout (10 min). Logging out...');
        ref.read(authProvider.notifier).logout();
        _messengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(
              ref.read(languageProvider) == 'te' 
                ? 'నిష్క్రియాత్మకత కారణంగా సెషన్ ముగిసింది' 
                : 'Session expired due to inactivity',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    }
  }
}

Timer? _inactivityTimer;

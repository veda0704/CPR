import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:acls_mobile/generated/app_localizations.dart';

import 'core/api/api_client.dart';
import 'core/storage/local_storage.dart';
import 'core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/providers/settings_provider.dart';
import 'features/settings/theme_color_provider.dart' show sharedPrefsProvider;
import 'features/auth/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/auth/splash_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/simulation/step_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('🎬 [Main] App starting...');
  final prefs = await SharedPreferences.getInstance();
  await LocalStorage.init();
  debugPrint('📦 [Main] LocalStorage initialized.');
  await ApiClient.setup();
  debugPrint('🌐 [Main] ApiClient setup complete.');
  
  final container = ProviderContainer(
    overrides: [
      sharedPrefsProvider.overrideWithValue(prefs),
    ],
  );
  
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
        state.matchedLocation.startsWith('/signup') ||
        state.matchedLocation == '/settings';
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
      path: '/settings',
      builder: (_, __) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/acls/:stepId',
      builder: (_, state) => StepScreen(
        stepId: state.pathParameters['stepId']!,
        fromRedirect: state.extra as bool? ?? false,
      ),
    ),
  ],
);

class AclsApp extends ConsumerWidget {
  const AclsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    
    return MaterialApp.router(
      title: 'iACLS',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _messengerKey,
      theme: AppTheme.lightTheme(settings.primaryColor),
      darkTheme: AppTheme.darkTheme(settings.primaryColor),
      themeMode: settings.themeMode,
      locale: Locale(settings.languageCode),
      supportedLocales: const [
        Locale('en'),
        Locale('te'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
    );
  }
}
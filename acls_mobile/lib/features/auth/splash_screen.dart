import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/storage/local_storage.dart';
import '../../core/widgets/loading_spinner.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    // Navigate after animation + small delay
    Future.delayed(const Duration(seconds: 2), () async {
      debugPrint('🕒 [SplashScreen] Checking login state...');
      final loggedIn = await LocalStorage.isLoggedIn;
      debugPrint('🔑 [SplashScreen] isLoggedIn: $loggedIn');
      if (mounted) {
        if (loggedIn) {
          context.go('/dashboard');
        } else {
          context.go('/login');
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/iacls-logo.png', width: 260),
                const SizedBox(height: 48),
                const LoadingSpinner.compact(
                  message: 'Initializing ACLS System...',
                  showSpinner: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

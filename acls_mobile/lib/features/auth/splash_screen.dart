import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/storage/local_storage.dart';
import '../../core/api/api_client.dart';

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

    // Initialize and then navigate
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    debugPrint('🎬 [SplashScreen] Starting initialization sequence...');
    
    // Create a minimum delay for the animation to look good
    final minDelay = Future.delayed(const Duration(milliseconds: 1800));
    
    // Actual loading tasks (already started in main, but ensuring here)
    final initializationTasks = Future.wait<void>([
      LocalStorage.init(),
      ApiClient.setup(),
      minDelay,
    ]);

    await initializationTasks;
    
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor,
              primaryColor.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/iacls-logo.png',
                  width: 260,
                  color: Colors.white,
                  colorBlendMode: BlendMode.srcIn,
                ),
                const SizedBox(height: 48),
                Text(
                  'Initializing ACLS System...',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

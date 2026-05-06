import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/widgets/animated_ecg.dart';
import '../../core/theme/app_theme.dart';
import '../settings/language_provider.dart';

class CompletionScreen extends ConsumerStatefulWidget {
  final String? moduleTitle;
  const CompletionScreen({super.key, this.moduleTitle});

  @override
  ConsumerState<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends ConsumerState<CompletionScreen>
    with TickerProviderStateMixin {
  late AnimationController _cardCtrl;
  late AnimationController _starsCtrl;
  late Animation<double> _cardScale;
  late Animation<double> _cardOpacity;

  @override
  void initState() {
    super.initState();
    _cardCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _starsCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    _cardScale = CurvedAnimation(parent: _cardCtrl, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.7, end: 1.0));
    _cardOpacity =
        CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut)
            .drive(Tween(begin: 0.0, end: 1.0));

    Future.delayed(const Duration(milliseconds: 100), () {
      _cardCtrl.forward();
      _starsCtrl.forward();
    });
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    _starsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final isTe = lang == 'te';

    return Scaffold(
      body: AnimatedECGBackground(
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(gradient: AppColors.bgGradient),
            ),

          // Confetti dots (simple decorative circles)
          ..._confettiDots(),

          // Central card
          Center(
            child: AnimatedBuilder(
              animation: _cardCtrl,
              builder: (_, child) => Opacity(
                opacity: _cardOpacity.value,
                child: Transform.scale(
                  scale: _cardScale.value,
                  child: child,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Trophy emoji ring
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha: 0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: const Center(
                        child: Text('🏆', style: TextStyle(fontSize: 44)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Animated stars
                    AnimatedBuilder(
                      animation: _starsCtrl,
                      builder: (_, __) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (i) {
                            final delay = i * 0.15;
                            final progress =
                                (_starsCtrl.value - delay).clamp(0.0, 1.0);
                            final scale =
                                Curves.elasticOut.transform(progress);
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Transform.scale(
                                scale: scale,
                                child: const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFFBBF24),
                                  size: 30,
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Headline
                    Text(
                      isTe ? 'అభినందనలు!' : 'Module Complete!',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.eliteSlate,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isTe
                          ? 'మీరు ఈ మాడ్యూల్‌ను విజయవంతంగా పూర్తి చేశారు.'
                          : 'You have successfully completed this training module.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.muted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Module badge
                    if (widget.moduleTitle != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                              color:
                                  Theme.of(context).primaryColor.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_outline_rounded,
                                size: 16,
                                color: Theme.of(context).primaryColor),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                widget.moduleTitle!,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 28),

                    // Dashboard button
                    _GradientButton(
                      onTap: () => context.go('/dashboard'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.home_rounded,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            isTe ? 'డాష్‌బోర్డ్‌కు వెళ్ళండి' : 'Back to Dashboard',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  List<Widget> _confettiDots() {
    final colors = [
      Theme.of(context).primaryColor, AppColors.yellow, const Color(0xFF34D399),
      const Color(0xFF60A5FA), const Color(0xFFA78BFA),
    ];
    return List.generate(30, (i) {
      return Positioned(
        left: (i * 37.0) % MediaQuery.sizeOf(context).width,
        top: (i * 53.0) % (MediaQuery.sizeOf(context).height * 0.6),
        child: Container(
          width: 8 + (i % 5) * 4.0,
          height: 8 + (i % 5) * 4.0,
          decoration: BoxDecoration(
            color: colors[i % colors.length].withValues(alpha: 0.4),
            shape: i % 2 == 0 ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: i % 2 != 0 ? BorderRadius.circular(2) : null,
          ),
        ),
      );
    });
  }
}

class _GradientButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _GradientButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha: 0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: child,
          ),
        ),
      ),
    );
  }
}

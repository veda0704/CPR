import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/animated_ecg.dart';
import '../settings/language_provider.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    ref
        .read(authProvider.notifier)
        .login(_emailCtrl.text.trim(), _passCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final lang = ref.watch(languageProvider);
    final isTe = lang == 'te';

    ref.listen(authProvider, (_, next) {
      if (next.status == AuthStatus.authenticated) {
        if (context.mounted) context.go('/dashboard');
      }
    });

    return Scaffold(
      body: AnimatedECGBackground(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: Theme.of(context).brightness == Brightness.dark
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF0F172A),
                      const Color(0xFF1E293B).withValues(alpha: 0.8),
                    ],
                  )
                : AppColors.bgGradient,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset('assets/images/iacls-logo.png',
                            height: 100, fit: BoxFit.contain),
                        _buildLangBar(lang, ref),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(28, 70, 28, 48),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.white.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white10
                                      : Colors.white.withValues(alpha: 0.6)),
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.darkOrange
                                        .withValues(alpha: 0.08),
                                    blurRadius: 48,
                                    offset: const Offset(0, 24))
                              ],
                            ),
                            child: _buildForm(authState, isTe),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -55,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: AppColors.darkOrange,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 6),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color(0x669A3412),
                                    blurRadius: 32,
                                    offset: Offset(0, 16))
                              ],
                            ),
                            child: const Icon(Icons.person_rounded,
                                color: Colors.white, size: 48),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -28,
                        left: 20,
                        right: 20,
                        child: SizedBox(
                          height: 56,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: AppColors.accentGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    color:
                                        AppColors.orange.withValues(alpha: 0.4),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8))
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent),
                              onPressed: authState.status == AuthStatus.loading
                                  ? null
                                  : _submit,
                              child: authState.status == AuthStatus.loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : Text(isTe ? 'లాగిన్' : 'LOGIN',
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 17,
                                          letterSpacing: 1.5,
                                          color: Colors.white)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  Text.rich(
                    TextSpan(
                      text: isTe ? 'ఖాతా లేదా? ' : "Don't have an account? ",
                      style: GoogleFonts.inter(
                          color: Theme.of(context).textTheme.bodySmall?.color ??
                              AppColors.darkOrange,
                          fontWeight: FontWeight.w500,
                          fontSize: 15),
                      children: [
                        WidgetSpan(
                            child: GestureDetector(
                                onTap: () => context.push('/signup'),
                                child: Text(isTe ? 'సైన్ అప్' : 'Sign Up',
                                    style: GoogleFonts.inter(
                                        color: AppColors.orange,
                                        fontWeight: FontWeight.w800))))
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  _FooterWidget(isTe: isTe),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLangBar(String current, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tab('EN', 'en', current == 'en', ref),
          _tab('తె', 'te', current == 'te', ref),
        ],
      ),
    );
  }

  Widget _tab(String label, String code, bool active, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(languageProvider.notifier).setLanguage(code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
            color: active ? AppColors.orange : Colors.transparent,
            borderRadius: BorderRadius.circular(16)),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: active ? Colors.white : AppColors.darkOrange)),
      ),
    );
  }

  Widget _buildForm(AuthState state, bool isTe) {
    return Column(
      children: [
        _buildInput(
            controller: _emailCtrl,
            hint: isTe ? 'ఈమెయిల్' : 'Email Address',
            icon: Icons.email_outlined),
        const SizedBox(height: 20),
        _buildInput(
            controller: _passCtrl,
            hint: isTe ? 'పాస్వర్డ్' : 'Password',
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            obscure: _obscure,
            onToggleObscure: () => setState(() => _obscure = !_obscure)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                        value: true,
                        onChanged: (v) {},
                        activeColor: AppColors.orange)),
                const SizedBox(width: 8),
                Text(isTe ? 'నన్ను గుర్తుంచుకోండి' : 'Remember me',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkOrange)),
              ],
            ),
            Text(isTe ? 'పాస్‌వర్డ్ మర్చిపోయారా?' : 'Forgot Password?',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkOrange.withValues(alpha: 0.7))),
          ],
        ),
        if (state.status == AuthStatus.error && state.errorMessage != null)
          Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      color: AppColors.red,
                      fontSize: 13,
                      fontWeight: FontWeight.w600))),
      ],
    );
  }

  Widget _buildInput(
      {required TextEditingController controller,
      required String hint,
      required IconData icon,
      bool isPassword = false,
      bool obscure = false,
      VoidCallback? onToggleObscure}) {
    return Container(
      height: 56,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E293B)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 4))
          ]),
      child: Row(
        children: [
          Container(
              width: 56,
              height: 56,
              color: AppColors.darkOrange,
              child: Icon(icon, color: Colors.white, size: 22)),
          Expanded(
              child: TextFormField(
                  controller: controller,
                  obscureText: obscure,
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: GoogleFonts.inter(
                          color: AppColors.muted, fontSize: 15),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      suffixIcon: isPassword
                          ? IconButton(
                              icon: Icon(
                                  obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.muted,
                                  size: 20),
                              onPressed: onToggleObscure)
                          : null))),
        ],
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
              "© 2025 | ${isTe ? 'శక్తినిచ్చింది' : 'Powered by'}",
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

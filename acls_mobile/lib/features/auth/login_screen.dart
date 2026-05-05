import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/widgets/loading_spinner.dart';
import '../settings/language_provider.dart';
import '../../core/storage/local_storage.dart';
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
  bool _rememberMe = false;
  String? _emailError;
  String? _passError;

  @override
  void initState() {
    super.initState();
    _loadRememberedData();
  }

  Future<void> _loadRememberedData() async {
    final rememberMe = LocalStorage.getRememberMe();
    if (rememberMe) {
      final authState = ref.read(authProvider);
      authState.whenData((data) {
        if (data.email != null) {
          setState(() {
            _emailCtrl.text = data.email!;
            _rememberMe = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    final isTe = ref.read(languageProvider) == 'te';
    bool isValid = true;
    
    setState(() {
      _emailError = null;
      _passError = null;
    });

    if (_emailCtrl.text.trim().isEmpty) {
      setState(() => _emailError = isTe ? 'ఇమెయిల్ అవసరం' : 'Email is required');
      isValid = false;
    } else if (!_emailCtrl.text.contains('@')) {
      setState(() => _emailError = isTe ? 'చెల్లుబాటు అయ్యే ఇమెయిల్ నమోదు చేయండి' : 'Enter a valid email');
      isValid = false;
    }

    if (_passCtrl.text.isEmpty) {
      setState(() => _passError = isTe ? 'పాస్‌వర్డ్ అవసరం' : 'Password is required');
      isValid = false;
    }

    return isValid;
  }

  void _submit() {
    if (!_validate()) return;
    
    ref
        .read(authProvider.notifier)
        .login(_emailCtrl.text.trim(), _passCtrl.text, _rememberMe);
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authProvider);
    final lang = ref.watch(languageProvider);
    final isTe = lang == 'te';

    ref.listen(authProvider, (_, next) {
      next.whenData((authState) {
        if (authState.status == AuthStatus.authenticated) {
          if (context.mounted) {
            context.go('/dashboard');
          }
        }
      });
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = authAsync.value;

    if (authAsync.isLoading && authState == null) {
      return const Scaffold(body: Center(child: LoadingSpinner.fullScreen(message: 'Loading...')));
    }

    if (authAsync.hasError && authState == null) {
      return Scaffold(body: Center(child: Text(authAsync.error.toString())));
    }

    final effectiveState = authState ?? const AuthState(status: AuthStatus.unauthenticated);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      body: Stack(
        children: [
            // Top Pastel Green Banner
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.42,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark 
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [const Color(0xFFE0F2F1), const Color(0xFFB2DFDB)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              'assets/images/iacls-logo.png',
                              height: 75, // Impactful hero logo
                              fit: BoxFit.contain,
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => ref.read(languageProvider.notifier).setLanguage(isTe ? 'en' : 'te'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
                                    ),
                                    child: Text(
                                      isTe ? 'English' : 'తెలుగు',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.tealDark,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _buildThemeToggle(),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Hero Illustration
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        height: 180,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Image.asset(
                            'assets/images/loginacls.png',
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),

            // Form Content
            Positioned.fill(
              top: MediaQuery.of(context).size.height * 0.38,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isTe ? 'మళ్ళీ స్వాగతం 👋' : 'Welcome Back 👋',
                              style: GoogleFonts.inter(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : AppColors.teal,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildForm(effectiveState, isTe, isDark),
                            const SizedBox(height: 12),
                            
                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: effectiveState.status == AuthStatus.loading || authAsync.isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.teal,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  elevation: 4,
                                ),
                                child: (effectiveState.status == AuthStatus.loading || authAsync.isLoading)
                                  ? const LoadingSpinner.compact(message: '')
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(isTe ? 'లాగిన్' : 'Login', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                                        const SizedBox(width: 12),
                                        const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                                      ],
                                    ),
                              ),
                            ),

                            const SizedBox(height: 20),
                            Center(
                              child: GestureDetector(
                                onTap: () => context.push('/signup'),
                                child: Text.rich(
                                  TextSpan(
                                    text: isTe ? 'ఖాతా లేదా? ' : "Don't have an account? ",
                                    style: GoogleFonts.inter(
                                      color: AppColors.muted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: isTe ? 'సైన్ అప్' : 'Sign Up',
                                        style: const TextStyle(color: AppColors.teal, fontWeight: FontWeight.w900),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: _buildFooter(isTe),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle() {
    return GestureDetector(
      onTap: () => ref.read(themeModeProvider.notifier).toggle(),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Theme.of(context).brightness == Brightness.dark ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
          color: AppColors.tealDark,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildForm(AuthState state, bool isTe, bool isDark) {
    return Column(
      children: [
        _buildInput(
          controller: _emailCtrl,
          hint: 'Email',
          icon: Icons.person_outline_rounded,
          isDark: isDark,
          keyboardType: TextInputType.emailAddress,
          action: TextInputAction.next,
          errorText: _emailError,
          onChanged: (v) {
            final isTe = ref.read(languageProvider) == 'te';
            if (v.isEmpty) {
              setState(() => _emailError = isTe ? 'ఇమెయిల్ అవసరం' : 'Email is required');
            } else if (!v.contains('@')) {
              setState(() => _emailError = isTe ? 'చెల్లుబాటు అయ్యే ఇమెయిల్ నమోదు చేయండి' : 'Enter a valid email');
            } else {
              setState(() => _emailError = null);
            }
          },
        ),
        const SizedBox(height: 16),
        _buildInput(
          controller: _passCtrl,
          hint: 'Password',
          icon: Icons.lock_outline_rounded,
          isDark: isDark,
          isPassword: true,
          obscure: _obscure,
          onToggle: () => setState(() => _obscure = !_obscure),
          action: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          errorText: _passError,
          onChanged: (v) {
            final isTe = ref.read(languageProvider) == 'te';
            if (v.isEmpty) {
              setState(() => _passError = isTe ? 'పాస్‌వర్డ్ అవసరం' : 'Password is required');
            } else {
              setState(() => _passError = null);
            }
          },
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: _rememberMe,
                    onChanged: (v) => setState(() => _rememberMe = v ?? false),
                    activeColor: AppColors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 8),
                Text(isTe ? 'నన్ను గుర్తుంచుకోండి' : 'Remember me', 
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.muted, fontSize: 13)),
              ],
            ),
            Text(isTe ? 'పాస్‌వర్డ్ మరిచిపోయారా?' : 'Forgot password?', 
              style: const TextStyle(color: AppColors.teal, fontWeight: FontWeight.w800, fontSize: 13)),
          ],
        ),
        if (state.status == AuthStatus.error)
          Container(
            margin: const EdgeInsets.only(top: 24),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.errorMessage ?? (isTe ? 'చెల్లుబాటు కాని ఆధారాలు' : 'Invalid credentials'),
                    style: GoogleFonts.inter(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
    TextInputType? keyboardType,
    TextInputAction? action,
    ValueChanged<String>? onSubmitted,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Focus(
          onFocusChange: (hasFocus) => setState(() {}),
          child: Builder(
            builder: (context) {
              final hasFocus = Focus.of(context).hasFocus;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: errorText != null
                              ? Colors.red
                              : hasFocus 
                                  ? AppColors.teal 
                                  : (isDark ? Colors.white24 : const Color(0xFFE2E8F0)),
                          width: 2,
                        ),
                      ),
                    ),
                    child: TextField(
                      controller: controller,
                      obscureText: obscure,
                      keyboardType: keyboardType,
                      textInputAction: action,
                      onSubmitted: onSubmitted,
                      onChanged: onChanged,
                      cursorColor: AppColors.teal,
                      style: GoogleFonts.inter(
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        filled: false,
                        hintText: hint,
                        hintStyle: GoogleFonts.inter(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Icon(
                            icon, 
                            color: errorText != null 
                                ? Colors.red 
                                : (hasFocus ? AppColors.teal : AppColors.muted), 
                            size: 22
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                        suffixIcon: isPassword && onToggle != null 
                          ? IconButton(
                              icon: Icon(
                                obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: hasFocus ? AppColors.teal : AppColors.muted,
                                size: 20,
                              ),
                              onPressed: onToggle,
                            )
                          : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  if (errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        errorText,
                        style: GoogleFonts.inter(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              );
            }
          ),
        );
      }
    );
  }

  Widget _buildFooter(bool isTe) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isTe ? '© 2026 iACLS ప్రోటోకాల్' : '© 2026 iACLS Protocol',
                style: GoogleFonts.inter(
                  color: AppColors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                height: 12,
                width: 1,
                color: Colors.grey.withValues(alpha: 0.2),
              ),
              Row(
                children: [
                  Text(
                    isTe ? 'పవర్డ్ బై ' : 'Powered by ',
                    style: GoogleFonts.inter(
                      color: AppColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Image.asset('assets/images/bavya-logo.png', height: 14),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

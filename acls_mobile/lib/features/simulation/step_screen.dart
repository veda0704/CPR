import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/theme_provider.dart';

import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/api/api_client.dart';
import '../../core/widgets/animated_ecg.dart';
import '../../core/widgets/loading_spinner.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/step_model.dart';
import '../settings/language_provider.dart';
import '../auth/auth_provider.dart';
import '../../core/storage/local_storage.dart';
import 'step_provider.dart';
import 'completion_screen.dart';
import 'scene_timer_provider.dart';

class StepScreen extends ConsumerStatefulWidget {
  final String stepId;
  const StepScreen({super.key, required this.stepId});

  @override
  ConsumerState<StepScreen> createState() => _StepScreenState();
}

class _StepScreenState extends ConsumerState<StepScreen> {
  VideoPlayerController? _videoController;
  bool _videoReady = false;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timerCtrl = ref.read(sceneTimerControllerProvider);
      // If first step, reset the timer
      if (widget.stepId.endsWith('_start') || widget.stepId == '1' || widget.stepId == 'adult_choking_step1') {
        (timerCtrl['reset'] as Function)();
      }
      (timerCtrl['start'] as Function)();
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _initVideo(String url) async {
    if (_isInit) return;
    String videoUrl = url;
    if (url.startsWith('/static/')) {
      final path = url.replaceFirst('/static/', '');
      videoUrl = '${ApiClient.baseUrl}acls/stream-video/$path';
    } else if (!url.startsWith('http')) {
      final base = ApiClient.baseUrl.split('/api/').first;
      final path = url.startsWith('/') ? url : '/$url';
      videoUrl = '$base$path';
    }
    final fullUrl = videoUrl;
    if (_videoController?.dataSource == fullUrl) return;
    _isInit = true;
    _videoReady = false;
    if (mounted) setState(() {});
    try {
      if (_videoController != null) {
        await _videoController!.dispose();
        _videoController = null;
      }
      VideoPlayerController ctrl = VideoPlayerController.networkUrl(Uri.parse(fullUrl));
      await ctrl.initialize();
      ctrl.setLooping(true);
      if (mounted) {
        setState(() {
          _videoController = ctrl;
          _videoReady = true;
          _videoController!.play();
        });
      }
    } catch (e) {
      debugPrint('🎬 Video Error: $e');
    } finally {
      _isInit = false;
    }
  }

  String _getModuleIdFromStep(String stepId) {
    final normalId = stepId.toLowerCase();
    if (normalId.startsWith('ecg_rhythms')) return 'ecg_rhythms';
    if (normalId.startsWith('adv_airway')) return 'adv_airway';
    if (normalId.startsWith('cardiac_alg')) return 'cardiac_alg';
    if (normalId.startsWith('scene_safety')) return 'scene_safety';
    if (normalId.startsWith('snake_bite')) return 'snake_bite';
    if (normalId == '1') return 'acls';
    if (normalId.startsWith('abcde')) return 'abcde';
    if (normalId.startsWith('bls')) return 'bls';
    if (normalId.startsWith('choking') ||
        normalId.startsWith('adult_choking') ||
        normalId.startsWith('infant_choking')) {
      return 'choking';
    }
    if (normalId.startsWith('airway')) return 'airway';
    if (normalId.startsWith('trauma')) return 'trauma';
    if (normalId.startsWith('poisoning')) return 'poisoning';
    if (normalId.startsWith('stroke')) return 'stroke';
    if (normalId.startsWith('disaster')) return 'disaster';
    if (normalId.startsWith('delivery')) return 'delivery';
    if (normalId.startsWith('ecg')) return 'ecg_rhythms';
    if (normalId.startsWith('rhythms')) return 'ecg_rhythms';
    if (normalId.startsWith('h5t5') ||
        normalId.startsWith('h1_') ||
        normalId.startsWith('h2_') ||
        normalId.startsWith('h3_') ||
        normalId.startsWith('h4_') ||
        normalId.startsWith('h5_') ||
        normalId.startsWith('t1_') ||
        normalId.startsWith('t2_') ||
        normalId.startsWith('t3_') ||
        normalId.startsWith('t4_') ||
        normalId.startsWith('t5_')) {
      return 'h5t5';
    }
    return '';
  }

  void _trackStepProgress(StepModel step) {
    final authState = ref.read(authProvider).value;
    final email = authState?.email ?? '';
    final moduleId = _getModuleIdFromStep(step.id.isNotEmpty ? step.id : widget.stepId);
    if (email.isEmpty || moduleId.isEmpty) return;

    final status = LocalStorage.getModuleStatus(email, moduleId);
    if (status != 'completed') {
      LocalStorage.setModuleStatus(email, moduleId, 'in_progress');
    }

    if (step.totalSteps > 0) {
      final progress = (step.currentStep / step.totalSteps) * 100;
      LocalStorage.setModuleProgress(email, moduleId, progress);
    }
  }

  void _handleChoice(BuildContext context,
      {String? next, ChoiceModel? choice}) {
    final target = next ?? choice?.next ?? 'dashboard';
    final isExit = choice?.isExit ?? false;
    final label = (choice?.label ?? '').toLowerCase();

    // 1. If the choice is explicitly a "Back" button, just pop
    if (label.contains('back') && label != 'back to dashboard') {
      context.pop();
      return;
    }

    if (target == 'dashboard') {
      final authState = ref.read(authProvider).value;
      final email = authState?.email ?? '';
      final moduleId = _getModuleIdFromStep(widget.stepId);

      // 2. If it's a legitimate completion (not just a BACK button), mark as complete
      if (moduleId.isNotEmpty && !label.contains('back')) {
        LocalStorage.setModuleStatus(email, moduleId, 'completed');
      }

      // 3. If it's an explicit exit (like "Home" or "Exit"), go to dashboard
      if (isExit || label.contains('exit') || label == 'back to dashboard') {
        context.go('/dashboard');
        return;
      }
      // 4. Otherwise, it's a completion action
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const CompletionScreen()));
    } else {
      // Check if we are transitioning to a new module (Continue to Next feature)
      final authState = ref.read(authProvider).value;
      final email = authState?.email ?? '';
      final currentModuleId = _getModuleIdFromStep(widget.stepId);
      final targetModuleId = _getModuleIdFromStep(target);
      
      // If the target is a different module (and we aren't just going 'back'), mark the current one as complete
      if (currentModuleId.isNotEmpty && targetModuleId.isNotEmpty && currentModuleId != targetModuleId && !label.contains('back')) {
        LocalStorage.setModuleStatus(email, currentModuleId, 'completed');
      } else if (label.contains('continue') && !label.contains('back') && currentModuleId.isNotEmpty) {
        // Fallback for cases where targetModuleId mapping isn't fully defined yet but it's clearly a 'continue' action
        LocalStorage.setModuleStatus(email, currentModuleId, 'completed');
      }

      context.push('/acls/$target');
    }
  }

  @override
  Widget build(BuildContext context) {
    final stepAsync = ref.watch(stepProvider(widget.stepId));
    final lang = ref.watch(languageProvider);
    final isTe = lang == 'te';

    return stepAsync.when(
      loading: () => Scaffold(
          body: Center(
              child: LoadingSpinner.fullScreen(message: isTe ? 'లోడ్ అవుతోంది...' : 'Loading...'))),
      error: (e, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 48, color: AppColors.muted),
              const SizedBox(height: 12),
              Text(
                  isTe
                      ? 'కనెక్షన్ లోపం (సర్వర్‌ని తనిఖీ చేయండి)'
                      : 'Connection error - Verify Server',
                  style: GoogleFonts.inter(color: AppColors.muted)),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: () => ref.invalidate(stepProvider(widget.stepId)),
                  child: Text(isTe ? 'మళ్ళీ ప్రయత్నించండి' : 'Retry')),
            ],
          ),
        ),
      ),
      data: (data) {
        final step = StepModel.fromJson(data);
        WidgetsBinding.instance.addPostFrameCallback((_) => _trackStepProgress(step));
        if (step.video != null && step.video!.endsWith('.mp4')) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_videoController == null ||
                !_videoController!.dataSource.contains(step.video!)) {
              _initVideo(step.video!);
            }
          });
        }
        return Scaffold(
          body: AnimatedECGBackground(
            animate: step.video == null || !step.video!.endsWith('.mp4'),
            child: Container(
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
                    : const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFF8FAFC),
                          Color(0xFFF1F5F9),
                        ],
                      ),
              ),
              child: Stack(
                children: [
                  SafeArea(
                    child: Column(
                      children: [
                        _StepHeader(
                          title: step.title, 
                          lang: lang, 
                          stepId: widget.stepId,
                          timeLimit: step.timeLimit,
                          onTimeout: () => _handleChoice(context, next: step.timeOutNext ?? 'dashboard'),
                        ),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(20, 80, 20, 16), // Increased top padding for floating timer
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          _QuestionCard(
                                              question: step.question,
                                              audioUrl: step.audioUrl),
                                          const SizedBox(height: 24),
                                          if (step.interactiveComponent == 'patient_type_selector' ||
                                              step.interactiveComponent == 'choice_cards')
                                            _buildMedia(step, isTe)
                                          else
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).brightness == Brightness.dark 
                                                  ? const Color(0xFF1E293B) 
                                                  : Colors.white,
                                                borderRadius: BorderRadius.circular(24),
                                                border: Border.all(
                                                  color: Theme.of(context).brightness == Brightness.dark 
                                                    ? Colors.white.withValues(alpha: 0.05) 
                                                    : Colors.black.withValues(alpha: 0.05),
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 0.12),
                                                    blurRadius: 24,
                                                    offset: const Offset(0, 8),
                                                  )
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(24),
                                                child: AspectRatio(
                                                    aspectRatio: 16 / 9,
                                                    child: _buildMedia(step, isTe)),
                                              ),
                                            ),
                                          const SizedBox(height: 24),
                                          ...step.choices
                                              .where((c) {
                                                if (widget.stepId == 'rhythms_start' && c.next == 'dashboard') return true;
                                                if (widget.stepId.contains('_start') && c.next == 'dashboard') return false;
                                                return true;
                                              })
                                              .map((choice) {
                                                return Padding(
                                                    padding: const EdgeInsets.only(bottom: 12),
                                                    child: _ChoiceButton(
                                                        choice: choice,
                                                        onTap: () => _handleChoice(context,
                                                            choice: choice)));
                                              }),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                    ],
                                  ),
                                ),
                              );
                            }
                          ),
                        ),
                        _PinnedFooter(isTe: isTe),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 165, // Definitively below the navbar safe area
                    right: 20, 
                    child: _FloatingTimer(sceneTime: ref.watch(sceneTimeProvider)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMedia(StepModel step, bool isTe) {
    if (step.interactiveComponent == 'ecg_monitor') {
      return _EcgPlaceholder(rhythms: step.interactiveProps?['rhythms']);
    } else if (step.interactiveComponent == 'patient_type_selector' ||
        step.interactiveComponent == 'choice_cards') {
      return _PatientSelector(
          options: step.interactiveProps?['options'] ?? [],
          isTe: isTe,
          onSelect: (next) => _handleChoice(context, next: next));
    } else if (step.video != null && step.video!.endsWith('.mp4')) {
      return _VideoWidget(
        controller: _videoController,
        ready: _videoReady,
        onRetry: () => _initVideo(step.video!),
      );
    } else if (step.video != null) {
      return _ImageWidget(url: step.video!);
    } else {
      return Container(color: Colors.black12);
    }
  }
}

class _PatientSelector extends StatelessWidget {
  final List<dynamic> options;
  final Function(String) onSelect;
  final bool isTe;
  const _PatientSelector(
      {required this.options, required this.onSelect, required this.isTe});


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 768;
    
    if (isTablet) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: options.map((opt) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _buildLargeCard(context, opt, isDark),
          ),
        )).toList(),
      );
    }

    return Column(
      children: options.map((opt) => _buildLargeCard(context, opt, isDark)).toList(),
    );
  }

  Widget _buildLargeCard(BuildContext context, dynamic opt, bool isDark) {
    return Container(
      width: double.infinity,
      height: 380, // Immersive Large Cards as requested
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 36,
            offset: const Offset(0, 16),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            _ImageWidget(url: opt['image']),
            
            // Premium Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          opt['label'].toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            height: 1.1
                          ),
                        ),
                      ),
                      if (opt['badge'] != null)
                        Icon(
                          opt['badge'] == 'check' ? Icons.check_circle_rounded : Icons.warning_rounded,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 26,
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    opt['description'],
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 28),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () => onSelect(opt['next']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                      ),
                      child: Text(
                        "SELECT ${opt['label']}".toUpperCase(),
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w900, 
                          fontSize: 14,
                          letterSpacing: 1.0
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionCard extends ConsumerStatefulWidget {
  final String question;
  final String? audioUrl;
  const _QuestionCard({required this.question, this.audioUrl});
  @override
  ConsumerState<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends ConsumerState<_QuestionCard>
    with WidgetsBindingObserver {
  bool _isPlaying = false;
  AudioPlayer? _audioPlayer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioPlayer = AudioPlayer();
    _audioPlayer!.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_isPlaying) {
        _audioPlayer?.stop();
        if (mounted) setState(() => _isPlaying = false);
      }
    }
  }

  void _speak() async {
    if (_isPlaying) {
      await _audioPlayer?.stop();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }

    if (widget.audioUrl == null) return;

    setState(() => _isPlaying = true);
    try {
      final base = ApiClient.baseUrl.split('/api/').first;
      final path = widget.audioUrl!.startsWith('/') ? widget.audioUrl! : '/${widget.audioUrl}';
      final fullUrl = widget.audioUrl!.startsWith('http')
          ? widget.audioUrl!
          : '$base$path';

      _audioPlayer ??= AudioPlayer();
      await _audioPlayer!.setPlayerMode(PlayerMode.lowLatency);
      await _audioPlayer!.setVolume(1.0);
      await _audioPlayer!.play(UrlSource(fullUrl));
    } catch (e) {
      debugPrint('❌ Audio Error: $e');
      if (mounted) {
        setState(() => _isPlaying = false);
        final base = ApiClient.baseUrl.split('/api/').first;
        final path = widget.audioUrl!.startsWith('/') ? widget.audioUrl! : '/${widget.audioUrl}';
        final fullUrl = widget.audioUrl!.startsWith('http')
            ? widget.audioUrl!
            : '$base$path';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: InkWell(
              onTap: () => debugPrint('URL: $fullUrl'),
              child: Text('Playback Error. URL: $fullUrl'),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
                label: 'Retry', textColor: Colors.white, onPressed: _speak),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFEEEEEE),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.question,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.slate,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _speak();
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.eliteTeal.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
                    color: AppColors.eliteTeal,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepHeader extends ConsumerWidget {
  final String title;
  final String lang;
  final String stepId;
  final int? timeLimit;
  final Function() onTimeout;

  const _StepHeader({
    required this.title, 
    required this.lang, 
    required this.stepId, 
    this.timeLimit,
    required this.onTimeout
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);
    final isTe = lang == 'te';
    final authState = ref.watch(authProvider).value;
    final userName = authState?.userName ?? 'User';


    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Container(
        height: 85,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFF004D39),
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
              // Content Row - Centered Vertically
              Align(
                alignment: const Alignment(0, -0.1), // Slightly above center to look more balanced
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      // Branded Logo
                      Padding(
                        padding: const EdgeInsets.only(left: 4), // Shifted left like in Dashboard
                        child: Image.asset(
                          'assets/images/iacls-logo.png',
                          height: 62, // Increased size for high-fidelity impact
                          color: Colors.white,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 14), // Balanced spacing

                      // Floating Title Pill
                      Expanded(
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF059669), Color(0xFF10B981)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF059669).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Center(
                            child: Text(
                              title.toUpperCase(),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 8),

                      // Step Timeout Timer
                      if (timeLimit != null) ...[
                        _NavbarTimer(seconds: timeLimit!, onTimeout: onTimeout),
                        const SizedBox(width: 4),
                      ],
                      
                      const SizedBox(width: 4),
                      _buildMenuArea(ref, isDark, isTe, userName),
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
    );
  }

  Widget _buildMenuArea(WidgetRef ref, bool isDark, bool isTe, String userName) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert_rounded,
        color: Colors.white,
        size: 28,
      ),
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (value) {
        if (value == 'dashboard') {
          GoRouter.of(ref.context).go('/dashboard');
        } else if (value == 'toggle_theme') {
          ref.read(themeModeProvider.notifier).toggle();
        } else if (value == 'toggle_lang') {
          ref.read(languageProvider.notifier).setLanguage(isTe ? 'en' : 'te');
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'dashboard',
          child: Row(
            children: [
              const Icon(Icons.home_rounded, color: AppColors.skyBlue, size: 20),
              const SizedBox(width: 12),
              Text(isTe ? 'హోమ్' : 'Home', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'toggle_lang',
          child: Row(
            children: [
              const Icon(Icons.translate_rounded, color: AppColors.skyBlue, size: 20),
              const SizedBox(width: 12),
              Text(isTe ? 'English' : 'తెలుగు', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'toggle_theme',
          child: Row(
            children: [
              Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: AppColors.skyBlue, size: 20),
              const SizedBox(width: 12),
              Text(isDark ? (isTe ? 'లైట్ మోడ్' : 'Light Mode') : (isTe ? 'డార్క్ మోడ్' : 'Dark Mode'), 
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}


class _NavbarTimer extends StatefulWidget {
  final int seconds;
  final VoidCallback onTimeout;
  const _NavbarTimer({required this.seconds, required this.onTimeout});

  @override
  State<_NavbarTimer> createState() => _NavbarTimerState();
}

class _NavbarTimerState extends State<_NavbarTimer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.seconds),
    );
    _controller.reverse(from: 1.0);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        widget.onTimeout();
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final remainingSeconds = (widget.seconds * _controller.value).ceil();
        final minutes = (remainingSeconds / 60).floor();
        final seconds = remainingSeconds % 60;
        final timeStr = "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
        
        final isLowTime = remainingSeconds <= 5;
        final color = isLowTime ? Colors.redAccent : Colors.white;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isLowTime 
                ? Colors.red.withValues(alpha: 0.2) 
                : Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isLowTime ? Colors.redAccent.withValues(alpha: 0.5) : Colors.white24,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 1.0, end: isLowTime ? 1.2 : 1.0),
                duration: const Duration(milliseconds: 500),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Icon(Icons.timer_outlined, color: color, size: 16),
                  );
                },
              ),
              const SizedBox(width: 6),
              Text(
                timeStr,
                style: GoogleFonts.inter(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VideoWidget extends StatefulWidget {
  final VideoPlayerController? controller;
  final bool ready;
  final VoidCallback? onRetry;
  const _VideoWidget({this.controller, required this.ready, this.onRetry});

  @override
  State<_VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<_VideoWidget> {
  bool _showControls = true;

  @override
  Widget build(BuildContext context) {
    if (widget.controller?.value.hasError ?? false) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.video_camera_back_outlined,
                  color: Colors.white24, size: 48),
              const SizedBox(height: 12),
              const Text('Video unavailable. Please try again.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: widget.onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.skyBlue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child:
                    const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: widget.ready && widget.controller != null
          ? GestureDetector(
              onTap: () => setState(() => _showControls = !_showControls),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: widget.controller!.value.size.width,
                      height: widget.controller!.value.size.height,
                      child: VideoPlayer(widget.controller!),
                    ),
                  ),
                  if (_showControls)
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white24, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  setState(() {
                                    widget.controller!.value.isPlaying
                                        ? widget.controller!.pause()
                                        : widget.controller!.play();
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Icon(
                                    widget.controller!.value.isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 2),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => widget.controller!
                                    .seekTo(Duration.zero)
                                    .then((_) => widget.controller!.play()),
                                child: const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.replay_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            )
          : Container(
              color: Colors.black,
              child: const Center(
                  child: LoadingSpinner.compact()),
            ),
    );
  }
}

class _ImageWidget extends StatelessWidget {
  final String url;
  const _ImageWidget({required this.url});

  @override
  Widget build(BuildContext context) {
    final base = ApiClient.baseUrl.split('/api/').first;
    final path = url.startsWith('/') ? url : '/$url';
    final fullUrl = url.startsWith('http') ? url : '$base$path';

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        fullUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, __, ___) => Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.broken_image_rounded, color: Colors.white24, size: 48),
                const SizedBox(height: 12),
                const Text('Image unavailable', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Force a rebuild to retry loading
                    (context as Element).markNeedsBuild();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.skyBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Retry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EcgPlaceholder extends StatefulWidget {
  final List<dynamic>? rhythms;
  const _EcgPlaceholder({this.rhythms});
  @override
  State<_EcgPlaceholder> createState() => _EcgPlaceholderState();
}

class _EcgPlaceholderState extends State<_EcgPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.black,
        child: Stack(children: [
          AnimatedBuilder(
              animation: _controller,
              builder: (c, _) => CustomPaint(
                  painter: _EcgPainter(progress: _controller.value),
                  size: Size.infinite)),
          Align(
              alignment: Alignment.topRight,
              child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                      (widget.rhythms ?? ['NSR']).join(' · ').toUpperCase(),
                      style: const TextStyle(
                          color: Color(0xFF00FF7F),
                          fontSize: 12,
                          fontWeight: FontWeight.w900)))),
        ]));
  }
}

class _EcgPainter extends CustomPainter {
  final double progress;
  _EcgPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FF7F)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final path = Path();
    double x = 0;
    double step = 80.0;
    path.moveTo(0, size.height * 0.5);
    while (x < size.width + step) {
      double cx = x - (progress * step);
      path.lineTo(cx + 20, size.height * 0.5);
      path.lineTo(cx + 24, size.height * 0.2);
      path.lineTo(cx + 28, size.height * 0.8);
      path.lineTo(cx + 32, size.height * 0.1);
      path.lineTo(cx + 38, size.height * 0.75);
      path.lineTo(cx + 42, size.height * 0.5);
      path.lineTo(cx + step, size.height * 0.5);
      x += step;
    }
    canvas.clipRect(Offset.zero & size);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _EcgPainter old) => old.progress != progress;
}

class _StepTimer extends StatefulWidget {
  final int seconds;
  final VoidCallback onTimeout;
  final bool isTe;
  const _StepTimer(
      {required this.seconds, required this.onTimeout, required this.isTe});
  @override
  State<_StepTimer> createState() => _StepTimerState();
}

class _StepTimerState extends State<_StepTimer> with TickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: Duration(seconds: widget.seconds))
      ..reverse(from: 1.0)
      ..addStatusListener((s) {
        if (s == AnimationStatus.dismissed) widget.onTimeout();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (c, _) {
          final rem = (widget.seconds * _controller.value).ceil();
          final color = rem <= 3 ? AppColors.red : AppColors.orange;
          return Column(children: [
            Stack(alignment: Alignment.center, children: [
              SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                      value: _controller.value,
                      strokeWidth: 8,
                      backgroundColor: color.withValues(alpha: 0.1),
                      color: color)),
              Text('$rem',
                  style: GoogleFonts.inter(
                      fontSize: 32, fontWeight: FontWeight.w900, color: color)),
            ]),
            const SizedBox(height: 8),
            Text(widget.isTe ? 'ఇప్పుడే నిర్ణయించుకోండి!' : 'DECIDE NOW!',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 2)),
          ]);
        });
  }
}

class _ChoiceButton extends StatelessWidget {
  final dynamic choice;
  final VoidCallback onTap;

  const _ChoiceButton({required this.choice, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSecondary = choice.color == 'secondary';
    
    final color = isSecondary 
        ? (isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.fromLabel(choice.color))
        : AppColors.fromLabel(choice.color);
        
    final textColor = isSecondary 
        ? (isDark ? Colors.white : AppColors.slate) 
        : Colors.white;

    return Opacity(
      opacity: 1.0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSecondary ? [] : [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isSecondary 
              ? BorderSide(
                  color: isDark 
                    ? Colors.white.withValues(alpha: 0.1) 
                    : const Color(0xFFE5E7EB), 
                  width: 1)
              : BorderSide.none,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            child: Container(
              height: 56,
              alignment: Alignment.center,
              child: Text(
                choice.label.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: 0.8,
                  shadows: isSecondary ? [] : [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PinnedFooter extends StatelessWidget {
  final bool isTe;
  const _PinnedFooter({required this.isTe});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1), 
            width: 1
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '© 2026 | ${isTe ? 'పవర్డ్ బై ' : 'Powered by '}',
              style: GoogleFonts.inter(
                color: isDark ? Colors.white70 : AppColors.slate,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            Image.asset(
              'assets/images/bavya-logo.png',
              height: 18,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingTimer extends StatefulWidget {
  final int sceneTime;
  const _FloatingTimer({required this.sceneTime});

  @override
  State<_FloatingTimer> createState() => _FloatingTimerState();
}

class _FloatingTimerState extends State<_FloatingTimer> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (widget.sceneTime / 60).floor();
    final seconds = widget.sceneTime % 60;
    final isUrgent = widget.sceneTime >= 120; // 2 minutes (CPR cycle)

    Widget timerPill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isUrgent 
            ? [const Color(0xFFEF4444), const Color(0xFFB91C1C)] // Urgent Red for CPR Cycle
            : [const Color(0xFF059669), const Color(0xFF065F46)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isUrgent ? Colors.red : Colors.black).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUrgent ? Icons.warning_amber_rounded : Icons.timer_outlined,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );

    if (isUrgent) {
      return AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: timerPill,
      );
    }

    return timerPill;
  }
}

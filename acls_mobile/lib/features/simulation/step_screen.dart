import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/api/api_client.dart';
import '../../core/widgets/animated_ecg.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/step_model.dart';
import '../../core/services/cache_service.dart';
import '../settings/language_provider.dart';
import 'step_provider.dart';
import 'completion_screen.dart';

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
      final base = ApiClient.baseUrl.replaceAll('/api/', '');
      videoUrl = '$base$url';
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
      VideoPlayerController ctrl;
      if (fullUrl.contains('stream-video')) {
        ctrl = VideoPlayerController.networkUrl(Uri.parse(fullUrl));
      } else {
        final file = await CacheService.fileCacheManager.getSingleFile(fullUrl);
        ctrl = VideoPlayerController.file(file);
      }
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

  void _handleChoice(BuildContext context,
      {String? next, ChoiceModel? choice}) {
    final target = next ?? choice?.next ?? 'dashboard';
    final isExit = choice?.isExit ?? false;

    if (target == 'dashboard') {
      if (isExit) {
        context.go('/dashboard');
        return;
      }
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const CompletionScreen()));
    } else {
      context.push('/acls/$target');
    }
  }

  @override
  Widget build(BuildContext context) {
    final stepAsync = ref.watch(stepProvider(widget.stepId));
    final lang = ref.watch(languageProvider);
    final isTe = lang == 'te';

    return stepAsync.when(
      loading: () => const Scaffold(
          body: Center(
              child: CircularProgressIndicator(color: AppColors.orange))),
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
                    : AppColors.bgGradient,
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    _StepHeader(title: step.title, lang: lang),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _QuestionCard(
                                question: step.question,
                                audioUrl: step.audioUrl),
                            const SizedBox(height: 24),
                            if (step.interactiveComponent ==
                                    'patient_type_selector' ||
                                step.interactiveComponent == 'choice_cards')
                              _buildMedia(step, isTe)
                            else
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.1),
                                          blurRadius: 16,
                                          offset: const Offset(0, 8))
                                    ]),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: _buildMedia(step, isTe)),
                                ),
                              ),
                            const SizedBox(height: 24),
                            ...step.choices.map((choice) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ChoiceButton(
                                    choice: choice,
                                    onTap: () => _handleChoice(context,
                                        choice: choice)))),
                            if (step.timeLimit != null)
                              const SizedBox(height: 24),
                            if (step.timeLimit != null)
                              _StepTimer(
                                  seconds: step.timeLimit!,
                                  isTe: isTe,
                                  onTimeout: () => _handleChoice(context,
                                      next: step.timeOutNext ?? 'dashboard')),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
      return _VideoWidget(controller: _videoController, ready: _videoReady);
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
            child: Text(
              isTe ? "రోగి రకాన్ని ఎంచుకోండి:" : "Select patient type:",
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: options.map((opt) {
                final isOrange = opt['theme'] == 'orange';
                final color = isOrange
                    ? const Color(0xFFEA580C)
                    : const Color(0xFFEF4444);
                final bgColor = isOrange
                    ? const Color(0xFFFFF7ED)
                    : const Color(0xFFFEF2F2);

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: color.withValues(alpha: 0.2), width: 2),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        padding: const EdgeInsets.all(8),
                        child: ClipOval(child: _ImageWidget(url: opt['image'])),
                      ),
                      const SizedBox(height: 16),
                      Text(opt['label'],
                          style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: color)),
                      const SizedBox(height: 4),
                      Text(opt['description'],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.muted,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => onSelect(opt['next']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 0),
                          minimumSize: const Size(double.infinity, 44),
                        ),
                        child:
                            const Icon(Icons.arrow_forward_rounded, size: 20),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
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
      final fullUrl = widget.audioUrl!.startsWith('http')
          ? widget.audioUrl!
          : '$base${widget.audioUrl}';

      _audioPlayer ??= AudioPlayer();
      await _audioPlayer!.setPlayerMode(PlayerMode.lowLatency);
      await _audioPlayer!.setVolume(1.0);
      await _audioPlayer!.play(UrlSource(fullUrl));
    } catch (e) {
      debugPrint('❌ Audio Error: $e');
      if (mounted) {
        setState(() => _isPlaying = false);
        final base = ApiClient.baseUrl.split('/api/').first;
        final fullUrl = widget.audioUrl!.startsWith('http')
            ? widget.audioUrl!
            : '$base${widget.audioUrl}';

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
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Stack(alignment: Alignment.topRight, children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Text(widget.question,
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                    height: 1.4))),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            color: _isPlaying
                ? AppColors.orange.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.02),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _speak,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(
                  _isPlaying
                      ? Icons.volume_up_rounded
                      : Icons.volume_down_rounded,
                  color: _isPlaying ? AppColors.orange : AppColors.muted,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _StepHeader extends ConsumerWidget {
  final String title;
  final String lang;
  const _StepHeader({required this.title, required this.lang});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))),
      child: Row(children: [
        _IconBtn(
            icon: Icons.arrow_back_ios_new_rounded, onTap: () => context.pop()),
        const SizedBox(width: 8),
        _IconBtn(
            icon: Icons.home_rounded, onTap: () => context.go('/dashboard')),
        const SizedBox(width: 12),
        Expanded(
            child: Text(title,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text))),
        const SizedBox(width: 8),
        _LangPill(current: lang),
      ]),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEEEEEE))),
            child: Icon(icon, size: 20, color: AppColors.orange)));
  }
}

class _LangPill extends ConsumerWidget {
  final String current;
  const _LangPill({required this.current});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
        onTap: () => ref
            .read(languageProvider.notifier)
            .setLanguage(current == 'en' ? 'te' : 'en'),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(20)),
            child: Text(current == 'en' ? 'తెలుగు' : 'EN',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white))));
  }
}

class _VideoWidget extends StatefulWidget {
  final VideoPlayerController? controller;
  final bool ready;
  const _VideoWidget({this.controller, required this.ready});

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
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.video_camera_back_outlined,
                  color: Colors.white24, size: 48),
              SizedBox(height: 8),
              Text('Connection Error - Verify Server',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
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
                      left: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(8),
                              icon: Icon(
                                widget.controller!.value.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              onPressed: () {
                                setState(() {
                                  widget.controller!.value.isPlaying
                                      ? widget.controller!.pause()
                                      : widget.controller!.play();
                                });
                              },
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(8),
                              icon: const Icon(Icons.replay_rounded,
                                  color: Colors.white, size: 22),
                              onPressed: () => widget.controller!
                                  .seekTo(Duration.zero)
                                  .then((_) => widget.controller!.play()),
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
                  child: CircularProgressIndicator(color: AppColors.orange)),
            ),
    );
  }
}

class _ImageWidget extends StatelessWidget {
  final String url;
  const _ImageWidget({required this.url});
  @override
  Widget build(BuildContext context) {
    final base = ApiClient.baseUrl.replaceAll('/api/', '');
    final fullUrl = url.startsWith('http') ? url : '$base$url';
    return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(fullUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
                color: Colors.black12,
                child: const Icon(Icons.broken_image,
                    color: Colors.white24, size: 48))));
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
  final ChoiceModel choice;
  final VoidCallback onTap;
  const _ChoiceButton({required this.choice, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final color = AppColors.fromLabel(choice.color);
    return Material(
        color: color,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Container(
                height: 56,
                alignment: Alignment.center,
                child: Text(choice.label.toUpperCase(),
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)))));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/ambiences_model.dart';
import '../../../shared/theme/app_theme.dart';
import '../../journal/screens/reflection_screen.dart';
import '../providers/mini_play_provider.dart';
import '../providers/player_provider.dart';

class SessionPlayerScreen extends ConsumerStatefulWidget {
  final AmbienceModel ambience;
  const SessionPlayerScreen({super.key, required this.ambience});

  @override
  ConsumerState<SessionPlayerScreen> createState() =>
      _SessionPlayerScreenState();
}

class _SessionPlayerScreenState extends ConsumerState<SessionPlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;
  late Animation<double> _breathAnim;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _breathAnim = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    // Activate mini player so it shows when user navigates away
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(miniPlayerProvider.notifier)
          .activate(widget.ambience, isPlaying: true);
    });
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _showEndDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'End Session?',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
        content: const Text(
          'Your progress will be saved.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(playerProvider(widget.ambience).notifier)
                  .endSession();
              ref.read(miniPlayerProvider.notifier).clear();
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ReflectionScreen(ambience: widget.ambience),
                ),
              );
            },
            child: const Text('End',
                style: TextStyle(color: AppColors.accentLime)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider(widget.ambience));

    // Keep mini player in sync
    ref.listen(playerProvider(widget.ambience), (_, next) {
      ref
          .read(miniPlayerProvider.notifier)
          .updateProgress(next.progress, next.isPlaying);

      if (next.isFinished && mounted) {
        ref.read(miniPlayerProvider.notifier).clear();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ReflectionScreen(ambience: widget.ambience),
          ),
        );
      }
    });

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _Background(
            imagePath: widget.ambience.imagePath,
            breathAnim: _breathAnim,
          ),
          SafeArea(
            child: Column(
              children: [
                _TopBar(
                  title: widget.ambience.title,
                  onEnd: () => _showEndDialog(context),
                ),
                const Spacer(),
                _BreathingOrb(breathAnim: _breathAnim),
                const SizedBox(height: 16),
                Text(
                  widget.ambience.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.ambience.tag,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const Spacer(),
                _Controls(
                  player: player,
                  fmt: _fmt,
                  onToggle: () => ref
                      .read(playerProvider(widget.ambience).notifier)
                      .togglePlay(),
                  onSeek: (v) => ref
                      .read(playerProvider(widget.ambience).notifier)
                      .seek(v),
                ),
                const SizedBox(height: 52),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Background ──────────────────────────────────────────────────────────────

class _Background extends StatelessWidget {
  final String imagePath;
  final Animation<double> breathAnim;
  const _Background({required this.imagePath, required this.breathAnim});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A3A1A), Color(0xFF0D1A0D)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.45),
                Colors.black.withOpacity(0.75),
              ],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: breathAnim,
          builder: (_, __) => Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: breathAnim.value * 0.9,
                colors: [
                  AppColors.accentLime.withOpacity(0.06),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Top Bar ─────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onEnd;
  const _TopBar({required this.title, required this.onEnd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withOpacity(0.12), width: 0.5),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 14),
            ),
          ),
          const Text(
            'Now Playing',
            style: TextStyle(
                color: Colors.white70, fontSize: 13, letterSpacing: 0.5),
          ),
          GestureDetector(
            onTap: onEnd,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                border: Border.all(
                    color: Colors.white.withOpacity(0.15), width: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('End',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Breathing Orb ───────────────────────────────────────────────────────────

class _BreathingOrb extends StatelessWidget {
  final Animation<double> breathAnim;
  const _BreathingOrb({required this.breathAnim});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: breathAnim,
      builder: (_, __) => Transform.scale(
        scale: breathAnim.value,
        child: Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accentLime.withOpacity(0.08),
            border: Border.all(
                color: AppColors.accentLime.withOpacity(0.18), width: 1),
          ),
          child: Center(
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentLime.withOpacity(0.15),
                border: Border.all(
                    color: AppColors.accentLime.withOpacity(0.3), width: 0.5),
              ),
              child: Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentLime.withOpacity(0.35),
                  ),
                  child: const Icon(Icons.forest_rounded,
                      color: AppColors.bgDeep, size: 26),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Controls ────────────────────────────────────────────────────────────────

class _Controls extends StatelessWidget {
  final PlayerState player;
  final String Function(Duration) fmt;
  final VoidCallback onToggle;
  final ValueChanged<double> onSeek;

  const _Controls({
    required this.player,
    required this.fmt,
    required this.onToggle,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(fmt(player.elapsed),
                  style:
                      const TextStyle(color: Colors.white54, fontSize: 12)),
              Text(fmt(player.total),
                  style:
                      const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2.5,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 6),
              activeTrackColor: AppColors.accentLime,
              inactiveTrackColor: Colors.white24,
              thumbColor: AppColors.accentLime,
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(
              value: player.progress.clamp(0.0, 1.0),
              onChanged: onSeek,
            ),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentLime,
              ),
              child: Icon(
                player.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: AppColors.bgDeep,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../data/models/ambiences_model.dart';
import '../../../shared/theme/app_theme.dart';
import '../../player/screens/session_player_screen.dart';

class AmbienceDetailScreen extends StatelessWidget {
  final AmbienceModel ambience;

  const AmbienceDetailScreen({super.key, required this.ambience});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        children: [
          _HeroImage(imagePath: ambience.imagePath),
          _BackButton(),
          DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.55,
            maxChildSize: 0.92,
            builder: (_, controller) => _BottomSheet(
              ambience: ambience,
              scrollController: controller,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero Image ──────────────────────────────────────────────────────────────

class _HeroImage extends StatelessWidget {
  final String imagePath;
  const _HeroImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.55,
      child: Stack(
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
          // Bottom fade into sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.bgDeep.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Back Button ─────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withOpacity(0.12), width: 0.5),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 15),
          ),
        ),
      ),
    );
  }
}

// ─── Bottom Sheet ─────────────────────────────────────────────────────────────

class _BottomSheet extends StatelessWidget {
  final AmbienceModel ambience;
  final ScrollController scrollController;

  const _BottomSheet({
    required this.ambience,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgDeep,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 40),
        children: [
          _DragHandle(),
          const SizedBox(height: 22),
          _TagRow(tag: ambience.tag, duration: ambience.duration),
          const SizedBox(height: 12),
          Text(
            ambience.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            ambience.description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.65,
            ),
          ),
          const SizedBox(height: 28),
          _SensorySection(chips: ambience.sensoryChips),
          const SizedBox(height: 36),
          _StartSessionButton(ambience: ambience),
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _TagRow extends StatelessWidget {
  final String tag;
  final String duration;
  const _TagRow({required this.tag, required this.duration});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: tagBg(tag),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            tag,
            style: TextStyle(
              color: tagColor(tag),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Icon(Icons.access_time_rounded,
            color: AppColors.textMuted, size: 13),
        const SizedBox(width: 4),
        Text(
          duration,
          style: const TextStyle(
              color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}

class _SensorySection extends StatelessWidget {
  final List<String> chips;
  const _SensorySection({required this.chips});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SENSORY RECIPE',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              chips.map((chip) => _SensoryChip(label: chip)).toList(),
        ),
      ],
    );
  }
}

class _SensoryChip extends StatelessWidget {
  final String label;
  const _SensoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        border: Border.all(color: AppColors.border, width: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _StartSessionButton extends StatelessWidget {
  final AmbienceModel ambience;
  const _StartSessionButton({required this.ambience});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SessionPlayerScreen(ambience: ambience),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          color: AppColors.accentLime,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(
          child: Text(
            'Start Session',
            style: TextStyle(
              color: AppColors.bgDeep,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

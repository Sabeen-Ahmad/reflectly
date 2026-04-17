import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/ambiences_model.dart';
import '../../../data/models/reflection_model.dart';
import '../../../shared/theme/app_theme.dart';
import '../provider/journal_provider.dart';
import 'history_screen.dart';

const _moods = ['Calm', 'Grounded', 'Energized', 'Sleepy'];

class ReflectionScreen extends ConsumerStatefulWidget {
  final AmbienceModel ambience;
  const ReflectionScreen({super.key, required this.ambience});

  @override
  ConsumerState<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen> {
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _saving = true);

    final mood = ref.read(selectedMoodProvider);
    final reflection = ReflectionModel(
      id: const Uuid().v4(),
      ambienceId: widget.ambience.id,
      ambienceTitle: widget.ambience.title,
      mood: mood,
      journalText: text,
      createdAt: DateTime.now(),
    );

    // Use notifier.save() — triggers list reload automatically
    await ref.read(reflectionListProvider.notifier).save(reflection);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (_) => const HistoryScreen(showClose: true)),
        (route) => route.isFirst,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mood = ref.watch(selectedMoodProvider);

    return Scaffold(
      backgroundColor: JournalColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(ambienceTitle: widget.ambience.title),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      '"What is gently present\nwith you right now?"',
                      style: TextStyle(
                        color: JournalColors.textDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _JournalInput(controller: _controller),
                    const SizedBox(height: 28),
                    _MoodSelector(selectedMood: mood),
                    const SizedBox(height: 36),
                    _SaveButton(saving: _saving, onSave: _save),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Top Bar ─────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String ambienceTitle;
  const _TopBar({required this.ambienceTitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Reflect',
            style: TextStyle(
              color: JournalColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: JournalColors.bgChip,
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: JournalColors.border, width: 0.5),
            ),
            child: Text(
              '$ambienceTitle · just now',
              style: const TextStyle(
                  color: JournalColors.textMid, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Journal Input ───────────────────────────────────────────────────────────

class _JournalInput extends StatelessWidget {
  final TextEditingController controller;
  const _JournalInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: JournalColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: JournalColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: 8,
        style: const TextStyle(
          color: JournalColors.textDark,
          fontSize: 15,
          height: 1.7,
        ),
        decoration: const InputDecoration(
          hintText: 'Let thoughts arrive without judgment...',
          hintStyle: TextStyle(
              color: JournalColors.textLight, fontSize: 15),
          contentPadding: EdgeInsets.all(18),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

// ─── Mood Selector ───────────────────────────────────────────────────────────

class _MoodSelector extends ConsumerWidget {
  final String selectedMood;
  const _MoodSelector({required this.selectedMood});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HOW DO YOU FEEL',
          style: TextStyle(
            color: JournalColors.textLight,
            fontSize: 10,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _moods.map((mood) {
            final active = mood == selectedMood;
            return GestureDetector(
              onTap: () =>
                  ref.read(selectedMoodProvider.notifier).state = mood,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: active
                      ? JournalColors.accent
                      : JournalColors.bgCard,
                  border: Border.all(
                    color: active
                        ? JournalColors.accent
                        : JournalColors.border,
                    width: active ? 1 : 0.5,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: active
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                ),
                child: Text(
                  mood,
                  style: TextStyle(
                    color: active ? Colors.white : JournalColors.textMid,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Save Button ─────────────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  final bool saving;
  final VoidCallback onSave;
  const _SaveButton({required this.saving, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: saving ? null : onSave,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          color: saving
              ? JournalColors.accent.withOpacity(0.5)
              : JournalColors.accent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : const Text(
                  'Save reflection',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}

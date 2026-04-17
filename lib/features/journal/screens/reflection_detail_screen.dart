import 'package:flutter/material.dart';
import '../../../data/models/reflection_model.dart';
import '../../../shared/theme/app_theme.dart';

class ReflectionDetailScreen extends StatelessWidget {
  final ReflectionModel reflection;
  const ReflectionDetailScreen({super.key, required this.reflection});

  String _formatFull(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JournalColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onBack: () => Navigator.pop(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Ambience title
                    Text(
                      reflection.ambienceTitle,
                      style: const TextStyle(
                        color: JournalColors.textDark,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Date
                    Text(
                      _formatFull(reflection.createdAt),
                      style: const TextStyle(
                          color: JournalColors.textLight, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    // Mood badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: JournalColors.accentBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        reflection.mood,
                        style: const TextStyle(
                          color: JournalColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Divider
                    Container(
                      height: 0.5,
                      color: JournalColors.border,
                    ),
                    const SizedBox(height: 24),
                    // Journal text
                    Text(
                      reflection.journalText,
                      style: const TextStyle(
                        color: JournalColors.textDark,
                        fontSize: 16,
                        height: 1.85,
                        letterSpacing: 0.1,
                      ),
                    ),
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
  final VoidCallback onBack;
  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: JournalColors.bgChip,
                shape: BoxShape.circle,
                border: Border.all(
                    color: JournalColors.border, width: 0.5),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: JournalColors.textMid, size: 14),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Reflection',
            style: TextStyle(
              color: JournalColors.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

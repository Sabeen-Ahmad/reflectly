import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_theme.dart';
import '../provider/journal_provider.dart';
import '../../../data/models/reflection_model.dart';
import 'new_entry_screen.dart';
import 'reflection_detail_screen.dart';

class HistoryScreen extends ConsumerWidget {
  final bool showClose;
  const HistoryScreen({super.key, this.showClose = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reflections = ref.watch(reflectionListProvider);

    return Scaffold(
      backgroundColor: JournalColors.bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewEntryScreen()),
        ),
        backgroundColor: JournalColors.accent,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.edit_rounded, size: 18),
        label: const Text(
          'New Entry',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(showClose: showClose),
            Expanded(
              child: reflections.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: JournalColors.accent,
                    strokeWidth: 1.5,
                  ),
                ),
                error: (e, _) => Center(
                  child: Text('Error: $e',
                      style: const TextStyle(
                          color: JournalColors.textMid)),
                ),
                data: (list) => list.isEmpty
                    ? const _EmptyState()
                    : ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(16, 4, 16, 100),
                        itemCount: list.length,
                        itemBuilder: (_, i) => _ReflectionCard(
                          reflection: list[i],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReflectionDetailScreen(
                                  reflection: list[i]),
                            ),
                          ),
                        ),
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
  final bool showClose;
  const _TopBar({this.showClose = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Reflections',
            style: TextStyle(
              color: JournalColors.textDark,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          if (showClose)
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: JournalColors.bgChip,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: JournalColors.border, width: 0.5),
                ),
                child: const Icon(Icons.close_rounded,
                    color: JournalColors.textMid, size: 16),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Reflection Card ─────────────────────────────────────────────────────────

class _ReflectionCard extends StatelessWidget {
  final ReflectionModel reflection;
  final VoidCallback onTap;

  const _ReflectionCard({required this.reflection, required this.onTap});

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today, ${_time(dt)}';
    if (diff.inDays == 1) return 'Yesterday, ${_time(dt)}';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _time(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _preview(String text) {
    final first = text.split('\n').first;
    return first.length > 65 ? '${first.substring(0, 65)}...' : first;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: JournalColors.bgCard,
          border: Border.all(color: JournalColors.border, width: 0.5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    reflection.ambienceTitle,
                    style: const TextStyle(
                      color: JournalColors.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(reflection.createdAt),
                  style: const TextStyle(
                      color: JournalColors.textLight, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _MoodBadge(mood: reflection.mood),
            const SizedBox(height: 8),
            Text(
              _preview(reflection.journalText),
              style: const TextStyle(
                color: JournalColors.textMid,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Mood Badge ──────────────────────────────────────────────────────────────

class _MoodBadge extends StatelessWidget {
  final String mood;
  const _MoodBadge({required this.mood});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: JournalColors.accentBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        mood,
        style: const TextStyle(
          color: JournalColors.accent,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco_rounded, color: JournalColors.textLight, size: 44),
            SizedBox(height: 16),
            Text(
              'No reflections yet.\nStart a session to begin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: JournalColors.textMid,
                fontSize: 14,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

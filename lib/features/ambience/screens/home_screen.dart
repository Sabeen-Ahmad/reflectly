import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/ambience_card.dart';
import '../providers/ambience_provider.dart';
import '../../journal/screens/history_screen.dart';
import 'ambience_detail_screen.dart';

const _tabs = ['All', 'Focus', 'Calm', 'Sleep', 'Reset'];

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredAmbiencesProvider);
    final selectedTab = ref.watch(selectedTagProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(),
            Expanded(
              child: filtered.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.accentLime,
                    strokeWidth: 1.5,
                  ),
                ),
                error: (e, _) => Center(
                  child: Text('Error: $e',
                      style:
                          const TextStyle(color: AppColors.textMuted)),
                ),
                data: (list) => _Body(
                  allAmbiences: list,
                  selectedTab: selectedTab,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Top Bar ────────────────────────────────────────────────────────────────

class _TopBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, there ',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'What do you need today?',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.accentLime.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.accentLime,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Body ────────────────────────────────────────────────────────────────────

class _Body extends ConsumerWidget {
  final List<dynamic> allAmbiences;
  final String selectedTab;

  const _Body({required this.allAmbiences, required this.selectedTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Featured = first ambience
    final featured =
        allAmbiences.isNotEmpty ? allAmbiences.first : null;

    // Popular = rest
    final popular =
        allAmbiences.length > 1 ? allAmbiences.sublist(1) : allAmbiences;

    return CustomScrollView(
      slivers: [
        // Search bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _SearchBar(),
          ),
        ),

        // Tabs
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _TabRow(selectedTab: selectedTab),
          ),
        ),

        // Featured card
        if (featured != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _FeaturedCard(
                ambience: featured,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AmbienceDetailScreen(ambience: featured),
                  ),
                ),
              ),
            ),
          ),

        // Section header
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 28, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Popular sounds',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'See all',
                  style: TextStyle(
                    color: AppColors.accentLime,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Popular list
        if (popular.isEmpty)
          const SliverToBoxAdapter(child: _EmptyState())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => AmbienceCard(
                  ambience: popular[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AmbienceDetailScreen(ambience: popular[i]),
                    ),
                  ),
                ),
                childCount: popular.length,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Search Bar ──────────────────────────────────────────────────────────────

class _SearchBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      onChanged: (v) =>
          ref.read(searchQueryProvider.notifier).state = v,
      style: const TextStyle(
          color: AppColors.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        hintText: 'Search sounds...',
        hintStyle: const TextStyle(
            color: AppColors.textMuted, fontSize: 13),
        prefixIcon: const Icon(Icons.search_rounded,
            color: AppColors.textMuted, size: 18),
        filled: true,
        fillColor: AppColors.bgSurface,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
              color: AppColors.accentLime, width: 0.8),
        ),
      ),
    );
  }
}

// ─── Tab Row ─────────────────────────────────────────────────────────────────

class _TabRow extends ConsumerWidget {
  final String selectedTab;
  const _TabRow({required this.selectedTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final tab = _tabs[i];
          final active = tab == selectedTab;
          return GestureDetector(
            onTap: () =>
                ref.read(selectedTagProvider.notifier).state = tab,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.accentLime
                    : AppColors.bgSurface,
                border: Border.all(
                  color: active
                      ? AppColors.accentLime
                      : AppColors.border,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tab,
                style: TextStyle(
                  color: active
                      ? AppColors.bgDeep
                      : AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: active
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Featured Card ───────────────────────────────────────────────────────────

class _FeaturedCard extends StatelessWidget {
  final dynamic ambience;
  final VoidCallback onTap;

  const _FeaturedCard({required this.ambience, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.bgSurface,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.asset(
              ambience.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A3A1A), Color(0xFF0D1A0D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tag chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.music_note_rounded,
                            color: Colors.white70, size: 11),
                        const SizedBox(width: 4),
                        Text(
                          '${ambience.sensoryChips.length} sounds',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Title & subtitle
                  Text(
                    ambience.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ambience.tag,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Bottom row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded,
                              color: Colors.white60, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            ambience.duration,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      // Play button
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.accentLime,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: AppColors.bgDeep,
                          size: 22,
                        ),
                      ),
                    ],
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

// ─── Empty State ─────────────────────────────────────────────────────────────

class _EmptyState extends ConsumerWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.forest_rounded,
                color: AppColors.textMuted, size: 40),
            const SizedBox(height: 16),
            const Text(
              'No sounds found',
              style: TextStyle(
                  color: AppColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                ref.read(searchQueryProvider.notifier).state = '';
                ref.read(selectedTagProvider.notifier).state = 'All';
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: AppColors.border, width: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Clear filters',
                  style: TextStyle(
                      color: AppColors.accentLime, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

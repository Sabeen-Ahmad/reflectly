import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/ambiences_model.dart';

class MiniPlayerState {
  final AmbienceModel? ambience;
  final bool isPlaying;
  final double progress;

  const MiniPlayerState({
    this.ambience,
    this.isPlaying = false,
    this.progress = 0,
  });

  bool get isActive => ambience != null;

  MiniPlayerState copyWith({
    AmbienceModel? ambience,
    bool? isPlaying,
    double? progress,
    bool clearAmbience = false,
  }) {
    return MiniPlayerState(
      ambience: clearAmbience ? null : ambience ?? this.ambience,
      isPlaying: isPlaying ?? this.isPlaying,
      progress: progress ?? this.progress,
    );
  }
}

class MiniPlayerNotifier extends StateNotifier<MiniPlayerState> {
  MiniPlayerNotifier() : super(const MiniPlayerState());

  void activate(AmbienceModel ambience, {bool isPlaying = true}) {
    state = state.copyWith(ambience: ambience, isPlaying: isPlaying);
  }

  void updateProgress(double progress, bool isPlaying) {
    state = state.copyWith(progress: progress, isPlaying: isPlaying);
  }

  void clear() {
    state = const MiniPlayerState();
  }
}

final miniPlayerProvider =
StateNotifierProvider<MiniPlayerNotifier, MiniPlayerState>(
      (_) => MiniPlayerNotifier(),
);
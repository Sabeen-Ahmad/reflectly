import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../data/models/ambiences_model.dart';

class PlayerState {
  final bool isPlaying;
  final Duration elapsed;
  final Duration total;
  final bool isFinished;

  const PlayerState({
    this.isPlaying = false,
    this.elapsed = Duration.zero,
    this.total = Duration.zero,
    this.isFinished = false,
  });

  double get progress =>
      total.inSeconds == 0 ? 0 : elapsed.inSeconds / total.inSeconds;

  PlayerState copyWith({
    bool? isPlaying,
    Duration? elapsed,
    Duration? total,
    bool? isFinished,
  }) {
    return PlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      elapsed: elapsed ?? this.elapsed,
      total: total ?? this.total,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}

/// Parses a duration string like "3 min", "5 min", "3:30" into a Duration.
Duration _parseDuration(String raw) {
  final trimmed = raw.trim();

  // "X min" format
  final minMatch = RegExp(r'^(\d+)\s*min$').firstMatch(trimmed);
  if (minMatch != null) {
    return Duration(minutes: int.parse(minMatch.group(1)!));
  }

  // "M:SS" format
  final colonMatch = RegExp(r'^(\d+):(\d{2})$').firstMatch(trimmed);
  if (colonMatch != null) {
    return Duration(
      minutes: int.parse(colonMatch.group(1)!),
      seconds: int.parse(colonMatch.group(2)!),
    );
  }

  // Fallback: try plain int as minutes
  final plain = int.tryParse(trimmed);
  if (plain != null) return Duration(minutes: plain);

  return const Duration(minutes: 3);
}

class PlayerNotifier extends StateNotifier<PlayerState> {
  final AmbienceModel ambience;
  final AudioPlayer _audio = AudioPlayer();
  Timer? _timer;

  PlayerNotifier(this.ambience) : super(const PlayerState()) {
    _init();
  }

  Future<void> _init() async {
    final total = _parseDuration(ambience.duration);
    state = state.copyWith(total: total);

    try {
      await _audio.setAsset(ambience.audioPath);
      await _audio.setLoopMode(LoopMode.one);
      await _audio.play();
      state = state.copyWith(isPlaying: true);
      _startTimer();
    } catch (_) {
      // Audio asset missing — timer still runs silently
      state = state.copyWith(isPlaying: true);
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = state.elapsed + const Duration(seconds: 1);
      if (next >= state.total) {
        _timer?.cancel();
        _audio.stop();
        state = state.copyWith(
          elapsed: state.total,
          isPlaying: false,
          isFinished: true,
        );
      } else {
        state = state.copyWith(elapsed: next);
      }
    });
  }

  void togglePlay() {
    if (state.isPlaying) {
      _audio.pause();
      _timer?.cancel();
      state = state.copyWith(isPlaying: false);
    } else {
      _audio.play();
      _startTimer();
      state = state.copyWith(isPlaying: true); // ← was setting false twice
    }
  }

  void seek(double ratio) {
    final secs = (ratio * state.total.inSeconds).round();
    state = state.copyWith(elapsed: Duration(seconds: secs));
    // Also seek the audio if it's loaded
    final audioDuration = _audio.duration;
    if (audioDuration != null) {
      final audioPos = Duration(
        milliseconds: (ratio * audioDuration.inMilliseconds).round(),
      );
      _audio.seek(audioPos);
    }
  }

  void endSession() {
    _timer?.cancel();
    _audio.stop();
    state = state.copyWith(isPlaying: false, isFinished: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audio.dispose();
    super.dispose();
  }
}

final playerProvider = StateNotifierProvider.autoDispose
    .family<PlayerNotifier, PlayerState, AmbienceModel>(
  (ref, ambience) => PlayerNotifier(ambience),
);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/reflection_model.dart';
import '../../../data/repositories/reflection_repository.dart';

final reflectionRepoProvider = Provider((_) => ReflectionRepository());

// ── StateNotifier — saves trigger immediate UI refresh ────────────────────────

class ReflectionListNotifier
    extends StateNotifier<AsyncValue<List<ReflectionModel>>> {
  final ReflectionRepository _repo;

  ReflectionListNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await _repo.getAll();
      if (mounted) state = AsyncValue.data(list);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  /// Saves a reflection and refreshes the list without showing a loading state.
  Future<void> save(ReflectionModel reflection) async {
    await _repo.save(reflection);
    await _load();
  }
}

final reflectionListProvider = StateNotifierProvider<ReflectionListNotifier,
    AsyncValue<List<ReflectionModel>>>(
  (ref) => ReflectionListNotifier(ref.read(reflectionRepoProvider)),
);

final selectedMoodProvider = StateProvider<String>((_) => 'Calm');

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/ambiences_model.dart';
import '../../../data/repositories/ambience_repository.dart';

final ambienceRepoProvider = Provider((_) => AmbienceRepository());

final ambienceListProvider = FutureProvider<List<AmbienceModel>>((ref) {
  return ref.read(ambienceRepoProvider).loadAmbiences();
});

final searchQueryProvider = StateProvider<String>((_) => '');
final selectedTagProvider = StateProvider<String>((_) => 'All');

final filteredAmbiencesProvider = Provider<AsyncValue<List<AmbienceModel>>>((ref) {
  final ambiencesAsync = ref.watch(ambienceListProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final tag = ref.watch(selectedTagProvider);

  return ambiencesAsync.whenData((list) {
    return list.where((a) {
      final matchQuery = a.title.toLowerCase().contains(query);
      final matchTag = tag == 'All' || a.tag == tag;
      return matchQuery && matchTag;
    }).toList();
  });
});
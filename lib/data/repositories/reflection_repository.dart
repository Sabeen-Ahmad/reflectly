import 'package:hive_flutter/hive_flutter.dart';
import '../models/reflection_model.dart';

class ReflectionRepository {
  static const _boxName = 'reflections';

  // Box is opened once at app startup via [init] and reused
  static Box<ReflectionModel>? _openBox;

  /// Call this once from main() after Hive.initFlutter()
  static Future<void> init() async {
    _openBox = await Hive.openBox<ReflectionModel>(_boxName);
  }

  Box<ReflectionModel> get _box {
    assert(_openBox != null,
        'ReflectionRepository.init() must be called before use');
    return _openBox!;
  }

  Future<void> save(ReflectionModel reflection) async {
    await _box.put(reflection.id, reflection);
  }

  Future<List<ReflectionModel>> getAll() async {
    final list = _box.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }
}

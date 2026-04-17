import 'package:hive/hive.dart';

part 'reflection_model.g.dart';

@HiveType(typeId: 0)
class ReflectionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String ambienceId;

  @HiveField(2)
  final String ambienceTitle;

  @HiveField(3)
  final String mood;

  @HiveField(4)
  final String journalText;

  @HiveField(5)
  final DateTime createdAt;

  ReflectionModel({
    required this.id,
    required this.ambienceId,
    required this.ambienceTitle,
    required this.mood,
    required this.journalText,
    required this.createdAt,
  });
}

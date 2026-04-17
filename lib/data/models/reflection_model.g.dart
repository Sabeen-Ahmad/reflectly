// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reflection_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReflectionModelAdapter extends TypeAdapter<ReflectionModel> {
  @override
  final int typeId = 0;

  @override
  ReflectionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReflectionModel(
      id: fields[0] as String,
      ambienceId: fields[1] as String,
      ambienceTitle: fields[2] as String,
      mood: fields[3] as String,
      journalText: fields[4] as String,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ReflectionModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.ambienceId)
      ..writeByte(2)
      ..write(obj.ambienceTitle)
      ..writeByte(3)
      ..write(obj.mood)
      ..writeByte(4)
      ..write(obj.journalText)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReflectionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

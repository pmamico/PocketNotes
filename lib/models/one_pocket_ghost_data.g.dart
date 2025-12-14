// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'one_pocket_ghost_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OnePocketGhostDataAdapter extends TypeAdapter<OnePocketGhostData> {
  @override
  final int typeId = 4;

  @override
  OnePocketGhostData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OnePocketGhostData(
      rackScores: (fields[0] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, OnePocketGhostData obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.rackScores);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnePocketGhostDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

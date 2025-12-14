// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bowliards_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BowliardsDataAdapter extends TypeAdapter<BowliardsData> {
  @override
  final int typeId = 3;

  @override
  BowliardsData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BowliardsData(
      frames: (fields[0] as List).cast<BowliardsFrame>(),
    );
  }

  @override
  void write(BinaryWriter writer, BowliardsData obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.frames);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BowliardsDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

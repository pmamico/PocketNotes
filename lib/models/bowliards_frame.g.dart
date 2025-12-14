// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bowliards_frame.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BowliardsFrameAdapter extends TypeAdapter<BowliardsFrame> {
  @override
  final int typeId = 2;

  @override
  BowliardsFrame read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BowliardsFrame(
      frameIndex: fields[0] as int,
      firstThrow: fields[1] as int,
      secondThrow: fields[2] as int,
      thirdThrow: fields[3] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, BowliardsFrame obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.frameIndex)
      ..writeByte(1)
      ..write(obj.firstThrow)
      ..writeByte(2)
      ..write(obj.secondThrow)
      ..writeByte(3)
      ..write(obj.thirdThrow);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BowliardsFrameAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

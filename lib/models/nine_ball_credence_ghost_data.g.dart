// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nine_ball_credence_ghost_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NineBallCredenceFrameAdapter extends TypeAdapter<NineBallCredenceFrame> {
  @override
  final int typeId = 9;

  @override
  NineBallCredenceFrame read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NineBallCredenceFrame(
      frameIndex: fields[0] as int,
      fiveBallCredence: fields[1] as double,
      nineBallCredence: fields[2] as double,
      fiveBallMade: fields[3] as bool,
      nineBallMade: fields[4] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, NineBallCredenceFrame obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.frameIndex)
      ..writeByte(1)
      ..write(obj.fiveBallCredence)
      ..writeByte(2)
      ..write(obj.nineBallCredence)
      ..writeByte(3)
      ..write(obj.fiveBallMade)
      ..writeByte(4)
      ..write(obj.nineBallMade);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NineBallCredenceFrameAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NineBallCredenceGhostDataAdapter
    extends TypeAdapter<NineBallCredenceGhostData> {
  @override
  final int typeId = 10;

  @override
  NineBallCredenceGhostData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NineBallCredenceGhostData(
      frames: (fields[0] as List).cast<NineBallCredenceFrame>(),
      totalScore: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, NineBallCredenceGhostData obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.frames)
      ..writeByte(1)
      ..write(obj.totalScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NineBallCredenceGhostDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

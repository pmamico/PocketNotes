// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_day_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameDayDataAdapter extends TypeAdapter<GameDayData> {
  @override
  final int typeId = 5;

  @override
  GameDayData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameDayData(
      satisfaction: fields[0] as int,
    );
  }

  @override
  void write(BinaryWriter writer, GameDayData obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.satisfaction);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameDayDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

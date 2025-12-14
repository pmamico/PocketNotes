// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'competition_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompetitionDataAdapter extends TypeAdapter<CompetitionData> {
  @override
  final int typeId = 7;

  @override
  CompetitionData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompetitionData(
      eventName: fields[0] as String,
      location: fields[1] as String?,
      format: fields[2] as String?,
      satisfaction: fields[3] as int,
      rounds: (fields[4] as List).cast<CompetitionRound>(),
    );
  }

  @override
  void write(BinaryWriter writer, CompetitionData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.eventName)
      ..writeByte(1)
      ..write(obj.location)
      ..writeByte(2)
      ..write(obj.format)
      ..writeByte(3)
      ..write(obj.satisfaction)
      ..writeByte(4)
      ..write(obj.rounds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompetitionDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'competition_round.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompetitionRoundAdapter extends TypeAdapter<CompetitionRound> {
  @override
  final int typeId = 6;

  @override
  CompetitionRound read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompetitionRound(
      stage: fields[0] as String,
      opponent: fields[1] as String?,
      myScore: fields[2] as int?,
      opponentScore: fields[3] as int?,
      won: fields[4] as bool?,
      note: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CompetitionRound obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.stage)
      ..writeByte(1)
      ..write(obj.opponent)
      ..writeByte(2)
      ..write(obj.myScore)
      ..writeByte(3)
      ..write(obj.opponentScore)
      ..writeByte(4)
      ..write(obj.won)
      ..writeByte(5)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompetitionRoundAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

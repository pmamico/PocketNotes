// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practice_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PracticeSessionAdapter extends TypeAdapter<PracticeSession> {
  @override
  final int typeId = 1;

  @override
  PracticeSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PracticeSession(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      type: fields[2] as PracticeType,
      note: fields[3] as String?,
      totalScore: fields[4] as int?,
      averageScore: fields[5] as double?,
      bowliardsData: fields[6] as BowliardsData?,
      onePocketGhostData: fields[7] as OnePocketGhostData?,
      gameDayData: fields[8] as GameDayData?,
      competitionData: fields[9] as CompetitionData?,
      nineBallCredenceGhostData: fields[10] as NineBallCredenceGhostData?,
    );
  }

  @override
  void write(BinaryWriter writer, PracticeSession obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.note)
      ..writeByte(4)
      ..write(obj.totalScore)
      ..writeByte(5)
      ..write(obj.averageScore)
      ..writeByte(6)
      ..write(obj.bowliardsData)
      ..writeByte(7)
      ..write(obj.onePocketGhostData)
      ..writeByte(8)
      ..write(obj.gameDayData)
      ..writeByte(9)
      ..write(obj.competitionData)
      ..writeByte(10)
      ..write(obj.nineBallCredenceGhostData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PracticeSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

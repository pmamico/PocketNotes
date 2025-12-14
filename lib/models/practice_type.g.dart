// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practice_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PracticeTypeAdapter extends TypeAdapter<PracticeType> {
  @override
  final int typeId = 0;

  @override
  PracticeType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PracticeType.bowliards;
      case 1:
        return PracticeType.onePocketGhost;
      case 2:
        return PracticeType.gameDay;
      case 3:
        return PracticeType.competition;
      case 4:
        return PracticeType.nineBallCredenceGhost;
      default:
        return PracticeType.bowliards;
    }
  }

  @override
  void write(BinaryWriter writer, PracticeType obj) {
    switch (obj) {
      case PracticeType.bowliards:
        writer.writeByte(0);
        break;
      case PracticeType.onePocketGhost:
        writer.writeByte(1);
        break;
      case PracticeType.gameDay:
        writer.writeByte(2);
        break;
      case PracticeType.competition:
        writer.writeByte(3);
        break;
      case PracticeType.nineBallCredenceGhost:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PracticeTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

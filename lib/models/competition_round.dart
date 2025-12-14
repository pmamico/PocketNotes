import 'package:hive/hive.dart';

part 'competition_round.g.dart';

@HiveType(typeId: 6)
class CompetitionRound {
  @HiveField(0)
  final String stage; // e.g. Qualifier, QF, Final
  @HiveField(1)
  final String? opponent;
  @HiveField(2)
  final int? myScore;
  @HiveField(3)
  final int? opponentScore;
  @HiveField(4)
  final bool? won;
  @HiveField(5)
  final String? note;

  const CompetitionRound({
    required this.stage,
    this.opponent,
    this.myScore,
    this.opponentScore,
    this.won,
    this.note,
  });
}

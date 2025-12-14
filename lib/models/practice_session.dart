import 'package:hive/hive.dart';
import 'practice_type.dart';
import 'bowliards_data.dart';
import 'one_pocket_ghost_data.dart';
import 'game_day_data.dart';
import 'competition_data.dart';
import 'nine_ball_credence_ghost_data.dart';

part 'practice_session.g.dart';

@HiveType(typeId: 1)
class PracticeSession extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final DateTime date;
  @HiveField(2)
  final PracticeType type;
  @HiveField(3)
  final String? note;
  @HiveField(4)
  final int? totalScore;
  @HiveField(5)
  final double? averageScore;
  @HiveField(6)
  final BowliardsData? bowliardsData;
  @HiveField(7)
  final OnePocketGhostData? onePocketGhostData;
  @HiveField(8)
  final GameDayData? gameDayData;
  @HiveField(9)
  final CompetitionData? competitionData;
  @HiveField(10)
  final NineBallCredenceGhostData? nineBallCredenceGhostData;

  PracticeSession({
    required this.id,
    required this.date,
    required this.type,
    this.note,
    this.totalScore,
    this.averageScore,
    this.bowliardsData,
    this.onePocketGhostData,
    this.gameDayData,
    this.competitionData,
    this.nineBallCredenceGhostData,
  });
}

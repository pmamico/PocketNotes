import 'package:hive/hive.dart';

part 'practice_type.g.dart';

@HiveType(typeId: 0)
enum PracticeType {
  @HiveField(0)
  bowliards,
  @HiveField(1)
  onePocketGhost,
  @HiveField(2)
  gameDay,
  @HiveField(3)
  competition,
  @HiveField(4)
  nineBallCredenceGhost,
}

import 'package:hive/hive.dart';

part 'nine_ball_credence_ghost_data.g.dart';

@HiveType(typeId: 9)
class NineBallCredenceFrame {
  @HiveField(0)
  final int frameIndex;
  @HiveField(1)
  final double fiveBallCredence;
  @HiveField(2)
  final double nineBallCredence;
  @HiveField(3)
  final bool fiveBallMade;
  @HiveField(4)
  final bool? nineBallMade;

  const NineBallCredenceFrame({
    required this.frameIndex,
    required this.fiveBallCredence,
    required this.nineBallCredence,
    required this.fiveBallMade,
    this.nineBallMade,
  });
}

@HiveType(typeId: 10)
class NineBallCredenceGhostData {
  @HiveField(0)
  final List<NineBallCredenceFrame> frames;
  @HiveField(1)
  final double totalScore;

  const NineBallCredenceGhostData({
    required this.frames,
    required this.totalScore,
  });
}

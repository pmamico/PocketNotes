import 'package:hive/hive.dart';

part 'bowliards_frame.g.dart';

@HiveType(typeId: 2)
class BowliardsFrame {
  @HiveField(0)
  final int frameIndex; // 1-10
  @HiveField(1)
  final int firstThrow; // 0-10
  @HiveField(2)
  final int secondThrow; // 0-10
  @HiveField(3)
  final int? thirdThrow; // only for 10th frame

  BowliardsFrame({
    required this.frameIndex,
    required this.firstThrow,
    required this.secondThrow,
    this.thirdThrow,
  });
}

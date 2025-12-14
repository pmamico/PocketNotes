import 'package:hive/hive.dart';
import 'bowliards_frame.dart';

part 'bowliards_data.g.dart';

@HiveType(typeId: 3)
class BowliardsData {
  @HiveField(0)
  final List<BowliardsFrame> frames;

  BowliardsData({required this.frames});
}

import 'package:hive/hive.dart';

part 'one_pocket_ghost_data.g.dart';

@HiveType(typeId: 4)
class OnePocketGhostData {
  @HiveField(0)
  final List<int> rackScores; // length 5, each 0–15

  OnePocketGhostData({required this.rackScores});
}

import 'package:hive/hive.dart';

part 'game_day_data.g.dart';

@HiveType(typeId: 5)
class GameDayData {
  @HiveField(0)
  final int satisfaction; // -1 dissatisfied, +1 satisfied

  const GameDayData({required this.satisfaction})
      : assert(satisfaction == -1 || satisfaction == 1,
            'Satisfaction must be -1 or 1');
}

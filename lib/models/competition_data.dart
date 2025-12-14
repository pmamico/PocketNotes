import 'package:hive/hive.dart';

import 'competition_round.dart';

part 'competition_data.g.dart';

@HiveType(typeId: 7)
class CompetitionData {
  @HiveField(0)
  final String eventName;
  @HiveField(1)
  final String? location;
  @HiveField(2)
  final String? format; // e.g. race-to-7, double elimination
  @HiveField(3)
  final int satisfaction; // -1 dissatisfied, +1 satisfied
  @HiveField(4)
  final List<CompetitionRound> rounds;

  const CompetitionData({
    required this.eventName,
    this.location,
    this.format,
    required this.satisfaction,
    required this.rounds,
  }) : assert(satisfaction == -1 || satisfaction == 1,
            'Satisfaction must be -1 or 1');
}

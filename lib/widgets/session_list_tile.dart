import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/practice_session.dart';
import '../models/practice_type.dart';

class SessionListTile extends StatelessWidget {
  final PracticeSession session;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  const SessionListTile({
    super.key,
    required this.session,
    required this.color,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    String title = '';
    final details = <String>[];
    IconData icon = Icons.event;
    switch (session.type) {
      case PracticeType.bowliards:
        title = 'Bowliards – ${session.totalScore ?? '-'} pts';
        icon = FontAwesomeIcons.bowlingBall;
        details.add(
          'Start: ${TimeOfDay.fromDateTime(session.date).format(context)}',
        );
        break;
      case PracticeType.onePocketGhost:
        final total = session.totalScore?.toString() ?? '-';
        title = 'One Pocket Ghost – total $total pts';
        icon = FontAwesomeIcons.ghost;
        details.add(
          'Start: ${TimeOfDay.fromDateTime(session.date).format(context)}',
        );
        break;
      case PracticeType.nineBallCredenceGhost:
        final totalCredence = session.totalScore != null
            ? '${session.totalScore} cb'
            : '-';
        title = '9 Ball Credence – $totalCredence';
        icon = FontAwesomeIcons.bullseye;
        details.add(
          'Start: ${TimeOfDay.fromDateTime(session.date).format(context)}',
        );
        final avg = session.averageScore;
        if (avg != null) {
          details.add('Average: ${avg.toStringAsFixed(1)} cb');
        }
        break;
      case PracticeType.gameDay:
        final mood = session.gameDayData?.satisfaction;
        final rating = mood == 1
            ? 'Satisfied'
            : mood == -1
            ? 'Unsatisfied'
            : 'No rating';
        title = 'Game day – $rating';
        icon = FontAwesomeIcons.faceGrinStars;
        break;
      case PracticeType.competition:
        final data = session.competitionData;
        final rounds = data?.rounds ?? [];
        final wins = rounds.where((r) => r.won == true).length;
        final losses = rounds.where((r) => r.won == false).length;
        title = 'Tournament – ${data?.eventName ?? 'Unknown'}';
        icon = FontAwesomeIcons.trophy;
        if (rounds.isNotEmpty) {
          details.add('Record: $wins W / $losses L');
        }
        final location = data?.location;
        if (location != null && location.isNotEmpty) {
          details.add(location);
        }
        final verdictValue = data?.satisfaction;
        final verdict = verdictValue == 1
            ? 'Satisfied'
            : verdictValue == -1
            ? 'Unsatisfied'
            : 'No rating';
        details.add(verdict);
        break;
    }
    if (session.note != null && session.note!.isNotEmpty) {
      details.add(session.note!);
    }
    final subtitle = details.join(' · ');
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.28), color.withOpacity(0.08)],
            ),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.35),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}

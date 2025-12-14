import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/practice_type.dart';

class PracticeTypeSelector extends StatelessWidget {
  final void Function(PracticeType type) onSelected;
  const PracticeTypeSelector({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'New entry',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.bowlingBall),
            title: const Text('Bowliards drills'),
            onTap: () => onSelected(PracticeType.bowliards),
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.ghost),
            title: const Text('One Pocket Ghost (5 rack)'),
            onTap: () => onSelected(PracticeType.onePocketGhost),
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.bullseye),
            title: const Text('9 Ball Credence'),
            onTap: () => onSelected(PracticeType.nineBallCredenceGhost),
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.faceGrinStars),
            title: const Text('Game day'),
            onTap: () => onSelected(PracticeType.gameDay),
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.trophy),
            title: const Text('Tournament'),
            onTap: () => onSelected(PracticeType.competition),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

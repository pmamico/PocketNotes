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
              'Új bejegyzés',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.bowlingBall),
            title: const Text('Bowliards edzés'),
            onTap: () => onSelected(PracticeType.bowliards),
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.ghost),
            title: const Text('One Pocket Ghost (5 rack)'),
            onTap: () => onSelected(PracticeType.onePocketGhost),
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.faceGrinStars),
            title: const Text('Játéknap'),
            onTap: () => onSelected(PracticeType.gameDay),
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.trophy),
            title: const Text('Verseny'),
            onTap: () => onSelected(PracticeType.competition),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

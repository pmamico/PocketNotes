import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../data/practice_session_repository.dart';
import '../models/game_day_data.dart';
import '../models/practice_session.dart';
import '../models/practice_type.dart';

class GameDayLoggingSheet extends StatefulWidget {
  final DateTime date;
  final PracticeSession? initialSession;
  const GameDayLoggingSheet({
    super.key,
    required this.date,
    this.initialSession,
  });

  @override
  State<GameDayLoggingSheet> createState() => _GameDayLoggingSheetState();
}

class _GameDayLoggingSheetState extends State<GameDayLoggingSheet> {
  int? _satisfaction;
  final TextEditingController _noteController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final session = widget.initialSession;
    if (session != null) {
      _satisfaction = session.gameDayData?.satisfaction;
      _noteController.text = session.note ?? '';
    }
  }

  void _toggleSatisfaction(int value, bool selected) {
    setState(() {
      if (!selected) {
        _satisfaction = null;
      } else {
        _satisfaction = value;
      }
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final rating = _satisfaction;
    if (rating == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a satisfaction rating.')),
      );
      return;
    }
    setState(() => _saving = true);
    final session = PracticeSession(
      id: widget.initialSession?.id ?? const Uuid().v4(),
      date: widget.date,
      type: PracticeType.gameDay,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      gameDayData: GameDayData(satisfaction: rating),
    );
    await context.read<PracticeSessionRepository>().addSession(session);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${widget.date.year}.${widget.date.month.toString().padLeft(2, '0')}.${widget.date.day.toString().padLeft(2, '0')}';
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Game day - $dateLabel',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Text('Satisfaction',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Satisfied'),
                  selected: _satisfaction == 1,
                  onSelected: (selected) => _toggleSatisfaction(1, selected),
                ),
                ChoiceChip(
                  label: const Text('Unsatisfied'),
                  selected: _satisfaction == -1,
                  onSelected: (selected) => _toggleSatisfaction(-1, selected),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

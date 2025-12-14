import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../data/practice_session_repository.dart';
import '../models/competition_data.dart';
import '../models/competition_round.dart';
import '../models/practice_session.dart';
import '../models/practice_type.dart';

class CompetitionLoggingScreen extends StatefulWidget {
  final DateTime date;
  final PracticeSession? initialSession;
  const CompetitionLoggingScreen({
    super.key,
    required this.date,
    this.initialSession,
  });

  @override
  State<CompetitionLoggingScreen> createState() => _CompetitionLoggingScreenState();
}

class _CompetitionLoggingScreenState extends State<CompetitionLoggingScreen> {
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _formatController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  late final List<_RoundFormData> _rounds;

  bool _saving = false;
  int? _satisfaction;

  @override
  void initState() {
    super.initState();
    final session = widget.initialSession;
    final data = session?.competitionData;
    _noteController.text = session?.note ?? '';
    if (data != null) {
      _eventNameController.text = data.eventName;
      _locationController.text = data.location ?? '';
      _formatController.text = data.format ?? '';
      _satisfaction = data.satisfaction;
      _rounds = data.rounds.isEmpty
          ? [_RoundFormData()]
          : data.rounds.map(_RoundFormData.fromRound).toList();
    } else {
      _rounds = [_RoundFormData()];
    }
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _locationController.dispose();
    _formatController.dispose();
    _noteController.dispose();
    for (final round in _rounds) {
      round.dispose();
    }
    super.dispose();
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

  void _addRound() {
    setState(() => _rounds.add(_RoundFormData()));
  }

  void _removeRound(int index) {
    if (_rounds.length == 1) return;
    final removed = _rounds.removeAt(index);
    removed.dispose();
    setState(() {});
  }

  Future<void> _save() async {
    final name = _eventNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Add meg a verseny nevét.')));
      return;
    }
    final rating = _satisfaction;
    if (rating == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Válassz elégedettséget a versenyhez.')));
      return;
    }
    final rounds = <CompetitionRound>[];
    for (var i = 0; i < _rounds.length; i++) {
      final converted = _rounds[i].toRound('Forduló ${i + 1}');
      if (converted != null) {
        rounds.add(converted);
      }
    }
    if (rounds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Legalább egy fordulót rögzíts.')),
      );
      return;
    }

    setState(() => _saving = true);
    final session = PracticeSession(
      id: widget.initialSession?.id ?? const Uuid().v4(),
      date: widget.date,
      type: PracticeType.competition,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      competitionData: CompetitionData(
        eventName: name,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        format: _formatController.text.trim().isEmpty
            ? null
            : _formatController.text.trim(),
        satisfaction: rating,
        rounds: rounds,
      ),
    );
    await context.read<PracticeSessionRepository>().addSession(session);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${widget.date.year}.${widget.date.month.toString().padLeft(2, '0')}.${widget.date.day.toString().padLeft(2, '0')}';
    return Scaffold(
      appBar: AppBar(title: Text('Verseny – $dateLabel')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _eventNameController,
                        decoration: const InputDecoration(
                          labelText: 'Verseny neve *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Helyszín',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _formatController,
                        decoration: const InputDecoration(
                          labelText: 'Formátum (pl. race-to-7)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Összkép',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Elégedett'),
                            selected: _satisfaction == 1,
                            onSelected: (selected) =>
                                _toggleSatisfaction(1, selected),
                          ),
                          ChoiceChip(
                            label: const Text('Elégedetlen'),
                            selected: _satisfaction == -1,
                            onSelected: (selected) =>
                                _toggleSatisfaction(-1, selected),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Fordulók',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      ..._rounds
                          .asMap()
                          .entries
                          .map(
                            (entry) => _RoundCard(
                              index: entry.key,
                              data: entry.value,
                              onRemove: _rounds.length > 1
                                  ? () => _removeRound(entry.key)
                                  : null,
                              onChanged: () => setState(() {}),
                            ),
                          ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _addRound,
                        icon: const Icon(Icons.add),
                        label: const Text('Új forduló'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _noteController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Jegyzet',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _saving ? null : () => Navigator.of(context).pop(),
                    child: const Text('Mégse'),
                  ),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Mentés'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundFormData {
  _RoundFormData();
  final TextEditingController stageController = TextEditingController();
  final TextEditingController opponentController = TextEditingController();
  final TextEditingController myScoreController = TextEditingController();
  final TextEditingController opponentScoreController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  bool? won;

  void dispose() {
      stageController.dispose();
    opponentController.dispose();
    myScoreController.dispose();
    opponentScoreController.dispose();
    noteController.dispose();
  }

  factory _RoundFormData.fromRound(CompetitionRound round) {
    final data = _RoundFormData();
    data.stageController.text = round.stage;
    data.opponentController.text = round.opponent ?? '';
    data.myScoreController.text =
        round.myScore != null ? round.myScore.toString() : '';
    data.opponentScoreController.text =
        round.opponentScore != null ? round.opponentScore.toString() : '';
    data.noteController.text = round.note ?? '';
    data.won = round.won;
    return data;
  }

  CompetitionRound? toRound(String fallbackStage) {
    final stageText = stageController.text.trim();
    final opponentText = opponentController.text.trim();
    final noteText = noteController.text.trim();
    final myScoreText = myScoreController.text.trim();
    final opponentScoreText = opponentScoreController.text.trim();

    final hasData = stageText.isNotEmpty ||
        opponentText.isNotEmpty ||
        noteText.isNotEmpty ||
        myScoreText.isNotEmpty ||
        opponentScoreText.isNotEmpty ||
        won != null;
    if (!hasData) return null;

    return CompetitionRound(
      stage: stageText.isEmpty ? fallbackStage : stageText,
      opponent: opponentText.isEmpty ? null : opponentText,
      myScore: myScoreText.isEmpty ? null : int.tryParse(myScoreText),
      opponentScore:
          opponentScoreText.isEmpty ? null : int.tryParse(opponentScoreText),
      won: won,
      note: noteText.isEmpty ? null : noteText,
    );
  }
}

class _RoundCard extends StatelessWidget {
  final int index;
  final _RoundFormData data;
  final VoidCallback? onRemove;
  final VoidCallback onChanged;

  const _RoundCard({
    required this.index,
    required this.data,
    this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Forduló ${index + 1}',
                    style: Theme.of(context).textTheme.titleSmall),
                if (onRemove != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Forduló törlése',
                    onPressed: onRemove,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: data.stageController,
              decoration: const InputDecoration(
                labelText: 'Megnevezés (pl. Negyeddöntő)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: data.opponentController,
              decoration: const InputDecoration(
                labelText: 'Ellenfél',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: data.myScoreController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Saját pont',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: data.opponentScoreController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Ellenfél pont',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Győzelem'),
                  selected: data.won == true,
                  onSelected: (selected) {
                    data.won = selected ? true : null;
                    onChanged();
                  },
                ),
                ChoiceChip(
                  label: const Text('Vereség'),
                  selected: data.won == false,
                  onSelected: (selected) {
                    data.won = selected ? false : null;
                    onChanged();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: data.noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Megjegyzés',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

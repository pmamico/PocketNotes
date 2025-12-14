import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../data/practice_session_repository.dart';
import '../models/one_pocket_ghost_data.dart';
import '../models/practice_session.dart';
import '../models/practice_type.dart';

class OnePocketGhostLoggingScreen extends StatefulWidget {
  final DateTime date;
  final PracticeSession? initialSession;
  const OnePocketGhostLoggingScreen({
    super.key,
    required this.date,
    this.initialSession,
  });

  @override
  State<OnePocketGhostLoggingScreen> createState() =>
      _OnePocketGhostLoggingScreenState();
}

class _OnePocketGhostLoggingScreenState
    extends State<OnePocketGhostLoggingScreen> {
  late final List<int?> _rackScores;
  int _currentRack = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _rackScores = List<int?>.filled(5, null);
    final session = widget.initialSession;
    final scores = session?.onePocketGhostData?.rackScores;
    if (scores != null) {
      for (var i = 0; i < scores.length && i < _rackScores.length; i++) {
        _rackScores[i] = scores[i];
      }
    }
  }

  int get _totalScore =>
      _rackScores.fold(0, (sum, value) => sum + (value ?? 0));
  double get _averageScore {
    final completed = _rackScores.whereType<int>();
    if (completed.isEmpty) return 0;
    return _totalScore / completed.length;
  }

  bool get _allValid => _rackScores.every((value) => value != null);

  Future<void> _save() async {
    if (!_allValid) return;
    setState(() => _saving = true);

    final session = PracticeSession(
      id: widget.initialSession?.id ?? const Uuid().v4(),
      date: widget.date,
      type: PracticeType.onePocketGhost,
      note: widget.initialSession?.note,
      totalScore: _totalScore,
      averageScore: _averageScore,
      onePocketGhostData: OnePocketGhostData(
        rackScores: _rackScores.cast<int>(),
      ),
    );

    await context.read<PracticeSessionRepository>().addSession(session);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialSession != null
              ? 'One Pocket Ghost – Edit Session'
              : 'One Pocket Ghost – New Session',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '${widget.date.year}-${widget.date.month.toString().padLeft(2, '0')}-${widget.date.day.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _OPGScoreboard(
              rackScores: _rackScores,
              currentRack: _currentRack,
              onRackTap: (rack) => setState(() => _currentRack = rack),
            ),
            const SizedBox(height: 16),
            _buildRackInput(_currentRack),
            const SizedBox(height: 24),
            Text(
              'Total score: $_totalScore',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'Rack average: ${_averageScore.toStringAsFixed(2)}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.secondary),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _currentRack > 0
                          ? () => setState(() => _currentRack--)
                          : null,
                    ),
                    Text('Rack ${_currentRack + 1}'),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _currentRack < 4
                          ? () => setState(() => _currentRack++)
                          : null,
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _saving || !_allValid ? null : _save,
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

  Widget _buildRackInput(int rackIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rack ${rackIndex + 1}',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 2,
          runSpacing: 2,
          children: List.generate(16, (value) {
            final selected = _rackScores[rackIndex] == value;
            return _scoreButton(
              value: value,
              selected: selected,
              onTap: () {
                setState(() {
                  _rackScores[rackIndex] = value;
                  if (rackIndex < 4) {
                    _currentRack = rackIndex + 1;
                  }
                });
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _scoreButton({
    required int value,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(32, 32),
          padding: EdgeInsets.zero,
          backgroundColor: selected ? Colors.teal : null,
          foregroundColor: selected ? Colors.white : null,
        ),
        onPressed: onTap,
        child: Text('$value'),
      ),
    );
  }
}

class _OPGScoreboard extends StatelessWidget {
  final List<int?> rackScores;
  final int currentRack;
  final void Function(int) onRackTap;

  const _OPGScoreboard({
    required this.rackScores,
    required this.currentRack,
    required this.onRackTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;
    final baseFill = Colors.white.withOpacity(0.05);
    final currentFill = accent.withOpacity(0.2);
    final borderShade = accent.withOpacity(0.35);
    final textStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: Colors.white,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final isCurrent = i == currentRack;
        final score = rackScores[i];
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onRackTap(i),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCurrent ? currentFill : baseFill,
              border: Border.all(
                color: isCurrent ? accent : borderShade,
                width: 1.4,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: accent.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            width: 40,
            child: Center(
              child: Text(
                score?.toString() ?? '',
                style: textStyle,
              ),
            ),
          ),
        );
      }),
    );
  }
}

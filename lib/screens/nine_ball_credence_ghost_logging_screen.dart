import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../data/practice_session_repository.dart';
import '../models/nine_ball_credence_ghost_data.dart';
import '../models/practice_session.dart';
import '../models/practice_type.dart';

class NineBallCredenceGhostLoggingScreen extends StatefulWidget {
  final DateTime date;
  final PracticeSession? initialSession;
  const NineBallCredenceGhostLoggingScreen({
    super.key,
    required this.date,
    this.initialSession,
  });

  @override
  State<NineBallCredenceGhostLoggingScreen> createState() =>
      _NineBallCredenceGhostLoggingScreenState();
}

class _NineBallCredenceGhostLoggingScreenState
    extends State<NineBallCredenceGhostLoggingScreen> {
  static const _framesCount = 5;
  static const double _minCredence = 0.50;
  static const double _maxCredence = 0.99;
  static const List<double> _credenceOptions = [
    0.50,
    0.60,
    0.70,
    0.80,
    0.90,
    0.99,
  ];

  late final List<double> _fiveCredences;
  late final List<double> _nineCredences;
  late final List<bool?> _fiveResults;
  late final List<bool?> _nineResults;

  int _currentFrame = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _fiveCredences = List<double>.filled(_framesCount, 0.50);
    _nineCredences = List<double>.filled(_framesCount, 0.50);
    _fiveResults = List<bool?>.filled(_framesCount, null);
    _nineResults = List<bool?>.filled(_framesCount, null);

    final existing = widget.initialSession?.nineBallCredenceGhostData;
    if (existing != null) {
      for (final frame in existing.frames) {
        final index = frame.frameIndex - 1;
        if (index < 0 || index >= _framesCount) continue;
        _fiveCredences[index] = _normalizeToOption(frame.fiveBallCredence);
        _nineCredences[index] = _normalizeToOption(frame.nineBallCredence);
        _fiveResults[index] = frame.fiveBallMade;
        _nineResults[index] = frame.nineBallMade;
      }
    }
  }

  bool get _allFramesValid {
    for (var i = 0; i < _framesCount; i++) {
      final five = _fiveResults[i];
      if (five == null) {
        return false;
      }
      if (five && _nineResults[i] == null) {
        return false;
      }
    }
    return true;
  }

  double get _totalScore {
    var total = 0.0;
    for (var i = 0; i < _framesCount; i++) {
      total += _frameScore(i);
    }
    return total;
  }

  double get _averageScore => _totalScore / _framesCount;

  String _formatScore(num value) => value.round().toString();

  double _frameScore(int index) {
    double total = 0;
    final five = _fiveResults[index];
    final nine = _nineResults[index];
    if (five != null) {
      total += _scoreSingle(_fiveCredences[index], five);
    }
    if (five == true && nine != null) {
      total += 2 * _scoreSingle(_nineCredences[index], nine);
    }
    return total;
  }

  double _scoreSingle(double credence, bool made) {
    final p = _clampCredence(credence);
    final numerator = made ? p : 1 - p;
    final ratio = numerator / 0.5;
    return 100 * (math.log(ratio) / math.log(2));
  }

  double _clampCredence(double value) {
    return value.clamp(_minCredence, _maxCredence).toDouble();
  }

  double _normalizeToOption(double value) {
    double closest = _credenceOptions.first;
    double minDiff = double.infinity;
    for (final option in _credenceOptions) {
      final diff = (option - value).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = option;
      }
    }
    return closest;
  }

  int _percentFromCredence(double value) =>
      (_normalizeToOption(value) * 100).round();

  double _credenceFromPercent(int percent) => percent / 100;

  Future<void> _save() async {
    if (!_allFramesValid) return;
    setState(() => _saving = true);

    final frames = List<NineBallCredenceFrame>.generate(_framesCount, (i) {
      final fiveMade = _fiveResults[i]!;
      return NineBallCredenceFrame(
        frameIndex: i + 1,
        fiveBallCredence: _fiveCredences[i],
        nineBallCredence: _nineCredences[i],
        fiveBallMade: fiveMade,
        nineBallMade: fiveMade ? _nineResults[i]! : null,
      );
    });
    final total = _totalScore;

    final session = PracticeSession(
      id: widget.initialSession?.id ?? const Uuid().v4(),
      date: widget.date,
      type: PracticeType.nineBallCredenceGhost,
      note: widget.initialSession?.note,
      totalScore: total.round(),
      averageScore: total / frames.length,
      nineBallCredenceGhostData: NineBallCredenceGhostData(
        frames: frames,
        totalScore: total,
      ),
    );

    await context.read<PracticeSessionRepository>().addSession(session);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel =
        '${widget.date.year}-${widget.date.month.toString().padLeft(2, '0')}-${widget.date.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialSession != null
              ? '9 Ball Credence – Edit entry'
              : '9 Ball Credence – New entry',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(dateLabel, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _FrameScoreboard(
              scores: List<double>.generate(_framesCount, _frameScore),
              fiveResults: _fiveResults,
              nineResults: _nineResults,
              currentFrame: _currentFrame,
              onFrameTap: (index) => setState(() => _currentFrame = index),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: _buildFrameEditor(_currentFrame),
              ),
            ),
            const SizedBox(height: 12),
            _buildSummary(theme),
            const SizedBox(height: 20),
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
                      onPressed: _currentFrame > 0
                          ? () => setState(() => _currentFrame--)
                          : null,
                    ),
                    Text('Frame ${_currentFrame + 1}'),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _currentFrame < _framesCount - 1
                          ? () => setState(() => _currentFrame++)
                          : null,
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _saving || !_allFramesValid ? null : _save,
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

  Widget _buildSummary(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total score', style: theme.textTheme.labelMedium),
            Text(_formatScore(_totalScore), style: theme.textTheme.titleLarge),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Frame average', style: theme.textTheme.labelMedium),
            Text(
              _formatScore(_averageScore),
              style: theme.textTheme.titleLarge,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFrameEditor(int frame) {
    final theme = Theme.of(context);
    final fiveCredence = _fiveCredences[frame];
    final nineCredence = _nineCredences[frame];
    final fiveResult = _fiveResults[frame];
    final nineResult = _nineResults[frame];
    final frameScore = _frameScore(frame);
    final canAttemptNine = fiveResult == true;

    Widget credencePicker({
      required String label,
      required double value,
      required Color color,
      ValueChanged<double>? onChanged,
      bool enabled = true,
      String? helperText,
    }) {
      final percentValue = _percentFromCredence(value);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(color: color),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: percentValue,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              enabled: enabled,
            ),
            items: _credenceOptions
                .map(
                  (option) => DropdownMenuItem<int>(
                    value: (option * 100).round(),
                    child: Text('${(option * 100).round()}%'),
                  ),
                )
                .toList(),
            onChanged: onChanged == null
                ? null
                : (selected) {
                    if (selected == null) return;
                    onChanged(_credenceFromPercent(selected));
                  },
          ),
          if (helperText != null) ...[
            const SizedBox(height: 6),
            Text(
              helperText,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ],
      );
    }

    Widget resultToggle({
      required String label,
      required bool? value,
      required Color color,
      required ValueChanged<bool?> onChanged,
      bool enabled = true,
      String? disabledHelper,
    }) {
      final helper = !enabled
          ? (disabledHelper ?? 'Available after a made 5 ball')
          : 'Mark whether it was made.';

      Widget buildButton(String text, bool target) {
        final selected = value == target;
        return Expanded(
          child: OutlinedButton(
            onPressed: enabled
                ? () => onChanged(selected ? null : target)
                : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: selected ? color : Colors.white,
              side: BorderSide(color: selected ? color : Colors.white30),
              backgroundColor: selected
                  ? color.withOpacity(0.2)
                  : Colors.transparent,
            ),
            child: Text(text),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(color: color),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              buildButton('Missed', false),
              const SizedBox(width: 8),
              buildButton('Made', true),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            helper,
            style: theme.textTheme.bodySmall?.copyWith(
              color: helper == disabledHelper ? Colors.white60 : Colors.white70,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Frame ${frame + 1}', style: theme.textTheme.titleSmall),
        const SizedBox(height: 12),
        credencePicker(
          label: 'Bet for 5 ball',
          value: fiveCredence,
          color: Colors.orangeAccent,
          onChanged: (value) => setState(() => _fiveCredences[frame] = value),
        ),
        resultToggle(
          label: '',
          value: fiveResult,
          color: Colors.orangeAccent,
          onChanged: (made) => setState(() {
            _fiveResults[frame] = made;
            if (made != true) {
              _nineResults[frame] = null;
            }
          }),
        ),
        const Divider(height: 32),
        if (canAttemptNine) ...[
          credencePicker(
            label: 'Bet for 9 ball',
            value: nineCredence,
            color: Colors.lightBlueAccent,
            onChanged: (value) => setState(() => _nineCredences[frame] = value),
            helperText: "If you're right, you earn double points.",
          ),
          resultToggle(
            label: '',
            value: nineResult,
            color: Colors.lightBlueAccent,
            onChanged: (made) => setState(() => _nineResults[frame] = made),
          ),
        ] else ...[
          Text(
            'If you make the 5 ball you can bet on the 9 ball for double points.',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          'Frame score: ${_formatScore(frameScore)}',
          style: theme.textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _FrameScoreboard extends StatelessWidget {
  final List<double> scores;
  final List<bool?> fiveResults;
  final List<bool?> nineResults;
  final int currentFrame;
  final void Function(int) onFrameTap;

  const _FrameScoreboard({
    required this.scores,
    required this.fiveResults,
    required this.nineResults,
    required this.currentFrame,
    required this.onFrameTap,
  });

  bool _frameComplete(int index) {
    final five = fiveResults[index];
    if (five == null) return false;
    if (five && nineResults[index] == null) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;
    final baseColor = Colors.white.withOpacity(0.05);

    return Row(
      children: List.generate(scores.length, (index) {
        final isCurrent = index == currentFrame;
        final completed = _frameComplete(index);
        final scoreLabel = completed ? scores[index].round().toString() : '—';
        final five = fiveResults[index];
        final nine = nineResults[index];
        return Expanded(
          child: GestureDetector(
            onTap: () => onFrameTap(index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: isCurrent ? accent.withOpacity(0.2) : baseColor,
                border: Border.all(
                  color: isCurrent
                      ? accent
                      : completed
                      ? Colors.greenAccent.withOpacity(0.5)
                      : Colors.white24,
                  width: 1.3,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      scoreLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _StatusIcons(five: five, nine: nine),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _StatusIcons extends StatelessWidget {
  final bool? five;
  final bool? nine;
  const _StatusIcons({required this.five, required this.nine});

  Widget _ballIcon(String label, Color color) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (five == false) {
      return const Icon(Icons.close, color: Colors.redAccent, size: 12);
    }
    if (five == true && nine == true) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ballIcon('5', Colors.orangeAccent),
          const SizedBox(width: 6),
          _ballIcon('9', Colors.amberAccent),
        ],
      );
    }
    if (five == true && nine == false) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ballIcon('5', Colors.orangeAccent),
          const SizedBox(width: 6),
          const Icon(Icons.close, color: Colors.redAccent, size: 12),
        ],
      );
    }
    if (five == true) {
      return _ballIcon('5', Colors.orangeAccent);
    }
    return Text('—', style: Theme.of(context).textTheme.bodySmall);
  }
}

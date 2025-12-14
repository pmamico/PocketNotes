import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../data/practice_session_repository.dart';
import '../models/bowliards_data.dart';
import '../models/bowliards_frame.dart';
import '../models/practice_session.dart';
import '../models/practice_type.dart';

class BowliardsLoggingScreen extends StatefulWidget {
  final DateTime date;
  final PracticeSession? initialSession;
  const BowliardsLoggingScreen({
    super.key,
    required this.date,
    this.initialSession,
  });

  @override
  State<BowliardsLoggingScreen> createState() => _BowliardsLoggingScreenState();
}

class _BowliardsLoggingScreenState extends State<BowliardsLoggingScreen> {
  late final List<int?> _firstThrows;
  late final List<int?> _secondThrows;
  int? _thirdThrow;
  int _currentFrame = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _firstThrows = List<int?>.filled(10, null);
    _secondThrows = List<int?>.filled(10, null);
    final session = widget.initialSession;
    final frames = session?.bowliardsData?.frames;
    if (frames != null) {
      for (final frame in frames) {
        final index = frame.frameIndex - 1;
        if (index < 0 || index >= 10) continue;
        _firstThrows[index] = frame.firstThrow;
        _secondThrows[index] = frame.secondThrow;
        if (index == 9) {
          _thirdThrow = frame.thirdThrow;
        }
      }
    }
  }

  int _getFrameScore(int index) {
    final first = _firstThrows[index];
    final second = _secondThrows[index];
    if (first == null || second == null) {
      return 0;
    }
    if (index == 9) {
      final needsThird = _needsThirdThrow;
      final third = needsThird ? (_thirdThrow ?? 0) : 0;
      return first + second + third;
    }
    if (first == 10) {
      final bonusRolls = _nextRolls(index + 1, 2);
      final bonus = bonusRolls.fold(0, (sum, value) => sum + value);
      return 10 + bonus;
    }
    if (first + second == 10) {
      final bonusRolls = _nextRolls(index + 1, 1);
      final bonus = bonusRolls.isNotEmpty ? bonusRolls.first : 0;
      return 10 + bonus;
    }
    return first + second;
  }

  int get _totalScore => List.generate(
        10,
        (i) => _getFrameScore(i),
      ).fold(0, (sum, value) => sum + value);

  bool get _needsThirdThrow {
    final first = _firstThrows[9];
    final second = _secondThrows[9];
    if (first == null || second == null) return false;
    return first == 10 || first + second == 10;
  }

  // Collect upcoming rolls so strike/spare bonuses use the correct fill balls.
  List<int> _nextRolls(int startFrame, int count) {
    final rolls = <int>[];
    for (var frame = startFrame; frame < 10 && rolls.length < count; frame++) {
      final first = _firstThrows[frame];
      final second = _secondThrows[frame];
      if (first == null) break;
      rolls.add(first);
      if (rolls.length == count) break;

      final isTenth = frame == 9;
      if (!isTenth && first == 10) {
        continue;
      }

      if (second == null) break;
      rolls.add(second);
      if (rolls.length == count) break;

      if (isTenth && _thirdThrow != null) {
        rolls.add(_thirdThrow!);
      }
    }
    if (rolls.length > count) {
      return rolls.sublist(0, count);
    }
    return rolls;
  }

  int _maxSecondValue(int frame) {
    final first = _firstThrows[frame];
    if (first == null) return 10;
    if (frame == 9 && first == 10) {
      return 10;
    }
    return 10 - first;
  }

  int? _maxThirdValue() {
    final first = _firstThrows[9];
    final second = _secondThrows[9];
    if (first == null || second == null) return null;
    if (first == 10) {
      if (second == 10) {
        return 10;
      }
      return 10 - second;
    }
    if (first + second == 10) {
      return 10;
    }
    return null;
  }

  void _clampThirdThrow() {
    if (!_needsThirdThrow) {
      _thirdThrow = null;
      return;
    }
    final maxThird = _maxThirdValue();
    if (maxThird != null && _thirdThrow != null && _thirdThrow! > maxThird) {
      _thirdThrow = null;
    }
  }

  bool get _allFramesValid {
    for (var i = 0; i < 10; i++) {
      if (_firstThrows[i] == null || _secondThrows[i] == null) {
        return false;
      }
    }
    if (_needsThirdThrow && _thirdThrow == null) {
      return false;
    }
    return true;
  }

  Future<void> _save() async {
    if (!_allFramesValid) return;
    setState(() => _saving = true);
    final frames = List<BowliardsFrame>.generate(
      10,
      (i) => BowliardsFrame(
        frameIndex: i + 1,
        firstThrow: _firstThrows[i]!,
        secondThrow: _secondThrows[i]!,
        thirdThrow: i == 9 && _needsThirdThrow ? _thirdThrow : null,
      ),
    );

    final session = PracticeSession(
      id: widget.initialSession?.id ?? const Uuid().v4(),
      date: widget.date,
      type: PracticeType.bowliards,
      note: widget.initialSession?.note,
      totalScore: _totalScore,
      bowliardsData: BowliardsData(frames: frames),
    );

    await context.read<PracticeSessionRepository>().addSession(session);
    if (mounted) Navigator.of(context).pop(true);
  }

  void _selectFirst(int frame, int value) {
    setState(() {
      _firstThrows[frame] = value;
      if (value == 10 && frame < 9) {
        _secondThrows[frame] = 0;
        _advanceFrame(frame);
        return;
      }
      final maxSecond = _maxSecondValue(frame);
      if (_secondThrows[frame] != null && _secondThrows[frame]! > maxSecond) {
        _secondThrows[frame] = null;
      }
      if (frame == 9) {
        _clampThirdThrow();
      }
    });
  }

  void _selectSecond(int frame, int value) {
    if (_firstThrows[frame] == null) return;
    final maxSecond = _maxSecondValue(frame);
    if (value > maxSecond) return;
    setState(() {
      _secondThrows[frame] = value;
      if (frame == 9) {
        _clampThirdThrow();
      } else {
        _advanceFrame(frame);
      }
    });
  }

  void _advanceFrame(int frame) {
    if (_currentFrame == frame && _currentFrame < 9) {
      _currentFrame++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialSession != null
              ? 'Bowliards – Edit Session'
              : 'Bowliards – New Session',
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
            _BowlingScoreboard(
              firstThrows: _firstThrows,
              secondThrows: _secondThrows,
              thirdThrow: _thirdThrow,
              currentFrame: _currentFrame,
              getSubtotal: (i) => List.generate(
                i + 1,
                (j) => _getFrameScore(j),
              ).fold(0, (a, b) => a + b),
              onFrameTap: (frame) => setState(() => _currentFrame = frame),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildFrameInput(_currentFrame)),
            const SizedBox(height: 16),
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
                      onPressed: _currentFrame < 9
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
            const SizedBox(height: 8),
            Text(
              'Total score: $_totalScore',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrameInput(int frame) {
    final maxSecond = _maxSecondValue(frame);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frame ${frame + 1}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          const Text('1st throw'),
          _scoreRow(
            values: List.generate(6, (v) => v),
            selected: _firstThrows[frame],
            onTap: (v) => _selectFirst(frame, v),
          ),
          _scoreRow(
            values: List.generate(5, (v) => v + 6),
            selected: _firstThrows[frame],
            onTap: (v) => _selectFirst(frame, v),
          ),
          const SizedBox(height: 16),
          const Text('2nd throw'),
          _scoreRow(
            values: List.generate(6, (v) => v),
            selected: _secondThrows[frame],
            maxValue: maxSecond,
            onTap: (v) => _selectSecond(frame, v),
          ),
          _scoreRow(
            values: List.generate(5, (v) => v + 6),
            selected: _secondThrows[frame],
            maxValue: maxSecond,
            onTap: (v) => _selectSecond(frame, v),
          ),
          if (frame == 9 && _needsThirdThrow) ...[
            const SizedBox(height: 16),
            const Text('3rd throw'),
            Builder(
              builder: (_) {
                final maxThird = _maxThirdValue() ?? 10;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _scoreRow(
                      values: List.generate(6, (v) => v),
                      selected: _thirdThrow,
                      maxValue: maxThird,
                      onTap: (v) => setState(() => _thirdThrow = v),
                    ),
                    _scoreRow(
                      values: List.generate(5, (v) => v + 6),
                      selected: _thirdThrow,
                      maxValue: maxThird,
                      onTap: (v) => setState(() => _thirdThrow = v),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _scoreRow({
    required List<int> values,
    required int? selected,
    required void Function(int) onTap,
    int? maxValue,
  }) {
    final filtered = maxValue != null
        ? values.where((v) => v <= maxValue).toList()
        : values;
    if (filtered.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: filtered
          .map(
            (v) => SizedBox(
              width: 44,
              height: 36,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selected == v ? Colors.teal : null,
                  foregroundColor: selected == v ? Colors.white : null,
                  padding: EdgeInsets.zero,
                ),
                onPressed: () => onTap(v),
                child: Text('$v'),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _BowlingScoreboard extends StatelessWidget {
  final List<int?> firstThrows;
  final List<int?> secondThrows;
  final int? thirdThrow;
  final int currentFrame;
  final int Function(int) getSubtotal;
  final void Function(int) onFrameTap;

  const _BowlingScoreboard({
    required this.firstThrows,
    required this.secondThrows,
    required this.thirdThrow,
    required this.currentFrame,
    required this.getSubtotal,
    required this.onFrameTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;
    final baseFill = Colors.white.withOpacity(0.04);
    final currentFill = accent.withOpacity(0.18);
    final borderShade = accent.withOpacity(0.35);
    final subtotalStyle = theme.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: Colors.white,
      letterSpacing: 0.2,
    );

    return Wrap(
      alignment: WrapAlignment.start,
      runAlignment: WrapAlignment.start,
      spacing: 4,
      runSpacing: 4,
      children: List.generate(10, (i) {
        final isCurrent = i == currentFrame;
        final first = firstThrows[i];
        final second = secondThrows[i];
        final isTenth = i == 9;
        final third = isTenth ? thirdThrow : null;
        final subtotal = (first != null && second != null)
            ? getSubtotal(i)
            : null;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onFrameTap(i),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            decoration: BoxDecoration(
              color: isCurrent ? currentFill : baseFill,
              border: Border.all(
                color: isCurrent ? accent : borderShade,
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: accent.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            width: isTenth ? 72 : 56,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _scoreCell(context, first),
                    const SizedBox(width: 2),
                    _scoreCell(context, second),
                    if (isTenth) ...[
                      const SizedBox(width: 2),
                      _scoreCell(context, third),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtotal?.toString() ?? '',
                  style: subtotalStyle,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _scoreCell(BuildContext context, int? value) {
    final theme = Theme.of(context);
    return Container(
      width: 18,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Text(
        value?.toString() ?? '',
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

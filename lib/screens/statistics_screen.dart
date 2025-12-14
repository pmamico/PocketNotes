import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/practice_session_repository.dart';
import '../models/practice_session.dart';
import '../models/practice_type.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Future<List<PracticeSession>> _sessionsFuture;
  StatsRange _weeklyRange = StatsRange.last4;
  PracticeType _selectedPracticeType = PracticeType.bowliards;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = _fetchSessions();
  }

  Future<List<PracticeSession>> _fetchSessions() async {
    final repo = context.read<PracticeSessionRepository>();
    final sessions = await repo.getAllSessions();
    return sessions;
  }

  Future<void> _refresh() async {
    final future = _fetchSessions();
    setState(() {
      _sessionsFuture = future;
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statisztikák')),
      body: FutureBuilder<List<PracticeSession>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(onRetry: _refresh);
          }
          final sessions = snapshot.data ?? [];
          if (sessions.isEmpty) {
            return _EmptyState(onRefresh: _refresh);
          }
          return _buildContent(sessions);
        },
      ),
    );
  }

  Widget _buildContent(List<PracticeSession> sessions) {
    final bowliardsSessions = sessions
        .where((s) => s.type == PracticeType.bowliards)
        .toList();
    final opgSessions = sessions
        .where((s) => s.type == PracticeType.onePocketGhost)
        .toList();
    final credenceSessions = sessions
        .where((s) => s.type == PracticeType.nineBallCredenceGhost)
        .toList();

    final bowliardsEvents = _buildEventSeries(
      bowliardsSessions,
      (s) => s.totalScore?.toDouble(),
    );
    final bowliardsWeekly = _buildWeeklyAverages(
      bowliardsSessions,
      (s) => s.totalScore?.toDouble(),
    );

    final opgEvents = _buildEventSeries(
      opgSessions,
      (s) => s.totalScore?.toDouble(),
    );
    final opgWeekly = _buildWeeklyAverages(
      opgSessions,
      (s) => s.totalScore?.toDouble(),
    );

    double? _credenceScoreSelector(PracticeSession session) {
      return session.nineBallCredenceGhostData?.totalScore ??
          session.totalScore?.toDouble();
    }

    final credenceEvents = _buildEventSeries(
      credenceSessions,
      _credenceScoreSelector,
    );
    final credenceWeekly = _buildWeeklyAverages(
      credenceSessions,
      _credenceScoreSelector,
    );

    final practiceCardConfigs = <PracticeType, _PracticeStatsCardConfig>{
      PracticeType.bowliards: _PracticeStatsCardConfig(
        title: 'Bowliards',
        color: Colors.teal,
        eventPoints: bowliardsEvents,
        weeklyPoints: _filterByRange(bowliardsWeekly, _weeklyRange),
        unitSuffix: ' pont',
        valueFormatter: (value) => value.toStringAsFixed(0),
        summary: _buildSummary(bowliardsEvents),
      ),
      PracticeType.onePocketGhost: _PracticeStatsCardConfig(
        title: 'One Pocket Ghost',
        color: Colors.indigo,
        eventPoints: opgEvents,
        weeklyPoints: _filterByRange(opgWeekly, _weeklyRange),
        unitSuffix: ' pont',
        valueFormatter: (value) => value.toStringAsFixed(0),
        summary: _buildSummary(opgEvents),
      ),
      PracticeType.nineBallCredenceGhost: _PracticeStatsCardConfig(
        title: '9 Ball Credence',
        color: Colors.cyan,
        eventPoints: credenceEvents,
        weeklyPoints: _filterByRange(credenceWeekly, _weeklyRange),
        unitSuffix: ' cb',
        valueFormatter: (value) => value.toStringAsFixed(1),
        summary: _buildSummary(credenceEvents),
      ),
    };
    final selectedPracticeType =
        practiceCardConfigs.containsKey(_selectedPracticeType)
        ? _selectedPracticeType
        : practiceCardConfigs.keys.first;
    final selectedPracticeConfig = practiceCardConfigs[selectedPracticeType]!;

    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text('Gyakorlatok', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: practiceCardConfigs.entries
                .map(
                  (entry) => ChoiceChip(
                    label: Text(entry.value.title),
                    selected: entry.key == selectedPracticeType,
                    onSelected: (_) =>
                        setState(() => _selectedPracticeType = entry.key),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          _RangeSelector(
            selected: _weeklyRange,
            onChanged: (range) => setState(() => _weeklyRange = range),
          ),
          const SizedBox(height: 12),
          _PracticeStatsCard(
            title: selectedPracticeConfig.title,
            color: selectedPracticeConfig.color,
            eventPoints: selectedPracticeConfig.eventPoints,
            weeklyPoints: selectedPracticeConfig.weeklyPoints,
            valueFormatter: selectedPracticeConfig.valueFormatter,
            unitSuffix: selectedPracticeConfig.unitSuffix,
            summary: selectedPracticeConfig.summary,
          ),
        ],
      ),
    );
  }

  List<_ChartPoint> _buildEventSeries(
    List<PracticeSession> sessions,
    double? Function(PracticeSession) selector,
  ) {
    final points = <_ChartPoint>[];
    for (final session in sessions) {
      final value = selector(session);
      if (value == null) continue;
      points.add(_ChartPoint(session.date, value));
    }
    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }

  List<_ChartPoint> _buildWeeklyAverages(
    List<PracticeSession> sessions,
    double? Function(PracticeSession) selector,
  ) {
    final buckets = <DateTime, _Accumulator>{};
    for (final session in sessions) {
      final value = selector(session);
      if (value == null) continue;
      final weekStart = _startOfWeek(session.date);
      buckets.putIfAbsent(weekStart, () => _Accumulator()).add(value);
    }
    final points =
        buckets.entries
            .map((entry) => _ChartPoint(entry.key, entry.value.average))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    return points;
  }

  _PracticeStatsSummary _buildSummary(List<_ChartPoint> points) {
    if (points.isEmpty) {
      return const _PracticeStatsSummary();
    }
    final maxPoint = points.reduce(
      (current, next) => next.value >= current.value ? next : current,
    );
    final values = points.map((p) => p.value).toList()..sort();
    final sum = values.reduce((a, b) => a + b);
    final average = sum / values.length;
    final mid = values.length ~/ 2;
    final median = values.length.isOdd
        ? values[mid]
        : (values[mid - 1] + values[mid]) / 2;
    return _PracticeStatsSummary(
      maxPoint: maxPoint,
      average: average,
      median: median,
    );
  }
}

class _PracticeStatsCardConfig {
  const _PracticeStatsCardConfig({
    required this.title,
    required this.color,
    required this.eventPoints,
    required this.weeklyPoints,
    required this.unitSuffix,
    required this.valueFormatter,
    required this.summary,
  });

  final String title;
  final Color color;
  final List<_ChartPoint> eventPoints;
  final List<_ChartPoint> weeklyPoints;
  final String unitSuffix;
  final String Function(double) valueFormatter;
  final _PracticeStatsSummary summary;
}

class _PracticeStatsSummary {
  const _PracticeStatsSummary({this.maxPoint, this.average, this.median});

  final _ChartPoint? maxPoint;
  final double? average;
  final double? median;
}

class _PracticeStatsCard extends StatelessWidget {
  const _PracticeStatsCard({
    required this.title,
    required this.color,
    required this.eventPoints,
    required this.weeklyPoints,
    required this.valueFormatter,
    required this.unitSuffix,
    required this.summary,
  });

  final String title;
  final Color color;
  final List<_ChartPoint> eventPoints;
  final List<_ChartPoint> weeklyPoints;
  final String Function(double) valueFormatter;
  final String unitSuffix;
  final _PracticeStatsSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _LineChartCard(
              title: 'Események',
              color: color,
              points: eventPoints,
              unitSuffix: unitSuffix,
              valueFormatter: valueFormatter,
            ),
            const SizedBox(height: 16),
            _LineChartCard(
              title: 'Heti átlag',
              color: color,
              points: weeklyPoints,
              unitSuffix: unitSuffix,
              valueFormatter: valueFormatter,
            ),
            const SizedBox(height: 20),
            _PracticeSummaryMetrics(
              summary: summary,
              unitSuffix: unitSuffix,
              valueFormatter: valueFormatter,
            ),
          ],
        ),
      ),
    );
  }
}

class _PracticeSummaryMetrics extends StatelessWidget {
  const _PracticeSummaryMetrics({
    required this.summary,
    required this.unitSuffix,
    required this.valueFormatter,
  });

  final _PracticeStatsSummary summary;
  final String unitSuffix;
  final String Function(double) valueFormatter;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final tiles = [
      _SummaryTile(
        icon: Icons.military_tech,
        title: 'Legmagasabb pont',
        value: summary.maxPoint != null
            ? '${valueFormatter(summary.maxPoint!.value)}$unitSuffix'
            : '—',
        subtitle: summary.maxPoint != null
            ? localizations.formatMediumDate(summary.maxPoint!.date)
            : 'Nincs adat',
      ),
      _SummaryTile(
        icon: Icons.show_chart,
        title: 'Átlag',
        value: summary.average != null
            ? '${valueFormatter(summary.average!)}$unitSuffix'
            : '—',
      ),
      _SummaryTile(
        icon: Icons.timeline,
        title: 'Medián',
        value: summary.median != null
            ? '${valueFormatter(summary.median!)}$unitSuffix'
            : '—',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 ? 3 : 1;
        final spacing = 12.0;
        if (columns == 1) {
          return Column(
            children: [
              for (var i = 0; i < tiles.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: i == tiles.length - 1 ? 0 : spacing,
                  ),
                  child: tiles[i],
                ),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < tiles.length; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: i == tiles.length - 1 ? 0 : spacing,
                  ),
                  child: tiles[i],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
  });

  final String title;
  final String value;
  final IconData icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.surfaceVariant.withOpacity(0.35);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: baseColor,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.secondary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _LineChartCard extends StatelessWidget {
  final String title;
  final List<_ChartPoint> points;
  final Color color;
  final String unitSuffix;
  final String Function(double) valueFormatter;

  const _LineChartCard({
    required this.title,
    required this.points,
    required this.color,
    required this.unitSuffix,
    required this.valueFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.outlineVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 1.6,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: points.isEmpty
                ? Center(
                    child: Text(
                      'Nincs adat',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : LineChart(_buildData()),
          ),
        ),
      ],
    );
  }

  LineChartData _buildData() {
    final spots = points
        .map(
          (point) =>
              FlSpot(point.date.millisecondsSinceEpoch.toDouble(), point.value),
        )
        .toList();
    final minX = spots.first.x;
    final maxX = spots.last.x;
    final minY = points.map((p) => p.value).reduce(math.min);
    final maxY = points.map((p) => p.value).reduce(math.max);
    final yPadding = (maxY - minY).abs() < 1 ? 1.5 : (maxY - minY) * 0.1;
    final xPadding = minX == maxX
        ? const Duration(days: 1).inMilliseconds.toDouble()
        : 0;

    return LineChartData(
      minX: minX - xPadding,
      maxX: maxX + xPadding,
      minY: minY - yPadding,
      maxY: maxY + yPadding,
      gridData: FlGridData(show: true, drawVerticalLine: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) => Text(
              valueFormatter(value),
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            getTitlesWidget: (value, meta) => Text(
              _formatDateLabel(value),
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          barWidth: 3,
          color: color,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: color.withValues(alpha: 0.12),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => Colors.black87,
          tooltipRoundedRadius: 8,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
              return LineTooltipItem(
                '${_formatTooltipDate(date)}\n${valueFormatter(spot.y)}$unitSuffix',
                const TextStyle(color: Colors.white),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  String _formatDateLabel(double value) {
    final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month.$day';
  }

  String _formatTooltipDate(DateTime date) {
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year.$month.$day';
  }
}

class _RangeSelector extends StatelessWidget {
  final StatsRange selected;
  final ValueChanged<StatsRange> onChanged;

  const _RangeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: StatsRange.values
          .map(
            (range) => ChoiceChip(
              label: Text(range.label),
              selected: range == selected,
              onSelected: (_) => onChanged(range),
            ),
          )
          .toList(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Future<void> Function() onRefresh;
  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(child: Text('Még nincs rögzített esemény.')),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Future<void> Function() onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Nem sikerült betölteni a statisztikát.'),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Újra')),
        ],
      ),
    );
  }
}

class _ChartPoint {
  final DateTime date;
  final double value;
  const _ChartPoint(this.date, this.value);
}

class _Accumulator {
  double _sum = 0;
  int _count = 0;

  void add(double value) {
    _sum += value;
    _count += 1;
  }

  double get average => _count == 0 ? 0 : _sum / _count;
}

DateTime _startOfWeek(DateTime date) {
  final weekdayIndex = date.weekday; // Monday = 1 ... Sunday = 7
  return DateTime(date.year, date.month, date.day - (weekdayIndex - 1));
}

List<_ChartPoint> _filterByRange(List<_ChartPoint> points, StatsRange range) {
  final weeks = range.weeks;
  if (weeks == null) return points;
  final cutoff = DateTime.now().subtract(Duration(days: weeks * 7));
  return points.where((p) => !p.date.isBefore(_startOfWeek(cutoff))).toList();
}

enum StatsRange { last4, last10, last52, all }

extension StatsRangeX on StatsRange {
  int? get weeks {
    switch (this) {
      case StatsRange.last4:
        return 4;
      case StatsRange.last10:
        return 10;
      case StatsRange.last52:
        return 52;
      case StatsRange.all:
        return null;
    }
  }

  String get label {
    switch (this) {
      case StatsRange.last4:
        return 'Utóbbi 4 hét';
      case StatsRange.last10:
        return 'Utóbbi 10 hét';
      case StatsRange.last52:
        return 'Utóbbi 52 hét';
      case StatsRange.all:
        return 'Összes';
    }
  }
}

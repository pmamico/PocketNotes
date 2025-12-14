import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../data/practice_session_repository.dart';
import '../models/practice_session.dart';
import '../models/practice_type.dart';
import '../widgets/pocket_notes_logo.dart';
import 'day_sessions_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<PracticeSession>> _sessionsByDay = {};
  bool _loading = true;
  static const Map<PracticeType, Color> _typeColors = {
    PracticeType.bowliards: Color(0xFF1AA57A),
    PracticeType.onePocketGhost: Color(0xFF5E60CE),
    PracticeType.gameDay: Color(0xFFF4A259),
    PracticeType.competition: Color(0xFFE24E59),
    PracticeType.nineBallCredenceGhost: Color(0xFF32B5C5),
  };
  static const Map<PracticeType, IconData> _typeIcons = {
    PracticeType.bowliards: FontAwesomeIcons.bowlingBall,
    PracticeType.onePocketGhost: FontAwesomeIcons.ghost,
    PracticeType.gameDay: FontAwesomeIcons.faceGrinStars,
    PracticeType.competition: FontAwesomeIcons.trophy,
    PracticeType.nineBallCredenceGhost: FontAwesomeIcons.bullseye,
  };
  static const IconData _multiTypeIcon = FontAwesomeIcons.layerGroup;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadSessionsForMonth(_focusedDay);
  }

  Future<void> _loadSessionsForMonth(DateTime month) async {
    setState(() => _loading = true);
    final repo = context.read<PracticeSessionRepository>();
    final sessions = await repo.getSessionsForMonth(month);
    final byDay = <DateTime, List<PracticeSession>>{};
    for (final s in sessions) {
      final d = DateTime(s.date.year, s.date.month, s.date.day);
      byDay.putIfAbsent(d, () => []).add(s);
    }
    setState(() {
      _sessionsByDay = byDay;
      _loading = false;
    });
  }

  List<PracticeSession> _getSessionsForDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return _sessionsByDay[d] ?? [];
  }

  Color _colorForType(PracticeType type) => _typeColors[type] ?? Colors.grey;
  IconData _iconForType(PracticeType type) => _typeIcons[type] ?? Icons.circle;

  Widget _buildMarkerIcon(Color color, IconData icon) {
    return Container(
      width: 18,
      height: 18,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.6), width: 1),
      ),
      child: Icon(icon, size: 10, color: color),
    );
  }

  Future<void> _openDaySessions(DateTime day) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => DaySessionsScreen(date: day)));
    if (!mounted) return;
    await _loadSessionsForMonth(_focusedDay);
  }

  Widget? _buildMarker(
    BuildContext context,
    DateTime date,
    List<PracticeSession> events,
  ) {
    if (events.isEmpty) return null;
    final uniqueTypes = events.map((session) => session.type).toSet();
    if (uniqueTypes.isEmpty) return null;

    final orderedTypes = PracticeType.values
        .where((type) => uniqueTypes.contains(type))
        .toList();
    final theme = Theme.of(context);
    final markers = orderedTypes.length > 2
        ? [
            _buildMarkerIcon(
              theme.colorScheme.secondary,
              _multiTypeIcon,
            ),
          ]
        : orderedTypes
            .map(
              (type) => _buildMarkerIcon(
                _colorForType(type),
                _iconForType(type),
              ),
            )
            .toList();
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: markers,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedDay = _selectedDay ?? DateTime.now();
    final sessionsForSelectedDay = _getSessionsForDay(selectedDay);
    final localizations = MaterialLocalizations.of(context);
    final dayLabel = localizations.formatFullDate(selectedDay);
    final monthLabel = localizations.formatMonthYear(_focusedDay);
    final labelStyle =
        theme.textTheme.labelMedium ?? const TextStyle(color: Colors.white70);
    final bodyStyle =
        theme.textTheme.bodyMedium ?? const TextStyle(color: Colors.white);
    final calendarTitleStyle =
        (theme.textTheme.titleMedium ?? const TextStyle()).copyWith(
          fontWeight: FontWeight.w600,
        );
    final dayEntrySummary = sessionsForSelectedDay.isEmpty
      ? 'No entries for this day'
      : sessionsForSelectedDay.length == 1
        ? '1 entry on this day'
        : '${sessionsForSelectedDay.length} entries on this day';

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF030C07), Color(0xFF05160F), Color(0xFF0B3A28)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          titleSpacing: 16,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const PocketNotesLogo(size: 44),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PocketNotes', style: theme.textTheme.titleLarge),
                  Text(
                    'Billiards training journal',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.query_stats),
              tooltip: 'Statistics',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StatisticsScreen()),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayLabel,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: _PocketPanel(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: TableCalendar<PracticeSession>(
                                  firstDay: DateTime.utc(2020, 1, 1),
                                  lastDay: DateTime.utc(2100, 12, 31),
                                  focusedDay: _focusedDay,
                                  selectedDayPredicate: (day) =>
                                      isSameDay(_selectedDay, day),
                                  eventLoader: (day) => _getSessionsForDay(day),
                                  onDaySelected: (selected, focused) {
                                    setState(() {
                                      _selectedDay = selected;
                                      _focusedDay = focused;
                                    });
                                  },
                                  onPageChanged: (focused) {
                                    _focusedDay = focused;
                                    _loadSessionsForMonth(focused);
                                  },
                                  headerStyle: HeaderStyle(
                                    formatButtonVisible: false,
                                    titleCentered: true,
                                    titleTextStyle: calendarTitleStyle,
                                    leftChevronIcon: Icon(
                                      Icons.chevron_left,
                                      color: theme.colorScheme.secondary,
                                    ),
                                    rightChevronIcon: Icon(
                                      Icons.chevron_right,
                                      color: theme.colorScheme.secondary,
                                    ),
                                  ),
                                  daysOfWeekStyle: DaysOfWeekStyle(
                                    weekdayStyle: labelStyle,
                                    weekendStyle: labelStyle.copyWith(
                                      color: theme.colorScheme.secondary,
                                    ),
                                  ),
                                  calendarStyle: CalendarStyle(
                                    markersAlignment: Alignment.bottomCenter,
                                    markersMaxCount: 4,
                                    markerSizeScale: 0.9,
                                    todayDecoration: BoxDecoration(
                                      border: Border.all(
                                        color: theme.colorScheme.secondary,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    selectedDecoration: BoxDecoration(
                                      color: theme.colorScheme.secondary,
                                      shape: BoxShape.circle,
                                    ),
                                    defaultTextStyle: bodyStyle,
                                    weekendTextStyle: bodyStyle.copyWith(
                                      color: theme.colorScheme.secondary,
                                    ),
                                    outsideDaysVisible: false,
                                  ),
                                  calendarBuilders:
                                      CalendarBuilders<PracticeSession>(
                                        markerBuilder: _buildMarker,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _PocketPanel(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          dayEntrySummary,
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  FilledButton.icon(
                                    onPressed: () =>
                                        _openDaySessions(selectedDay),
                                    icon: const Icon(Icons.open_in_new),
                                    label: const Text('Open day'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _PocketPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  const _PocketPanel({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x4426402C), Color(0x11000000)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.25)),
          child: child,
        ),
      ),
    );
  }
}

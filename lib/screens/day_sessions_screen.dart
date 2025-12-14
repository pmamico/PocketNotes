import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/practice_session_repository.dart';
import '../models/practice_session.dart';
import '../models/practice_type.dart';
import '../widgets/practice_type_selector.dart';
import '../widgets/session_list_tile.dart';
import 'bowliards_logging_screen.dart';
import 'competition_logging_screen.dart';
import 'game_day_logging_sheet.dart';
import 'one_pocket_ghost_logging_screen.dart';

class DaySessionsScreen extends StatefulWidget {
  final DateTime date;
  const DaySessionsScreen({super.key, required this.date});

  @override
  State<DaySessionsScreen> createState() => _DaySessionsScreenState();
}

class _DaySessionsScreenState extends State<DaySessionsScreen> {
  static const Map<PracticeType, Color> _typeColors = {
    PracticeType.bowliards: Color(0xFF1AA57A),
    PracticeType.onePocketGhost: Color(0xFF5E60CE),
    PracticeType.gameDay: Color(0xFFF4A259),
    PracticeType.competition: Color(0xFFE24E59),
  };

  late PracticeSessionRepository _repository;
  bool _initialized = false;
  bool _loading = true;
  List<PracticeSession> _sessions = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _repository = context.read<PracticeSessionRepository>();
      _loadSessions();
      _initialized = true;
    }
  }

  Color _colorForType(PracticeType type) => _typeColors[type] ?? Colors.grey;

  Future<void> _loadSessions() async {
    setState(() => _loading = true);
    final sessions = await _repository.getSessionsForDate(widget.date);
    setState(() {
      _sessions = sessions;
      _loading = false;
    });
  }

  Future<void> _editSession(PracticeSession session) async {
    Future<bool?> openEditor() {
      switch (session.type) {
        case PracticeType.bowliards:
          return Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BowliardsLoggingScreen(
                date: session.date,
                initialSession: session,
              ),
            ),
          );
        case PracticeType.onePocketGhost:
          return Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OnePocketGhostLoggingScreen(
                date: session.date,
                initialSession: session,
              ),
            ),
          );
        case PracticeType.gameDay:
          return showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            builder: (_) => GameDayLoggingSheet(
              date: session.date,
              initialSession: session,
            ),
          );
        case PracticeType.competition:
          return Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CompetitionLoggingScreen(
                date: session.date,
                initialSession: session,
              ),
            ),
          );
      }
    }

    final result = await openEditor();
    if (result == true) {
      await _loadSessions();
    }
  }

  Future<void> _addSession() async {
    final type = await showModalBottomSheet<PracticeType>(
      context: context,
      builder: (context) => PracticeTypeSelector(
        onSelected: (type) => Navigator.of(context).pop(type),
      ),
    );
    if (type == null) return;

    Future<bool?> navigateToLogger() {
      switch (type) {
        case PracticeType.bowliards:
          return Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BowliardsLoggingScreen(date: widget.date),
            ),
          );
        case PracticeType.onePocketGhost:
          return Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OnePocketGhostLoggingScreen(date: widget.date),
            ),
          );
        case PracticeType.gameDay:
          return showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            builder: (_) => GameDayLoggingSheet(date: widget.date),
          );
        case PracticeType.competition:
          return Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CompetitionLoggingScreen(date: widget.date),
            ),
          );
      }
    }

    final result = await navigateToLogger();
    if (result == true) {
      await _loadSessions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final dayLabel = localizations.formatFullDate(widget.date);

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dayLabel),
            Text(
              '${_sessions.length} feljegyzés',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.crop_free, size: 40, color: Colors.white54),
                      const SizedBox(height: 8),
                      Text(
                        'Nincs feljegyzés erre a napra',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Koppints az "Új bejegyzés" gombra és kezdd el a napot.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _sessions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final session = _sessions[index];
                    return SessionListTile(
                      session: session,
                      color: _colorForType(session.type),
                      onTap: () => _editSession(session),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSession,
        icon: const Icon(Icons.add),
        label: const Text('Új bejegyzés'),
      ),
    );
  }
}

import 'package:hive/hive.dart';
import '../models/practice_session.dart';

class PracticeSessionRepository {
  static const String boxName = 'practice_sessions';

  Future<Box<PracticeSession>> _openBox() async {
    return await Hive.openBox<PracticeSession>(boxName);
  }

  Future<List<PracticeSession>> getSessionsForDate(DateTime date) async {
    final box = await _openBox();
    final sessions = box.values.where((session) =>
      session.date.year == date.year &&
      session.date.month == date.month &&
      session.date.day == date.day
    ).toList();
    sessions.sort((a, b) => a.date.compareTo(b.date));
    return sessions;
  }

  Future<List<PracticeSession>> getSessionsForMonth(DateTime month) async {
    final box = await _openBox();
    return box.values.where((session) =>
      session.date.year == month.year &&
      session.date.month == month.month
    ).toList();
  }

  Future<void> addSession(PracticeSession session) async {
    final box = await _openBox();
    await box.put(session.id, session);
  }

  Future<void> deleteSession(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }

  Future<PracticeSession?> getSessionById(String id) async {
    final box = await _openBox();
    return box.get(id);
  }

  Future<List<PracticeSession>> getAllSessions() async {
    final box = await _openBox();
    final sessions = box.values.toList();
    sessions.sort((a, b) => a.date.compareTo(b.date));
    return sessions;
  }
}

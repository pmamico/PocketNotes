// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:notes/main.dart';
import 'package:notes/models/bowliards_data.dart';
import 'package:notes/models/bowliards_frame.dart';
import 'package:notes/models/competition_data.dart';
import 'package:notes/models/competition_round.dart';
import 'package:notes/models/game_day_data.dart';
import 'package:notes/models/one_pocket_ghost_data.dart';
import 'package:notes/models/practice_session.dart';
import 'package:notes/models/practice_type.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final dir = await Directory.systemTemp.createTemp('notes_hive_test');
    Hive.init(dir.path);
    Hive.registerAdapter(PracticeTypeAdapter());
    Hive.registerAdapter(PracticeSessionAdapter());
    Hive.registerAdapter(BowliardsFrameAdapter());
    Hive.registerAdapter(BowliardsDataAdapter());
    Hive.registerAdapter(OnePocketGhostDataAdapter());
    Hive.registerAdapter(GameDayDataAdapter());
    Hive.registerAdapter(CompetitionRoundAdapter());
    Hive.registerAdapter(CompetitionDataAdapter());
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
  });

  testWidgets('Home screen renders title', (tester) async {
    await tester.pumpWidget(const PocketNotesApp());

    expect(find.text('PocketNotes'), findsWidgets);
  });
}

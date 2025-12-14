import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/practice_type.dart';
import 'models/practice_session.dart';
import 'models/bowliards_frame.dart';
import 'models/bowliards_data.dart';
import 'models/one_pocket_ghost_data.dart';
import 'models/game_day_data.dart';
import 'models/competition_round.dart';
import 'models/competition_data.dart';
import 'models/nine_ball_credence_ghost_data.dart';
import 'data/practice_session_repository.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PracticeTypeAdapter());
  Hive.registerAdapter(PracticeSessionAdapter());
  Hive.registerAdapter(BowliardsFrameAdapter());
  Hive.registerAdapter(BowliardsDataAdapter());
  Hive.registerAdapter(OnePocketGhostDataAdapter());
  Hive.registerAdapter(GameDayDataAdapter());
  Hive.registerAdapter(CompetitionRoundAdapter());
  Hive.registerAdapter(CompetitionDataAdapter());
  Hive.registerAdapter(NineBallCredenceFrameAdapter());
  Hive.registerAdapter(NineBallCredenceGhostDataAdapter());
  runApp(const PocketNotesApp());
}

class PocketNotesApp extends StatelessWidget {
  const PocketNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [Provider(create: (_) => PracticeSessionRepository())],
      child: MaterialApp(
        title: 'PocketNotes',
        theme: _buildPocketTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}

ThemeData _buildPocketTheme() {
  const background = Color(0xFF04130E);
  const surface = Color(0xFF0B2319);
  const accent = Color(0xFFE3B55A);
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF1AA57A),
    brightness: Brightness.dark,
    background: background,
    surface: surface,
  );
  final baseTextTheme = ThemeData(brightness: Brightness.dark).textTheme;
  final glassColor = Colors.white.withOpacity(0.04);

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: background,
    textTheme: baseTextTheme
        .apply(bodyColor: Colors.white, displayColor: Colors.white)
        .copyWith(
          headlineMedium: baseTextTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          titleLarge: baseTextTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
          labelSmall: baseTextTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.6,
          ),
        ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: baseTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: Colors.white,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: Colors.black87,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    dividerColor: Colors.white24,
    cardTheme: CardThemeData(
      color: glassColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: accent),
    ),
  );
}

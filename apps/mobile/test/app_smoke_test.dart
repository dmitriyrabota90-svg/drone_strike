import 'package:drone_strike/app/drone_strike_app.dart';
import 'package:drone_strike/core/assets/app_assets.dart';
import 'package:drone_strike/core/localization/app_locale_controller.dart';
import 'package:drone_strike/game/drone_game.dart';
import 'package:drone_strike/game/game_config.dart';
import 'package:drone_strike/game/level_config.dart';
import 'package:drone_strike/game/overlays/game_over_overlay.dart';
import 'package:drone_strike/game/overlays/mission_complete_overlay.dart';
import 'package:drone_strike/game/overlays/no_lives_overlay.dart';
import 'package:drone_strike/game/systems/level_generator.dart';
import 'package:drone_strike/game/systems/scoring_system.dart';
import 'package:drone_strike/l10n/generated/app_localizations.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> pumpDroneStrikeApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(const ProviderScope(child: DroneStrikeApp()));
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

Future<void> pumpOverlay(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('splash renders logo and subtitle', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(child: DroneStrikeApp()));
    await tester.pump();

    expect(find.image(const AssetImage(AppAssets.logo)), findsOneWidget);
    expect(find.text('FPV mission arcade'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  });

  testWidgets('app starts and main menu appears', (tester) async {
    await pumpDroneStrikeApp(tester);

    expect(find.image(const AssetImage(AppAssets.logo)), findsOneWidget);
    expect(find.text('Level Select'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
  });

  testWidgets('main menu hides Continue for a new guest', (tester) async {
    await pumpDroneStrikeApp(tester);

    expect(find.text('Continue'), findsNothing);
  });

  testWidgets('login screen renders email and password fields', (tester) async {
    await pumpDroneStrikeApp(tester);

    await tester.tap(find.text('Login').first);
    await tester.pumpAndSettle();

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('register screen renders legal checkboxes', (tester) async {
    await pumpDroneStrikeApp(tester);

    await tester.tap(find.text('Login').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Register').last);
    await tester.pumpAndSettle();

    expect(find.text('I accept the terms of use'), findsOneWidget);
    expect(find.text('I accept personal data processing'), findsOneWidget);
    expect(find.text('I am at least 13 years old'), findsOneWidget);
  });

  testWidgets('profile screen renders guest state', (tester) async {
    await pumpDroneStrikeApp(tester);

    await tester.ensureVisible(find.text('Profile'));
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Guest mode'), findsOneWidget);
    expect(find.text('Login required'), findsOneWidget);
  });

  testWidgets('level select unlocks missions 1 and 2 for guest', (
    tester,
  ) async {
    await pumpDroneStrikeApp(tester);

    await tester.tap(find.text('Level Select'));
    await tester.pumpAndSettle();

    expect(find.text('Mission 1'), findsOneWidget);
    expect(find.text('Mission 2'), findsOneWidget);
    expect(find.text('Mission 3'), findsOneWidget);
    expect(find.text('Locked'), findsWidgets);
  });

  testWidgets('guest can open mission 2 but mission 3 stays locked', (
    tester,
  ) async {
    await pumpDroneStrikeApp(tester);

    await tester.tap(find.text('Level Select'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mission 3'));
    await tester.pumpAndSettle();

    expect(find.text('Registration required'), findsOneWidget);
    expect(find.text('Mission: 3'), findsNothing);

    await tester.tap(find.text('Mission 2'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Mission: 2'), findsOneWidget);
  });

  testWidgets('leaderboard screen requires login for guest', (tester) async {
    await pumpDroneStrikeApp(tester);

    await tester.ensureVisible(find.text('Leaderboard'));
    await tester.tap(find.text('Leaderboard'));
    await tester.pumpAndSettle();

    expect(find.text('Login required to view leaderboard'), findsOneWidget);
  });

  testWidgets('mission 1 opens Flame game screen', (tester) async {
    await pumpDroneStrikeApp(tester);

    await tester.tap(find.text('Level Select'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mission 1'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Mission: 1'), findsOneWidget);
    expect(find.text('Lives: 3'), findsOneWidget);
    expect(find.text('Tap to start'), findsOneWidget);
  });

  testWidgets('first game tap starts mission', (tester) async {
    await pumpDroneStrikeApp(tester);

    await tester.tap(find.text('Level Select'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mission 1'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Tap to start'), findsOneWidget);

    await tester.tapAt(const Offset(400, 300));
    await tester.pump();

    expect(find.text('Tap to start'), findsNothing);
  });

  testWidgets('pause button opens pause overlay', (tester) async {
    await pumpDroneStrikeApp(tester);

    await tester.tap(find.text('Level Select'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mission 1'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();

    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('Restart mission'), findsOneWidget);
  });

  testWidgets('settings screen renders sound legal and account sections', (
    tester,
  ) async {
    await pumpDroneStrikeApp(tester);

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -360));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Sound'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Russian'), findsOneWidget);
    expect(find.text('Legal Documents'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
  });

  testWidgets('mission complete overlay renders fake mission result', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 450);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const result = MissionResult(
      missionNumber: 1,
      baseScore: 100,
      flightAccuracyBonus: 25,
      tankHitBonus: 30,
      totalScore: 155,
      isGuest: true,
      backendSubmitted: false,
    );

    await pumpOverlay(tester, const MissionCompleteOverlay(result: result));

    expect(find.text('Mission complete'), findsOneWidget);
    expect(find.text('Guest result'), findsOneWidget);
    expect(find.text('Total score'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('game over overlay shows remaining lives', (tester) async {
    final game = DroneGame(
      levelConfig: LevelConfig.forMission(1),
      initialPlayerLevel: 1,
    );
    game.updateLives(2);

    await pumpOverlay(tester, GameOverOverlay(game: game));

    expect(find.text('Mission failed'), findsOneWidget);
    expect(find.text('Remaining lives: 2'), findsOneWidget);
  });

  testWidgets('no lives overlay renders', (tester) async {
    SharedPreferences.setMockInitialValues({
      'lives.current_lives': 0,
      'lives.next_life_at': DateTime.now()
          .add(const Duration(minutes: 5))
          .toIso8601String(),
    });

    await pumpOverlay(tester, const NoLivesOverlay());

    expect(find.text('No lives'), findsOneWidget);
    expect(find.textContaining('Next life in'), findsOneWidget);
  });

  test('scoring clamps bonuses to expected ranges', () {
    final scoring = ScoringSystem();
    scoring.recordAccuracySample(
      droneCenterY: 100,
      gapCenterY: 100,
      gapHeight: 56,
    );
    final tankBonus = scoring.calculateTankHitBonus(
      droneCenter: const Offset(50, 50),
      tankRect: const Rect.fromLTWH(0, 0, 100, 100),
    );

    expect(scoring.flightAccuracyBonus, inInclusiveRange(0, 50));
    expect(tankBonus, inInclusiveRange(0, 50));
  });

  test('game physics uses glide-friendly velocity limits', () {
    expect(GameConfig.gravity, 460.0);
    expect(GameConfig.tapImpulse, -235.0);
    expect(GameConfig.startTapImpulse, -135.0);
    expect(GameConfig.maxRiseSpeed, -285.0);
    expect(GameConfig.maxFallSpeed, 390.0);
  });

  test('locale controller persists ru and en selections', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(await container.read(appLocaleControllerProvider.future), isNull);

    await container
        .read(appLocaleControllerProvider.notifier)
        .setLocale(const Locale('ru'));
    expect(
      container.read(appLocaleControllerProvider).requireValue?.languageCode,
      'ru',
    );

    var preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('settings.locale'), 'ru');

    await container
        .read(appLocaleControllerProvider.notifier)
        .setLocale(const Locale('en'));
    expect(
      container.read(appLocaleControllerProvider).requireValue?.languageCode,
      'en',
    );

    preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('settings.locale'), 'en');
  });

  test('level config keeps introductory gaps and smooth mission scaling', () {
    final mission1 = LevelConfig.forMission(1);
    final mission2 = LevelConfig.forMission(2);
    final mission3 = LevelConfig.forMission(3);
    final mission10 = LevelConfig.forMission(10);

    expect(mission1.gapMultiplier, 2.8);
    expect(mission2.gapMultiplier, 2.6);
    expect(mission3.gapMultiplier, 2.4);
    expect(mission10.gapMultiplier, greaterThanOrEqualTo(2.0));
    expect(mission1.finalZoneSeconds, 2.75);
    expect(mission10.finalZoneSeconds, 2.75);
    expect(mission1.forwardSpeed, lessThan(mission2.forwardSpeed));
    expect(mission2.forwardSpeed, lessThan(mission3.forwardSpeed));
    expect(mission10.forwardSpeed, greaterThan(mission3.forwardSpeed));
    expect(mission1.minObstacleSpacing, GameConfig.droneWidth * 4.1);
    expect(mission3.minObstacleSpacing, GameConfig.droneWidth * 4.0);
    expect(mission10.obstacleCount, 15);
  });

  test('level generator clamps generated gaps to MVP minimum', () {
    final generator = LevelGenerator();
    for (var mission = 1; mission <= 10; mission++) {
      final level = generator.generate(
        config: LevelConfig.forMission(mission),
        viewportSize: Vector2(800, 450),
      );

      for (final pair in level.obstaclePairs) {
        expect(
          pair.gapHeight,
          greaterThanOrEqualTo(GameConfig.droneHeight * 2),
        );
      }
    }
  });
}

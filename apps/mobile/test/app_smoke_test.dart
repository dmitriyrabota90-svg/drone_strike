import 'dart:io';
import 'dart:math' as math;

import 'package:drone_strike/app/drone_strike_app.dart';
import 'package:drone_strike/core/assets/app_assets.dart';
import 'package:drone_strike/core/localization/app_locale_controller.dart';
import 'package:drone_strike/features/achievements/data/achievements_repository.dart';
import 'package:drone_strike/features/achievements/domain/achievement_definition.dart';
import 'package:drone_strike/features/achievements/domain/achievement_evaluator.dart';
import 'package:drone_strike/features/lives/data/lives_repository.dart';
import 'package:drone_strike/features/lives/domain/lives_controller.dart';
import 'package:drone_strike/features/lives/domain/lives_state.dart';
import 'package:drone_strike/features/progress/data/progress_dto.dart';
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

Future<void> pumpGameScreenReady(WidgetTester tester) async {
  for (var i = 0; i < 100; i += 1) {
    await tester.pump(const Duration(milliseconds: 50));
    if (find.byKey(const ValueKey('hud_mission_badge')).evaluate().isNotEmpty) {
      return;
    }
  }
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
    expect(find.text('Forgot password?'), findsOneWidget);
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

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Mission 2'));
    await tester.tap(find.text('Mission 2').hitTestable());
    await pumpGameScreenReady(tester);

    expect(find.byKey(const ValueKey('hud_mission_badge')), findsOneWidget);
  });

  testWidgets('leaderboard screen requires login for guest', (tester) async {
    await pumpDroneStrikeApp(tester);

    await tester.ensureVisible(find.text('Leaderboard'));
    await tester.tap(find.text('Leaderboard'));
    await tester.pumpAndSettle();

    expect(find.text('Login required to view leaderboard'), findsOneWidget);
  });

  testWidgets('shop screen shows planned nickname change item', (tester) async {
    await pumpDroneStrikeApp(tester);

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -360));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Shop').hitTestable());
    await tester.pumpAndSettle();

    expect(find.text('Nickname change'), findsOneWidget);
    expect(find.text('Coming soon'), findsWidgets);
  });

  testWidgets('mission 1 opens Flame game screen', (tester) async {
    await pumpDroneStrikeApp(tester);

    await tester.tap(find.text('Level Select'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mission 1'));
    await pumpGameScreenReady(tester);

    expect(find.byKey(const ValueKey('hud_mission_badge')), findsOneWidget);
    expect(find.byKey(const ValueKey('hud_lives_indicator')), findsOneWidget);
    expect(find.byKey(const ValueKey('hud_mission_progress')), findsOneWidget);
    expect(find.text('Tap to start'), findsOneWidget);
  });

  testWidgets('first game tap starts mission', (tester) async {
    await pumpDroneStrikeApp(tester);

    await tester.tap(find.text('Level Select'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mission 1'));
    await pumpGameScreenReady(tester);

    expect(find.text('Tap to start'), findsOneWidget);

    await tester.tapAt(const Offset(400, 300));
    await tester.pump(const Duration(milliseconds: 60));

    expect(find.text('Tap to start'), findsNothing);
  });

  testWidgets('pause button opens pause overlay', (tester) async {
    await pumpDroneStrikeApp(tester);

    await tester.tap(find.text('Level Select'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mission 1'));
    await pumpGameScreenReady(tester);
    await tester.tap(find.byKey(const ValueKey('hud_pause_button')));
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

  testWidgets('achievements screen renders MVP achievement list', (
    tester,
  ) async {
    await pumpDroneStrikeApp(tester);

    await tester.ensureVisible(find.text('Achievements'));
    await tester.tap(find.text('Achievements'));
    await tester.pumpAndSettle();

    expect(find.text('Achievements'), findsWidgets);
    expect(find.text('First Run'), findsOneWidget);
    expect(find.text('Training Complete'), findsOneWidget);
    expect(find.text('Locked'), findsWidgets);
  });

  testWidgets('achievements screen shows local unlocked achievements', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'achievements.unlocked': '{"first_run":"2026-01-01T00:00:00.000Z"}',
    });
    await tester.pumpWidget(const ProviderScope(child: DroneStrikeApp()));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Achievements'));
    await tester.tap(find.text('Achievements'));
    await tester.pumpAndSettle();

    expect(find.text('First Run'), findsOneWidget);
    expect(find.textContaining('Unlocked: 2026-01-01'), findsOneWidget);
    expect(find.text('Locked'), findsWidgets);
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
      batteryBonus: 10,
      batteriesCollected: 2,
      totalScore: 165,
      isGuest: true,
      backendSubmitted: false,
    );

    await pumpOverlay(tester, const MissionCompleteOverlay(result: result));

    expect(find.text('Mission complete'), findsOneWidget);
    expect(find.text('Guest result'), findsOneWidget);
    expect(find.text('Battery bonus'), findsOneWidget);
    expect(find.text('Total score'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('game over overlay renders without duplicating lives', (
    tester,
  ) async {
    final game = DroneGame(
      levelConfig: LevelConfig.forMission(1),
      initialPlayerLevel: 1,
    );
    game.updateLives(2);

    await pumpOverlay(tester, GameOverOverlay(game: game));

    expect(find.text('Mission failed'), findsOneWidget);
    expect(find.textContaining('Remaining lives'), findsNothing);
  });

  testWidgets('no lives overlay renders', (tester) async {
    SharedPreferences.setMockInitialValues({
      'lives.current_lives': 0,
      'lives.next_life_at': DateTime.now()
          .add(const Duration(seconds: 90))
          .toIso8601String(),
    });

    await pumpOverlay(tester, const NoLivesOverlay());

    expect(find.text('No lives'), findsNothing);
    expect(find.textContaining('Next life in'), findsOneWidget);
  });

  testWidgets('no lives overlay closes when a life recovers', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repository = _FakeLivesRepository(
      const LivesState(
        currentLives: 1,
        maxLives: 5,
        nextLifeAt: null,
        recoverySecondsRemaining: 0,
        isPremium: false,
      ),
    );
    final container = ProviderContainer(
      overrides: [livesRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const DroneStrikeApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Level Select'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mission 1'));
    await pumpGameScreenReady(tester);

    repository.state = const LivesState(
      currentLives: 0,
      maxLives: 5,
      nextLifeAt: null,
      recoverySecondsRemaining: 90,
      isPremium: false,
    );
    await container.read(livesControllerProvider.notifier).recover();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('No lives'), findsNothing);
    expect(find.textContaining('Next life in'), findsOneWidget);

    repository.state = const LivesState(
      currentLives: 1,
      maxLives: 5,
      nextLifeAt: null,
      recoverySecondsRemaining: 0,
      isPremium: false,
    );
    await container.read(livesControllerProvider.notifier).recover();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('No lives'), findsNothing);
    expect(find.text('Tap to start'), findsOneWidget);
  });

  test('spending a life keeps ninety second recovery', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = LivesRepository();
    final now = DateTime.utc(2026, 1, 1, 12);

    final next = await repository.spendLife(now: now);

    expect(next.currentLives, 4);
    expect(next.nextLifeAt, now.add(const Duration(seconds: 90)));
    expect(next.recoverySecondsRemaining, 90);
  });

  test('lives balance uses five lives and 90 second recovery', () {
    final full = LivesState.full();

    expect(LivesState.normalMaxLives, 5);
    expect(LivesState.normalRecovery, const Duration(seconds: 90));
    expect(full.currentLives, 5);
    expect(full.maxLives, 5);
  });

  test('scoring clamps bonuses to expected ranges', () {
    final scoring = ScoringSystem();
    scoring.recordAccuracySample(
      droneCenterY: 100,
      gapCenterY: 100,
      gapHeight: 56,
    );
    final tankBonus = scoring.calculateTankHitBonus(
      droneRect: const Rect.fromLTWH(45, 45, 10, 10),
      tankRect: const Rect.fromLTWH(0, 0, 100, 100),
    );

    expect(scoring.flightAccuracyBonus, inInclusiveRange(0, 50));
    expect(tankBonus, 150);
  });

  test('tank hit bonus is zero without a successful hit', () {
    final scoring = ScoringSystem();
    final tankBonus = scoring.calculateTankHitBonus(
      droneRect: const Rect.fromLTWH(200, 200, 10, 10),
      tankRect: const Rect.fromLTWH(0, 0, 100, 100),
    );

    expect(tankBonus, 0);
  });

  test('battery scoring adds five points and caps at forty', () {
    final scoring = ScoringSystem();

    expect(scoring.collectBattery(1), isTrue);
    expect(scoring.collectBattery(1), isFalse);
    expect(scoring.batteriesCollected, 1);
    expect(scoring.batteryBonus, 5);

    for (var id = 2; id <= 20; id += 1) {
      scoring.collectBattery(id);
    }

    expect(scoring.batteryBonus, ScoringSystem.maxBatteryBonus);
    final result = scoring.buildMissionResult(
      missionNumber: 1,
      tankHitBonus: 30,
      isGuest: true,
    );
    expect(result.batteryBonus, ScoringSystem.maxBatteryBonus);
    expect(result.totalScore, result.coreScore + result.batteryBonus);
  });

  test('achievement definitions include exactly the 8 MVP icons', () {
    expect(achievementDefinitions, hasLength(8));
    expect(achievementDefinitions.map((definition) => definition.id).toSet(), {
      AchievementIds.firstRun,
      AchievementIds.trainingComplete,
      AchievementIds.fifthTarget,
      AchievementIds.mvpCampaign,
      AchievementIds.cleanHit,
      AchievementIds.bullseye,
      AchievementIds.stableFlight,
      AchievementIds.perfectScore,
    });
    expect(
      achievementDefinitions.map((definition) => definition.iconPath).toSet(),
      AppAssets.achievementIconAssets.toSet(),
    );
    for (final definition in achievementDefinitions) {
      expect(File(definition.iconPath).existsSync(), isTrue);
    }
  });

  test('achievement storage does not duplicate unlock timestamps', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = AchievementsRepository();
    final firstUnlock = DateTime.utc(2026, 1, 1);
    final secondUnlock = DateTime.utc(2026, 1, 2);

    final first = await repository.unlockAll([
      AchievementIds.firstRun,
    ], now: firstUnlock);
    final second = await repository.unlockAll([
      AchievementIds.firstRun,
    ], now: secondUnlock);

    expect(first, hasLength(1));
    expect(second, hasLength(1));
    expect(second[AchievementIds.firstRun], firstUnlock);
  });

  test('achievement evaluator unlocks mission result achievements', () {
    const result = MissionResult(
      missionNumber: 1,
      baseScore: ScoringSystem.baseScore,
      flightAccuracyBonus: 50,
      tankHitBonus: ScoringSystem.tankHitBonus,
      totalScore: ScoringSystem.maxScore,
      isGuest: true,
      backendSubmitted: false,
    );

    final unlocked = AchievementEvaluator.evaluate(missionResult: result);

    expect(unlocked, contains(AchievementIds.firstRun));
    expect(unlocked, contains(AchievementIds.cleanHit));
    expect(unlocked, contains(AchievementIds.bullseye));
    expect(unlocked, contains(AchievementIds.stableFlight));
    expect(unlocked, contains(AchievementIds.perfectScore));
  });

  test('achievement evaluator unlocks progress achievements', () {
    final progress = ProgressResponseDto(
      totalScore: 2000,
      playerLevel: 5,
      completedMissionsCount: 10,
      unlockedMission: 5,
      missions: [
        for (var mission = 1; mission <= 10; mission += 1)
          MissionProgressItemDto(
            missionNumber: mission,
            bestScore: mission == 1 ? ScoringSystem.maxScore : 150,
            bestFlightAccuracyBonus: mission == 2 ? 45 : 25,
            bestTankHitBonus: mission == 3 ? ScoringSystem.tankHitBonus : 30,
            completedAt: DateTime.utc(2026, 1, mission),
          ),
      ],
    );

    final unlocked = AchievementEvaluator.evaluate(progress: progress);

    expect(unlocked, contains(AchievementIds.firstRun));
    expect(unlocked, contains(AchievementIds.trainingComplete));
    expect(unlocked, contains(AchievementIds.fifthTarget));
    expect(unlocked, contains(AchievementIds.mvpCampaign));
    expect(unlocked, contains(AchievementIds.cleanHit));
    expect(unlocked, contains(AchievementIds.bullseye));
    expect(unlocked, contains(AchievementIds.stableFlight));
    expect(unlocked, contains(AchievementIds.perfectScore));
  });

  test('game physics uses glide-friendly velocity limits', () {
    expect(GameConfig.gravity, 460.0);
    expect(GameConfig.tapImpulse, -235.0);
    expect(GameConfig.startTapImpulse, -135.0);
    expect(GameConfig.maxRiseSpeed, -285.0);
    expect(GameConfig.maxFallSpeed, 390.0);
    expect(GameConfig.droneWidth, 84.0);
    expect(GameConfig.droneHeight, 48.0);
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
    final mission7 = LevelConfig.forMission(7);
    final mission10 = LevelConfig.forMission(10);
    final mission13 = LevelConfig.forMission(13);

    expect(mission1.minGapMultiplier, 4.1);
    expect(mission1.maxGapMultiplier, 6.5);
    expect(mission2.minGapMultiplier, 3.7);
    expect(mission2.maxGapMultiplier, 6.0);
    expect(mission3.minGapMultiplier, 3.2);
    expect(mission3.maxGapMultiplier, 5.4);
    expect(mission7.minGapMultiplier, 2.4);
    expect(mission7.maxGapMultiplier, 3.9);
    expect(mission10.minGapMultiplier, 2.3);
    expect(mission10.maxGapMultiplier, 3.6);
    expect(mission13.minGapMultiplier, 2.3);
    expect(mission13.maxGapMultiplier, 3.6);
    expect(mission1.finalZoneSeconds, 2.75);
    expect(mission10.finalZoneSeconds, 2.75);
    expect(mission1.forwardSpeed, lessThan(mission2.forwardSpeed));
    expect(mission2.forwardSpeed, lessThan(mission3.forwardSpeed));
    expect(mission10.forwardSpeed, greaterThan(mission3.forwardSpeed));
    expect(mission1.minObstacleSpacing, 320.0);
    expect(mission1.maxObstacleSpacing, 520.0);
    expect(mission3.minObstacleSpacing, 280.0);
    expect(mission3.maxObstacleSpacing, 470.0);
    expect(mission7.minObstacleSpacing, 220.0);
    expect(mission7.maxObstacleSpacing, 390.0);
    expect(mission1.obstacleCount, 8);
    expect(mission1.batteryCount, 3);
    expect(mission3.obstacleCount, 12);
    expect(mission3.batteryCount, 5);
    expect(mission7.obstacleCount, 20);
    expect(mission7.batteryCount, 7);
    expect(mission10.obstacleCount, 22);
    expect(mission10.batteryCount, 8);
    expect(mission13.obstacleCount, 22);
    expect(mission13.batteryCount, 8);
    expect(GameConfig.tankExplosionDelaySeconds, 1.2);
  });

  test('level generator clamps generated gaps to MVP minimum', () {
    final generator = LevelGenerator();
    for (var mission = 1; mission <= 10; mission++) {
      final level = generator.generate(
        config: LevelConfig.forMission(mission),
        viewportSize: Vector2(800, 450),
      );

      if (mission == 1) {
        expect(level.obstaclePairs, hasLength(8));
        expect(level.batteries, hasLength(3));
      }
      if (mission == 3) {
        expect(level.obstaclePairs, hasLength(12));
        expect(level.batteries, hasLength(5));
      }
      if (mission == 7) {
        expect(level.obstaclePairs, hasLength(20));
        expect(level.batteries, hasLength(7));
      }

      for (final pair in level.obstaclePairs) {
        expect(
          pair.gapHeight,
          greaterThanOrEqualTo(GameConfig.droneHeight * 2.3),
        );
      }

      final roundedGaps = level.obstaclePairs
          .map((pair) => pair.gapHeight.round())
          .toSet();
      final roundedTrees = level.obstaclePairs
          .map((pair) => pair.treeHeight.round())
          .toSet();
      final roundedNets = level.obstaclePairs
          .map((pair) => pair.netHeight.round())
          .toSet();
      final roundedSpacings = level.obstaclePairs
          .skip(1)
          .map((pair) => pair.spacingFromPrevious.round())
          .toSet();
      final gapCenters = level.obstaclePairs
          .map((pair) => (pair.gapTopY + pair.gapBottomY) / 2)
          .toList();
      final heightDifferences = level.obstaclePairs
          .map((pair) => (pair.treeHeight - pair.netHeight).abs())
          .toList();
      expect(roundedGaps.length, greaterThan(1));
      expect(roundedTrees.length, greaterThan(1));
      expect(roundedNets.length, greaterThan(1));
      expect(roundedSpacings.length, greaterThan(1));
      expect(
        gapCenters.reduce(math.max) - gapCenters.reduce(math.min),
        greaterThan(GameConfig.droneHeight * 1.2),
      );
      expect(
        heightDifferences
            .where((difference) => difference > GameConfig.droneHeight * 0.75)
            .length,
        greaterThanOrEqualTo(level.obstaclePairs.length ~/ 3),
      );
      for (final pair in level.obstaclePairs) {
        expect(pair.gapTopY, greaterThanOrEqualTo(GameConfig.playableTopY));
        expect(
          pair.gapBottomY,
          lessThanOrEqualTo(450 - GameConfig.bottomBoundaryHeight),
        );
      }
    }

    final mission1Level = generator.generate(
      config: LevelConfig.forMission(1),
      viewportSize: Vector2(800, 450),
    );
    final mission7Level = generator.generate(
      config: LevelConfig.forMission(7),
      viewportSize: Vector2(800, 450),
    );
    expect(
      _averageSpacing(mission7Level),
      lessThan(_averageSpacing(mission1Level)),
    );
  });
}

double _averageSpacing(GeneratedLevel level) {
  final spacings = level.obstaclePairs
      .skip(1)
      .map((pair) => pair.spacingFromPrevious)
      .toList();
  return spacings.reduce((value, element) => value + element) / spacings.length;
}

class _FakeLivesRepository extends LivesRepository {
  _FakeLivesRepository(this.state);

  LivesState state;

  @override
  Future<LivesState> load({DateTime? now}) async => state;

  @override
  Future<LivesState> recoverLivesIfNeeded({DateTime? now}) async => state;

  @override
  Future<LivesState> spendLife({DateTime? now}) async {
    if (!state.hasLives) {
      return state;
    }
    state = state.copyWith(
      currentLives: state.currentLives - 1,
      nextLifeAt: (now ?? DateTime.now()).add(state.recoveryDuration),
      recoverySecondsRemaining: state.recoveryDuration.inSeconds,
    );
    return state;
  }

  @override
  Future<void> save(LivesState state) async {
    this.state = state;
  }
}

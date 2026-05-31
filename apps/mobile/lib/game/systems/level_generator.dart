import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import '../components/battery_component.dart';
import '../components/obstacle_pair_component.dart';
import '../components/tank_component.dart';
import '../game_config.dart';
import '../game_visual_theme.dart';
import '../level_config.dart';
import '../obstacle_asset_registry.dart';

class GeneratedLevel {
  const GeneratedLevel({
    required this.obstaclePairs,
    required this.batteries,
    required this.tank,
  });

  final List<ObstaclePairComponent> obstaclePairs;
  final List<BatteryComponent> batteries;
  final TankComponent tank;
}

class GeneratedObstacleData {
  const GeneratedObstacleData({
    required this.index,
    required this.x,
    required this.spacingFromPrevious,
    required this.gapBand,
    required this.gapTopY,
    required this.gapBottomY,
    required this.gapHeight,
    required this.treeHeight,
    required this.netHeight,
  });

  final int index;
  final double x;
  final double spacingFromPrevious;
  final GeneratedGapBand gapBand;
  final double gapTopY;
  final double gapBottomY;
  final double gapHeight;
  final double treeHeight;
  final double netHeight;
}

class LevelGenerator {
  const LevelGenerator();

  GeneratedLevel generate({
    required LevelConfig config,
    required Vector2 viewportSize,
    required GameVisualTheme visualTheme,
  }) {
    final ceilingY = GameConfig.playableTopY;
    final groundY = viewportSize.y - GameConfig.bottomBoundaryHeight;
    final minGapHeight = GameConfig.droneHeight * 2.3;
    final minNetHeight = math.max(42.0, viewportSize.y * 0.10);
    final minTreeHeight = math.max(70.0, viewportSize.y * 0.15);
    final availablePlayHeight = groundY - ceilingY;
    final maxPlayableGapHeight = math.max(
      minGapHeight,
      availablePlayHeight - minNetHeight - minTreeHeight,
    );
    final verticalVarietyReserve = math.max(
      GameConfig.droneHeight * 1.5,
      viewportSize.y * 0.18,
    );
    final maxVariedGapHeight = math.max(
      minGapHeight,
      maxPlayableGapHeight - verticalVarietyReserve,
    );
    final firstObstacleX = viewportSize.x + (config.isTutorial ? 300.0 : 250.0);
    final random = math.Random(config.missionNumber * 7919 + 97);
    final generated = <GeneratedObstacleData>[];

    var currentX = firstObstacleX;
    for (var index = 0; index < config.obstacleCount; index++) {
      final spacingFromPrevious = index == 0
          ? 0.0
          : _randomInRange(
              random,
              config.minObstacleSpacing,
              config.maxObstacleSpacing,
            );
      if (index > 0) {
        currentX += spacingFromPrevious;
      }

      final gapBand = _gapBandFor(index, config.missionNumber);
      final gapHeight = _generateGapHeight(
        random: random,
        band: gapBand,
        config: config,
        minGapHeight: minGapHeight,
        maxPlayableGapHeight: maxPlayableGapHeight,
        maxVariedGapHeight: maxVariedGapHeight,
      );
      final minGapTopY = ceilingY + minNetHeight;
      final maxGapTopY = groundY - minTreeHeight - gapHeight;
      final gapTopY = _generateGapTopY(
        random: random,
        band: gapBand,
        minGapTopY: minGapTopY,
        maxGapTopY: maxGapTopY,
      );
      final gapBottomY = gapTopY + gapHeight;
      final treeHeight = groundY - gapBottomY;
      final netHeight = gapTopY - ceilingY;

      generated.add(
        GeneratedObstacleData(
          index: index,
          x: currentX,
          spacingFromPrevious: spacingFromPrevious,
          gapBand: gapBand,
          gapTopY: gapTopY,
          gapBottomY: gapBottomY,
          gapHeight: gapHeight,
          treeHeight: treeHeight,
          netHeight: netHeight,
        ),
      );
    }

    final pairs = [
      for (final obstacle in generated)
        ObstaclePairComponent(
          worldX: obstacle.x,
          spacingFromPrevious: obstacle.spacingFromPrevious,
          gapTopY: obstacle.gapTopY,
          gapBottomY: obstacle.gapBottomY,
          treeHeight: obstacle.treeHeight,
          netHeight: obstacle.netHeight,
          gapHeight: obstacle.gapHeight,
          width: config.obstacleWidth,
          bottomVariant: ObstacleAssetRegistry.pick(
            mount: ObstacleMount.bottom,
            height: obstacle.treeHeight,
            theme: visualTheme,
            seed: config.missionNumber * 101 + obstacle.index * 17,
          ),
          topVariant: ObstacleAssetRegistry.pick(
            mount: ObstacleMount.top,
            height: obstacle.netHeight,
            theme: visualTheme,
            seed: config.missionNumber * 131 + obstacle.index * 19,
          ),
          variantSeed: config.missionNumber * 31 + obstacle.index,
        ),
    ];
    final batteries = _generateBatteries(
      config: config,
      obstacles: generated,
      random: random,
      viewportHeight: viewportSize.y,
    );

    if (kDebugMode) {
      debugPrint(_formatDebugLog(config, generated));
    }

    return GeneratedLevel(
      obstaclePairs: pairs,
      batteries: batteries,
      tank: TankComponent(
        worldX:
            pairs.last.worldX + config.forwardSpeed * config.finalZoneSeconds,
      ),
    );
  }

  List<BatteryComponent> _generateBatteries({
    required LevelConfig config,
    required List<GeneratedObstacleData> obstacles,
    required math.Random random,
    required double viewportHeight,
  }) {
    if (obstacles.length < 2 || config.batteryCount <= 0) {
      return const [];
    }

    final batteries = <BatteryComponent>[];
    final usedObstacleIndexes = <int>{};
    final ceilingY = GameConfig.playableTopY;
    final groundY = viewportHeight - GameConfig.bottomBoundaryHeight;
    final verticalMargin = GameConfig.batteryHeight * 1.1;
    for (var index = 0; index < config.batteryCount; index++) {
      final targetPosition =
          ((index + 1) * obstacles.length / (config.batteryCount + 1)).round() -
          1;
      final obstacleIndex = targetPosition.clamp(0, obstacles.length - 2);
      if (!usedObstacleIndexes.add(obstacleIndex)) {
        continue;
      }

      final previous = obstacles[obstacleIndex];
      final next = obstacles[obstacleIndex + 1];
      final segmentStartX = previous.x + config.obstacleWidth * 1.35;
      final segmentEndX = next.x - config.obstacleWidth * 0.45;
      if (segmentEndX <= segmentStartX) {
        continue;
      }

      final travelT = 0.42 + random.nextDouble() * 0.18;
      final safeY = _lerp(
        (previous.gapTopY + previous.gapBottomY) / 2,
        (next.gapTopY + next.gapBottomY) / 2,
        travelT,
      );
      final offsetDirection = _batteryOffsetDirection(
        safeY: safeY,
        ceilingY: ceilingY,
        groundY: groundY,
        index: index,
        random: random,
      );
      final offsetScale = config.isTutorial ? 0.34 : 0.48;
      final riskOffset = math.max(
        GameConfig.droneHeight * (config.isTutorial ? 0.85 : 1.1),
        math.min(previous.gapHeight, next.gapHeight) * offsetScale,
      );
      final centerY = (safeY + offsetDirection * riskOffset).clamp(
        ceilingY + verticalMargin,
        groundY - verticalMargin,
      );
      final xJitter =
          (random.nextDouble() - 0.5) * math.min(56.0, config.obstacleWidth);
      batteries.add(
        BatteryComponent(
          id: index,
          worldX: _lerp(segmentStartX, segmentEndX, travelT) + xJitter,
          worldCenterY: centerY.toDouble(),
        ),
      );
    }

    return batteries;
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  double _batteryOffsetDirection({
    required double safeY,
    required double ceilingY,
    required double groundY,
    required int index,
    required math.Random random,
  }) {
    final upperRoom = safeY - ceilingY;
    final lowerRoom = groundY - safeY;
    if (upperRoom < GameConfig.droneHeight * 2.0) {
      return 1;
    }
    if (lowerRoom < GameConfig.droneHeight * 2.0) {
      return -1;
    }
    return (index + (random.nextBool() ? 0 : 1)).isEven ? -1 : 1;
  }

  double _randomInRange(math.Random random, double min, double max) {
    return min + (max - min) * random.nextDouble();
  }

  GeneratedGapBand _gapBandFor(int index, int missionNumber) {
    return switch ((index * 7 + missionNumber * 3) % 20) {
      0 || 1 || 2 || 3 || 4 || 5 || 6 => GeneratedGapBand.center,
      7 || 8 || 9 || 10 || 11 || 12 => GeneratedGapBand.high,
      13 || 14 || 15 || 16 || 17 || 18 => GeneratedGapBand.low,
      _ => GeneratedGapBand.varied,
    };
  }

  double _generateGapHeight({
    required math.Random random,
    required GeneratedGapBand band,
    required LevelConfig config,
    required double minGapHeight,
    required double maxPlayableGapHeight,
    required double maxVariedGapHeight,
  }) {
    final configMinGapHeight = math.max(
      GameConfig.droneHeight * config.minGapMultiplier,
      minGapHeight,
    );
    final configMaxGapHeight = math.max(
      configMinGapHeight,
      GameConfig.droneHeight * config.maxGapMultiplier,
    );
    final absoluteMax = math.min(configMaxGapHeight, maxPlayableGapHeight);
    final variedMax = math.min(configMaxGapHeight, maxVariedGapHeight);
    final upper = switch (band) {
      GeneratedGapBand.center => absoluteMax,
      _ => variedMax,
    };
    final lower = switch (band) {
      GeneratedGapBand.center => math.min(configMinGapHeight, upper),
      _ => minGapHeight,
    };

    if (upper <= lower) {
      return lower.clamp(minGapHeight, maxPlayableGapHeight).toDouble();
    }
    return _randomInRange(random, lower, upper)
        .clamp(minGapHeight, maxPlayableGapHeight)
        .toDouble();
  }

  double _generateGapTopY({
    required math.Random random,
    required GeneratedGapBand band,
    required double minGapTopY,
    required double maxGapTopY,
  }) {
    if (maxGapTopY <= minGapTopY) {
      return minGapTopY;
    }

    final span = maxGapTopY - minGapTopY;
    final t = switch (band) {
      GeneratedGapBand.high => _randomInRange(random, 0.0, 0.28),
      GeneratedGapBand.center => _randomInRange(random, 0.38, 0.62),
      GeneratedGapBand.low => _randomInRange(random, 0.72, 1.0),
      GeneratedGapBand.varied => random.nextDouble(),
    };
    return minGapTopY + span * t;
  }

  String _formatDebugLog(
    LevelConfig config,
    List<GeneratedObstacleData> obstacles,
  ) {
    final buffer = StringBuffer()
      ..writeln(
        'LevelGenerator mission=${config.missionNumber} '
        'count=${config.obstacleCount} '
        'gapRange=${config.minGapMultiplier.toStringAsFixed(1)}..'
        '${config.maxGapMultiplier.toStringAsFixed(1)} '
        'spacingRange=${config.minObstacleSpacing.toStringAsFixed(0)}..'
        '${config.maxObstacleSpacing.toStringAsFixed(0)}',
      );
    for (final obstacle in obstacles) {
      buffer.writeln(
        '  obstacle=${obstacle.index} '
        'band=${obstacle.gapBand.name} '
        'x=${obstacle.x.toStringAsFixed(1)} '
        'spacing=${obstacle.spacingFromPrevious.toStringAsFixed(1)} '
        'gapTop=${obstacle.gapTopY.toStringAsFixed(1)} '
        'gapBottom=${obstacle.gapBottomY.toStringAsFixed(1)} '
        'gap=${obstacle.gapHeight.toStringAsFixed(1)} '
        'tree=${obstacle.treeHeight.toStringAsFixed(1)} '
        'net=${obstacle.netHeight.toStringAsFixed(1)}',
      );
    }
    return buffer.toString().trimRight();
  }
}

enum GeneratedGapBand { high, center, low, varied }

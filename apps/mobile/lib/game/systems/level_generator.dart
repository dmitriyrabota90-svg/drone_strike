import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import '../components/obstacle_pair_component.dart';
import '../components/tank_component.dart';
import '../game_config.dart';
import '../level_config.dart';

class GeneratedLevel {
  const GeneratedLevel({required this.obstaclePairs, required this.tank});

  final List<ObstaclePairComponent> obstaclePairs;
  final TankComponent tank;
}

class GeneratedObstacleData {
  const GeneratedObstacleData({
    required this.index,
    required this.x,
    required this.spacingFromPrevious,
    required this.gapTopY,
    required this.gapBottomY,
    required this.gapHeight,
    required this.treeHeight,
    required this.netHeight,
  });

  final int index;
  final double x;
  final double spacingFromPrevious;
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
  }) {
    final ceilingY = GameConfig.topBoundaryHeight;
    final groundY = viewportSize.y - GameConfig.bottomBoundaryHeight;
    final minGapHeight = GameConfig.droneHeight * 2.3;
    final minNetHeight = math.max(42.0, viewportSize.y * 0.10);
    final minTreeHeight = math.max(70.0, viewportSize.y * 0.15);
    final maxPlayableGapHeight = math.max(
      minGapHeight,
      groundY - ceilingY - minNetHeight - minTreeHeight,
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

      final gapMultiplier = _randomInRange(
        random,
        config.minGapMultiplier,
        config.maxGapMultiplier,
      );
      final gapHeight = math
          .max(GameConfig.droneHeight * gapMultiplier, minGapHeight)
          .clamp(minGapHeight, maxPlayableGapHeight)
          .toDouble();
      final minGapTopY = ceilingY + minNetHeight;
      final maxGapTopY = groundY - minTreeHeight - gapHeight;
      final gapTopY = maxGapTopY <= minGapTopY
          ? minGapTopY
          : _randomInRange(random, minGapTopY, maxGapTopY);
      final gapBottomY = gapTopY + gapHeight;
      final treeHeight = groundY - gapBottomY;
      final netHeight = gapTopY - ceilingY;

      generated.add(
        GeneratedObstacleData(
          index: index,
          x: currentX,
          spacingFromPrevious: spacingFromPrevious,
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
          variantSeed: config.missionNumber * 31 + obstacle.index,
        ),
    ];

    if (kDebugMode) {
      debugPrint(_formatDebugLog(config, generated));
    }

    return GeneratedLevel(
      obstaclePairs: pairs,
      tank: TankComponent(
        worldX:
            pairs.last.worldX + config.forwardSpeed * config.finalZoneSeconds,
      ),
    );
  }

  double _randomInRange(math.Random random, double min, double max) {
    return min + (max - min) * random.nextDouble();
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

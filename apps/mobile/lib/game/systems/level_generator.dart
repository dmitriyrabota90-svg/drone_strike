import 'dart:math' as math;

import 'package:flame/components.dart';

import '../components/obstacle_pair_component.dart';
import '../components/tank_component.dart';
import '../game_config.dart';
import '../level_config.dart';

class GeneratedLevel {
  const GeneratedLevel({required this.obstaclePairs, required this.tank});

  final List<ObstaclePairComponent> obstaclePairs;
  final TankComponent tank;
}

class LevelGenerator {
  const LevelGenerator();

  GeneratedLevel generate({
    required LevelConfig config,
    required Vector2 viewportSize,
  }) {
    final gapHeight = GameConfig.droneHeight * config.gapMultiplier;
    final bottomY = viewportSize.y - GameConfig.bottomBoundaryHeight;
    final usableTop = GameConfig.topBoundaryHeight + 44;
    final usableBottom = bottomY - 92 - gapHeight;
    final safeBottom = math.max(usableTop, usableBottom);
    final obstacleZoneStart = viewportSize.x + 260;
    final obstacleZoneEnd =
        config.obstacleZoneDistance - config.finalZoneDistance * 0.45;
    final spacing = math.max(
      config.minObstacleSpacing,
      (obstacleZoneEnd - obstacleZoneStart) / config.obstacleCount,
    );

    final pairs = <ObstaclePairComponent>[];
    for (var i = 0; i < config.obstacleCount; i++) {
      final wave = math.sin((i + 1) * 1.37 + config.missionNumber * 0.43);
      final spacingJitter = (i % 3 - 1) * 18.0;
      final worldX = obstacleZoneStart + spacing * i + spacingJitter;
      final isLast = i == config.obstacleCount - 1;
      final pairGapHeight = isLast ? gapHeight + 18 : gapHeight;
      final gapTop = usableTop + (safeBottom - usableTop) * ((wave + 1) / 2);
      final netHeight = gapTop - GameConfig.topBoundaryHeight;
      final treeTop = gapTop + pairGapHeight;
      final treeHeight = math.max(72.0, bottomY - treeTop);

      pairs.add(
        ObstaclePairComponent(
          worldX: worldX,
          treeHeight: treeHeight,
          netHeight: netHeight,
          gapHeight: pairGapHeight,
          width: config.obstacleWidth,
        ),
      );
    }

    final tankWorldX =
        config.obstacleZoneDistance + config.finalZoneDistance * 0.62;

    return GeneratedLevel(
      obstaclePairs: pairs,
      tank: TankComponent(worldX: tankWorldX),
    );
  }
}

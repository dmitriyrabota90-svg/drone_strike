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
    final minimumGapHeight = GameConfig.droneHeight * 2.0;
    final gapHeight = math.max(
      GameConfig.droneHeight * config.gapMultiplier,
      minimumGapHeight,
    );
    final bottomY = viewportSize.y - GameConfig.bottomBoundaryHeight;
    final usableTop = GameConfig.topBoundaryHeight + 48;
    final usableBottom = bottomY - 98 - gapHeight;
    final safeBottom = math.max(usableTop, usableBottom);
    final obstacleZoneStart = viewportSize.x + (config.isTutorial ? 330 : 285);
    final tankWorldX =
        config.obstacleZoneDistance + config.finalZoneDistance * 0.78;
    final lastObstacleWorldX =
        tankWorldX - config.forwardSpeed * config.finalZoneSeconds;
    final spacingDivisor = math.max(1, config.obstacleCount - 1);
    final spacing = math.max(
      config.minObstacleSpacing,
      (lastObstacleWorldX - obstacleZoneStart) / spacingDivisor,
    );

    final pairs = <ObstaclePairComponent>[];
    for (var i = 0; i < config.obstacleCount; i++) {
      final wave = math.sin((i + 1) * 1.37 + config.missionNumber * 0.43);
      final spacingJitter = (i % 3 - 1) * (config.isTutorial ? 12.0 : 18.0);
      final isLast = i == config.obstacleCount - 1;
      final worldX = isLast
          ? lastObstacleWorldX
          : math.min(
              obstacleZoneStart + spacing * i + spacingJitter,
              lastObstacleWorldX - config.minObstacleSpacing,
            );
      final pairGapHeight = isLast ? gapHeight + 22 : gapHeight;
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

    return GeneratedLevel(
      obstaclePairs: pairs,
      tank: TankComponent(worldX: tankWorldX),
    );
  }
}

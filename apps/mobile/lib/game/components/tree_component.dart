import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game_config.dart';

class TreeComponent extends PositionComponent {
  TreeComponent({
    required this.worldX,
    required this.treeHeight,
    required this.treeWidth,
  });

  double worldX;
  double treeHeight;
  double treeWidth;

  @override
  Future<void> onLoad() async {
    await add(RectangleHitbox());
  }

  Rect get collisionRect {
    return Rect.fromLTWH(
      position.x + treeWidth * 0.12,
      position.y + 2,
      treeWidth * 0.76,
      treeHeight - 2,
    );
  }

  void updateWorld({
    required double worldOffset,
    required double viewportHeight,
  }) {
    size = Vector2(treeWidth, treeHeight);
    position = Vector2(
      worldX - worldOffset,
      viewportHeight - GameConfig.bottomBoundaryHeight - treeHeight,
    );
  }

  @override
  void render(Canvas canvas) {
    final trunkPaint = Paint()..color = const Color(0xFF7B4A2A);
    final trunkShadowPaint = Paint()..color = const Color(0xFF4A2C1C);
    final crownPaint = Paint()..color = const Color(0xFF2D7A46);
    final crownDarkPaint = Paint()..color = const Color(0xFF1D5935);

    final trunkWidth = treeWidth * 0.24;
    final trunkX = (treeWidth - trunkWidth) / 2;
    canvas.drawRect(
      Rect.fromLTWH(trunkX, treeHeight * 0.34, trunkWidth, treeHeight * 0.66),
      trunkPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        trunkX + trunkWidth * 0.55,
        treeHeight * 0.34,
        trunkWidth * 0.35,
        treeHeight * 0.66,
      ),
      trunkShadowPaint,
    );

    final crownHeight = treeHeight * 0.58;
    canvas.drawRect(
      Rect.fromLTWH(treeWidth * 0.08, 0, treeWidth * 0.84, crownHeight),
      crownPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(treeWidth * 0.16, crownHeight * 0.18, treeWidth * 0.68, 10),
      crownDarkPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(treeWidth * 0.04, crownHeight * 0.46, treeWidth * 0.92, 12),
      crownDarkPaint,
    );
  }
}

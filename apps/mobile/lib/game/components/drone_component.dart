import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game_config.dart';

class DroneComponent extends PositionComponent {
  DroneComponent()
    : super(size: Vector2(GameConfig.droneWidth, GameConfig.droneHeight));

  double verticalVelocity = 0;

  @override
  Future<void> onLoad() async {
    await add(
      RectangleHitbox(
        size: Vector2(GameConfig.droneWidth - 10, GameConfig.droneHeight - 8),
        position: Vector2(5, 4),
      ),
    );
  }

  @override
  void update(double dt) {
    verticalVelocity += GameConfig.gravity * dt;
    position.y += verticalVelocity * dt;
  }

  void boost() {
    verticalVelocity = GameConfig.tapImpulse;
  }

  void resetTo(Vector2 startPosition) {
    position = startPosition;
    verticalVelocity = 0;
  }

  @override
  void render(Canvas canvas) {
    final bodyPaint = Paint()..color = const Color(0xFF89D8FF);
    final shadowPaint = Paint()..color = const Color(0xFF1C3954);
    final rotorPaint = Paint()..color = const Color(0xFFE8F7FF);
    final cameraPaint = Paint()..color = const Color(0xFFFFD166);

    canvas.drawRect(const Rect.fromLTWH(16, 10, 26, 12), bodyPaint);
    canvas.drawRect(const Rect.fromLTWH(12, 14, 34, 6), shadowPaint);
    canvas.drawRect(const Rect.fromLTWH(42, 13, 8, 8), cameraPaint);

    canvas.drawRect(const Rect.fromLTWH(7, 5, 11, 5), rotorPaint);
    canvas.drawRect(const Rect.fromLTWH(7, 22, 11, 5), rotorPaint);
    canvas.drawRect(const Rect.fromLTWH(39, 5, 11, 5), rotorPaint);
    canvas.drawRect(const Rect.fromLTWH(39, 22, 11, 5), rotorPaint);

    canvas.drawRect(const Rect.fromLTWH(13, 9, 6, 14), bodyPaint);
    canvas.drawRect(const Rect.fromLTWH(38, 9, 6, 14), bodyPaint);
  }
}

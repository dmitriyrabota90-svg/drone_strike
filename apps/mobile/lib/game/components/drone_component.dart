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
        size: Vector2(GameConfig.droneWidth - 16, GameConfig.droneHeight - 14),
        position: Vector2(8, 7),
      ),
    );
  }

  @override
  void update(double dt) {
    verticalVelocity += GameConfig.gravity * dt;
    verticalVelocity = verticalVelocity.clamp(
      GameConfig.maxRiseSpeed,
      GameConfig.maxFallSpeed,
    );
    position.y += verticalVelocity * dt;
  }

  void boost() {
    verticalVelocity = GameConfig.tapImpulse;
  }

  void startBoost() {
    verticalVelocity = GameConfig.startTapImpulse;
  }

  void resetTo(Vector2 startPosition) {
    position = startPosition;
    verticalVelocity = 0;
  }

  @override
  void render(Canvas canvas) {
    final armPaint = Paint()..color = const Color(0xFF5AAFD2);
    final bodyPaint = Paint()..color = const Color(0xFF10263A);
    final bodyLightPaint = Paint()..color = const Color(0xFF8BE2FF);
    final rotorPaint = Paint()..color = const Color(0xFFE8F7FF);
    final rotorShadowPaint = Paint()..color = const Color(0xFF4C7890);
    final cameraPaint = Paint()..color = const Color(0xFFFFD166);
    final redAccentPaint = Paint()..color = const Color(0xFFFF5A66);
    final blueAccentPaint = Paint()..color = const Color(0xFF4DA3FF);

    canvas.drawRect(const Rect.fromLTWH(11, 8, 36, 4), armPaint);
    canvas.drawRect(const Rect.fromLTWH(11, 20, 36, 4), armPaint);
    canvas.drawRect(const Rect.fromLTWH(15, 6, 5, 20), armPaint);
    canvas.drawRect(const Rect.fromLTWH(37, 6, 5, 20), armPaint);

    _drawRotor(canvas, const Offset(10, 5), rotorPaint, rotorShadowPaint);
    _drawRotor(canvas, const Offset(10, 22), rotorPaint, rotorShadowPaint);
    _drawRotor(canvas, const Offset(39, 5), rotorPaint, rotorShadowPaint);
    _drawRotor(canvas, const Offset(39, 22), rotorPaint, rotorShadowPaint);

    canvas.drawRect(const Rect.fromLTWH(18, 10, 22, 12), bodyPaint);
    canvas.drawRect(const Rect.fromLTWH(21, 12, 16, 4), bodyLightPaint);
    canvas.drawRect(const Rect.fromLTWH(39, 13, 9, 7), cameraPaint);
    canvas.drawRect(const Rect.fromLTWH(20, 20, 6, 3), redAccentPaint);
    canvas.drawRect(const Rect.fromLTWH(31, 20, 6, 3), blueAccentPaint);
  }

  void _drawRotor(
    Canvas canvas,
    Offset offset,
    Paint rotorPaint,
    Paint shadowPaint,
  ) {
    canvas.drawRect(Rect.fromLTWH(offset.dx, offset.dy, 9, 5), shadowPaint);
    canvas.drawRect(
      Rect.fromLTWH(offset.dx - 2, offset.dy + 1, 13, 3),
      rotorPaint,
    );
  }
}

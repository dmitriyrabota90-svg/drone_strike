import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game_config.dart';

class TankComponent extends PositionComponent {
  TankComponent({required this.worldX})
    : super(size: Vector2(tankWidth, tankHeight));

  static const tankWidth = 118.0;
  static const tankHeight = 46.0;

  double worldX;

  @override
  Future<void> onLoad() async {
    await add(
      RectangleHitbox(
        size: Vector2(tankWidth - 14, tankHeight - 8),
        position: Vector2(7, 6),
      ),
    );
  }

  Rect get collisionRect {
    return Rect.fromLTWH(
      position.x + 8,
      position.y + 6,
      size.x - 16,
      size.y - 8,
    );
  }

  void updateWorld({
    required double worldOffset,
    required double viewportHeight,
  }) {
    position = Vector2(
      worldX - worldOffset,
      viewportHeight - GameConfig.bottomBoundaryHeight - tankHeight,
    );
  }

  bool get missedDroneFailSafe => position.x + size.x < -120;

  @override
  void render(Canvas canvas) {
    final bodyPaint = Paint()..color = const Color(0xFF536B5F);
    final bodyLightPaint = Paint()..color = const Color(0xFF78907F);
    final trackPaint = Paint()..color = const Color(0xFF273B35);
    final barrelPaint = Paint()..color = const Color(0xFFA3B19B);
    final glowPaint = Paint()..color = const Color(0x2289D8FF);

    canvas.drawOval(
      Rect.fromLTWH(-20, tankHeight - 18, tankWidth + 42, 22),
      glowPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(8, tankHeight - 17, tankWidth - 16, 14),
      trackPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(20, tankHeight - 35, tankWidth - 34, 20),
      bodyPaint,
    );
    canvas.drawRect(Rect.fromLTWH(42, tankHeight - 45, 36, 18), bodyLightPaint);
    canvas.drawRect(
      Rect.fromLTWH(tankWidth - 36, tankHeight - 40, 42, 6),
      barrelPaint,
    );

    for (var x = 16.0; x < tankWidth - 16; x += 18) {
      canvas.drawCircle(Offset(x, tankHeight - 10), 5, bodyLightPaint);
    }
  }
}

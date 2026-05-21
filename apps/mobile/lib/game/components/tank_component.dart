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
      position.x + 4,
      position.y + 3,
      size.x - 8,
      size.y - 5,
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
    final bodyPaint = Paint()..color = const Color(0xFF617B6E);
    final bodyLightPaint = Paint()..color = const Color(0xFF9EB49E);
    final trackPaint = Paint()..color = const Color(0xFF273B35);
    final barrelPaint = Paint()..color = const Color(0xFFC0CDAF);
    final glowPaint = Paint()..color = const Color(0x3389D8FF);
    final outlinePaint = Paint()
      ..color = const Color(0x6689D8FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawOval(
      Rect.fromLTWH(-28, tankHeight - 22, tankWidth + 56, 28),
      glowPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(-12, tankHeight - 18, tankWidth + 24, 20),
      outlinePaint,
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

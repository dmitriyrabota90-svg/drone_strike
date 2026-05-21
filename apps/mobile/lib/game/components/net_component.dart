import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game_config.dart';

class NetComponent extends PositionComponent {
  NetComponent({
    required this.worldX,
    required this.netHeight,
    required this.netWidth,
  });

  double worldX;
  double netHeight;
  double netWidth;

  @override
  Future<void> onLoad() async {
    await add(RectangleHitbox());
  }

  Rect get collisionRect {
    return Rect.fromLTWH(
      position.x + 2,
      position.y,
      netWidth - 4,
      netHeight - 2,
    );
  }

  void updateWorld({required double worldOffset}) {
    size = Vector2(netWidth, netHeight);
    position = Vector2(worldX - worldOffset, GameConfig.topBoundaryHeight);
  }

  @override
  void render(Canvas canvas) {
    final fillPaint = Paint()..color = const Color(0x22081222);
    final framePaint = Paint()
      ..color = const Color(0xFFD2E8F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final meshPaint = Paint()
      ..color = const Color(0xAA94B6CA)
      ..strokeWidth = 1;
    final hazardPaint = Paint()..color = const Color(0xFFE54B5D);

    canvas.drawRect(size.toRect(), fillPaint);
    canvas.drawRect(Rect.fromLTWH(0, 0, netWidth, 4), hazardPaint);
    canvas.drawRect(size.toRect(), framePaint);

    for (var x = 7.0; x < netWidth; x += 11) {
      canvas.drawLine(Offset(x, 0), Offset(x, netHeight), meshPaint);
    }
    for (var y = 9.0; y < netHeight; y += 11) {
      canvas.drawLine(Offset(0, y), Offset(netWidth, y), meshPaint);
    }

    for (var y = 6.0; y < netHeight; y += 28) {
      canvas.drawRect(Rect.fromLTWH(netWidth - 8, y, 5, 5), hazardPaint);
    }
  }
}

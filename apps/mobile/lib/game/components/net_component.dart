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
    return Rect.fromLTWH(position.x, position.y, netWidth, netHeight);
  }

  void updateWorld({required double worldOffset}) {
    size = Vector2(netWidth, netHeight);
    position = Vector2(worldX - worldOffset, GameConfig.topBoundaryHeight);
  }

  @override
  void render(Canvas canvas) {
    final framePaint = Paint()
      ..color = const Color(0xFFBFD6E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final meshPaint = Paint()
      ..color = const Color(0x8894B6CA)
      ..strokeWidth = 1;
    final hazardPaint = Paint()..color = const Color(0xFFE54B5D);

    canvas.drawRect(size.toRect(), framePaint);

    for (var x = 8.0; x < netWidth; x += 12) {
      canvas.drawLine(Offset(x, 0), Offset(x, netHeight), meshPaint);
    }
    for (var y = 10.0; y < netHeight; y += 12) {
      canvas.drawLine(Offset(0, y), Offset(netWidth, y), meshPaint);
    }

    for (var y = 6.0; y < netHeight; y += 28) {
      canvas.drawRect(Rect.fromLTWH(netWidth - 8, y, 5, 5), hazardPaint);
    }
  }
}

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum BoundarySide { top, bottom }

class BoundaryComponent extends PositionComponent {
  BoundaryComponent({required this.side, required this.thickness});

  final BoundarySide side;
  final double thickness;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = Vector2(size.x, thickness);
    position = Vector2(0, side == BoundarySide.top ? 0 : size.y - thickness);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFFD6424A);
    final glowPaint = Paint()..color = const Color(0x55D6424A);
    canvas.drawRect(size.toRect(), glowPaint);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, 2), paint);
  }
}

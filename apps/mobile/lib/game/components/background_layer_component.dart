import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game_config.dart';

class BackgroundLayerComponent extends PositionComponent {
  BackgroundLayerComponent({this.forwardSpeed = GameConfig.forwardSpeed});

  final double forwardSpeed;
  double _scroll = 0;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  @override
  void update(double dt) {
    _scroll = (_scroll + forwardSpeed * dt) % 360;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint()..color = const Color(0xFF061426));
    _drawClouds(canvas);
    _drawForest(canvas);
  }

  void _drawClouds(Canvas canvas) {
    final paint = Paint()..color = const Color(0x332F78A3);
    for (var i = 0; i < 7; i++) {
      final baseX = (i * 140.0 - _scroll * 0.28) % (size.x + 160) - 80;
      final y = 36.0 + (i % 3) * 34;
      canvas.drawRect(Rect.fromLTWH(baseX, y, 54, 10), paint);
      canvas.drawRect(Rect.fromLTWH(baseX + 18, y - 8, 44, 10), paint);
      canvas.drawRect(Rect.fromLTWH(baseX + 50, y + 2, 34, 8), paint);
    }
  }

  void _drawForest(Canvas canvas) {
    final groundY = size.y - 76;
    final farPaint = Paint()..color = const Color(0xFF0B2233);
    final nearPaint = Paint()..color = const Color(0xFF0E2F32);

    for (var i = 0; i < 18; i++) {
      final x = (i * 64.0 - _scroll * 0.55) % (size.x + 80) - 40;
      final height = 34.0 + (i % 4) * 10;
      _drawTree(canvas, x, groundY, height, farPaint);
    }

    for (var i = 0; i < 16; i++) {
      final x = (i * 78.0 - _scroll) % (size.x + 90) - 45;
      final height = 46.0 + math.sin(i * 1.7).abs() * 30;
      _drawTree(canvas, x, size.y - 28, height, nearPaint);
    }
  }

  void _drawTree(
    Canvas canvas,
    double x,
    double baseY,
    double height,
    Paint paint,
  ) {
    final path = Path()
      ..moveTo(x, baseY)
      ..lineTo(x + 16, baseY - height)
      ..lineTo(x + 32, baseY)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawRect(Rect.fromLTWH(x + 14, baseY - 4, 4, 16), paint);
  }
}

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/assets/app_assets.dart';
import '../game_config.dart';
import '../game_image_cache.dart';

class BatteryComponent extends PositionComponent {
  BatteryComponent({
    required this.id,
    required this.worldX,
    required this.worldCenterY,
  }) : super(size: Vector2(GameConfig.batteryWidth, GameConfig.batteryHeight));

  final int id;
  final double worldX;
  final double worldCenterY;

  var _elapsed = 0.0;
  var _collected = false;
  ui.Image? _sprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _sprite = await GameImageCache.load(AppAssets.batteryCollectible);
  }

  bool get isCollected => _collected;

  Rect get collisionRect {
    final center = Offset(position.x + size.x / 2, position.y + size.y / 2);
    return Rect.fromCircle(
      center: center,
      radius: GameConfig.batteryCollectRadius,
    );
  }

  Offset get centerOffset =>
      Offset(position.x + size.x / 2, position.y + size.y / 2);

  void updateWorld({required double worldOffset}) {
    position = Vector2(
      worldX - worldOffset,
      worldCenterY - GameConfig.batteryHeight / 2,
    );
  }

  bool collect() {
    if (_collected) {
      return false;
    }
    _collected = true;
    return true;
  }

  void reset() {
    _collected = false;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
  }

  @override
  void render(Canvas canvas) {
    if (_collected) {
      return;
    }

    final pulse = 0.65 + math.sin(_elapsed * 8) * 0.20;
    final glowPaint = Paint()
      ..color = Color.lerp(
        const Color(0x0069F2FF),
        const Color(0xAA69F2FF),
        pulse,
      )!
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final bodyPaint = Paint()..color = const Color(0xDD092A3F);
    final borderPaint = Paint()
      ..color = const Color(0xFF79F4FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final corePaint = Paint()..color = const Color(0xFFFFC857);
    final capPaint = Paint()..color = const Color(0xFFFF7A30);

    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 4, size.x - 7, size.y - 8),
      const Radius.circular(4),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-4, -3, size.x + 8, size.y + 6),
        const Radius.circular(10),
      ),
      glowPaint,
    );

    final sprite = _sprite;
    if (sprite != null) {
      final spriteBounds = _containRect(
        sprite,
        Rect.fromLTWH(0, 0, size.x, size.y),
      );
      canvas.drawImageRect(
        sprite,
        Rect.fromLTWH(0, 0, sprite.width.toDouble(), sprite.height.toDouble()),
        spriteBounds,
        Paint()
          ..filterQuality = FilterQuality.medium
          ..colorFilter = ColorFilter.mode(
            Colors.white.withValues(alpha: 0.92 + pulse * 0.08),
            BlendMode.modulate,
          ),
      );
      return;
    }

    canvas.drawRRect(body, bodyPaint);
    canvas.drawRRect(body, borderPaint);
    canvas.drawRect(Rect.fromLTWH(size.x - 5, 8, 4, size.y - 16), capPaint);
    canvas.drawRect(Rect.fromLTWH(8, 8, size.x * 0.44, size.y - 16), corePaint);
    canvas.drawRect(
      Rect.fromLTWH(8 + size.x * 0.44, 8, 3, size.y - 16),
      Paint()..color = const Color(0xFFFFF2A6),
    );
  }

  Rect _containRect(ui.Image image, Rect bounds) {
    final scale = math.min(
      bounds.width / image.width,
      bounds.height / image.height,
    );
    final width = image.width * scale;
    final height = image.height * scale;
    return Rect.fromLTWH(
      bounds.left + (bounds.width - width) / 2,
      bounds.top + (bounds.height - height) / 2,
      width,
      height,
    );
  }
}

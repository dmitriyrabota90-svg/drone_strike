import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/assets/app_assets.dart';
import '../game_config.dart';
import '../game_image_cache.dart';

class DroneComponent extends PositionComponent {
  DroneComponent()
    : super(size: Vector2(GameConfig.droneWidth, GameConfig.droneHeight));

  double verticalVelocity = 0;
  ui.Image? _sprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    unawaited(
      GameImageCache.load(AppAssets.gameDroneFpvMain).then((image) {
        _sprite = image;
      }),
    );
    await add(
      RectangleHitbox(
        size: Vector2(
          GameConfig.droneWidth - GameConfig.droneHitboxInsetX * 2,
          GameConfig.droneHeight - GameConfig.droneHitboxInsetY * 2,
        ),
        position: Vector2(
          GameConfig.droneHitboxInsetX,
          GameConfig.droneHitboxInsetY,
        ),
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
    final sprite = _sprite;
    if (sprite != null) {
      canvas.drawImageRect(
        sprite,
        Rect.fromLTWH(0, 0, sprite.width.toDouble(), sprite.height.toDouble()),
        _containRect(sprite, Rect.fromLTWH(0, 0, size.x, size.y)),
        Paint()..filterQuality = FilterQuality.medium,
      );
      return;
    }

    canvas.save();
    canvas.scale(size.x / 56.0, size.y / 32.0);
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
    canvas.restore();
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

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/assets/app_assets.dart';
import '../game_image_cache.dart';

class ExplosionComponent extends PositionComponent {
  ExplosionComponent._({
    required Offset center,
    required this.duration,
    required this.maxRadius,
    required this.sparkCount,
    required this.palette,
    this.burstAssetPath,
    this.smokeAssetPath,
  }) : _seed = center.dx.round() * 31 + center.dy.round() * 17,
       super(
         position: Vector2(center.dx - maxRadius, center.dy - maxRadius),
         size: Vector2.all(maxRadius * 2),
       );

  factory ExplosionComponent.tank({required Offset center}) {
    return ExplosionComponent._(
      center: center,
      duration: 1.2,
      maxRadius: 94,
      sparkCount: 28,
      burstAssetPath: AppAssets.tankExplosionBurst,
      smokeAssetPath: AppAssets.tankFireSmokeAfterHit,
      palette: const [
        Color(0xFFFFF1A6),
        Color(0xFFFF9D2E),
        Color(0xFFFF3D21),
        Color(0xFF1B2738),
      ],
    );
  }

  factory ExplosionComponent.battery({required Offset center}) {
    return ExplosionComponent._(
      center: center,
      duration: 0.38,
      maxRadius: 34,
      sparkCount: 12,
      palette: const [Color(0xFF9EFFFF), Color(0xFFFFE88A), Color(0xFFFF8A30)],
    );
  }

  final double duration;
  final double maxRadius;
  final int sparkCount;
  final List<Color> palette;
  final String? burstAssetPath;
  final String? smokeAssetPath;
  final int _seed;

  double _elapsed = 0;
  ui.Image? _burstSprite;
  ui.Image? _smokeSprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final burstPath = burstAssetPath;
    final smokePath = smokeAssetPath;
    if (burstPath != null) {
      unawaited(
        GameImageCache.load(burstPath).then((image) {
          _burstSprite = image;
        }),
      );
    }
    if (smokePath != null) {
      unawaited(
        GameImageCache.load(smokePath).then((image) {
          _smokeSprite = image;
        }),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = (_elapsed / duration).clamp(0.0, 1.0);
    final fade = 1 - progress;
    final center = Offset(size.x / 2, size.y / 2);
    final coreRadius = maxRadius * (0.18 + progress * 0.28);

    if (_burstSprite != null || _smokeSprite != null) {
      _renderSprites(canvas, center, progress, fade);
    }

    final glowPaint = Paint()
      ..color = palette[1].withValues(alpha: 0.36 * fade)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(center, maxRadius * (0.35 + progress * 0.32), glowPaint);

    canvas.drawCircle(
      center,
      coreRadius,
      Paint()..color = palette[0].withValues(alpha: 0.92 * fade),
    );
    canvas.drawCircle(
      center,
      coreRadius * 1.7,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = palette[2].withValues(alpha: 0.74 * fade),
    );

    for (var i = 0; i < sparkCount; i++) {
      final random = math.Random(_seed + i * 101);
      final angle = random.nextDouble() * math.pi * 2;
      final speed = maxRadius * (0.34 + random.nextDouble() * 0.72);
      final distance = speed * Curves.easeOut.transform(progress);
      final sparkCenter =
          center + Offset(math.cos(angle), math.sin(angle)) * distance;
      final sparkLength = 5 + random.nextDouble() * 12;
      final sparkEnd =
          sparkCenter + Offset(math.cos(angle), math.sin(angle)) * sparkLength;
      final color = palette[i % palette.length].withValues(alpha: fade);
      canvas.drawLine(
        sparkCenter,
        sparkEnd,
        Paint()
          ..color = color
          ..strokeWidth = 1.5 + random.nextDouble() * 2.5
          ..strokeCap = StrokeCap.round,
      );
    }

    if (palette.length > 3) {
      for (var i = 0; i < 6; i++) {
        final random = math.Random(_seed + 900 + i);
        final angle = random.nextDouble() * math.pi * 2;
        final distance =
            maxRadius * (0.16 + random.nextDouble() * 0.36) * progress;
        canvas.drawCircle(
          center + Offset(math.cos(angle), math.sin(angle)) * distance,
          7 + random.nextDouble() * 9,
          Paint()..color = palette[3].withValues(alpha: 0.28 * fade),
        );
      }
    }
  }

  void _renderSprites(
    Canvas canvas,
    Offset center,
    double progress,
    double fade,
  ) {
    final smoke = _smokeSprite;
    if (smoke != null) {
      final smokeProgress = Curves.easeOut.transform(progress);
      final smokeSize = maxRadius * (1.45 + smokeProgress * 0.22);
      _drawSprite(
        canvas,
        smoke,
        Rect.fromCenter(
          center: center.translate(0, -maxRadius * 0.12),
          width: smokeSize,
          height: smokeSize,
        ),
        opacity: (0.18 + progress * 0.65).clamp(0.0, 0.82),
      );
    }

    final burst = _burstSprite;
    if (burst != null && progress < 0.72) {
      final burstProgress = Curves.easeOutBack.transform(
        (progress / 0.72).clamp(0.0, 1.0),
      );
      final burstSize = maxRadius * (0.8 + burstProgress * 1.2);
      _drawSprite(
        canvas,
        burst,
        Rect.fromCenter(center: center, width: burstSize, height: burstSize),
        opacity: (1 - progress / 0.72).clamp(0.0, 1.0),
      );
    }
  }

  void _drawSprite(
    Canvas canvas,
    ui.Image image,
    Rect bounds, {
    required double opacity,
  }) {
    final scale = math.min(
      bounds.width / image.width,
      bounds.height / image.height,
    );
    final width = image.width * scale;
    final height = image.height * scale;
    final dst = Rect.fromLTWH(
      bounds.left + (bounds.width - width) / 2,
      bounds.top + (bounds.height - height) / 2,
      width,
      height,
    );
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      dst,
      Paint()
        ..filterQuality = FilterQuality.medium
        ..colorFilter = ColorFilter.mode(
          Colors.white.withValues(alpha: opacity),
          BlendMode.modulate,
        ),
    );
  }
}

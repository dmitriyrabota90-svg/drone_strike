import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/assets/app_assets.dart';
import '../game_config.dart';
import '../game_image_cache.dart';
import '../game_visual_theme.dart';

class BackgroundLayerComponent extends PositionComponent {
  BackgroundLayerComponent({
    this.forwardSpeed = GameConfig.forwardSpeed,
    this.visualTheme = GameVisualTheme.night,
  });

  final double forwardSpeed;
  final GameVisualTheme visualTheme;
  double _scroll = 0;
  ui.Image? _sky;
  ui.Image? _clouds01;
  ui.Image? _clouds02;
  ui.Image? _cityRuins;
  ui.Image? _roadGround;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadSprites();
  }

  Future<void> _loadSprites() async {
    _sky = await GameImageCache.load(
      visualTheme.isDay ? AppAssets.gameDaySkyBase : AppAssets.gameSkyBaseNight,
    );
    _clouds01 = await GameImageCache.load(
      visualTheme.isDay
          ? AppAssets.gameDayCloudsLayer01
          : AppAssets.gameCloudsLayer01,
    );
    _clouds02 = visualTheme.isDay
        ? await GameImageCache.load(AppAssets.gameDayCloudsLayer01)
        : await GameImageCache.load(AppAssets.gameCloudsLayer02);
    _cityRuins = await GameImageCache.load(
      visualTheme.isDay
          ? AppAssets.gameDayCityRuinsLayer
          : AppAssets.gameCityRuinsLayer,
    );
    _roadGround = await GameImageCache.load(
      visualTheme.isDay
          ? AppAssets.gameDayRoadGroundLayer
          : AppAssets.gameRoadGroundLayer,
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  @override
  void update(double dt) {
    _scroll += forwardSpeed * dt;
    if (_scroll > 100000) {
      _scroll = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    final sky = _sky;
    if (sky == null) {
      canvas.drawRect(size.toRect(), Paint()..color = const Color(0xFF061426));
    } else {
      _drawImage(canvas, sky, Rect.fromLTWH(0, 0, size.x, size.y));
    }

    final clouds01 = _clouds01;
    final clouds02 = _clouds02;
    if (clouds01 == null || clouds02 == null) {
      _drawClouds(canvas);
    } else {
      _drawRepeatingLayer(
        canvas,
        clouds01,
        y: size.y * 0.02,
        height: size.y * 0.42,
        scrollFactor: 0.12,
        opacity: 0.62,
      );
      _drawRepeatingLayer(
        canvas,
        clouds02,
        y: size.y * 0.14,
        height: size.y * 0.36,
        scrollFactor: 0.20,
        opacity: 0.50,
      );
    }

    final cityRuins = _cityRuins;
    final roadGround = _roadGround;
    final roadHeight = visualTheme.isDay
        ? math.max(58.0, size.y * 0.16)
        : math.max(32.0, size.y * 0.09);
    final roadY = visualTheme.isDay
        ? size.y - roadHeight * 0.92
        : size.y - roadHeight;
    final cityHeight = visualTheme.isDay
        ? math.max(260.0, size.y * 0.64)
        : math.max(300.0, size.y * 0.84);
    final cityY = visualTheme.isDay
        ? (roadY - cityHeight * 0.84).clamp(size.y * 0.18, size.y * 0.36)
        : math.max(size.y * 0.46, roadY - cityHeight * 0.46);
    if (cityRuins == null || roadGround == null) {
      canvas.drawRect(
        Rect.fromLTWH(0, cityY, size.x, size.y - cityY),
        Paint()..color = const Color(0x66030A12),
      );
      _drawForest(canvas);
    } else {
      _drawRepeatingLayer(
        canvas,
        cityRuins,
        y: cityY,
        height: cityHeight,
        scrollFactor: 0.32,
        opacity: 0.78,
      );
      _drawRepeatingLayer(
        canvas,
        roadGround,
        y: roadY,
        height: roadHeight,
        scrollFactor: 0.52,
        opacity: 0.88,
      );
    }

    canvas.drawRect(
      size.toRect(),
      Paint()
        ..color = visualTheme.isDay
            ? const Color(0x18030A12)
            : const Color(0x33000000),
    );
  }

  void _drawRepeatingLayer(
    Canvas canvas,
    ui.Image image, {
    required double y,
    required double height,
    required double scrollFactor,
    required double opacity,
  }) {
    final imageAspect = image.width / image.height;
    final tileWidth = math.max(size.x, height * imageAspect);
    final offset = (_scroll * scrollFactor) % tileWidth;
    final paint = Paint()
      ..filterQuality = FilterQuality.medium
      ..colorFilter = ColorFilter.mode(
        Color.fromRGBO(255, 255, 255, opacity),
        BlendMode.modulate,
      );

    for (var x = -offset - 2; x < size.x + tileWidth; x += tileWidth - 1) {
      _drawImage(
        canvas,
        image,
        Rect.fromLTWH(x, y, tileWidth + 2, height),
        paint: paint,
      );
    }
  }

  void _drawImage(Canvas canvas, ui.Image image, Rect dst, {Paint? paint}) {
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      dst,
      paint ?? (Paint()..filterQuality = FilterQuality.medium),
    );
  }

  void _drawClouds(Canvas canvas) {
    final paint = Paint()..color = const Color(0x262F78A3);
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
    final farPaint = Paint()..color = const Color(0xFF071A28);
    final nearPaint = Paint()..color = const Color(0xFF0A2629);

    for (var i = 0; i < 18; i++) {
      final x = (i * 64.0 - _scroll * 0.55) % (size.x + 80) - 40;
      final height = 34.0 + (i % 4) * 10;
      _drawTree(canvas, x, groundY, height, farPaint);
    }

    for (var i = 0; i < 16; i++) {
      final x = (i * 78.0 - _scroll) % (size.x + 90) - 45;
      final height = 38.0 + math.sin(i * 1.7).abs() * 24;
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

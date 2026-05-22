import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/assets/app_assets.dart';
import '../game_config.dart';
import '../game_image_cache.dart';

class TreeComponent extends PositionComponent {
  static const _segmentOverlap = 2.5;
  static const _crownOverlap = 3.0;

  TreeComponent({
    required this.worldX,
    required this.treeHeight,
    required this.treeWidth,
    this.variantSeed = 0,
  });

  double worldX;
  double treeHeight;
  double treeWidth;
  final int variantSeed;
  ui.Image? _trunkBottom;
  ui.Image? _trunkMiddle;
  ui.Image? _crownTop;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    unawaited(_loadSprites());
    await add(RectangleHitbox());
  }

  Rect get collisionRect {
    return Rect.fromLTWH(
      position.x + treeWidth * 0.16,
      position.y + 4,
      treeWidth * 0.68,
      treeHeight - 6,
    );
  }

  void updateWorld({
    required double worldOffset,
    required double viewportHeight,
  }) {
    size = Vector2(treeWidth, treeHeight);
    position = Vector2(
      worldX - worldOffset,
      viewportHeight - GameConfig.bottomBoundaryHeight - treeHeight,
    );
  }

  @override
  void render(Canvas canvas) {
    if (_renderSpriteTree(canvas)) {
      return;
    }

    final trunkPaint = Paint()..color = const Color(0xFF8A5631);
    final trunkShadowPaint = Paint()..color = const Color(0xFF4A2C1C);
    final crownPaint = Paint()..color = const Color(0xFF2F8A4D);
    final crownDarkPaint = Paint()..color = const Color(0xFF173E2A);
    final crownEdgePaint = Paint()..color = const Color(0xFF64B36F);

    final trunkWidth = treeWidth * 0.24;
    final trunkX = (treeWidth - trunkWidth) / 2;
    canvas.drawRect(
      Rect.fromLTWH(trunkX, treeHeight * 0.34, trunkWidth, treeHeight * 0.66),
      trunkPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        trunkX + trunkWidth * 0.55,
        treeHeight * 0.34,
        trunkWidth * 0.35,
        treeHeight * 0.66,
      ),
      trunkShadowPaint,
    );

    final crownHeight = treeHeight * 0.58;
    canvas.drawRect(
      Rect.fromLTWH(treeWidth * 0.05, 2, treeWidth * 0.90, crownHeight),
      crownDarkPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(treeWidth * 0.08, 0, treeWidth * 0.84, crownHeight),
      crownPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(treeWidth * 0.12, 3, treeWidth * 0.32, 5),
      crownEdgePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(treeWidth * 0.16, crownHeight * 0.18, treeWidth * 0.68, 10),
      crownDarkPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(treeWidth * 0.04, crownHeight * 0.46, treeWidth * 0.92, 12),
      crownDarkPaint,
    );
  }

  String get _crownAsset {
    return switch (variantSeed % 3) {
      0 => AppAssets.treeCrownTop01,
      1 => AppAssets.treeCrownTop02,
      _ => AppAssets.treeCrownTop03,
    };
  }

  Future<void> _loadSprites() async {
    _trunkBottom = await GameImageCache.load(AppAssets.treeTrunkBottom);
    _trunkMiddle = await GameImageCache.load(AppAssets.treeTrunkMiddle);
    _crownTop = await GameImageCache.load(_crownAsset);
  }

  bool _renderSpriteTree(Canvas canvas) {
    final trunkBottom = _trunkBottom;
    final trunkMiddle = _trunkMiddle;
    final crownTop = _crownTop;
    if (trunkBottom == null || trunkMiddle == null || crownTop == null) {
      return false;
    }

    final paint = Paint()..filterQuality = FilterQuality.medium;
    final bottomHeight = math.min(
      treeHeight * 0.28,
      _scaledHeight(trunkBottom, treeWidth),
    );
    final crownHeight = math.min(
      treeHeight * 0.46,
      math.max(treeWidth * 0.55, _scaledHeight(crownTop, treeWidth)),
    );
    final middleTop = crownHeight;
    final middleBottom = math.max(middleTop, treeHeight - bottomHeight);
    final middleHeight = math.max(
      12.0,
      math.min(treeWidth * 0.62, _scaledHeight(trunkMiddle, treeWidth)),
    );

    _drawImage(
      canvas,
      trunkBottom,
      Rect.fromLTWH(0, treeHeight - bottomHeight, treeWidth, bottomHeight),
      paint,
    );

    var y = middleBottom + _segmentOverlap;
    while (y > middleTop) {
      final segmentHeight = math.min(
        middleHeight,
        y - middleTop + _segmentOverlap,
      );
      y -= segmentHeight;
      _drawImage(
        canvas,
        trunkMiddle,
        Rect.fromLTWH(0, y, treeWidth, segmentHeight),
        paint,
      );
      y += _segmentOverlap;
    }

    _drawImage(
      canvas,
      crownTop,
      Rect.fromLTWH(0, 0, treeWidth, crownHeight + _crownOverlap),
      paint,
    );
    return true;
  }

  double _scaledHeight(ui.Image image, double width) {
    return width * image.height / image.width;
  }

  void _drawImage(Canvas canvas, ui.Image image, Rect dst, Paint paint) {
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      dst,
      paint,
    );
  }
}

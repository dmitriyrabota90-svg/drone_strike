import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/assets/app_assets.dart';
import '../game_config.dart';
import '../game_image_cache.dart';

class TreeComponent extends PositionComponent {
  static const _bottomMiddleOverlap = 4.0;
  static const _middleOverlap = 2.0;
  static const _middleCrownOverlap = 1.5;
  static const _minSegmentHeight = 18.0;

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
    await _loadSprites();
    await add(RectangleHitbox());
  }

  Rect get collisionRect {
    final insetX = treeWidth * GameConfig.treeHitboxInsetXRatio;
    final topInset = GameConfig.treeHitboxTopInset;
    final bottomInset = math.min(
      GameConfig.treeHitboxBottomInset,
      math.max(0, treeHeight - topInset),
    );
    return Rect.fromLTWH(
      position.x + insetX,
      position.y + topInset,
      treeWidth - insetX * 2,
      math.max(0, treeHeight - topInset - bottomInset),
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
    final bottomHeight = math.min(treeHeight * 0.32, treeWidth * 0.62);
    final crownHeight = math.min(treeHeight * 0.30, treeWidth * 0.56);
    final middleTopLimit = math.max(0.0, crownHeight - _middleCrownOverlap);
    final middleHeight = math.max(_minSegmentHeight, treeWidth * 0.42);

    _drawImage(
      canvas,
      trunkBottom,
      Rect.fromLTWH(0, treeHeight - bottomHeight, treeWidth, bottomHeight),
      paint,
    );

    var segmentBottom = treeHeight - bottomHeight + _bottomMiddleOverlap;
    while (segmentBottom > middleTopLimit) {
      final segmentTop = math.max(middleTopLimit, segmentBottom - middleHeight);
      final reachedCrown = segmentTop <= middleTopLimit + 0.001;
      _drawImage(
        canvas,
        trunkMiddle,
        Rect.fromLTWH(0, segmentTop, treeWidth, segmentBottom - segmentTop),
        paint,
      );
      if (reachedCrown) {
        break;
      }
      segmentBottom = segmentTop + _middleOverlap;
    }

    _drawImage(
      canvas,
      crownTop,
      Rect.fromLTWH(0, 0, treeWidth, crownHeight),
      paint,
    );
    return true;
  }

  void _drawImage(Canvas canvas, ui.Image image, Rect dst, Paint paint) {
    final src = _coverSourceRect(image, dst);
    canvas.drawImageRect(image, src, dst, paint);
  }

  Rect _coverSourceRect(ui.Image image, Rect dst) {
    final sourceWidth = image.width.toDouble();
    final sourceHeight = image.height.toDouble();
    final sourceAspect = sourceWidth / sourceHeight;
    final dstAspect = dst.width / dst.height;
    if (dstAspect > sourceAspect) {
      final height = sourceWidth / dstAspect;
      return Rect.fromLTWH(0, (sourceHeight - height) / 2, sourceWidth, height);
    }
    final width = sourceHeight * dstAspect;
    return Rect.fromLTWH((sourceWidth - width) / 2, 0, width, sourceHeight);
  }
}

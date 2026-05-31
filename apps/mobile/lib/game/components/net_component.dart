import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/assets/app_assets.dart';
import '../game_config.dart';
import '../game_image_cache.dart';
import '../obstacle_asset_registry.dart';

class NetComponent extends PositionComponent {
  static const _segmentOverlap = 2.5;
  static const _topMountOverlap = 3.0;
  static const _minSegmentHeight = 18.0;

  NetComponent({
    required this.worldX,
    required this.netHeight,
    required this.netWidth,
    this.assetVariant = ObstacleAssetRegistry.topModularNet,
    this.variantSeed = 0,
  });

  double worldX;
  double netHeight;
  double netWidth;
  final ObstacleAssetVariant assetVariant;
  final int variantSeed;
  ui.Image? _topMount;
  ui.Image? _middle;
  ui.Image? _bottom;
  ui.Image? _wholeImage;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadSprites();
    await add(RectangleHitbox());
  }

  Rect get collisionRect {
    final visualRect =
        _wholeVisualRect ?? Rect.fromLTWH(0, 0, netWidth, netHeight);
    final insetX = visualRect.width * assetVariant.hitboxInsetXRatio;
    final topInset = assetVariant.hitboxTopInset;
    final bottomInset = math.min(
      assetVariant.hitboxBottomInset,
      math.max(0, visualRect.height - topInset),
    );
    return Rect.fromLTWH(
      position.x + visualRect.left + insetX,
      position.y + visualRect.top + topInset,
      math.max(0, visualRect.width - insetX * 2),
      math.max(0, visualRect.height - topInset - bottomInset),
    );
  }

  void updateWorld({required double worldOffset}) {
    size = Vector2(netWidth, netHeight);
    position = Vector2(worldX - worldOffset, GameConfig.playableTopY);
  }

  @override
  void render(Canvas canvas) {
    if (_renderWholeObstacle(canvas)) {
      return;
    }
    if (_renderSpriteNet(canvas)) {
      return;
    }

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

  String get _topMountAsset {
    return variantSeed.isEven
        ? AppAssets.netTopMount01
        : AppAssets.netTopMount02;
  }

  String get _middleAsset {
    return variantSeed.isEven ? AppAssets.netMiddle01 : AppAssets.netMiddle02;
  }

  String get _bottomAsset {
    return variantSeed.isEven ? AppAssets.netBottom01 : AppAssets.netBottom02;
  }

  Future<void> _loadSprites() async {
    if (!assetVariant.isModular) {
      _wholeImage = await GameImageCache.load(assetVariant.assetPath!);
      return;
    }
    _topMount = await GameImageCache.load(_topMountAsset);
    _middle = await GameImageCache.load(_middleAsset);
    _bottom = await GameImageCache.load(_bottomAsset);
  }

  bool _renderWholeObstacle(Canvas canvas) {
    final image = _wholeImage;
    if (image == null) {
      return false;
    }

    final bounds = Rect.fromLTWH(0, 0, netWidth, netHeight);
    final dst = assetVariant.fitMode == ObstacleFitMode.cover
        ? bounds
        : _containRect(image, bounds, alignToTop: true);
    _drawImage(canvas, image, dst, Paint()..filterQuality = FilterQuality.high);
    return true;
  }

  Rect? get _wholeVisualRect {
    final image = _wholeImage;
    if (image == null || assetVariant.isModular) {
      return null;
    }
    final bounds = Rect.fromLTWH(0, 0, netWidth, netHeight);
    return assetVariant.fitMode == ObstacleFitMode.cover
        ? bounds
        : _containRect(image, bounds, alignToTop: true);
  }

  bool _renderSpriteNet(Canvas canvas) {
    final topMount = _topMount;
    final middle = _middle;
    final bottom = _bottom;
    if (topMount == null || middle == null || bottom == null) {
      return false;
    }

    final paint = Paint()..filterQuality = FilterQuality.medium;
    final topHeight = math.min(netHeight * 0.26, netWidth * 0.44);
    final bottomHeight = math.min(netHeight * 0.22, netWidth * 0.40);
    final middleHeight = math.max(_minSegmentHeight, netWidth * 0.48);

    _drawImage(
      canvas,
      topMount,
      Rect.fromLTWH(0, 0, netWidth, topHeight + _topMountOverlap),
      paint,
    );

    final middleTop = topHeight;
    final middleBottom = math.max(middleTop, netHeight - bottomHeight);
    var y = math.max(0.0, middleTop - _segmentOverlap);
    while (y < middleBottom) {
      final segmentHeight = math.min(
        middleHeight,
        middleBottom - y + _segmentOverlap,
      );
      _drawImage(
        canvas,
        middle,
        Rect.fromLTWH(0, y, netWidth, segmentHeight),
        paint,
      );
      y += segmentHeight - _segmentOverlap;
    }

    _drawImage(
      canvas,
      bottom,
      Rect.fromLTWH(
        0,
        netHeight - bottomHeight - _segmentOverlap,
        netWidth,
        bottomHeight + _segmentOverlap,
      ),
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

  Rect _containRect(ui.Image image, Rect bounds, {required bool alignToTop}) {
    final scale = math.min(
      bounds.width / image.width,
      bounds.height / image.height,
    );
    final width = image.width * scale;
    final height = image.height * scale;
    return Rect.fromLTWH(
      bounds.left + (bounds.width - width) / 2,
      alignToTop ? bounds.top : bounds.bottom - height,
      width,
      height,
    );
  }
}

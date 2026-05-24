import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class GameImageCache {
  const GameImageCache._();

  static const _loadTimeout = Duration(seconds: 3);
  static final Map<String, ui.Image> _images = {};
  static final Map<String, Future<ui.Image?>> _pendingLoads = {};
  static final Set<String> _failedAssets = {};

  static Future<ui.Image?> load(String assetPath) async {
    final cached = _images[assetPath];
    if (cached != null) {
      return cached;
    }
    if (_failedAssets.contains(assetPath)) {
      return null;
    }

    return _pendingLoads.putIfAbsent(assetPath, () async {
      try {
        final data = await rootBundle.load(assetPath);
        final image = await _decode(data.buffer.asUint8List()).timeout(
          _loadTimeout,
        );
        _images[assetPath] = image;
        return image;
      } catch (error) {
        _failedAssets.add(assetPath);
        debugPrint('Game image load failed: $assetPath: $error');
        return null;
      } finally {
        _pendingLoads.remove(assetPath);
      }
    });
  }

  static Future<void> precache(Iterable<String> assetPaths) async {
    await Future.wait(assetPaths.map(load));
  }

  static Future<ui.Image> _decode(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}

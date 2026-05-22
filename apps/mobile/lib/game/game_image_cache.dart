import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class GameImageCache {
  const GameImageCache._();

  static final Map<String, ui.Image> _images = {};

  static Future<ui.Image?> load(String assetPath) async {
    final cached = _images[assetPath];
    if (cached != null) {
      return cached;
    }

    try {
      final data = await rootBundle.load(assetPath);
      final image = await _decode(data.buffer.asUint8List());
      _images[assetPath] = image;
      return image;
    } catch (error) {
      debugPrint('Game image load failed: $assetPath: $error');
      return null;
    }
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

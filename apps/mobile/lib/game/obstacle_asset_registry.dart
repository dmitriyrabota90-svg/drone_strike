import 'dart:math' as math;

import '../core/assets/app_assets.dart';
import 'game_visual_theme.dart';

enum ObstacleMount { bottom, top }

enum ObstacleFitMode { modular, contain, cover }

class ObstacleAssetVariant {
  const ObstacleAssetVariant({
    required this.id,
    required this.mount,
    required this.assetPath,
    required this.minHeight,
    required this.maxHeight,
    required this.weight,
    required this.fitMode,
    required this.hitboxInsetXRatio,
    required this.hitboxTopInset,
    required this.hitboxBottomInset,
    this.allowedThemes = const {GameVisualTheme.night, GameVisualTheme.day},
  });

  final String id;
  final ObstacleMount mount;
  final String? assetPath;
  final double minHeight;
  final double maxHeight;
  final int weight;
  final ObstacleFitMode fitMode;
  final double hitboxInsetXRatio;
  final double hitboxTopInset;
  final double hitboxBottomInset;
  final Set<GameVisualTheme> allowedThemes;

  bool supports({required double height, required GameVisualTheme theme}) {
    return height >= minHeight &&
        height <= maxHeight &&
        allowedThemes.contains(theme);
  }

  bool get isModular => assetPath == null;
}

class ObstacleAssetRegistry {
  const ObstacleAssetRegistry._();

  static const bottomModularTree = ObstacleAssetVariant(
    id: 'modular_tree',
    mount: ObstacleMount.bottom,
    assetPath: null,
    minHeight: 0,
    maxHeight: 10000,
    weight: 9,
    fitMode: ObstacleFitMode.modular,
    hitboxInsetXRatio: 0.22,
    hitboxTopInset: 8,
    hitboxBottomInset: 8,
  );

  static const topModularNet = ObstacleAssetVariant(
    id: 'modular_net',
    mount: ObstacleMount.top,
    assetPath: null,
    minHeight: 0,
    maxHeight: 10000,
    weight: 9,
    fitMode: ObstacleFitMode.modular,
    hitboxInsetXRatio: 0.12,
    hitboxTopInset: 4,
    hitboxBottomInset: 8,
  );

  static const bottomVariants = <ObstacleAssetVariant>[
    bottomModularTree,
    ObstacleAssetVariant(
      id: 'tree_bottom_full_leaf_01',
      mount: ObstacleMount.bottom,
      assetPath: AppAssets.treeBottomFullLeaf01,
      minHeight: 110,
      maxHeight: 230,
      weight: 5,
      fitMode: ObstacleFitMode.contain,
      // Whole PNGs often include transparent canvas; these insets describe
      // visible mass rather than the full image bounds.
      hitboxInsetXRatio: 0.32,
      hitboxTopInset: 18,
      hitboxBottomInset: 10,
    ),
    ObstacleAssetVariant(
      id: 'tree_bottom_full_leaf_02',
      mount: ObstacleMount.bottom,
      assetPath: AppAssets.treeBottomFullLeaf02,
      minHeight: 110,
      maxHeight: 230,
      weight: 5,
      fitMode: ObstacleFitMode.contain,
      hitboxInsetXRatio: 0.32,
      hitboxTopInset: 18,
      hitboxBottomInset: 10,
    ),
    ObstacleAssetVariant(
      id: 'street_light_bottom_01',
      mount: ObstacleMount.bottom,
      assetPath: AppAssets.streetLightBottom01,
      minHeight: 120,
      maxHeight: 240,
      weight: 4,
      fitMode: ObstacleFitMode.contain,
      hitboxInsetXRatio: 0.43,
      hitboxTopInset: 22,
      hitboxBottomInset: 8,
      allowedThemes: {GameVisualTheme.day, GameVisualTheme.night},
    ),
    ObstacleAssetVariant(
      id: 'street_light_bottom_02',
      mount: ObstacleMount.bottom,
      assetPath: AppAssets.streetLightBottom02,
      minHeight: 120,
      maxHeight: 240,
      weight: 4,
      fitMode: ObstacleFitMode.contain,
      hitboxInsetXRatio: 0.43,
      hitboxTopInset: 22,
      hitboxBottomInset: 8,
      allowedThemes: {GameVisualTheme.day, GameVisualTheme.night},
    ),
    ObstacleAssetVariant(
      id: 'concrete_barrier_bottom_01',
      mount: ObstacleMount.bottom,
      assetPath: AppAssets.concreteBarrierBottom01,
      minHeight: 60,
      maxHeight: 145,
      weight: 5,
      fitMode: ObstacleFitMode.contain,
      hitboxInsetXRatio: 0.24,
      hitboxTopInset: 14,
      hitboxBottomInset: 8,
      allowedThemes: {GameVisualTheme.day, GameVisualTheme.night},
    ),
    ObstacleAssetVariant(
      id: 'concrete_barrier_bottom_02',
      mount: ObstacleMount.bottom,
      assetPath: AppAssets.concreteBarrierBottom02,
      minHeight: 60,
      maxHeight: 145,
      weight: 5,
      fitMode: ObstacleFitMode.contain,
      hitboxInsetXRatio: 0.24,
      hitboxTopInset: 14,
      hitboxBottomInset: 8,
      allowedThemes: {GameVisualTheme.day, GameVisualTheme.night},
    ),
  ];

  static const topVariants = <ObstacleAssetVariant>[
    topModularNet,
    ObstacleAssetVariant(
      id: 'tree_crown_top_full_leaf_01',
      mount: ObstacleMount.top,
      assetPath: AppAssets.treeCrownTopFullLeaf01,
      minHeight: 70,
      maxHeight: 185,
      weight: 5,
      fitMode: ObstacleFitMode.contain,
      hitboxInsetXRatio: 0.31,
      hitboxTopInset: 8,
      hitboxBottomInset: 18,
    ),
    ObstacleAssetVariant(
      id: 'tree_crown_top_full_leaf_02',
      mount: ObstacleMount.top,
      assetPath: AppAssets.treeCrownTopFullLeaf02,
      minHeight: 70,
      maxHeight: 185,
      weight: 5,
      fitMode: ObstacleFitMode.contain,
      hitboxInsetXRatio: 0.31,
      hitboxTopInset: 8,
      hitboxBottomInset: 18,
    ),
    ObstacleAssetVariant(
      id: 'urban_wire_top_01',
      mount: ObstacleMount.top,
      assetPath: AppAssets.urbanWireTop01,
      minHeight: 48,
      maxHeight: 140,
      weight: 5,
      fitMode: ObstacleFitMode.contain,
      hitboxInsetXRatio: 0.18,
      hitboxTopInset: 8,
      hitboxBottomInset: 28,
      allowedThemes: {GameVisualTheme.day, GameVisualTheme.night},
    ),
    ObstacleAssetVariant(
      id: 'urban_wire_top_02',
      mount: ObstacleMount.top,
      assetPath: AppAssets.urbanWireTop02,
      minHeight: 48,
      maxHeight: 140,
      weight: 5,
      fitMode: ObstacleFitMode.contain,
      hitboxInsetXRatio: 0.18,
      hitboxTopInset: 8,
      hitboxBottomInset: 28,
      allowedThemes: {GameVisualTheme.day, GameVisualTheme.night},
    ),
  ];

  static ObstacleAssetVariant pick({
    required ObstacleMount mount,
    required double height,
    required GameVisualTheme theme,
    required int seed,
  }) {
    final variants = mount == ObstacleMount.bottom
        ? bottomVariants
        : topVariants;
    final compatible = variants
        .where((variant) => variant.supports(height: height, theme: theme))
        .toList(growable: false);
    final fallback = mount == ObstacleMount.bottom
        ? bottomModularTree
        : topModularNet;
    if (compatible.isEmpty) {
      return fallback;
    }

    final totalWeight = compatible.fold<int>(
      0,
      (total, variant) => total + math.max(1, variant.weight),
    );
    var ticket = math.Random(seed).nextInt(totalWeight);
    for (final variant in compatible) {
      ticket -= math.max(1, variant.weight);
      if (ticket < 0) {
        return variant;
      }
    }
    return compatible.last;
  }
}

import 'package:flame/components.dart';

import 'net_component.dart';
import 'tree_component.dart';
import '../obstacle_asset_registry.dart';

class ObstaclePairComponent extends Component {
  ObstaclePairComponent({
    required this.worldX,
    required this.spacingFromPrevious,
    required this.gapTopY,
    required this.gapBottomY,
    required this.treeHeight,
    required this.netHeight,
    required this.gapHeight,
    required this.width,
    required this.bottomVariant,
    required this.topVariant,
    this.variantSeed = 0,
  }) : tree = TreeComponent(
         worldX: worldX,
         treeHeight: treeHeight,
         treeWidth: width,
         assetVariant: bottomVariant,
         variantSeed: variantSeed,
       ),
       net = NetComponent(
         worldX: worldX,
         netHeight: netHeight,
         netWidth: width,
         assetVariant: topVariant,
         variantSeed: variantSeed,
       );

  final double worldX;
  final double spacingFromPrevious;
  final double gapTopY;
  final double gapBottomY;
  final double treeHeight;
  final double netHeight;
  final double gapHeight;
  final double width;
  final ObstacleAssetVariant bottomVariant;
  final ObstacleAssetVariant topVariant;
  final int variantSeed;
  final TreeComponent tree;
  final NetComponent net;

  @override
  Future<void> onLoad() async {
    await add(net);
    await add(tree);
  }

  void updateWorld({
    required double worldOffset,
    required double viewportHeight,
  }) {
    net.updateWorld(worldOffset: worldOffset);
    tree.updateWorld(worldOffset: worldOffset, viewportHeight: viewportHeight);
  }

  bool get isOffscreenLeft => tree.position.x + width < -80;

  double get screenCenterX => tree.position.x + width / 2;

  double get gapCenterY => net.position.y + netHeight + gapHeight / 2;
}

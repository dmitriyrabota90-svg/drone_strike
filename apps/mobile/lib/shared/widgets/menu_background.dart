import 'package:flutter/material.dart';

import '../../core/assets/app_assets.dart';

class MenuBackground extends StatelessWidget {
  const MenuBackground({
    required this.child,
    this.useSafeArea = true,
    super.key,
  });

  final Widget child;
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    final content = useSafeArea ? SafeArea(child: child) : child;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(AppAssets.menuBackground, fit: BoxFit.cover),
        const DecoratedBox(
          decoration: BoxDecoration(
            color: Color(0x99020A13),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xCC020812), Color(0x99061120), Color(0xEE020812)],
            ),
          ),
        ),
        content,
      ],
    );
  }
}

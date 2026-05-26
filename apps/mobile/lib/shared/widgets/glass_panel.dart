import 'package:flutter/material.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({required this.child, this.padding, super.key});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xD90A1726),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x663AA7C9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: Material(
          type: MaterialType.transparency,
          child: child,
        ),
      ),
    );
  }
}

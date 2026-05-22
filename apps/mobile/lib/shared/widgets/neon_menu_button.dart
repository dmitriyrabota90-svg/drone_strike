import 'package:flutter/material.dart';

enum NeonMenuButtonVariant { primary, secondary, danger }

class NeonMenuButton extends StatelessWidget {
  const NeonMenuButton({
    required this.text,
    this.icon,
    this.onPressed,
    this.variant = NeonMenuButtonVariant.primary,
    super.key,
  });

  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final NeonMenuButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final accent = switch (variant) {
      NeonMenuButtonVariant.primary => const Color(0xFF70E7FF),
      NeonMenuButtonVariant.secondary => const Color(0xFFE6B85C),
      NeonMenuButtonVariant.danger => const Color(0xFFFF6B6B),
    };
    final foreground = enabled ? Colors.white : const Color(0xFF6C7887);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.34),
                  blurRadius: 14,
                  spreadRadius: -2,
                ),
              ]
            : null,
      ),
      child: Material(
        color: enabled ? const Color(0xDD081A2B) : const Color(0x8808121E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: enabled ? accent : const Color(0xFF263A55),
            width: 1.4,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: SizedBox(
            height: 50,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: enabled ? accent : foreground, size: 20),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

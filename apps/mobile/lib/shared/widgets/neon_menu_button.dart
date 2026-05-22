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
    final palette = _NeonButtonPalette.forVariant(variant, enabled: enabled);
    final accent = palette.accent;
    final foreground = enabled ? Colors.white : const Color(0xFF6C7887);

    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: _NeonButtonBorder(
          side: BorderSide(color: accent.withValues(alpha: 0.68), width: 1.1),
        ),
        shadows: enabled
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.52),
                  blurRadius: 22,
                  spreadRadius: -3,
                ),
                BoxShadow(
                  color: accent.withValues(alpha: 0.20),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        shape: _NeonButtonBorder(
          side: BorderSide(color: palette.border, width: 2.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const _NeonButtonBorder(),
          onTap: onPressed,
          splashColor: accent.withValues(alpha: 0.22),
          highlightColor: accent.withValues(alpha: 0.13),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [palette.fillTop, palette.fillBottom],
              ),
            ),
            child: SizedBox(
              height: 52,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _NeonButtonDecorationPainter(
                          accent: accent,
                          enabled: enabled,
                        ),
                      ),
                    ),
                  ),
                  if (icon != null)
                    Positioned(
                      left: 18,
                      top: 0,
                      bottom: 0,
                      child: Icon(
                        icon,
                        color: enabled ? accent : foreground,
                        size: 20,
                      ),
                    ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Text(
                        text,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: foreground,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                          height: 1.0,
                          shadows: enabled
                              ? [
                                  Shadow(
                                    color: accent.withValues(alpha: 0.62),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
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

class _NeonButtonPalette {
  const _NeonButtonPalette({
    required this.accent,
    required this.border,
    required this.fillTop,
    required this.fillBottom,
  });

  final Color accent;
  final Color border;
  final Color fillTop;
  final Color fillBottom;

  static _NeonButtonPalette forVariant(
    NeonMenuButtonVariant variant, {
    required bool enabled,
  }) {
    if (!enabled) {
      return const _NeonButtonPalette(
        accent: Color(0xFF405064),
        border: Color(0xFF263A55),
        fillTop: Color(0xAA07101C),
        fillBottom: Color(0xAA030811),
      );
    }

    return switch (variant) {
      NeonMenuButtonVariant.primary => const _NeonButtonPalette(
        accent: Color(0xFF67EAFF),
        border: Color(0xFF24CFFF),
        fillTop: Color(0xEE0A2E48),
        fillBottom: Color(0xEE051729),
      ),
      NeonMenuButtonVariant.secondary => const _NeonButtonPalette(
        accent: Color(0xFF469BFF),
        border: Color(0xFF2476E8),
        fillTop: Color(0xE90A2441),
        fillBottom: Color(0xE9051325),
      ),
      NeonMenuButtonVariant.danger => const _NeonButtonPalette(
        accent: Color(0xFFFF7A3D),
        border: Color(0xFFFF4E4E),
        fillTop: Color(0xEE401416),
        fillBottom: Color(0xEE1B090C),
      ),
    };
  }
}

class _NeonButtonBorder extends ShapeBorder {
  const _NeonButtonBorder({this.side = BorderSide.none});

  final BorderSide side;

  static const double _cut = 12;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect.deflate(side.width), textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final cut = _cut.clamp(0, rect.shortestSide / 2);
    return Path()
      ..moveTo(rect.left + cut, rect.top)
      ..lineTo(rect.right - cut, rect.top)
      ..lineTo(rect.right, rect.top + cut)
      ..lineTo(rect.right, rect.bottom - cut)
      ..lineTo(rect.right - cut, rect.bottom)
      ..lineTo(rect.left + cut, rect.bottom)
      ..lineTo(rect.left, rect.bottom - cut)
      ..lineTo(rect.left, rect.top + cut)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || side.width == 0) {
      return;
    }
    final paint = side.toPaint()..style = PaintingStyle.stroke;
    canvas.drawPath(getOuterPath(rect.deflate(side.width / 2)), paint);
  }

  @override
  ShapeBorder scale(double t) {
    return _NeonButtonBorder(side: side.scale(t));
  }
}

class _NeonButtonDecorationPainter extends CustomPainter {
  const _NeonButtonDecorationPainter({
    required this.accent,
    required this.enabled,
  });

  final Color accent;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    final glowPaint = Paint()
      ..color = accent.withValues(alpha: enabled ? 0.22 : 0.07)
      ..strokeWidth = 1.1;
    final strongPaint = Paint()
      ..color = accent.withValues(alpha: enabled ? 0.62 : 0.14)
      ..strokeWidth = 1.4;

    canvas
      ..drawLine(const Offset(18, 8), Offset(size.width * 0.34, 8), strongPaint)
      ..drawLine(
        Offset(size.width - 18, size.height - 8),
        Offset(size.width * 0.66, size.height - 8),
        strongPaint,
      )
      ..drawLine(
        Offset(12, size.height - 12),
        Offset(30, size.height - 12),
        glowPaint,
      )
      ..drawLine(
        Offset(size.width - 12, 12),
        Offset(size.width - 30, 12),
        glowPaint,
      );

    final cornerPaint = Paint()
      ..color = accent.withValues(alpha: enabled ? 0.34 : 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(
      Path()
        ..moveTo(7, 22)
        ..lineTo(7, 13)
        ..lineTo(16, 4),
      cornerPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - 7, size.height - 22)
        ..lineTo(size.width - 7, size.height - 13)
        ..lineTo(size.width - 16, size.height - 4),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _NeonButtonDecorationPainter oldDelegate) {
    return oldDelegate.accent != accent || oldDelegate.enabled != enabled;
  }
}

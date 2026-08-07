import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Decorative geometric pattern. Use inside a [Stack] with [Positioned.fill]
/// (or another sized parent). Does not include [Positioned] itself so it can be
/// wrapped with [IgnorePointer] safely.
class GeoPattern extends StatelessWidget {
  const GeoPattern({super.key, this.dark = true, this.id = 'geo'});

  final bool dark;
  final String id;

  @override
  Widget build(BuildContext context) {
    final stroke = dark ? AppColors.white : AppColors.charcoal;
    final opacity = dark ? 0.05 : 0.06;
    return CustomPaint(
      painter: _GeoPatternPainter(stroke: stroke, opacity: opacity),
      child: const SizedBox.expand(),
    );
  }
}

class _GeoPatternPainter extends CustomPainter {
  _GeoPatternPainter({required this.stroke, required this.opacity});

  final Color stroke;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final paint = Paint()
      ..color = stroke.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const step = 72.0;
    for (var y = 0.0; y < size.height; y += step) {
      for (var x = 0.0; x < size.width; x += step) {
        final cx = x + 36;
        final cy = y + 36;
        canvas.drawCircle(Offset(cx, cy), 3, paint);
        final path = Path()
          ..moveTo(cx, cy - 32)
          ..lineTo(cx + 6, cy - 18)
          ..lineTo(cx + 20, cy - 24)
          ..lineTo(cx + 14, cy - 10)
          ..lineTo(cx + 28, cy - 12)
          ..lineTo(cx + 18, cy - 2)
          ..lineTo(cx + 28, cy + 8)
          ..lineTo(cx + 14, cy + 6)
          ..lineTo(cx + 20, cy + 20)
          ..lineTo(cx + 6, cy + 14)
          ..lineTo(cx, cy + 28)
          ..lineTo(cx - 6, cy + 14)
          ..lineTo(cx - 20, cy + 20)
          ..lineTo(cx - 14, cy + 6)
          ..lineTo(cx - 28, cy + 8)
          ..lineTo(cx - 18, cy - 2)
          ..lineTo(cx - 28, cy - 12)
          ..lineTo(cx - 14, cy - 10)
          ..lineTo(cx - 20, cy - 24)
          ..lineTo(cx - 6, cy - 18)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

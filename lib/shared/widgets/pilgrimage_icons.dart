import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'kaaba_icon.dart';

export 'kaaba_icon.dart';

/// Tawaf ring + Kaaba centre (Umrah journey card).
class TawafIcon extends StatelessWidget {
  const TawafIcon({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: const _TawafPainter());
  }
}

class _TawafPainter extends CustomPainter {
  const _TawafPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 64;
    final cx = 32 * s, cy = 32 * s;
    canvas.drawCircle(
      Offset(cx, cy),
      27 * s,
      Paint()
        ..color = AppColors.yellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * s,
    );
    for (final deg in [0, 52, 104, 156, 208, 260, 312]) {
      final r = deg * math.pi / 180;
      canvas.drawCircle(
        Offset(cx + 19 * s * math.cos(r), cy + 19 * s * math.sin(r)),
        2.5 * s,
        Paint()..color = AppColors.yellow.withValues(alpha: 0.55),
      );
    }
    final rect = RRect.fromRectAndRadius(Rect.fromLTWH(20 * s, 19 * s, 24 * s, 28 * s), Radius.circular(2 * s));
    canvas.drawRRect(rect, Paint()..color = AppColors.navy);
    canvas.drawRRect(
      rect,
      Paint()
        ..color = AppColors.yellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * s,
    );
    canvas.drawRect(Rect.fromLTWH(20 * s, 28 * s, 24 * s, 5 * s), Paint()..color = AppColors.yellow.withValues(alpha: 0.12));
    final door = Path()
      ..moveTo(26 * s, 47 * s)
      ..lineTo(26 * s, 38 * s)
      ..quadraticBezierTo(32 * s, 32 * s, 38 * s, 38 * s)
      ..lineTo(38 * s, 47 * s)
      ..close();
    canvas.drawPath(door, Paint()..color = AppColors.yellow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Arafat mountain silhouette (Hajj card).
class ArafatIcon extends StatelessWidget {
  const ArafatIcon({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: const _ArafatPainter());
  }
}

class _ArafatPainter extends CustomPainter {
  const _ArafatPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 56;
    canvas.drawCircle(Offset(28 * s, 13 * s), 8 * s, Paint()..color = AppColors.yellow.withValues(alpha: 0.15));
    canvas.drawCircle(Offset(28 * s, 13 * s), 5 * s, Paint()..color = AppColors.yellow.withValues(alpha: 0.28));
    final mountain = Path()
      ..moveTo(2 * s, 46 * s)
      ..lineTo(14 * s, 26 * s)
      ..lineTo(20 * s, 34 * s)
      ..lineTo(28 * s, 18 * s)
      ..lineTo(36 * s, 34 * s)
      ..lineTo(43 * s, 24 * s)
      ..lineTo(54 * s, 46 * s)
      ..close();
    canvas.drawPath(mountain, Paint()..color = AppColors.navy);
    canvas.drawPath(
      mountain,
      Paint()
        ..color = AppColors.yellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8 * s,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Featured guide uses Kaaba SVG from assets (CMS: pilgrimage.featured_kaaba).
class FeaturedKaabaIcon extends StatelessWidget {
  const FeaturedKaabaIcon({super.key, this.size = 42});

  final double size;

  @override
  Widget build(BuildContext context) {
    return KaabaIcon(size: size, pageKey: 'pilgrimage', slotKey: 'featured_kaaba');
  }
}

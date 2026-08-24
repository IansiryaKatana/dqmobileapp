import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/services/qibla_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/dq_theme.dart';

/// Live Qibla compass. Needle points to Kaaba relative to device heading.
///
/// Big number = absolute Qibla bearing (true north), matching Google Qibla Finder.
/// When the phone top faces Qibla within tolerance, shows “Qibla found”.
class QiblaCompass extends StatefulWidget {
  const QiblaCompass({
    super.key,
    required this.qiblaBearing,
    this.heading,
    this.compassAvailable = true,
    this.size = 248,
  });

  final double qiblaBearing;
  final double? heading;
  final bool compassAvailable;
  final double size;

  @override
  State<QiblaCompass> createState() => _QiblaCompassState();
}

class _QiblaCompassState extends State<QiblaCompass> with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _smoothController;
  double _displayNeedle = 0;
  double _fromNeedle = 0;
  double _toNeedle = 0;
  bool _introDone = false;

  double get _targetNeedle {
    if (widget.heading == null) return widget.qiblaBearing;
    return QiblaService.relativeNeedleDegrees(widget.qiblaBearing, widget.heading);
  }

  bool get _aligned => QiblaService.isAligned(widget.qiblaBearing, widget.heading);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _smoothController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    )..addListener(() {
        final t = Curves.easeOut.transform(_smoothController.value);
        setState(() => _displayNeedle = _lerpAngle(_fromNeedle, _toNeedle, t));
      });

    _fromNeedle = 0;
    _toNeedle = _targetNeedle + 720;
    _smoothController.duration = const Duration(milliseconds: 1600);
    _smoothController.forward().whenComplete(() {
      if (!mounted) return;
      _introDone = true;
      _displayNeedle = _targetNeedle;
      _fromNeedle = _targetNeedle;
      _toNeedle = _targetNeedle;
      _smoothController.duration = const Duration(milliseconds: 180);
    });
  }

  @override
  void didUpdateWidget(covariant QiblaCompass oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!mounted || !_introDone) return;
    final next = _targetNeedle;
    if ((next - _toNeedle).abs() < 0.4) return;
    _fromNeedle = _displayNeedle;
    _toNeedle = next;
    _smoothController
      ..reset()
      ..forward();
  }

  static double _lerpAngle(double from, double to, double t) {
    var delta = (to - from) % 360;
    if (delta > 180) delta -= 360;
    if (delta < -180) delta += 360;
    return (from + delta * t) % 360;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _smoothController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dq = context.dq;
    final showLive = widget.heading != null && widget.compassAvailable;
    final absoluteLabel = widget.qiblaBearing.round();
    final instruction = showLive
        ? QiblaService.turnInstruction(widget.qiblaBearing, widget.heading)
        : widget.compassAvailable
            ? 'Waiting for compass…'
            : 'Compass unavailable on this device';

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: _aligned
                ? [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.35),
                      blurRadius: 28,
                      spreadRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              return CustomPaint(
                painter: _CompassPainter(
                  needleDegrees: _displayNeedle,
                  pulse: _pulseController.value,
                  aligned: _aligned,
                  dialFace: colors.surface,
                  dialBorder: dq.cardBorder,
                  tickMajor: colors.onSurface,
                  tickMinor: dq.muted,
                  hub: colors.onSurface,
                ),
                size: Size(widget.size, widget.size),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _aligned
              ? Container(
                  key: const ValueKey('found'),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Qibla found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                )
              : Text(
                  key: const ValueKey('bearing'),
                  '$absoluteLabel°',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: AppColors.yellow,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
        ),
        const SizedBox(height: 6),
        Text(
          _aligned
              ? 'Hold steady — you are facing Makkah'
              : 'Qibla ${QiblaService.directionLabel(widget.qiblaBearing)} from true north',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.onSurface),
        ),
        const SizedBox(height: 4),
        Text(
          instruction,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: _aligned ? const Color(0xFF059669) : dq.muted,
            fontWeight: _aligned ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        if (showLive && !_aligned) ...[
          const SizedBox(height: 8),
          Text(
            'Rotate until the needle points up',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: dq.muted.withValues(alpha: 0.85)),
          ),
        ],
      ],
    );
  }
}

class _CompassPainter extends CustomPainter {
  _CompassPainter({
    required this.needleDegrees,
    required this.pulse,
    required this.aligned,
    required this.dialFace,
    required this.dialBorder,
    required this.tickMajor,
    required this.tickMinor,
    required this.hub,
  });

  final double needleDegrees;
  final double pulse;
  final bool aligned;
  final Color dialFace;
  final Color dialBorder;
  final Color tickMajor;
  final Color tickMinor;
  final Color hub;

  static const _cx = 112.0;
  static const _cy = 112.0;

  double _toRad(double d) => (d - 90) * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 224;
    canvas.scale(scale);

    final ringColor = aligned ? const Color(0xFF10B981) : dialBorder;
    final borderPaint = Paint()
      ..color = ringColor.withValues(alpha: aligned ? 0.85 : 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = aligned ? 3 : 2;
    canvas.drawCircle(const Offset(_cx, _cy), 109, borderPaint);

    canvas.drawCircle(const Offset(_cx, _cy), 104, Paint()..color = dialFace);
    canvas.drawCircle(
      const Offset(_cx, _cy),
      104,
      Paint()
        ..color = dialBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    for (var i = 0; i < 72; i++) {
      final a = _toRad(i * 5.0);
      final isCard = i % 18 == 0;
      final isInter = i % 9 == 0;
      final isSub = i % 3 == 0;
      final r2 = 104.0;
      final r1 = isCard ? 88.0 : isInter ? 92.0 : isSub ? 97.0 : 100.0;
      final paint = Paint()
        ..color = (isCard ? tickMajor : tickMinor)
            .withValues(alpha: isCard ? 0.55 : isInter ? 0.35 : 0.18)
        ..strokeWidth = isCard ? 1.8 : isInter ? 1.1 : isSub ? 0.65 : 0.35
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(_cx + r2 * math.cos(a), _cy + r2 * math.sin(a)),
        Offset(_cx + r1 * math.cos(a), _cy + r1 * math.sin(a)),
        paint,
      );
    }

    const labels = ['N', 'E', 'S', 'W'];
    for (var i = 0; i < 4; i++) {
      final a = _toRad(i * 90.0);
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: labels[i] == 'N' ? AppColors.yellow : tickMinor.withValues(alpha: 0.6),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(_cx + 75 * math.cos(a) - tp.width / 2, _cy + 75 * math.sin(a) - tp.height / 2),
      );
    }

    for (final delay in [0.0, 0.5]) {
      final t = ((pulse + delay) % 1.0);
      final r = 6 + t * 66;
      final color = aligned ? const Color(0xFF10B981) : AppColors.yellow;
      canvas.drawCircle(
        const Offset(_cx, _cy),
        r,
        Paint()
          ..color = color.withValues(alpha: (1 - t) * 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }

    // Fixed “face this way” marker at top (phone top / screen up).
    final topMarker = Path()
      ..moveTo(_cx, 8)
      ..lineTo(_cx + 8, 22)
      ..lineTo(_cx - 8, 22)
      ..close();
    canvas.drawPath(
      topMarker,
      Paint()..color = aligned ? const Color(0xFF10B981) : hub,
    );

    canvas.save();
    canvas.translate(_cx, _cy);
    canvas.rotate(needleDegrees * math.pi / 180);
    canvas.translate(-_cx, -_cy);

    final counterNeedle = Path()
      ..moveTo(_cx, _cy + 78)
      ..lineTo(_cx + 5, _cy + 12)
      ..lineTo(_cx, _cy + 24)
      ..lineTo(_cx - 5, _cy + 12)
      ..close();
    canvas.drawPath(counterNeedle, Paint()..color = tickMinor.withValues(alpha: 0.38));

    final needleColor = aligned ? const Color(0xFF10B981) : AppColors.yellow;
    final qiblaNeedle = Path()
      ..moveTo(_cx, _cy - 78)
      ..lineTo(_cx + 5, _cy - 12)
      ..lineTo(_cx, _cy - 24)
      ..lineTo(_cx - 5, _cy - 12)
      ..close();
    canvas.drawPath(qiblaNeedle, Paint()..color = needleColor);

    canvas.drawCircle(Offset(_cx, _cy - 78), 4, Paint()..color = needleColor.withValues(alpha: 0.3));
    canvas.drawCircle(const Offset(_cx, _cy), 9, Paint()..color = hub);
    canvas.drawCircle(const Offset(_cx, _cy), 4.5, Paint()..color = needleColor);
    canvas.drawCircle(const Offset(_cx, _cy), 2, Paint()..color = hub);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) =>
      oldDelegate.needleDegrees != needleDegrees ||
      oldDelegate.pulse != pulse ||
      oldDelegate.aligned != aligned ||
      oldDelegate.dialFace != dialFace ||
      oldDelegate.dialBorder != dialBorder ||
      oldDelegate.tickMajor != tickMajor ||
      oldDelegate.tickMinor != tickMinor ||
      oldDelegate.hub != hub;
}

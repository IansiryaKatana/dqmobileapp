import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';

/// Full-bleed gold→black textured background for splash and onboarding.
class DqOnboardBackground extends StatelessWidget {
  const DqOnboardBackground({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          AppAssets.onboardingBg,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFF0B141D)),
        ),
        // Soft bottom fade only — source art already darkens toward the base.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.transparent,
                Color(0x33000000),
                Color(0x88000000),
              ],
              stops: [0.0, 0.45, 0.72, 1.0],
            ),
          ),
        ),
        if (child case final child?) child,
      ],
    );
  }
}

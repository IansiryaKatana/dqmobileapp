import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_assets.dart';
import '../../core/services/app_media_repository.dart';

/// Full-bleed brand→black textured background for splash and onboarding.
/// CMS: App Media → Onboarding → Background (`onboarding.background`).
class DqOnboardBackground extends ConsumerWidget {
  const DqOnboardBackground({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Color(0xFF0B141D)),
        const Positioned.fill(
          child: AppMediaImage(
            pageKey: 'onboarding',
            slotKey: 'background',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            fallbackAsset: AppAssets.onboardingBg,
          ),
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

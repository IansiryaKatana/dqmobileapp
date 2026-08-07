import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Figma wordmark: "Donate" in navy/white + "Quran" in yellow.
class DqLogo extends StatelessWidget {
  const DqLogo({super.key, this.size = LogoSize.medium, this.light = false});

  final LogoSize size;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final fontSize = switch (size) {
      LogoSize.small => 16.0,
      LogoSize.medium => 20.0,
      LogoSize.large => 24.0,
    };
    final donateColor = light ? AppColors.white : AppColors.navy;
    return Semantics(
      label: 'Donate Quran',
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          children: [
            TextSpan(text: 'Donate', style: TextStyle(color: donateColor)),
            const TextSpan(text: ' Quran', style: TextStyle(color: AppColors.yellow)),
          ],
        ),
      ),
    );
  }
}

enum LogoSize { small, medium, large }

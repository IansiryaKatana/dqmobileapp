import 'package:flutter/material.dart';

import 'app_colors.dart';

class DqTheme extends ThemeExtension<DqTheme> {
  const DqTheme({
    required this.surfaceAlt,
    required this.cardBorder,
    required this.muted,
    required this.hero,
  });

  final Color surfaceAlt;
  final Color cardBorder;
  final Color muted;
  final Color hero;

  static DqTheme of(BuildContext context) =>
      Theme.of(context).extension<DqTheme>()!;

  static const light = DqTheme(
    surfaceAlt: AppColors.sand,
    cardBorder: AppColors.border,
    muted: AppColors.muted,
    hero: AppColors.navy,
  );

  static const dark = DqTheme(
    surfaceAlt: AppColors.darkSand,
    cardBorder: Color(0xFF2A3D52),
    muted: Color(0xFF9CA3AF),
    hero: AppColors.navy,
  );

  @override
  DqTheme copyWith({
    Color? surfaceAlt,
    Color? cardBorder,
    Color? muted,
    Color? hero,
  }) {
    return DqTheme(
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      cardBorder: cardBorder ?? this.cardBorder,
      muted: muted ?? this.muted,
      hero: hero ?? this.hero,
    );
  }

  @override
  DqTheme lerp(ThemeExtension<DqTheme>? other, double t) {
    if (other is! DqTheme) return this;
    return DqTheme(
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      hero: Color.lerp(hero, other.hero, t)!,
    );
  }
}

extension DqThemeContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  DqTheme get dq => DqTheme.of(this);
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/dq_theme.dart';
import 'kaaba_icon.dart';

class DqFeaturedGuideCard extends StatelessWidget {
  const DqFeaturedGuideCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge = 'Featured Guide',
    this.icon,
    this.leading,
  });

  final String badge;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final IconData? icon;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkCard : AppColors.white;
    final titleColor = isDark ? AppColors.darkText : AppColors.navy;
    final iconColor = isDark ? AppColors.yellow : AppColors.navy;

    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.yellow, width: 2),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.yellow.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.yellow.withValues(alpha: 0.28)),
                ),
                child: leading ?? Icon(icon ?? Icons.mosque_rounded, size: 32, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      badge.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: AppColors.yellow,
                      ),
                    ),
                    Text(
                      title,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: titleColor, height: 1.25),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: context.dq.muted)),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(color: AppColors.yellow, shape: BoxShape.circle),
                child: const Icon(Icons.chevron_right, size: 18, color: AppColors.onBrand),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

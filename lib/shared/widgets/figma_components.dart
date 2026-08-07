import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/dq_theme.dart';

/// Figma pill tabs (yellow active, sand inactive).
class DqPillTabs<T> extends StatelessWidget {
  const DqPillTabs({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onSelected,
    required this.labelBuilder,
  });

  final List<T> tabs;
  final T selected;
  final ValueChanged<T> onSelected;
  final String Function(T tab) labelBuilder;

  @override
  Widget build(BuildContext context) {
    final dq = context.dq;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((tab) {
          final isActive = tab == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: isActive ? AppColors.yellow : dq.surfaceAlt,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () => onSelected(tab),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Text(
                    labelBuilder(tab),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive ? AppColors.navy : dq.muted,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class DqSectionLabel extends StatelessWidget {
  const DqSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final dq = context.dq;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: dq.muted,
        ),
      ),
    );
  }
}

/// Figma grouped menu list with white rows and chevrons.
class DqMenuGroup extends StatelessWidget {
  const DqMenuGroup({super.key, required this.items});

  final List<DqMenuItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dq = context.dq;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dq.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Material(
            color: colors.surface,
            child: InkWell(
              onTap: item.onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: i > 0 ? Border(top: BorderSide(color: dq.cardBorder)) : null,
                ),
                child: Row(
                  children: [
                    if (item.icon != null) ...[
                      Icon(item.icon, size: 18, color: colors.onSurface),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.onSurface),
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 18, color: dq.muted),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class DqMenuItem {
  const DqMenuItem({required this.label, required this.onTap, this.icon});

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
}

/// Figma surah list row.
class DqSurahRow extends StatelessWidget {
  const DqSurahRow({
    super.key,
    required this.number,
    required this.nameEn,
    required this.nameAr,
    required this.verses,
    required this.onTap,
  });

  final int number;
  final String nameEn;
  final String nameAr;
  final int verses;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dq = context.dq;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: dq.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: dq.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$number',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: colors.onSurface),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nameEn, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.onSurface)),
                    Text('$verses verses', style: TextStyle(fontSize: 11, color: dq.muted)),
                  ],
                ),
              ),
              Text(
                nameAr,
                style: GoogleFonts.amiri(fontSize: 17, color: colors.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Figma saved ayah card.
class DqSavedAyahCard extends StatelessWidget {
  const DqSavedAyahCard({
    super.key,
    required this.reference,
    required this.arabic,
    required this.english,
  });

  final String reference;
  final String arabic;
  final String english;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dq = context.dq;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dq.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(reference, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.yellow)),
          const SizedBox(height: 10),
          Text(
            arabic,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.amiri(fontSize: 20, height: 1.9, color: colors.onSurface),
          ),
          const SizedBox(height: 10),
          Text(english, style: TextStyle(fontSize: 13, height: 1.5, color: dq.muted)),
        ],
      ),
    );
  }
}

/// Figma 2-column info card grid item.
class DqInfoTile extends StatelessWidget {
  const DqInfoTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dq = context.dq;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dq.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.yellow),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: dq.muted)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Figma continue-reading navy card.
class DqContinueReadingCard extends StatelessWidget {
  const DqContinueReadingCard({
    super.key,
    required this.surah,
    required this.ayah,
    this.subtitle,
    required this.onContinue,
  });

  final String surah;
  final String ayah;
  final String? subtitle;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.yellow.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Continue Reading', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
                const SizedBox(height: 2),
                Text(surah, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                if (subtitle != null)
                  Text(subtitle!, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.35))),
              ],
            ),
          ),
          Material(
            color: AppColors.yellow,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onContinue,
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Continue', style: TextStyle(color: AppColors.navy, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Figma mini audio player bar.
class DqMiniAudioBar extends StatelessWidget {
  const DqMiniAudioBar({
    super.key,
    required this.title,
    required this.reciter,
    required this.playing,
    required this.onToggle,
    this.progress,
    this.dark = false,
  });

  final String title;
  final String reciter;
  final bool playing;
  final VoidCallback onToggle;
  /// Null when indeterminate / live playback (shows animated indeterminate bar).
  final double? progress;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dq = context.dq;
    final bg = dark ? AppColors.navy : Theme.of(context).scaffoldBackgroundColor;
    final innerBg = dark ? Colors.white.withValues(alpha: 0.06) : dq.surfaceAlt;
    final txt = dark ? Colors.white : colors.onSurface;
    final dim = dark ? Colors.white.withValues(alpha: 0.38) : dq.muted;
    final track = dark ? Colors.white.withValues(alpha: 0.12) : dq.cardBorder;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: dark ? Colors.white.withValues(alpha: 0.07) : dq.cardBorder)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: innerBg, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: txt)),
                  Text(reciter, style: TextStyle(fontSize: 11, color: dim)),
                ],
              ),
            ),
            SizedBox(
              width: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: track,
                  color: AppColors.yellow,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Material(
              color: AppColors.yellow,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onToggle,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(playing ? Icons.pause : Icons.play_arrow, color: AppColors.navy, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Figma search field on sand background.
class DqSearchField extends StatelessWidget {
  const DqSearchField({super.key, required this.hint, required this.onChanged});

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dq = context.dq;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: dq.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dq.cardBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 15, color: dq.muted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(fontSize: 13, color: dq.muted),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              style: TextStyle(fontSize: 13, color: colors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

/// Navy hero header used on profile history screens (Figma profileScreens).
class DqNavyHeader extends StatelessWidget {
  const DqNavyHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.onBack,
    this.stats,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onBack;
  final Widget? stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(color: AppColors.navy),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -32,
            right: -32,
            child: Container(
              width: 144,
              height: 144,
              decoration: BoxDecoration(
                color: AppColors.yellow.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: onBack,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  minimumSize: const Size(32, 32),
                  padding: EdgeInsets.zero,
                ),
                icon: const Icon(Icons.arrow_back, size: 16, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
              ],
              if (stats != null) ...[const SizedBox(height: 16), stats!],
            ],
          ),
        ],
      ),
    );
  }
}

/// Figma-styled auth text field (rounded, sand border).
class DqAuthField extends StatelessWidget {
  const DqAuthField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.navy, width: 1.5)),
        suffixIcon: suffix,
      ),
      style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown/markdown.dart' as md;

import '../../core/constants/app_assets.dart';
import '../../core/router/root_nav.dart';
import '../../core/services/app_media_repository.dart';
import '../../core/services/guide_repository.dart';
import '../../core/services/guide_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/dq_theme.dart';
import '../../shared/widgets/dq_buttons.dart';
import '../../shared/widgets/dq_states.dart';
import '../../shared/widgets/geo_pattern.dart';
import '../../shared/widgets/pilgrimage_icons.dart';

class UmrahHajjScreen extends ConsumerWidget {
  const UmrahHajjScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hubAsync = ref.watch(pilgrimageHubProvider);

    return hubAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => _UmrahHajjBody(
        hub: GuideService.hub,
        journey: GuideService.journeySections(),
        explore: GuideService.exploreSections(),
      ),
      data: (data) => _UmrahHajjBody(hub: data.hub, journey: data.journey, explore: data.explore),
    );
  }
}

class _UmrahHajjBody extends StatelessWidget {
  const _UmrahHajjBody({
    required this.hub,
    required this.journey,
    required this.explore,
  });

  final GuideHubCopy hub;
  final List<GuideSection> journey;
  final List<GuideSection> explore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DqScreenHeader(title: 'Umrah & Hajj', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  _heroBanner(hub),
                  const SizedBox(height: 20),
                  const _SectionLabel('Start Your Journey'),
                  const SizedBox(height: 8),
                  ...journey.map(
                    (section) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _JourneyCard(
                        badge: section.badge.isNotEmpty ? section.badge : 'Step by Step',
                        title: section.title,
                        subtitle: section.subtitle,
                        slug: section.slug,
                        icon: guideIconFor(section.icon),
                        onTap: () => pushRootRoute(context, section.route),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const _SectionLabel('Explore More'),
                  const SizedBox(height: 8),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1,
                    children: explore
                        .map(
                          (section) => _ExploreTile(
                            label: section.title.replaceAll(' ', '\n'),
                            icon: guideIconFor(section.icon),
                            onTap: () => pushRootRoute(context, section.route),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.dq.cardBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.mosque_outlined, color: context.colors.primary, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            hub.disclaimer,
                            style: TextStyle(fontSize: 12, height: 1.5, color: context.dq.muted),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroBanner(GuideHubCopy hub) {
    final ayahAr = hub.ayahAr.trim();
    final ayahEn = hub.ayahEn.trim();
    final ayahRef = hub.ayahRef.trim();
    final translation = [
      if (ayahEn.isNotEmpty) '"$ayahEn"',
      if (ayahRef.isNotEmpty) ayahRef,
    ].join(' — ');

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: const BoxDecoration(color: AppColors.navy),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.yellow.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.yellow.withValues(alpha: 0.25)),
                      ),
                      child: const Center(child: TawafIcon(size: 42)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hub.eyebrow,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                              color: AppColors.yellow.withValues(alpha: 0.85),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _prettyTitle(hub.title),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (ayahAr.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    ayahAr,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.amiri(
                      fontSize: 17,
                      height: 1.7,
                      color: AppColors.yellow.withValues(alpha: 0.55),
                    ),
                  ),
                  if (translation.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          translation,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
          const Positioned.fill(child: IgnorePointer(child: GeoPattern(dark: true))),
        ],
      ),
    );
  }
}

/// CMS-backed step-by-step guide (Umrah, Hajj, Spiritual Prep, etc.)
class GuideStepsScreen extends ConsumerStatefulWidget {
  const GuideStepsScreen({super.key, required this.slug});

  final String slug;

  @override
  ConsumerState<GuideStepsScreen> createState() => _GuideStepsScreenState();
}

class _GuideStepsScreenState extends ConsumerState<GuideStepsScreen> {
  int? _openStep = 0;

  bool get _isPilgrimage => widget.slug == 'umrah' || widget.slug == 'hajj';

  @override
  void didUpdateWidget(GuideStepsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slug != widget.slug) {
      _openStep = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sectionAsync = ref.watch(guideSectionProvider(widget.slug));
    final stepsAsync = ref.watch(guideStepsProvider(widget.slug));

    final fallback = GuideService.sectionBySlug(widget.slug);
    final title = sectionAsync.maybeWhen(data: (s) => s?.title, orElse: () => null) ?? fallback?.title ?? 'Guide';
    final subtitle = sectionAsync.maybeWhen(data: (s) => s?.subtitle, orElse: () => null) ?? fallback?.subtitle ?? '';

    if (_isPilgrimage) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        body: Column(
          children: [
            Expanded(
              child: stepsAsync.when(
                loading: () => Column(
                  children: [
                    _PilgrimageGuideHeader(
                      slug: widget.slug,
                      title: title,
                      subtitle: subtitle,
                      stepCount: 0,
                      openStep: null,
                      onSelect: (_) {},
                    ),
                    const Expanded(
                      child: ColoredBox(
                        color: AppColors.cream,
                        child: DqLoadingOverlay(message: 'Loading guide...'),
                      ),
                    ),
                  ],
                ),
                error: (_, _) => _pilgrimageBody(
                  title: title,
                  subtitle: subtitle,
                  steps: GuideService.stepsFor(widget.slug).map(_withStructuredFields).toList(),
                ),
                data: (steps) {
                  if (steps.isEmpty) {
                    return ColoredBox(
                      color: AppColors.cream,
                      child: SafeArea(
                        child: Column(
                          children: [
                            _PilgrimageGuideHeader(
                              slug: widget.slug,
                              title: title,
                              subtitle: subtitle,
                              stepCount: 0,
                              openStep: _openStep,
                              onSelect: (_) {},
                            ),
                            const Expanded(
                              child: DqEmptyState(
                                icon: Icons.menu_book_outlined,
                                title: 'No steps yet',
                                message: 'This guide is being prepared. Please check back soon.',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return _pilgrimageBody(
                    title: title,
                    subtitle: subtitle,
                    steps: steps.map(_withStructuredFields).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DqScreenHeader(title: title, onBack: () => context.pop()),
            Expanded(
              child: stepsAsync.when(
                loading: () => const DqLoadingOverlay(message: 'Loading guide...'),
                error: (_, _) => _stepsList(context, GuideService.stepsFor(widget.slug)),
                data: (steps) {
                  if (steps.isEmpty) {
                    return const DqEmptyState(
                      icon: Icons.menu_book_outlined,
                      title: 'No steps yet',
                      message: 'This guide is being prepared. Please check back soon.',
                    );
                  }
                  return _stepsList(context, steps);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pilgrimageBody({
    required String title,
    required String subtitle,
    required List<GuideStep> steps,
  }) {
    final safeOpen = _openStep == null
        ? null
        : (_openStep!.clamp(0, steps.isEmpty ? 0 : steps.length - 1));

    return Column(
      children: [
        _PilgrimageGuideHeader(
          slug: widget.slug,
          title: title,
          subtitle: subtitle,
          stepCount: steps.length,
          openStep: safeOpen,
          onSelect: (i) => setState(() => _openStep = _openStep == i ? null : i),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            itemCount: steps.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final step = steps[i];
              final n = step.sortOrder > 0 ? step.sortOrder : i + 1;
              return _PilgrimageAccordionCard(
                step: step,
                stepNumber: n,
                slug: widget.slug,
                isOpen: safeOpen == i,
                onToggle: () => setState(() => _openStep = _openStep == i ? null : i),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _stepsList(BuildContext context, List<GuideStep> steps) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: steps.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final step = steps[i];
        return Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(color: context.dq.cardBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (step.imageAsset != null)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _logisticsMediaForAsset(step.imageAsset!),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.yellow,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(color: AppColors.onBrand, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(step.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          const SizedBox(height: 6),
                          Text(step.body, style: TextStyle(fontSize: 13, height: 1.5, color: context.dq.muted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PilgrimageGuideHeader extends ConsumerWidget {
  const _PilgrimageGuideHeader({
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.stepCount,
    required this.openStep,
    required this.onSelect,
  });

  final String slug;
  final String title;
  final String subtitle;
  final int stepCount;
  final int? openStep;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final map = ref.watch(appMediaMapProvider).valueOrNull;
    final url = map?['$slug.header']?.url;
    final hasImage = url != null && url.isNotEmpty;

    return ColoredBox(
      color: AppColors.navy,
      child: Stack(
        children: [
          if (hasImage)
            Positioned.fill(
              child: AppMediaImage(pageKey: slug, slotKey: AppAssets.pilgrimageHeaderSlot, fit: BoxFit.cover),
            ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.navy.withValues(alpha: hasImage ? 0.45 : 1),
                      AppColors.navy.withValues(alpha: hasImage ? 0.78 : 1),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (!hasImage) const Positioned.fill(child: IgnorePointer(child: GeoPattern(dark: true))),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DqBackButton(onPressed: () => context.pop(), dark: true),
                  const SizedBox(height: 16),
                  Text(
                    'Umrah & Hajj',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.yellow,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _prettyTitle(title),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  if (subtitle.isNotEmpty || stepCount > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      [
                        if (stepCount > 0) '$stepCount steps',
                        if (subtitle.isNotEmpty) subtitle,
                      ].join(' · '),
                      style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5)),
                    ),
                  ],
                  if (stepCount > 0) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: stepCount,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final isOpen = openStep == i;
                          return SizedBox(
                            width: 44,
                            height: 44,
                            child: Material(
                              color: isOpen ? AppColors.yellow : Colors.white.withValues(alpha: 0.15),
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => onSelect(i),
                                child: Center(
                                  child: Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: isOpen ? AppColors.navy : Colors.white.withValues(alpha: 0.75),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PilgrimageAccordionCard extends StatelessWidget {
  const _PilgrimageAccordionCard({
    required this.step,
    required this.stepNumber,
    required this.slug,
    required this.isOpen,
    required this.onToggle,
  });

  final GuideStep step;
  final int stepNumber;
  final String slug;
  final bool isOpen;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final arabic = step.arabic?.trim();
    final arabicEn = step.arabicEn?.trim();
    final showDuaCard = arabicEn != null && arabicEn.isNotEmpty;
    final markdown = step.description.isNotEmpty ? step.description : step.body;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isOpen ? AppColors.navy : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: isOpen ? 0.12 : 0.05),
            blurRadius: isOpen ? 16 : 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isOpen ? AppColors.navy : AppColors.sand,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'STEP',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                            color: isOpen ? AppColors.yellow : AppColors.muted,
                          ),
                        ),
                        Text(
                          '$stepNumber',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            height: 1,
                            color: isOpen ? AppColors.yellow : AppColors.navy,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            height: 1.25,
                            color: AppColors.charcoal,
                          ),
                        ),
                        if (step.subtitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            step.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: AppColors.muted),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isOpen ? AppColors.navy : AppColors.sand,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: isOpen ? Colors.white : AppColors.navy,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isOpen) ...[
            Divider(height: 1, color: AppColors.border),
            _PilgrimageStepImage(pageKey: slug, stepNumber: stepNumber),
            if (arabic != null && arabic.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.yellow,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        arabic,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.amiri(fontSize: 16, color: AppColors.navy),
                      ),
                    ),
                  ],
                ),
              ),
            if (markdown.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: MarkdownBody(
                  data: markdown,
                  selectable: false,
                  builders: {'blockquote': _NavyBlockquoteBuilder()},
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(fontSize: 13, height: 1.55, color: AppColors.charcoal),
                    strong: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: AppColors.navy,
                    ),
                    listBullet: const TextStyle(color: AppColors.yellow, fontSize: 13),
                    listBulletPadding: const EdgeInsets.only(right: 8),
                    em: const TextStyle(fontStyle: FontStyle.italic, color: AppColors.muted, fontSize: 13),
                    h1: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.navy),
                    h2: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.navy),
                    h3: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.navy),
                  ),
                ),
              ),
            if (showDuaCard)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.yellow.withValues(alpha: 0.12)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (arabic != null && arabic.isNotEmpty)
                        Text(
                          arabic,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.amiri(fontSize: 20, height: 1.8, color: AppColors.yellow),
                        ),
                      if (arabic != null && arabic.isNotEmpty) const SizedBox(height: 8),
                      Text(
                        arabicEn,
                        style: TextStyle(fontSize: 12, height: 1.5, color: Colors.white.withValues(alpha: 0.55)),
                      ),
                    ],
                  ),
                ),
              )
            else
              const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _PilgrimageStepImage extends ConsumerWidget {
  const _PilgrimageStepImage({required this.pageKey, required this.stepNumber});

  final String pageKey;
  final int stepNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotKey = AppAssets.pilgrimageSlotFor(pageKey, stepNumber: stepNumber);
    final map = ref.watch(appMediaMapProvider).valueOrNull;
    final url = map?['$pageKey.$slotKey']?.url;
    if (url == null || url.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: AppMediaImage(pageKey: pageKey, slotKey: slotKey, fit: BoxFit.cover),
    );
  }
}

class _NavyBlockquoteBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final raw = element.textContent.trim();
    if (raw.isEmpty) return const SizedBox.shrink();
    final lines = raw.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.yellow.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < lines.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _quoteLine(lines[i], index: i),
          ],
        ],
      ),
    );
  }

  Widget _quoteLine(String line, {required int index}) {
    final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(line);
    if (hasArabic) {
      return Text(
        line,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: GoogleFonts.amiri(fontSize: 20, height: 1.8, color: AppColors.yellow),
      );
    }
    return Text(
      line,
      style: TextStyle(
        fontSize: 12,
        height: 1.5,
        fontStyle: index == 0 ? FontStyle.normal : FontStyle.italic,
        color: Colors.white.withValues(alpha: index <= 1 ? 0.9 : 0.55),
      ),
    );
  }
}

String _prettyTitle(String raw) {
  final text = raw.replaceAll('\\n', '\n').trim();
  if (text.isEmpty) return text;
  final letters = text.replaceAll(RegExp(r'[^A-Za-z]'), '');
  if (letters.isEmpty || letters != letters.toUpperCase()) return text;
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
  }).join(' ');
}

GuideStep _withStructuredFields(GuideStep step) {
  if (step.subtitle.isNotEmpty && step.description.isNotEmpty) return step;
  Map<String, dynamic>? meta;
  final trimmed = step.body.trim();
  if (trimmed.startsWith('{')) {
    try {
      meta = jsonDecode(trimmed) as Map<String, dynamic>;
    } catch (_) {
      meta = null;
    }
  }
  if (meta == null) {
    if (step.description.isNotEmpty) return step;
    return GuideStep(
      title: step.title,
      body: step.body,
      imageAsset: step.imageAsset,
      sortOrder: step.sortOrder,
      subtitle: step.subtitle,
      description: step.body,
      arabic: step.arabic,
      arabicEn: step.arabicEn,
      icon: step.icon,
      iconUrl: step.iconUrl,
      repeatLabel: step.repeatLabel,
      timeLabel: step.timeLabel,
      rakaat: step.rakaat,
      accent: step.accent,
    );
  }
  return GuideStep(
    title: step.title,
    body: step.body,
    imageAsset: step.imageAsset,
    sortOrder: step.sortOrder,
    subtitle: step.subtitle.isNotEmpty ? step.subtitle : (meta['subtitle'] as String? ?? ''),
    description: step.description.isNotEmpty
        ? step.description
        : (meta['desc'] as String? ?? meta['description'] as String? ?? ''),
    arabic: (step.arabic?.isNotEmpty == true) ? step.arabic : meta['arabic'] as String?,
    arabicEn: (step.arabicEn?.isNotEmpty == true) ? step.arabicEn : meta['arabic_en'] as String?,
    icon: step.icon,
    iconUrl: step.iconUrl,
    repeatLabel: step.repeatLabel,
    timeLabel: step.timeLabel,
    rakaat: step.rakaat,
    accent: step.accent,
  );
}

Widget _logisticsMediaForAsset(String assetPath) {
  const map = {
    AppAssets.logisticsVisa: 'visa',
    AppAssets.logisticsIhram: 'ihram',
    AppAssets.logisticsHaram: 'haram',
    AppAssets.logisticsNabawi: 'nabawi',
    AppAssets.logisticsJannat: 'jannat',
    AppAssets.logisticsNusuk: 'nusuk',
  };
  final slot = map[assetPath];
  if (slot == null) {
    return Image.asset(assetPath, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink());
  }
  return AppMediaImage(
    pageKey: 'logistics',
    slotKey: slot,
    fit: BoxFit.cover,
    fallbackAsset: assetPath,
  );
}

/// Legacy route aliases — prefer [GuideStepsScreen].
class UmrahGuideScreen extends StatelessWidget {
  const UmrahGuideScreen({super.key});

  @override
  Widget build(BuildContext context) => const GuideStepsScreen(slug: 'umrah');
}

class HajjGuideScreen extends StatelessWidget {
  const HajjGuideScreen({super.key});

  @override
  Widget build(BuildContext context) => const GuideStepsScreen(slug: 'hajj');
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: context.dq.muted),
      ),
    );
  }
}

class _JourneyCard extends StatelessWidget {
  const _JourneyCard({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.slug,
    required this.icon,
    required this.onTap,
  });

  final String badge;
  final String title;
  final String subtitle;
  final String slug;
  final IconData icon;
  final VoidCallback onTap;

  bool get _isHajj => slug == 'hajj';

  Widget _journeyIcon() {
    return switch (slug) {
      'umrah' => const TawafIcon(size: 52),
      'hajj' => const ArafatIcon(size: 52),
      _ => Icon(icon, size: 36, color: AppColors.navy),
    };
  }

  @override
  Widget build(BuildContext context) {
    final navyCard = _isHajj;
    return Material(
      color: navyCard ? AppColors.navy : context.colors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: navyCard ? null : Border.all(color: context.dq.cardBorder, width: 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              if (!navyCard) Container(height: 6, width: double.infinity, color: AppColors.yellow),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: AppColors.yellow.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.yellow.withValues(alpha: 0.28)),
                      ),
                      child: Center(child: _journeyIcon()),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            badge.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                              color: navyCard ? AppColors.yellow.withValues(alpha: 0.7) : AppColors.yellow,
                            ),
                          ),
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: navyCard ? Colors.white : AppColors.navy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.35,
                              color: navyCard ? Colors.white.withValues(alpha: 0.45) : context.dq.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(color: AppColors.yellow, shape: BoxShape.circle),
                      child: const Icon(Icons.chevron_right, color: AppColors.navy),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExploreTile extends StatelessWidget {
  const _ExploreTile({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.dq.cardBorder, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(color: AppColors.sand, borderRadius: BorderRadius.circular(18)),
                child: Icon(icon, color: context.colors.primary, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

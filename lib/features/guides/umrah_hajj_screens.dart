import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      error: (_, __) => _UmrahHajjBody(
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.sand,
              border: Border.all(color: AppColors.border, width: 1.5),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.yellow.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.yellow.withValues(alpha: 0.35)),
                  ),
                  child: const Center(child: FeaturedKaabaIcon(size: 52)),
                ),
                const SizedBox(height: 12),
                Container(width: 40, height: 1, color: AppColors.navy.withValues(alpha: 0.18)),
                const SizedBox(height: 12),
                Text(
                  hub.eyebrow,
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.muted, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  hub.title.replaceAll('\\n', '\n'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    letterSpacing: 1.2,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 12),
                Container(width: 40, height: 1, color: AppColors.navy.withValues(alpha: 0.18)),
              ],
            ),
          ),
          const Positioned.fill(child: IgnorePointer(child: GeoPattern(dark: false))),
        ],
      ),
    );
  }
}

/// CMS-backed step-by-step guide (Umrah, Hajj, Spiritual Prep, etc.)
class GuideStepsScreen extends ConsumerWidget {
  const GuideStepsScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionAsync = ref.watch(guideSectionProvider(slug));
    final stepsAsync = ref.watch(guideStepsProvider(slug));

    final fallback = GuideService.sectionBySlug(slug);
    final title = sectionAsync.maybeWhen(data: (s) => s?.title, orElse: () => null) ?? fallback?.title ?? 'Guide';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DqScreenHeader(title: title, onBack: () => context.pop()),
            Expanded(
              child: stepsAsync.when(
                loading: () => const DqLoadingOverlay(message: 'Loading guide...'),
                error: (_, __) => _stepsList(context, GuideService.stepsFor(slug)),
                data: (steps) {
                  if (steps.isEmpty) {
                    return DqEmptyState(
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

  Widget _stepsList(BuildContext context, List<GuideStep> steps) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: steps.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
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
    return Image.asset(assetPath, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink());
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

  Widget _journeyIcon() {
    return switch (slug) {
      'umrah' => const TawafIcon(size: 52),
      'hajj' => const ArafatIcon(size: 52),
      _ => Icon(icon, size: 36, color: AppColors.navy),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: context.dq.cardBorder, width: 1.5),
          ),
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
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1, color: AppColors.yellow),
                    ),
                    Text(title, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: context.colors.primary)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: context.dq.muted, height: 1.35)),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(color: AppColors.yellow, shape: BoxShape.circle),
                child: const Icon(Icons.chevron_right, color: AppColors.onBrand),
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

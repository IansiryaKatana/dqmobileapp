import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env_config.dart';
import 'content_repository.dart';
import 'guide_service.dart';

class PilgrimageHubData {
  const PilgrimageHubData({
    required this.hub,
    required this.journey,
    required this.explore,
    this.usedFallback = false,
  });

  final GuideHubCopy hub;
  final List<GuideSection> journey;
  final List<GuideSection> explore;
  final bool usedFallback;
}

IconData guideIconFor(String key) {
  return switch (key) {
    'mosque' => Icons.mosque_outlined,
    'landscape' => Icons.landscape_outlined,
    'volunteer_activism' => Icons.volunteer_activism_outlined,
    'location_city' => Icons.location_city_outlined,
    'luggage' => Icons.luggage_outlined,
    'quiz' => Icons.quiz_outlined,
    _ => Icons.menu_book_outlined,
  };
}

class GuideRepository {
  GuideRepository(this._client);

  final SupabaseClient? _client;

  Future<PilgrimageHubData> fetchHub() async {
    final hubCopy = await _fetchHubCopy();
    final sectionsResult = await _fetchSections();
    return PilgrimageHubData(
      hub: hubCopy.data,
      journey: sectionsResult.data.where((s) => s.hubGroup == 'journey').toList(),
      explore: sectionsResult.data.where((s) => s.hubGroup == 'explore').toList(),
      usedFallback: hubCopy.usedFallback || sectionsResult.usedFallback,
    );
  }

  Future<({GuideHubCopy data, bool usedFallback})> _fetchHubCopy() async {
    final client = _client;
    if (client == null) return (data: GuideService.hub, usedFallback: true);

    try {
      final row = await client.from('app_settings').select('value').eq('key', 'pilgrimage_hub').maybeSingle();
      final value = row?['value'] as Map<String, dynamic>?;
      if (value == null) return (data: GuideService.hub, usedFallback: true);
      return (
        data: GuideHubCopy(
          eyebrow: value['eyebrow'] as String? ?? GuideService.hub.eyebrow,
          title: value['title'] as String? ?? GuideService.hub.title,
          disclaimer: value['disclaimer'] as String? ?? GuideService.hub.disclaimer,
        ),
        usedFallback: false,
      );
    } catch (_) {
      return (data: GuideService.hub, usedFallback: true);
    }
  }

  Future<({List<GuideSection> data, bool usedFallback})> _fetchSections() async {
    final client = _client;
    if (client == null) return (data: GuideService.sections, usedFallback: true);

    try {
      final rows = await client
          .from('guide_sections')
          .select('slug, title, subtitle, badge, icon, hub_group, route')
          .eq('published', true)
          .order('sort_order');

      if (rows.isEmpty) return (data: GuideService.sections, usedFallback: true);

      return (
        data: rows
            .map(
              (row) => GuideSection(
                slug: row['slug'] as String,
                title: row['title'] as String,
                subtitle: row['subtitle'] as String? ?? '',
                badge: row['badge'] as String? ?? '',
                icon: row['icon'] as String? ?? 'mosque',
                hubGroup: row['hub_group'] as String? ?? 'journey',
                route: row['route'] as String? ?? '',
              ),
            )
            .toList(),
        usedFallback: false,
      );
    } catch (_) {
      return (data: GuideService.sections, usedFallback: true);
    }
  }

  Future<List<GuideStep>> fetchSteps(String slug) async {
    final client = _client;
    if (client == null) return GuideService.stepsFor(slug);

    try {
      final rows = await client
          .from('guide_steps')
          .select('*')
          .eq('guide_slug', slug)
          .eq('published', true)
          .order('sort_order', ascending: true);

      if (rows.isEmpty) return GuideService.stepsFor(slug);

      final steps = rows
          .map(
            (row) => GuideStep(
              title: row['title'] as String,
              body: row['body'] as String? ?? '',
              sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
              subtitle: row['subtitle'] as String? ?? '',
              description: row['description'] as String? ?? '',
              arabic: row['arabic'] as String?,
              arabicEn: row['arabic_en'] as String?,
              icon: row['icon'] as String? ?? '',
              iconUrl: row['icon_url'] as String?,
              repeatLabel: row['repeat_label'] as String?,
              timeLabel: row['time_label'] as String?,
              rakaat: (row['rakaat'] as num?)?.toInt(),
              accent: row['accent'] as String?,
            ),
          )
          .toList();
      steps.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return steps;
    } catch (_) {
      return GuideService.stepsFor(slug);
    }
  }

  Future<GuideSection?> fetchSection(String slug) async {
    final sections = await _fetchSections();
    for (final s in sections.data) {
      if (s.slug == slug) return s;
    }
    return GuideService.sectionBySlug(slug);
  }
}

final guideRepositoryProvider = Provider<GuideRepository>((ref) {
  return GuideRepository(EnvConfig.supabase);
});

final pilgrimageHubProvider = FutureProvider<PilgrimageHubData>((ref) async {
  final data = await ref.watch(guideRepositoryProvider).fetchHub();
  if (data.usedFallback) {
    ref.read(cmsFallbackFlagProvider.notifier).state = true;
  }
  return data;
});

final guideStepsProvider = FutureProvider.family<List<GuideStep>, String>((ref, slug) {
  return ref.watch(guideRepositoryProvider).fetchSteps(slug);
});

final guideSectionProvider = FutureProvider.family<GuideSection?, String>((ref, slug) {
  return ref.watch(guideRepositoryProvider).fetchSection(slug);
});

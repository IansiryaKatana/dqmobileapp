import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/router/root_nav.dart';
import '../../core/services/guide_repository.dart';
import '../../core/services/guide_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/dq_theme.dart';
import '../../shared/widgets/dq_buttons.dart';
import '../../shared/widgets/geo_pattern.dart';

class HowToPrayScreen extends ConsumerWidget {
  const HowToPrayScreen({super.key});

  static const _fallbackPrayers = [
    _PrayerCard(name: 'Fajr', arabic: 'الفجر', time: 'Before sunrise', rakaat: 2, accent: Color(0xFFFF8C42), routeKey: 'fajr'),
    _PrayerCard(name: 'Dhuhr', arabic: 'الظهر', time: 'Midday', rakaat: 4, accent: Color(0xFF10B981), routeKey: 'dhuhr'),
    _PrayerCard(name: 'Asr', arabic: 'العصر', time: 'Afternoon', rakaat: 4, accent: Color(0xFF6366F1), routeKey: 'asr'),
    _PrayerCard(name: 'Maghrib', arabic: 'المغرب', time: 'After sunset', rakaat: 3, accent: Color(0xFFF43F5E), routeKey: 'maghrib'),
    _PrayerCard(name: 'Isha', arabic: 'العشاء', time: 'Night', rakaat: 4, accent: AppColors.navy, routeKey: 'isha'),
  ];

  List<_PrayerCard> _fromCms(List<GuideStep> rows) {
    if (rows.isEmpty) return _fallbackPrayers;
    final out = <_PrayerCard>[];
    for (final row in rows) {
      Map<String, dynamic>? meta;
      final trimmed = row.body.trim();
      if (trimmed.startsWith('{')) {
        try {
          meta = jsonDecode(trimmed) as Map<String, dynamic>;
        } catch (_) {
          meta = null;
        }
      }
      final accentHex = (row.accent?.isNotEmpty == true) ? row.accent : meta?['accent'] as String?;
      Color accent = AppColors.navy;
      if (accentHex != null && accentHex.startsWith('#') && accentHex.length >= 7) {
        final v = int.tryParse(accentHex.substring(1), radix: 16);
        if (v != null) accent = Color(0xFF000000 | v);
      }
      final arabic = (row.arabic?.isNotEmpty == true) ? row.arabic! : (meta?['arabic'] as String? ?? '');
      final time = (row.timeLabel?.isNotEmpty == true)
          ? row.timeLabel!
          : (meta?['time'] as String? ?? row.body);
      final rakaat = row.rakaat ??
          (meta?['rakaat'] is int ? meta!['rakaat'] as int : int.tryParse('${meta?['rakaat']}') ?? 2);
      final routeKey = AppAssets.prayGuideSlugForName(row.title)?.replaceFirst('pray-', '') ??
          row.title.toLowerCase().trim();
      out.add(
        _PrayerCard(
          name: row.title,
          arabic: arabic,
          time: time,
          rakaat: rakaat,
          accent: accent,
          routeKey: routeKey,
        ),
      );
    }
    return out.isEmpty ? _fallbackPrayers : out;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final steps = ref.watch(guideStepsProvider('how-to-pray')).valueOrNull ?? const [];
    final section = ref.watch(guideSectionProvider('how-to-pray')).valueOrNull;
    final prayers = _fromCms(steps);
    final title = section?.title.isNotEmpty == true ? section!.title : 'How to Pray';
    final subtitle = section?.subtitle.isNotEmpty == true ? section!.subtitle : 'Step-by-step salah guide';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DqScreenHeader(
              title: title,
              onBack: () => context.pop(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(subtitle, style: TextStyle(fontSize: 11, color: context.dq.muted)),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  _wuduHero(context),
                  const SizedBox(height: 16),
                  _sectionDivider(context, '5 Daily Prayers'),
                  const SizedBox(height: 12),
                  ...prayers.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _prayerTile(context, e.value, e.key + 1),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wuduHero(BuildContext context) {
    return Material(
      color: AppColors.navy,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => pushRootRoute(context, '/wudu-guide'),
        child: Stack(
          children: [
            const Positioned.fill(child: IgnorePointer(child: GeoPattern())),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.yellow.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '① Start here first',
                            style: TextStyle(color: AppColors.yellow, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Wudu',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ritual purification — required before every prayer',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, height: 1.4),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.yellow,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.water_drop_outlined, size: 16, color: AppColors.onBrand),
                              SizedBox(width: 8),
                              Text('Learn Wudu', style: TextStyle(color: AppColors.onBrand, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'الوضوء',
                    style: TextStyle(
                      fontSize: 28,
                      color: AppColors.yellow.withValues(alpha: 0.6),
                      height: 1,
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

  Widget _sectionDivider(BuildContext context, String label) {
    return Row(
      children: [
        Expanded(child: Divider(color: context.dq.cardBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: AppColors.muted),
          ),
        ),
        Expanded(child: Divider(color: context.dq.cardBorder)),
      ],
    );
  }

  Widget _prayerTile(BuildContext context, _PrayerCard prayer, int index) {
    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => pushRootRoute(context, '/pray-guide/${prayer.routeKey}'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.dq.cardBorder),
            boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: prayer.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: TextStyle(color: prayer.accent, fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(prayer.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        const SizedBox(width: 8),
                        Text(prayer.arabic, style: TextStyle(fontSize: 14, color: context.colors.primary)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(prayer.time, style: TextStyle(fontSize: 12, color: context.dq.muted)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.sand,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${prayer.rakaat} rak\'ah',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.muted),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: context.dq.muted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrayerCard {
  const _PrayerCard({
    required this.name,
    required this.arabic,
    required this.time,
    required this.rakaat,
    required this.accent,
    required this.routeKey,
  });

  final String name;
  final String arabic;
  final String time;
  final int rakaat;
  final Color accent;
  final String routeKey;
}

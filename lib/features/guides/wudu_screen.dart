import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_assets.dart';
import '../../core/services/app_media_repository.dart';
import '../../core/services/guide_repository.dart';
import '../../core/services/guide_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/dq_theme.dart';
import '../../shared/widgets/dq_buttons.dart';

class GuideFlowStep {
  const GuideFlowStep({
    required this.n,
    required this.title,
    required this.subtitle,
    this.repeat,
    required this.desc,
    this.arabic,
    this.arabicEn,
    required this.icon,
    this.iconUrl,
  });

  final int n;
  final String title;
  final String subtitle;
  final String? repeat;
  final String desc;
  final String? arabic;
  final String? arabicEn;
  final IconData icon;
  final String? iconUrl;
}

typedef GuideSlotResolver = String Function({required int stepNumber, required String title});

const _wuduFallbackSteps = [
  GuideFlowStep(
    n: 1,
    title: 'Bismillah',
    subtitle: 'Intention',
    desc: 'Before Wudu: Make the intention in your heart. Then say:',
    arabic: 'بِسۡمِ اللهِ',
    arabicEn: 'Bismillah — In the name of Allah',
    icon: Icons.favorite_border_rounded,
  ),
  GuideFlowStep(
    n: 2,
    title: 'Hands',
    subtitle: 'Wash both hands',
    repeat: '× 3 times',
    desc: 'Completely wash both hands, including the wrists and between the fingers.',
    icon: Icons.back_hand_outlined,
  ),
  GuideFlowStep(
    n: 3,
    title: 'Mouth',
    subtitle: 'Rinse the mouth',
    repeat: '× 3 times',
    desc: 'Using the right hand, put a small amount of water into the mouth, swirl it around, then expel.',
    icon: Icons.water_drop_outlined,
  ),
  GuideFlowStep(
    n: 4,
    title: 'Nose',
    subtitle: 'Rinse the nostrils',
    repeat: '× 3 times',
    desc: 'Sniff water into the nostrils as far as possible with the right hand, then blow it out using the left hand.',
    icon: Icons.air_outlined,
  ),
  GuideFlowStep(
    n: 5,
    title: 'Face',
    subtitle: 'Wash the full face',
    repeat: '× 3 times',
    desc: 'Wash the face from the hairline to the chin, and from earlobe to earlobe — the entire face must be covered.',
    icon: Icons.face_outlined,
  ),
  GuideFlowStep(
    n: 6,
    title: 'Arms',
    subtitle: 'Wash to the elbows',
    repeat: '× 3 times',
    desc: 'Wash both arms to and including the elbows, including between the fingers. Begin with the right arm.',
    icon: Icons.pan_tool_alt_outlined,
  ),
  GuideFlowStep(
    n: 7,
    title: 'Head',
    subtitle: 'Wipe the head',
    desc: 'Wipe the head with wet fingers, starting at the fringe to the back hairline and back again — all in one movement.',
    icon: Icons.self_improvement_outlined,
  ),
  GuideFlowStep(
    n: 8,
    title: 'Ears',
    subtitle: 'Wipe both ears',
    desc: 'Simultaneously wipe the insides of both ears with the index fingers and the back of the ears with the thumbs.',
    icon: Icons.hearing_outlined,
  ),
  GuideFlowStep(
    n: 9,
    title: 'Feet',
    subtitle: 'Wash to the ankles',
    repeat: '× 3 times',
    desc: 'Wash both feet including the ankles and between the toes. Begin with the right foot.',
    icon: Icons.directions_walk_outlined,
  ),
  GuideFlowStep(
    n: 10,
    title: "Closing Du'a",
    subtitle: 'Invocation',
    desc: 'After Wudu, say:',
    arabic: 'أَشْهَدُ أَن لَّا إِلَٰهَ إِلَّا ٱللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
    arabicEn:
        'Ash-hadu an lā ilāha illallāh, wa ash-hadu anna Muḥammadan ʿabduhu wa rasūluh. (I bear witness that there is no god but Allah, and Muhammad is His servant and messenger.)',
    icon: Icons.check_circle_outline_rounded,
  ),
];

List<GuideFlowStep> prayFallbackSteps({required String name, required int rakaat}) {
  return [
    GuideFlowStep(
      n: 1,
      title: 'Intention',
      subtitle: 'Niyyah',
      desc: 'Stand facing the Qibla. Make the intention in your heart to pray $name ($rakaat rakʿah) for the sake of Allah.',
      icon: Icons.favorite_border_rounded,
    ),
    GuideFlowStep(
      n: 2,
      title: 'Takbir',
      subtitle: 'Opening takbir',
      desc: 'Raise both hands to the ears (or shoulders) and say Allahu Akbar to begin the prayer.',
      arabic: 'ٱللَّهُ أَكْبَرُ',
      arabicEn: 'Allahu Akbar — Allah is the Greatest',
      icon: Icons.pan_tool_alt_outlined,
    ),
    GuideFlowStep(
      n: 3,
      title: 'Qiyam',
      subtitle: 'Standing · Al-Fatihah',
      repeat: 'Each rakʿah',
      desc:
          'Stand calmly with the right hand over the left. Recite Al-Fatihah, then another short surah. Do this in every rakʿah of $name.',
      arabic: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
      arabicEn: 'Begin with Al-Fatihah, then a short surah',
      icon: Icons.menu_book_outlined,
    ),
    GuideFlowStep(
      n: 4,
      title: 'Ruku',
      subtitle: 'Bowing',
      repeat: '× 3',
      desc: 'Say Allahu Akbar, then bow with the back straight and hands on the knees. Glorify Allah three times.',
      arabic: 'سُبْحَانَ رَبِّيَ ٱلْعَظِيمِ',
      arabicEn: 'Subhana Rabbiyal Azeem — Glory be to my Lord, the Most Great',
      icon: Icons.self_improvement_outlined,
    ),
    GuideFlowStep(
      n: 5,
      title: "I'tidal",
      subtitle: 'Standing after ruku',
      desc: 'Rise from ruku, then stand upright. Say Sami Allahu liman hamidah, then Rabbana wa lakal hamd.',
      arabic: 'سَمِعَ ٱللَّهُ لِمَنْ حَمِدَهُ',
      arabicEn: 'Sami Allahu liman hamidah — Allah hears those who praise Him',
      icon: Icons.accessibility_new_outlined,
    ),
    GuideFlowStep(
      n: 6,
      title: 'Sujud',
      subtitle: 'Prostration',
      repeat: '× 3',
      desc:
          'Say Allahu Akbar and go into prostration: forehead, nose, palms, knees, and toes on the ground. Glorify Allah three times.',
      arabic: 'سُبْحَانَ رَبِّيَ ٱلْأَعْلَىٰ',
      arabicEn: "Subhana Rabbiyal A'la — Glory be to my Lord, the Most High",
      icon: Icons.expand_outlined,
    ),
    GuideFlowStep(
      n: 7,
      title: 'Jalsa',
      subtitle: 'Sitting between sujud',
      desc: 'Say Allahu Akbar and sit briefly between the two prostrations. Ask Allah for forgiveness.',
      arabic: 'رَبِّ ٱغْفِرْ لِي',
      arabicEn: 'Rabbighfir li — My Lord, forgive me',
      icon: Icons.airline_seat_recline_normal,
    ),
    GuideFlowStep(
      n: 8,
      title: 'Second Sujud',
      subtitle: 'Complete the rakʿah',
      repeat: '× 3',
      desc:
          'Say Allahu Akbar and prostrate a second time. This completes one rakʿah. Stand for the next rakʿah until you finish all $rakaat for $name.',
      arabic: 'سُبْحَانَ رَبِّيَ ٱلْأَعْلَىٰ',
      arabicEn: "Subhana Rabbiyal A'la — Glory be to my Lord, the Most High",
      icon: Icons.expand_outlined,
    ),
    GuideFlowStep(
      n: 9,
      title: 'Tashahhud',
      subtitle: 'Final sitting',
      desc:
          'In the last rakʿah of $name, remain seated after the second sujud. Recite the tashahhud (and salawat on the Prophet ﷺ).',
      arabic: 'ٱلتَّحِيَّاتُ لِلَّهِ',
      arabicEn: 'At-tahiyyatu lillah… (the tashahhud)',
      icon: Icons.volunteer_activism_outlined,
    ),
    GuideFlowStep(
      n: 10,
      title: 'Salam',
      subtitle: 'Ending the prayer',
      repeat: 'Right, then left',
      desc: 'Turn the head to the right, then to the left, saying the salam each time. Your $name prayer is complete.',
      arabic: 'ٱلسَّلَامُ عَلَيْكُمْ وَرَحْمَةُ ٱللَّهِ',
      arabicEn: 'As-salamu alaykum wa rahmatullah',
      icon: Icons.waving_hand_outlined,
    ),
  ];
}

IconData _guideIcon(String? key) {
  return switch (key) {
    'favorite_border' => Icons.favorite_border_rounded,
    'back_hand' => Icons.back_hand_outlined,
    'water_drop' => Icons.water_drop_outlined,
    'air' => Icons.air_outlined,
    'face' => Icons.face_outlined,
    'pan_tool' => Icons.pan_tool_alt_outlined,
    'self_improvement' => Icons.self_improvement_outlined,
    'hearing' => Icons.hearing_outlined,
    'directions_walk' => Icons.directions_walk_outlined,
    'check_circle' => Icons.check_circle_outline_rounded,
    'menu_book' => Icons.menu_book_outlined,
    'accessibility_new' => Icons.accessibility_new_outlined,
    'expand' => Icons.expand_outlined,
    'airline_seat_recline_normal' => Icons.airline_seat_recline_normal,
    'volunteer_activism' => Icons.volunteer_activism_outlined,
    'waving_hand' => Icons.waving_hand_outlined,
    _ => Icons.self_improvement_outlined,
  };
}

List<GuideFlowStep> _stepsFromCms(List<GuideStep> rows, List<GuideFlowStep> fallback) {
  if (rows.isEmpty) return fallback;
  final out = <GuideFlowStep>[];
  for (var i = 0; i < rows.length; i++) {
    final row = rows[i];
    Map<String, dynamic>? meta;
    final trimmed = row.body.trim();
    if (trimmed.startsWith('{')) {
      try {
        meta = jsonDecode(trimmed) as Map<String, dynamic>;
      } catch (_) {
        meta = null;
      }
    }
    final subtitle = row.subtitle.isNotEmpty ? row.subtitle : (meta?['subtitle'] as String? ?? '');
    final desc = row.description.isNotEmpty
        ? row.description
        : (meta?['desc'] as String? ?? (meta == null ? row.body : ''));
    final arabic = (row.arabic?.isNotEmpty == true) ? row.arabic : meta?['arabic'] as String?;
    final arabicEn = (row.arabicEn?.isNotEmpty == true) ? row.arabicEn : meta?['arabic_en'] as String?;
    final repeat = (row.repeatLabel?.isNotEmpty == true) ? row.repeatLabel : meta?['repeat'] as String?;
    final iconKey = row.icon.isNotEmpty ? row.icon : meta?['icon'] as String?;
    final iconUrl = (row.iconUrl?.isNotEmpty == true) ? row.iconUrl : meta?['icon_url'] as String?;
    final stepNumber = row.sortOrder > 0 ? row.sortOrder : i + 1;
    out.add(
      GuideFlowStep(
        n: stepNumber,
        title: row.title,
        subtitle: subtitle,
        repeat: repeat,
        desc: desc,
        arabic: arabic,
        arabicEn: arabicEn,
        icon: _guideIcon(iconKey),
        iconUrl: iconUrl,
      ),
    );
  }
  return out.isEmpty ? fallback : out;
}

/// Shared step-by-step guide UI (Wudu + daily prayers).
class StepGuideScreen extends ConsumerStatefulWidget {
  const StepGuideScreen({
    super.key,
    required this.guideSlug,
    required this.mediaPageKey,
    required this.slotFor,
    required this.fallbackSteps,
    required this.defaultTitle,
    required this.defaultSubtitle,
    this.bundledFallbackForSlot,
  });

  final String guideSlug;
  final String mediaPageKey;
  final GuideSlotResolver slotFor;
  final List<GuideFlowStep> fallbackSteps;
  final String defaultTitle;
  final String defaultSubtitle;
  final String? Function(String slotKey)? bundledFallbackForSlot;

  @override
  ConsumerState<StepGuideScreen> createState() => _StepGuideScreenState();
}

class _StepGuideScreenState extends ConsumerState<StepGuideScreen> {
  int _stepIdx = 0;

  @override
  Widget build(BuildContext context) {
    final stepsAsync = ref.watch(guideStepsProvider(widget.guideSlug));
    final sectionAsync = ref.watch(guideSectionProvider(widget.guideSlug));
    final steps = _stepsFromCms(stepsAsync.valueOrNull ?? const [], widget.fallbackSteps);
    final section = sectionAsync.valueOrNull;
    final safeIdx = _stepIdx.clamp(0, steps.length - 1);
    if (safeIdx != _stepIdx) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _stepIdx = safeIdx);
      });
    }
    final step = steps[safeIdx];
    final isFirst = safeIdx == 0;
    final isLast = safeIdx == steps.length - 1;
    final progress = (safeIdx + 1) / steps.length;
    final title = section?.title.isNotEmpty == true ? section!.title : widget.defaultTitle;
    final subtitle = section?.subtitle.isNotEmpty == true ? section!.subtitle : widget.defaultSubtitle;

    final colors = context.colors;
    final dq = context.dq;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 20, 0),
              child: Row(
                children: [
                  DqBackButton(onPressed: () => context.pop()),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colors.onSurface)),
                        Text(subtitle, style: TextStyle(fontSize: 11, color: dq.muted)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: dq.surfaceAlt,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: dq.cardBorder),
                    ),
                    child: Text(
                      '${safeIdx + 1} / ${steps.length}',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: dq.muted),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: dq.surfaceAlt,
                  valueColor: const AlwaysStoppedAnimation(AppColors.yellow),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: dq.surfaceAlt,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: dq.cardBorder),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _GuideStepArt(
                      step: step,
                      mediaPageKey: widget.mediaPageKey,
                      slotFor: widget.slotFor,
                      bundledFallbackForSlot: widget.bundledFallbackForSlot,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(20)),
                        child: Text('Step ${step.n}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.yellow)),
                      ),
                      if (step.repeat != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.yellow.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.yellow.withValues(alpha: 0.25)),
                          ),
                          child: Text(step.repeat!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.yellow)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(step.title, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: colors.onSurface)),
                  Text(step.subtitle, style: TextStyle(fontSize: 13, color: dq.muted)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: dq.cardBorder),
                    ),
                    child: Text(step.desc, style: TextStyle(fontSize: 14, height: 1.5, color: colors.onSurface)),
                  ),
                  if (step.arabic != null) ...[
                    const SizedBox(height: 12),
                    Container(
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
                          Text(
                            step.arabic!,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: GoogleFonts.amiri(fontSize: 20, height: 1.8, color: AppColors.yellow),
                          ),
                          if (step.arabicEn != null) ...[
                            const SizedBox(height: 8),
                            Text(step.arabicEn!, style: TextStyle(fontSize: 12, height: 1.5, color: Colors.white.withValues(alpha: 0.55))),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(steps.length, (i) {
                      final active = i == safeIdx;
                      return GestureDetector(
                        onTap: () => setState(() => _stepIdx = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: active ? 20 : 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: active ? AppColors.yellow : dq.cardBorder,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.paddingOf(context).bottom),
              decoration: BoxDecoration(
                color: scaffoldBg,
                border: Border(top: BorderSide(color: dq.cardBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isFirst ? null : () => setState(() => _stepIdx--),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: isFirst ? dq.cardBorder : colors.onSurface, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
                      ),
                      child: Text(
                        '← Previous',
                        style: TextStyle(color: isFirst ? dq.cardBorder : colors.onSurface, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DqPrimaryButton(
                      label: isLast ? 'Done ✓' : 'Next →',
                      onPressed: () {
                        if (isLast) {
                          context.pop();
                        } else {
                          setState(() => _stepIdx++);
                        }
                      },
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
}

class _GuideStepArt extends ConsumerWidget {
  const _GuideStepArt({
    required this.step,
    required this.mediaPageKey,
    required this.slotFor,
    this.bundledFallbackForSlot,
  });

  final GuideFlowStep step;
  final String mediaPageKey;
  final GuideSlotResolver slotFor;
  final String? Function(String slotKey)? bundledFallbackForSlot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotKey = slotFor(stepNumber: step.n, title: step.title);
    final map = ref.watch(appMediaMapProvider).valueOrNull;
    final slot = map?['$mediaPageKey.$slotKey'];
    final cmsUrl = slot?.url;
    final url = (cmsUrl != null && cmsUrl.isNotEmpty)
        ? cmsUrl
        : (step.iconUrl != null && step.iconUrl!.isNotEmpty ? step.iconUrl : null);
    final asset = slot?.fallbackAsset ?? bundledFallbackForSlot?.call(slotKey);
    final icon = Icon(step.icon, size: 72, color: context.colors.onSurface.withValues(alpha: 0.35));

    if (url != null) {
      return Image.network(
        url,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _bundledOrIcon(asset, icon),
      );
    }
    return _bundledOrIcon(asset, icon);
  }

  Widget _bundledOrIcon(String? asset, Widget icon) {
    if (asset == null || asset.isEmpty) return Center(child: icon);
    return Image.asset(
      asset,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => Center(child: icon),
    );
  }
}

class WuduGuideScreen extends StatelessWidget {
  const WuduGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StepGuideScreen(
      guideSlug: 'wudu',
      mediaPageKey: 'wudu',
      slotFor: AppAssets.wuduSlotFor,
      fallbackSteps: _wuduFallbackSteps,
      defaultTitle: 'Wudu Guide',
      defaultSubtitle: 'How to make ablution',
      bundledFallbackForSlot: (slot) => slot == 'bismillah' ? AppAssets.wuduBismillah : null,
    );
  }
}

class PrayerGuideScreen extends StatelessWidget {
  const PrayerGuideScreen({super.key, required this.prayerKey});

  /// Short key: fajr | dhuhr | asr | maghrib | isha
  final String prayerKey;

  static const _meta = {
    'fajr': (name: 'Fajr', rakaat: 2, arabic: 'الفجر'),
    'dhuhr': (name: 'Dhuhr', rakaat: 4, arabic: 'الظهر'),
    'asr': (name: 'Asr', rakaat: 4, arabic: 'العصر'),
    'maghrib': (name: 'Maghrib', rakaat: 3, arabic: 'المغرب'),
    'isha': (name: 'Isha', rakaat: 4, arabic: 'العشاء'),
  };

  @override
  Widget build(BuildContext context) {
    final key = prayerKey.toLowerCase();
    final meta = _meta[key] ?? _meta['fajr']!;
    final guideSlug = AppAssets.prayGuideSlugs[key] ?? 'pray-fajr';
    return StepGuideScreen(
      guideSlug: guideSlug,
      mediaPageKey: guideSlug,
      slotFor: AppAssets.praySlotFor,
      fallbackSteps: prayFallbackSteps(name: meta.name, rakaat: meta.rakaat),
      defaultTitle: meta.name,
      defaultSubtitle: 'How to pray ${meta.name} · ${meta.rakaat} rakʿah',
    );
  }
}

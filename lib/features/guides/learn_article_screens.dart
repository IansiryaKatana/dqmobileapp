import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/guide_repository.dart';
import '../../core/services/guide_service.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/dq_buttons.dart';
import '../../shared/widgets/geo_pattern.dart';

class _ArticleSection {
  const _ArticleSection({required this.heading, required this.body});

  final String heading;
  final String body;
}

class _LearnArticleScaffold extends StatelessWidget {
  const _LearnArticleScaffold({
    required this.title,
    required this.subtitle,
    required this.heroLabel,
    required this.heroIcon,
    required this.sections,
    this.footer,
  });

  final String title;
  final String subtitle;
  final String heroLabel;
  final IconData heroIcon;
  final List<_ArticleSection> sections;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
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
                        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.charcoal)),
                        Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          color: AppColors.navy,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.yellow.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(heroLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.yellow)),
                              ),
                              const SizedBox(height: 12),
                              Icon(heroIcon, size: 40, color: AppColors.yellow.withValues(alpha: 0.85)),
                            ],
                          ),
                        ),
                        const Positioned.fill(child: IgnorePointer(child: GeoPattern())),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final section in sections)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(section.heading, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                            const SizedBox(height: 8),
                            Text(section.body, style: const TextStyle(fontSize: 13, height: 1.55, color: AppColors.muted)),
                          ],
                        ),
                      ),
                    ),
                  if (footer != null) footer!,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CmsLearnArticleScreen extends ConsumerWidget {
  const _CmsLearnArticleScreen({
    required this.slug,
    required this.fallbackTitle,
    required this.fallbackSubtitle,
    required this.fallbackHeroLabel,
    required this.fallbackHeroIcon,
    required this.fallbackSections,
    this.footer,
  });

  final String slug;
  final String fallbackTitle;
  final String fallbackSubtitle;
  final String fallbackHeroLabel;
  final IconData fallbackHeroIcon;
  final List<_ArticleSection> fallbackSections;
  final Widget? footer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(guideSectionProvider(slug)).valueOrNull;
    final steps = ref.watch(guideStepsProvider(slug)).valueOrNull ?? const <GuideStep>[];
    final cmsSections = steps
        .where((s) => s.title.trim().isNotEmpty)
        .map((s) => _ArticleSection(heading: s.title, body: s.body))
        .toList();

    return _LearnArticleScaffold(
      title: section?.title.isNotEmpty == true ? section!.title : fallbackTitle,
      subtitle: section?.subtitle.isNotEmpty == true ? section!.subtitle : fallbackSubtitle,
      heroLabel: section?.badge.isNotEmpty == true ? section!.badge : fallbackHeroLabel,
      heroIcon: fallbackHeroIcon,
      sections: cmsSections.isNotEmpty ? cmsSections : fallbackSections,
      footer: footer,
    );
  }
}

class WhatIsIslamScreen extends StatelessWidget {
  const WhatIsIslamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CmsLearnArticleScreen(
      slug: 'what-is-islam',
      fallbackTitle: 'What is Islam?',
      fallbackSubtitle: 'The fundamentals of the faith',
      fallbackHeroLabel: 'Faith',
      fallbackHeroIcon: Icons.mosque_outlined,
      fallbackSections: [
        _ArticleSection(
          heading: 'The Meaning of Islam',
          body:
              'Islam is an Arabic word meaning "submission" or "peace through submission to the will of God." It is not a new religion — Islam is the same message of pure monotheism that was revealed to all prophets, from Adam, to Abraham, to Moses, to Jesus, and finally to Muhammad ﷺ.',
        ),
        _ArticleSection(
          heading: 'The Six Articles of Faith',
          body:
              'Muslims believe in: (1) Allah — the One God, unique and without partners; (2) The Angels — created from light, they worship Allah continuously; (3) The Books — including the Torah, Psalms, Gospel, and the Quran; (4) The Prophets — over 124,000 prophets were sent to guide mankind; (5) The Day of Judgement — all souls will be accountable; (6) Divine Decree — Allah\'s complete knowledge of all things.',
        ),
        _ArticleSection(
          heading: 'The Five Pillars',
          body:
              'The Five Pillars are the core practices of Islam: (1) Shahada — declaration of faith; (2) Salah — five daily prayers; (3) Zakat — giving 2.5% of wealth in charity; (4) Sawm — fasting during Ramadan; (5) Hajj — pilgrimage to Makkah at least once in a lifetime for those able.',
        ),
        _ArticleSection(
          heading: 'Why People Embrace Islam',
          body:
              'People come to Islam from every background and culture. What draws them is often the clarity of monotheism, the directness of the connection to God without intermediaries, and the comprehensive way Islam guides all aspects of life — from personal worship to ethics, family, and society.',
        ),
      ],
    );
  }
}

class WhatIsQuranScreen extends StatelessWidget {
  const WhatIsQuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _CmsLearnArticleScreen(
      slug: 'what-is-quran',
      fallbackTitle: 'What is the Quran?',
      fallbackSubtitle: 'The holy book of Islam',
      fallbackHeroLabel: 'Revelation',
      fallbackHeroIcon: Icons.menu_book_rounded,
      fallbackSections: const [
        _ArticleSection(
          heading: 'The Word of Allah',
          body:
              'The Quran is the final revelation from Allah (God), revealed to the Prophet Muhammad ﷺ over 23 years through the Angel Jibreel (Gabriel). It is the primary source of Islamic law and guidance, and the central text of Muslim life.',
        ),
        _ArticleSection(
          heading: 'Its Structure',
          body:
              'The Quran consists of 114 chapters (surahs), ranging from long detailed chapters to short powerful ones. It contains 6,236 verses (ayat). The chapters are arranged generally from longest to shortest, not in the order of revelation.',
        ),
        _ArticleSection(
          heading: 'Its Miraculous Nature',
          body:
              'Muslims believe the Quran is a miracle — its literary style, precision, and depth are considered humanly impossible to replicate. It has been memorised in its entirety by millions (known as Hafiz) and preserved unchanged for over 1,400 years in the original Arabic.',
        ),
        _ArticleSection(
          heading: 'The Quran in Daily Life',
          body:
              'The Quran is recited in every prayer, studied for guidance, recited at births and deaths, and memorised as an act of worship. It covers theology, law, stories of past prophets, moral guidance, and direct address to the human soul.',
        ),
      ],
      footer: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: DqPrimaryButton(label: 'Read the Quran', onPressed: () => context.go('/quran')),
      ),
    );
  }
}

class WhoIsProphetScreen extends StatelessWidget {
  const WhoIsProphetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CmsLearnArticleScreen(
      slug: 'who-is-prophet',
      fallbackTitle: 'Prophet Muhammad ﷺ',
      fallbackSubtitle: 'His life and teachings',
      fallbackHeroLabel: 'Prophethood',
      fallbackHeroIcon: Icons.person_outline,
      fallbackSections: [
        _ArticleSection(
          heading: 'His Early Life',
          body:
              "Muhammad ﷺ was born in Makkah in 570 CE into the noble tribe of Quraysh. He was orphaned young — his father died before his birth and his mother passed when he was six. He grew up known as 'Al-Amin' (The Trustworthy) for his outstanding character, honesty, and reliability.",
        ),
        _ArticleSection(
          heading: 'The Prophethood',
          body:
              "At the age of 40, while meditating in the Cave of Hira near Makkah, the Angel Jibreel appeared and delivered the first revelation of the Quran: 'Read in the name of your Lord who created.' (96:1). This marked the beginning of his mission to call humanity to pure monotheism.",
        ),
        _ArticleSection(
          heading: 'His Character',
          body:
              'The Prophet ﷺ was described as the walking Quran — his entire life embodied its teachings. He was known for extraordinary mercy, patience, and humility. He said: "The best of you are those who have the best manners and character." His sunnah (way of life) forms the second source of Islamic guidance after the Quran.',
        ),
        _ArticleSection(
          heading: 'His Legacy',
          body:
              'In just 23 years, the message of Islam spread across Arabia. Within a century of his passing, it had reached from Spain to China. Today, over 1.9 billion people follow his teachings. He is considered the final prophet — the seal of all prophets — bringing the complete and preserved message of monotheism to all of humanity.',
        ),
      ],
    );
  }
}

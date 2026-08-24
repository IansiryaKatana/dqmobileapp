import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/content_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/dq_buttons.dart';
import '../../shared/widgets/figma_components.dart';

IconData logisticsIconFromName(String name) {
  return switch (name) {
    'assignment_turned_in_outlined' => Icons.assignment_turned_in_outlined,
    'checkroom_outlined' => Icons.checkroom_outlined,
    'account_balance_outlined' => Icons.account_balance_outlined,
    'mosque_outlined' => Icons.mosque_outlined,
    'park_outlined' => Icons.park_outlined,
    'smartphone_outlined' => Icons.smartphone_outlined,
    'payments_outlined' => Icons.payments_outlined,
    'wifi_outlined' => Icons.wifi_outlined,
    'train_outlined' => Icons.train_outlined,
    _ => Icons.info_outline,
  };
}

class LogisticsScreen extends ConsumerStatefulWidget {
  const LogisticsScreen({super.key});

  @override
  ConsumerState<LogisticsScreen> createState() => _LogisticsScreenState();
}

class _LogisticsScreenState extends ConsumerState<LogisticsScreen> {
  int? _openIndex;

  int _globalIndex(List<LogisticsGroup> groups, int groupIdx, int itemIdx) {
    var offset = 0;
    for (var g = 0; g < groupIdx; g++) {
      offset += groups[g].items.length;
    }
    return offset + itemIdx;
  }

  @override
  Widget build(BuildContext context) {
    final copy = ref.watch(logisticsCopyProvider).valueOrNull ?? LogisticsCopy.fallback;
    final groups = copy.groups;
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            DqScreenHeader(title: 'Logistics', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  for (var gi = 0; gi < groups.length; gi++) ...[
                    DqSectionLabel(groups[gi].label),
                    for (var ii = 0; ii < groups[gi].items.length; ii++) ...[
                      _AccordionCard(
                        item: groups[gi].items[ii],
                        expanded: _openIndex == _globalIndex(groups, gi, ii),
                        onTap: () {
                          final idx = _globalIndex(groups, gi, ii);
                          setState(() => _openIndex = _openIndex == idx ? null : idx);
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccordionCard extends StatelessWidget {
  const _AccordionCard({required this.item, required this.expanded, required this.onTap});

  final LogisticsItem item;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: expanded ? AppColors.yellow.withValues(alpha: 0.4) : AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: AppColors.sand, borderRadius: BorderRadius.circular(12)),
                      child: Icon(logisticsIconFromName(item.icon), size: 20, color: AppColors.navy),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                          const SizedBox(height: 2),
                          Text(item.snippet, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                        ],
                      ),
                    ),
                    Icon(expanded ? Icons.expand_less : Icons.expand_more, color: AppColors.muted),
                  ],
                ),
              ),
              if (expanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _buildBody(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final visaCards = (item.visaCards != null && item.visaCards!.isNotEmpty)
        ? item.visaCards!
        : const [
            LogisticsVisaCard(title: 'e-Visa', lines: ['SAR 535 (~£114)', 'Application & insurance included']),
            LogisticsVisaCard(title: 'On Arrival', lines: ['SAR 480 (~£102)', '+ SAR 180 medical (~£38)']),
          ];
    final steps = item.ihramSteps ?? const <LogisticsIhramStep>[];
    final tips = item.tips ?? const <LogisticsTip>[];
    return switch (item.kind) {
      LogisticsBodyKind.visaGrid => Row(
          children: [
            for (var i = 0; i < visaCards.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: _InfoChip(title: visaCards[i].title, lines: visaCards[i].lines),
              ),
            ],
          ],
        ),
      LogisticsBodyKind.ihramSteps => Column(
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _NumberedRow(n: steps[i].n, title: steps[i].title, desc: steps[i].desc),
            ],
          ],
        ),
      LogisticsBodyKind.emojiTips => Column(
          children: [
            for (var i = 0; i < tips.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _EmojiTip(tips[i].emoji, tips[i].text),
            ],
          ],
        ),
    };
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.sand, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navy)),
          const SizedBox(height: 6),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(line, style: const TextStyle(fontSize: 11, color: AppColors.muted, height: 1.35)),
            ),
        ],
      ),
    );
  }
}

class _NumberedRow extends StatelessWidget {
  const _NumberedRow({required this.n, required this.title, required this.desc});

  final String n;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: AppColors.navy, shape: BoxShape.circle),
          child: Text(n, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.yellow)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(fontSize: 11, height: 1.45, color: AppColors.muted)),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmojiTip extends StatelessWidget {
  const _EmojiTip(this.emoji, this.text);

  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppColors.sand, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 11, height: 1.45, color: AppColors.charcoal))),
        ],
      ),
    );
  }
}

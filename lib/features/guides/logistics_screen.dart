import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/dq_buttons.dart';
import '../../shared/widgets/figma_components.dart';

enum _LogisticsBodyKind { visaGrid, ihramSteps, emojiTips }

class _LogisticsItemData {
  const _LogisticsItemData({
    required this.title,
    required this.snippet,
    required this.icon,
    required this.kind,
    this.tips,
    this.ihramSteps,
  });

  final String title;
  final String snippet;
  final IconData icon;
  final _LogisticsBodyKind kind;
  final List<(String emoji, String text)>? tips;
  final List<(String n, String title, String desc)>? ihramSteps;
}

class _LogisticsGroupData {
  const _LogisticsGroupData({required this.label, required this.items});

  final String label;
  final List<_LogisticsItemData> items;
}

const _groups = [
  _LogisticsGroupData(
    label: 'Before You Travel',
    items: [
      _LogisticsItemData(
        title: 'Umrah Visa',
        snippet: 'e-Visa SAR 535 · Visa on arrival SAR 480',
        icon: Icons.assignment_turned_in_outlined,
        kind: _LogisticsBodyKind.visaGrid,
      ),
      _LogisticsItemData(
        title: 'Ihram — What to Know',
        snippet: 'Ghusl · Niyyah · Two unstitched cloths',
        icon: Icons.checkroom_outlined,
        kind: _LogisticsBodyKind.ihramSteps,
        ihramSteps: [
          ('1', 'Ghusl & Prayer', 'Perform ghusl (bath) and 2 rakat nafl salah before entering Ihram.'),
          ('2', 'Enter before Meeqat', 'Ihram must be entered before the meeqat boundary. On a flight, the airline will announce the crossing point.'),
          ('3', 'Wear the Garments', 'Two white unstitched cloths — izar (lower) and rida (upper). Slippers must leave the middle bone uncovered.'),
        ],
      ),
    ],
  ),
  _LogisticsGroupData(
    label: 'Holy Sites',
    items: [
      _LogisticsItemData(
        title: 'Masjid al-Haram, Makkah',
        snippet: 'Grand Mosque tips · Arrive 30 min early',
        icon: Icons.account_balance_outlined,
        kind: _LogisticsBodyKind.emojiTips,
        tips: [
          ('🏨', 'Take a hotel card so you can find your way back.'),
          ('🚪', 'Identify the closest door to the Haram from your hotel.'),
          ('⏰', 'Arrive at least 30 min before salaah time to find a spot.'),
          ('🕌', "For Jumu'ah, arrive no later than 10am in off-peak seasons."),
        ],
      ),
      _LogisticsItemData(
        title: 'Masjid an-Nabawi, Madinah',
        snippet: 'Rawdah booking · Respectful adab',
        icon: Icons.mosque_outlined,
        kind: _LogisticsBodyKind.emojiTips,
        tips: [
          ('📱', 'Book Rawdah visit slots via the Nusuk app in advance.'),
          ('🤲', "Make du'a quietly and avoid blocking walkways."),
          ('👟', 'Wear comfortable shoes — you will walk significant distances.'),
        ],
      ),
      _LogisticsItemData(
        title: 'Jannat al-Baqi',
        snippet: 'Visiting the blessed cemetery',
        icon: Icons.park_outlined,
        kind: _LogisticsBodyKind.emojiTips,
        tips: [
          ('🕊️', "Visit with humility and make du'a for the deceased companions."),
          ('📵', 'Photography is discouraged — focus on reflection and prayer.'),
        ],
      ),
    ],
  ),
  _LogisticsGroupData(
    label: 'Apps & Booking',
    items: [
      _LogisticsItemData(
        title: 'Nusuk App',
        snippet: 'Official Saudi pilgrimage platform',
        icon: Icons.smartphone_outlined,
        kind: _LogisticsBodyKind.emojiTips,
        tips: [
          ('📲', 'Download Nusuk for Umrah permits, Rawdah slots, and transport.'),
          ('🪪', 'Link your passport and visa for seamless check-in.'),
        ],
      ),
      _LogisticsItemData(
        title: 'Money & Payments',
        snippet: 'SAR cash · Cards widely accepted',
        icon: Icons.payments_outlined,
        kind: _LogisticsBodyKind.emojiTips,
        tips: [
          ('💳', 'Major credit cards work in hotels and malls.'),
          ('💵', 'Keep some Saudi Riyals for taxis and small vendors.'),
        ],
      ),
      _LogisticsItemData(
        title: 'Mobile & Internet',
        snippet: 'eSIM · Local SIM at airport',
        icon: Icons.wifi_outlined,
        kind: _LogisticsBodyKind.emojiTips,
        tips: [
          ('📶', 'Purchase a local SIM or eSIM at the airport for maps and Nusuk.'),
          ('🔋', 'Carry a power bank — you will use your phone heavily.'),
        ],
      ),
      _LogisticsItemData(
        title: 'Haramain Train',
        snippet: 'Makkah ↔ Madinah high-speed rail',
        icon: Icons.train_outlined,
        kind: _LogisticsBodyKind.emojiTips,
        tips: [
          ('🚄', 'Book train tickets early during peak Hajj and Ramadan seasons.'),
          ('🧳', 'Arrive at the station at least 60 minutes before departure.'),
        ],
      ),
    ],
  ),
];

class LogisticsScreen extends StatefulWidget {
  const LogisticsScreen({super.key});

  @override
  State<LogisticsScreen> createState() => _LogisticsScreenState();
}

class _LogisticsScreenState extends State<LogisticsScreen> {
  int? _openIndex;

  int _globalIndex(int groupIdx, int itemIdx) {
    var offset = 0;
    for (var g = 0; g < groupIdx; g++) {
      offset += _groups[g].items.length;
    }
    return offset + itemIdx;
  }

  @override
  Widget build(BuildContext context) {
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
                  for (var gi = 0; gi < _groups.length; gi++) ...[
                    DqSectionLabel(_groups[gi].label),
                    for (var ii = 0; ii < _groups[gi].items.length; ii++) ...[
                      _AccordionCard(
                        item: _groups[gi].items[ii],
                        expanded: _openIndex == _globalIndex(gi, ii),
                        onTap: () {
                          final idx = _globalIndex(gi, ii);
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

  final _LogisticsItemData item;
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
                      child: Icon(item.icon, size: 20, color: AppColors.navy),
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
    return switch (item.kind) {
      _LogisticsBodyKind.visaGrid => const Row(
          children: [
            Expanded(
              child: _InfoChip(
                title: 'e-Visa',
                lines: ['SAR 535 (~£114)', 'Application & insurance included'],
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _InfoChip(
                title: 'On Arrival',
                lines: ['SAR 480 (~£102)', '+ SAR 180 medical (~£38)'],
              ),
            ),
          ],
        ),
      _LogisticsBodyKind.ihramSteps => Column(
          children: [
            for (var i = 0; i < item.ihramSteps!.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _NumberedRow(n: item.ihramSteps![i].$1, title: item.ihramSteps![i].$2, desc: item.ihramSteps![i].$3),
            ],
          ],
        ),
      _LogisticsBodyKind.emojiTips => Column(
          children: [
            for (var i = 0; i < item.tips!.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _EmojiTip(item.tips![i].$1, item.tips![i].$2),
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

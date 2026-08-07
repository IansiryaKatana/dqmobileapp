import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/router/root_nav.dart';
import '../../core/services/app_media_repository.dart';
import '../../core/services/content_repository.dart';
import '../../core/services/impact_stats_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/dq_theme.dart';
import '../../shared/utils/dq_refresh.dart';
import '../../shared/utils/responsive_layout.dart';
import '../../shared/widgets/dq_logo.dart';
import '../../shared/widgets/geo_pattern.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<int> _targets = [
    ImpactStats.fallback.quransFunded,
    ImpactStats.fallback.ordersPlaced,
    ImpactStats.fallback.countries,
  ];
  static const _labels = ['Qurans Funded', 'Orders Placed', 'Countries'];
  final _counts = List<int>.filled(3, 0);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadImpact();
  }

  Future<void> _loadImpact() async {
    final stats = await ref.read(impactStatsProvider.future);
    if (!mounted) return;
    setState(() => _targets = [stats.quransFunded, stats.ordersPlaced, stats.countries]);
    _animateCounters();
  }

  void _animateCounters() {
    final start = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (t) {
      final p = (DateTime.now().difference(start).inMilliseconds / 2000).clamp(0.0, 1.0);
      final eased = 1 - (1 - p) * (1 - p) * (1 - p);
      setState(() {
        for (var i = 0; i < 3; i++) {
          _counts[i] = (eased * _targets[i]).round();
        }
      });
      if (p >= 1) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await dqPullRefresh(
      ref,
      invalidate: [homeCampaignProvider, impactStatsProvider],
      awaitExtras: () async {
        await Future.wait([
          ref.read(homeCampaignProvider.future),
          ref.read(impactStatsProvider.future),
        ]);
        await _loadImpact();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (disableAnimations && _counts.every((c) => c == 0)) {
      for (var i = 0; i < 3; i++) {
        _counts[i] = _targets[i];
      }
    }
    return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const DqLogo(),
                Semantics(
                  button: true,
                  label: 'Profile settings',
                  child: InkWell(
                    onTap: () => context.push('/profile'),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: context.dq.surfaceAlt,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.dq.cardBorder),
                      ),
                      child: Icon(Icons.person_outline, size: 18, color: context.colors.onSurface),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: ResponsiveLayout(
                maxContentWidth: ResponsiveLayout.isTablet(context) ? 960 : 720,
                compact: _homeBody(context),
                expanded: _homeBodyTablet(context),
              ),
            ),
          ),
        ],
      );
  }

  Widget _readQuranBanner(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 130,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppMediaImage(
              pageKey: 'home',
              slotKey: 'quran_banner',
              fit: BoxFit.cover,
              fallbackAsset: AppAssets.quranBookshot,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withValues(alpha: 0.72), Colors.transparent],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Read Quran',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      Material(
                        color: AppColors.yellow,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: () => context.go('/quran'),
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Open', style: TextStyle(color: AppColors.navy, fontSize: 12, fontWeight: FontWeight.w600)),
                                SizedBox(width: 2),
                                Icon(Icons.chevron_right, size: 14, color: AppColors.navy),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          const Positioned.fill(child: IgnorePointer(child: GeoPattern())),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: AppColors.navy,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.yellow.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Donate Quran',
                    style: TextStyle(color: AppColors.yellow, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Share the Quran.\nEarn ongoing reward.',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.3),
                ),
                const SizedBox(height: 8),
                Text(
                  'Donate, order a free Quran, read, learn and support distribution worldwide.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => pushRootRoute(context, '/donate'),
                        style: ElevatedButton.styleFrom(minimumSize: const Size(0, 48)),
                        child: const Text('Donate Now', style: TextStyle(fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => pushRootRoute(context, '/order'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white.withValues(alpha: 0.09),
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                          ),
                        ),
                        child: const Text('Order Free', style: TextStyle(fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    final colors = context.colors;
    final dq = context.dq;
    final items = [
      ('Qibla', Icons.explore_outlined, () => context.go('/qibla')),
      ('Ask Scholar', Icons.help_outline_rounded, () => context.push('/ask-scholar')),
      ('How to Pray', Icons.self_improvement_outlined, () => pushRootRoute(context, '/how-to-pray')),
      ('Books & Articles', Icons.menu_book_outlined, () => pushRootRoute(context, '/learn')),
    ];
    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: item.$3,
              borderRadius: BorderRadius.circular(AppTheme.radiusButton),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: dq.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                  border: Border.all(color: dq.cardBorder),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.$2, size: 18, color: colors.onSurface),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.$1,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: colors.onSurface),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _impactCard(BuildContext context) {
    final colors = context.colors;
    final dq = context.dq;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: dq.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OUR IMPACT',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: dq.muted, letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(3, (i) {
              return Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: i < 2 ? Border(right: BorderSide(color: dq.cardBorder)) : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        _counts[i].toString().replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (m) => '${m[1]},',
                            ),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.yellow),
                      ),
                      const SizedBox(height: 4),
                      Text(_labels[i], textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: dq.muted)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _campaignCard(BuildContext context) {
    final campaign = ref.watch(homeCampaignProvider).valueOrNull ?? HomeCampaignCopy.fallback;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppColors.yellow.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Featured Campaign', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
                Text(campaign.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(campaign.subtitle, style: const TextStyle(color: AppColors.yellow, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => pushRootRoute(context, '/donate'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40), padding: const EdgeInsets.symmetric(horizontal: 16)),
            child: const Text('Sponsor', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _newMuslimCard(BuildContext context) {
    final colors = context.colors;
    final dq = context.dq;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dq.surfaceAlt,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: dq.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Learning Path', style: TextStyle(fontSize: 11, color: dq.muted)),
                Text('New to Islam?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colors.onSurface)),
                Text('Begin your journey here', style: TextStyle(fontSize: 12, color: dq.muted)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push('/new-muslim'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('Start Here', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _homeBody(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        _readQuranBanner(context),
        const SizedBox(height: 14),
        _heroCard(context),
        const SizedBox(height: 14),
        _quickActions(context),
        const SizedBox(height: 14),
        _impactCard(context),
        const SizedBox(height: 14),
        _campaignCard(context),
        const SizedBox(height: 14),
        _newMuslimCard(context),
      ],
    );
  }

  Widget _homeBodyTablet(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 100),
      children: [
        _readQuranBanner(context),
        const SizedBox(height: 20),
        _heroCard(context),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _quickActions(context)),
            const SizedBox(width: 20),
            Expanded(child: _impactCard(context)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _campaignCard(context)),
            const SizedBox(width: 20),
            Expanded(child: _newMuslimCard(context)),
          ],
        ),
      ],
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/root_nav.dart';
import '../../core/services/bookmark_service.dart';
import '../../core/services/qibla_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/dq_theme.dart';
import '../../shared/utils/dq_refresh.dart';
import '../../shared/widgets/dq_buttons.dart';
import '../../shared/widgets/dq_states.dart';
import '../../shared/widgets/figma_components.dart';
import '../../shared/widgets/qibla_compass.dart';

class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen> {
  QiblaLocationResult? _location;
  double? _heading;
  bool _loading = true;
  String? _error;
  StreamSubscription<double>? _headingSub;
  final bool _compassAvailable = QiblaService.isCompassAvailable;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _headingSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await QiblaService.loadLocationBearing();
      if (!mounted) return;
      setState(() {
        _location = result;
        _loading = false;
        _error = result.errorMessage;
      });
      if (result.hasPermission) {
        _startHeadingStream();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Could not find Qibla direction. Try again.';
        });
      }
    }
  }

  void _startHeadingStream() {
    _headingSub?.cancel();
    final declination = _location?.declination ?? 0;
    final stream = QiblaService.headingStream(declination: declination);
    if (stream == null) return;
    _headingSub = stream.listen(
      (heading) {
        if (!mounted) return;
        setState(() => _heading = heading);
      },
      onError: (_) {},
    );
  }

  Future<void> _onEnableLocation() async {
    final status = _location?.status;
    if (status == QiblaPermissionStatus.deniedForever) {
      await QiblaService.openAppSettings();
      return;
    }
    if (status == QiblaPermissionStatus.serviceDisabled) {
      await QiblaService.openLocationSettings();
      return;
    }
    await _load();
  }

  Future<void> _onRefresh() {
    return dqPullRefresh(
      ref,
      awaitExtras: () => _load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 200),
            DqLoadingOverlay(message: 'Finding Qibla direction...'),
          ],
        ),
      );
    }
    final data = _location;
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        Text('Qibla', style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 24),
        if (data != null && data.hasPermission) ...[
          Center(
            child: QiblaCompass(
              qiblaBearing: data.bearing,
              heading: _heading,
              compassAvailable: _compassAvailable,
            ),
          ),
          if (!_compassAvailable) ...[
            const SizedBox(height: 12),
            Text(
              'This device has no magnetometer (common on emulators). Use a physical phone to point toward Qibla. Bearing from your location: ${QiblaService.directionLabel(data.bearing)}.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: context.dq.muted),
            ),
          ],
        ] else ...[
          DqEmptyState(
            icon: Icons.explore_off_outlined,
            title: 'Location needed',
            message: _error ?? 'Enable location to find the Qibla direction.',
            action: DqPrimaryButton(
              label: data?.status == QiblaPermissionStatus.deniedForever ||
                      data?.status == QiblaPermissionStatus.serviceDisabled
                  ? 'Open settings'
                  : 'Enable Location',
              onPressed: _onEnableLocation,
            ),
          ),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: DqInfoTile(
                label: 'Location',
                value: data?.locationLabel ?? '—',
                icon: Icons.location_on_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DqInfoTile(
                label: 'Distance to Makkah',
                value: data != null && data.hasPermission
                    ? '${data.distanceKm.round()} km'
                    : '—',
                icon: Icons.straighten,
              ),
            ),
          ],
        ),
        if (data != null && data.hasPermission) ...[
          const SizedBox(height: 10),
          DqInfoTile(
            label: 'Qibla bearing (true north)',
            value: QiblaService.directionLabel(data.bearing),
            icon: Icons.explore_outlined,
          ),
          if (_heading != null) ...[
            const SizedBox(height: 10),
            DqInfoTile(
              label: QiblaService.isAligned(data.bearing, _heading)
                  ? 'Status'
                  : 'Turn',
              value: QiblaService.turnInstruction(data.bearing, _heading),
              icon: QiblaService.isAligned(data.bearing, _heading)
                  ? Icons.check_circle_outline
                  : Icons.rotate_right,
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Tip: calibrate by waving the phone in a figure-8. Hold flat, away from metal.',
            style: TextStyle(fontSize: 12, color: context.dq.muted.withValues(alpha: 0.9)),
          ),
        ],
        const SizedBox(height: 20),
        const DqSectionLabel('Resources'),
        DqMenuGroup(
          items: [
            DqMenuItem(
              label: 'How to Pray',
              onTap: () => context.push('/how-to-pray'),
            ),
            DqMenuItem(
              label: 'New Muslim Prayer Guide',
              onTap: () => context.push('/new-muslim'),
            ),
          ],
        ),
      ],
    ),
    );
  }
}

enum _SavedTab { ayahs, articles, receipts }

class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  _SavedTab _tab = _SavedTab.ayahs;

  Future<void> _onRefresh() {
    return dqPullRefresh(
      ref,
      invalidate: [bookmarkServiceProvider],
      awaitExtras: () => ref.read(bookmarkServiceProvider.future).then((_) {}),
    );
  }

  Widget _scrollablePlaceholder(Widget child) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 200, child: child),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookmarksAsync = ref.watch(bookmarkServiceProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Text('Saved', style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: DqPillTabs<_SavedTab>(
            tabs: _SavedTab.values,
            selected: _tab,
            onSelected: (t) => setState(() => _tab = t),
            labelBuilder: (t) => switch (t) {
              _SavedTab.ayahs => 'Ayahs',
              _SavedTab.articles => 'Articles',
              _SavedTab.receipts => 'Receipts',
            },
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: bookmarksAsync.when(
              loading: () => _scrollablePlaceholder(const DqLoadingOverlay()),
              error: (_, __) => _scrollablePlaceholder(
                const DqEmptyState(icon: Icons.error_outline, title: 'Could not load', message: 'Pull to refresh later.'),
              ),
              data: (service) => switch (_tab) {
                _SavedTab.ayahs => _ayahsTab(context, service),
                _SavedTab.articles => _articlesTab(context, service),
                _SavedTab.receipts => _receiptsTab(context, service),
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _ayahsTab(BuildContext context, BookmarkService service) {
    if (service.bookmarks.isEmpty) {
      return _scrollablePlaceholder(
        const DqEmptyState(
          icon: Icons.favorite_outline,
          title: 'Nothing saved yet',
          message: 'Bookmark ayahs from the Quran reader.',
        ),
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: service.bookmarks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final b = service.bookmarks[i];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push(
              '/quran/reader',
              extra: QuranReaderArgs(surahNumber: b.surahNumber, surahName: b.surahName, initialAyah: b.ayahNumber),
            ),
            borderRadius: BorderRadius.circular(16),
            child: DqSavedAyahCard(
              reference: '${b.surahName} · Ayah ${b.ayahNumber}',
              arabic: '﴿ ... ﴾',
              english: 'Tap to open this ayah in the Quran reader.',
            ),
          ),
        );
      },
    );
  }

  Widget _articlesTab(BuildContext context, BookmarkService service) {
    if (service.articles.isEmpty) {
      return _scrollablePlaceholder(
        const DqEmptyState(
          icon: Icons.article_outlined,
          title: 'No articles saved',
          message: 'Save articles from Learn to find them here.',
        ),
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: service.articles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final a = service.articles[i];
        return Material(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => context.push('/learn/article', extra: a.articleId),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.dq.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.onSurface)),
                  const SizedBox(height: 4),
                  Text('Article · Islamic Studies', style: TextStyle(fontSize: 11, color: context.dq.muted)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _receiptsTab(BuildContext context, BookmarkService service) {
    if (service.receipts.isEmpty) {
      return _scrollablePlaceholder(
        DqEmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'No receipts yet',
          message: 'You haven\'t made a donation yet. Receipts from your donations will appear here.',
          action: DqPrimaryButton(
            label: 'Make a Donation',
            onPressed: () => pushRootRoute(context, '/donate'),
          ),
        ),
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: service.receipts.length,
      itemBuilder: (_, i) {
        final r = service.receipts[i];
        return DqCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Donation Receipt', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('#${r.receiptId}', style: TextStyle(color: context.dq.muted, fontSize: 12)),
                ],
              ),
              Text('£${(r.amountPence / 100).toStringAsFixed(0)}', style: const TextStyle(color: AppColors.yellow, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        );
      },
    );
  }
}

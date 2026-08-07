import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env_config.dart';
import '../constants/app_assets.dart';

class AppMediaSlot {
  const AppMediaSlot({
    required this.pageKey,
    required this.slotKey,
    this.url,
    this.fallbackAsset,
  });

  final String pageKey;
  final String slotKey;
  final String? url;
  final String? fallbackAsset;

  String get key => '$pageKey.$slotKey';
}

class AppMediaRepository {
  AppMediaRepository(this._client);

  final SupabaseClient? _client;
  Map<String, AppMediaSlot>? _cache;

  void clearCache() => _cache = null;

  /// Drop disk/memory bitmaps for current URLs so reused or replaced files redraw.
  Future<void> evictImageCaches() async {
    final urls = _cache?.values
            .map((s) => s.url)
            .whereType<String>()
            .where((u) => u.isNotEmpty && !u.toLowerCase().endsWith('.svg')) ??
        const <String>[];
    for (final url in urls) {
      await CachedNetworkImage.evictFromCache(url);
    }
  }

  Future<Map<String, AppMediaSlot>> fetchAll({bool force = false}) async {
    if (!force && _cache != null) return _cache!;
    final client = _client;
    if (client == null) {
      _cache = _bundledDefaults();
      return _cache!;
    }
    try {
      final rows = await client.from('app_page_media').select('page_key, slot_key, url, fallback_asset');
      final map = <String, AppMediaSlot>{};
      for (final row in rows as List) {
        final page = row['page_key'] as String;
        final slot = row['slot_key'] as String;
        map['$page.$slot'] = AppMediaSlot(
          pageKey: page,
          slotKey: slot,
          url: row['url'] as String?,
          fallbackAsset: row['fallback_asset'] as String?,
        );
      }
      // Ensure bundled defaults exist even if DB missing rows.
      for (final e in _bundledDefaults().entries) {
        map.putIfAbsent(e.key, () => e.value);
      }
      _cache = map;
      return map;
    } catch (_) {
      _cache = _bundledDefaults();
      return _cache!;
    }
  }

  AppMediaSlot? slotSync(String pageKey, String slotKey) => _cache?['$pageKey.$slotKey'];

  static Map<String, AppMediaSlot> _bundledDefaults() => {
        'onboarding.logo': const AppMediaSlot(
          pageKey: 'onboarding',
          slotKey: 'logo',
          fallbackAsset: AppAssets.logoWordmark,
        ),
        'home.quran_banner': const AppMediaSlot(
          pageKey: 'home',
          slotKey: 'quran_banner',
          fallbackAsset: AppAssets.quranBookshot,
        ),
        'home.app_icon': const AppMediaSlot(
          pageKey: 'home',
          slotKey: 'app_icon',
          fallbackAsset: AppAssets.appIcon,
        ),
        'order.product': const AppMediaSlot(
          pageKey: 'order',
          slotKey: 'product',
          fallbackAsset: AppAssets.quranBookshot,
        ),
        'more.kaaba_icon': const AppMediaSlot(
          pageKey: 'more',
          slotKey: 'kaaba_icon',
          fallbackAsset: AppAssets.kaabaIcon,
        ),
        'pilgrimage.featured_kaaba': const AppMediaSlot(
          pageKey: 'pilgrimage',
          slotKey: 'featured_kaaba',
          fallbackAsset: AppAssets.kaabaIcon,
        ),
        'qibla.compass_mark': const AppMediaSlot(
          pageKey: 'qibla',
          slotKey: 'compass_mark',
          fallbackAsset: AppAssets.kaabaIcon,
        ),
        'logistics.visa': const AppMediaSlot(
          pageKey: 'logistics',
          slotKey: 'visa',
          fallbackAsset: AppAssets.logisticsVisa,
        ),
        'logistics.ihram': const AppMediaSlot(
          pageKey: 'logistics',
          slotKey: 'ihram',
          fallbackAsset: AppAssets.logisticsIhram,
        ),
        'logistics.haram': const AppMediaSlot(
          pageKey: 'logistics',
          slotKey: 'haram',
          fallbackAsset: AppAssets.logisticsHaram,
        ),
        'logistics.nabawi': const AppMediaSlot(
          pageKey: 'logistics',
          slotKey: 'nabawi',
          fallbackAsset: AppAssets.logisticsNabawi,
        ),
        'logistics.jannat': const AppMediaSlot(
          pageKey: 'logistics',
          slotKey: 'jannat',
          fallbackAsset: AppAssets.logisticsJannat,
        ),
        'logistics.nusuk': const AppMediaSlot(
          pageKey: 'logistics',
          slotKey: 'nusuk',
          fallbackAsset: AppAssets.logisticsNusuk,
        ),
      };
}

final appMediaRepositoryProvider = Provider<AppMediaRepository>((ref) {
  return AppMediaRepository(EnvConfig.supabase);
});

final appMediaMapProvider = FutureProvider<Map<String, AppMediaSlot>>((ref) {
  // Always hit Supabase when this provider (re)builds; in-memory cache must not
  // survive invalidate/pull-to-refresh.
  return ref.watch(appMediaRepositoryProvider).fetchAll(force: true);
});

/// Resolves CMS url or bundled asset for a page slot.
class AppMediaImage extends ConsumerWidget {
  const AppMediaImage({
    super.key,
    required this.pageKey,
    required this.slotKey,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.fallbackAsset,
  });

  final String pageKey;
  final String slotKey;
  final BoxFit fit;
  final double? width;
  final double? height;
  final String? fallbackAsset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final map = ref.watch(appMediaMapProvider).valueOrNull;
    final slot = map?['$pageKey.$slotKey'];
    final url = slot?.url;
    final asset = slot?.fallbackAsset ?? fallbackAsset;

    if (url != null && url.isNotEmpty) {
      if (url.toLowerCase().endsWith('.svg')) {
        return SvgPicture.network(url, width: width, height: height, fit: fit);
      }
      return CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        errorWidget: (_, __, ___) => _assetOrEmpty(asset),
      );
    }
    return _assetOrEmpty(asset);
  }

  Widget _assetOrEmpty(String? asset) {
    if (asset == null || asset.isEmpty) {
      return SizedBox(width: width, height: height);
    }
    if (asset.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(asset, width: width, height: height, fit: fit);
    }
    return Image.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => SizedBox(width: width, height: height),
    );
  }
}

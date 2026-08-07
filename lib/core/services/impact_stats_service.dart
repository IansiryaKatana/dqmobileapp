import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env_config.dart';
import 'content_repository.dart';

class ImpactStats {
  const ImpactStats({
    required this.quransFunded,
    required this.ordersPlaced,
    required this.countries,
  });

  final int quransFunded;
  final int ordersPlaced;
  final int countries;

  /// Historical baselines — org has been distributing for ~20 years.
  /// Live DB counts are floored to these so the home counters never start at 0.
  static const fallback = ImpactStats(
    quransFunded: 875000,
    ordersPlaced: 24561,
    countries: 32,
  );

  ImpactStats withOverrides(ImpactOverrides overrides) {
    int floor(int computed, int? override, int baseline) {
      final minFloor = (override != null && override > baseline) ? override : baseline;
      return computed > minFloor ? computed : minFloor;
    }

    return ImpactStats(
      quransFunded: floor(quransFunded, overrides.quransFunded, fallback.quransFunded),
      ordersPlaced: floor(ordersPlaced, overrides.ordersPlaced, fallback.ordersPlaced),
      countries: floor(countries, overrides.countries, fallback.countries),
    );
  }
}

abstract final class ImpactStatsService {
  static Future<ImpactStats> fetch() async {
    final client = EnvConfig.supabase;
    if (client == null) return ImpactStats.fallback;
    try {
      final row = await client.from('impact_stats').select().maybeSingle();
      if (row == null) return ImpactStats.fallback;
      return ImpactStats(
        quransFunded: row['qurans_funded'] as int? ?? 0,
        ordersPlaced: row['orders_placed'] as int? ?? 0,
        countries: row['countries'] as int? ?? 0,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Impact stats fetch failed: $e');
      return ImpactStats.fallback;
    }
  }
}

final impactStatsProvider = FutureProvider<ImpactStats>((ref) async {
  final stats = await ImpactStatsService.fetch();
  final overrides = await ref.watch(contentRepositoryProvider).fetchImpactOverrides();
  // Always apply historical baselines (+ any CMS floors).
  return stats.withOverrides(overrides);
});

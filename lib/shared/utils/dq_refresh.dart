import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/app_media_repository.dart';

/// Clears App Media memory + image caches, then reloads from Supabase.
Future<void> refreshAppMedia(WidgetRef ref) async {
  final repo = ref.read(appMediaRepositoryProvider);
  await repo.evictImageCaches();
  repo.clearCache();
  ref.invalidate(appMediaMapProvider);
  await ref.read(appMediaMapProvider.future);
}

/// Pull-to-refresh helper: refresh App Media, invalidate page providers, then
/// run [awaitExtras] (e.g. `ref.read(fooProvider.future)` or screen reloads).
Future<void> dqPullRefresh(
  WidgetRef ref, {
  List<ProviderOrFamily> invalidate = const [],
  Future<void> Function()? awaitExtras,
}) async {
  await refreshAppMedia(ref);
  for (final provider in invalidate) {
    ref.invalidate(provider);
  }
  if (awaitExtras != null) {
    await awaitExtras();
  }
}

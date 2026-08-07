import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/content_repository.dart';
import '../../core/theme/app_colors.dart';

/// Subtle banner — does not pretend CMS is live when offline/static data is shown.
class CmsFallbackBanner extends ConsumerWidget {
  const CmsFallbackBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usingFallback = ref.watch(cmsFallbackFlagProvider);
    if (!usingFallback) return const SizedBox.shrink();
    return Material(
      color: AppColors.sand,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: Colors.brown.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                kReleaseMode
                    ? 'Showing offline content — live CMS unavailable.'
                    : 'Debug: using bundled content fallback.',
                style: TextStyle(fontSize: 12, color: Colors.brown.shade800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

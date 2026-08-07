import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_assets.dart';
import '../../core/services/app_media_repository.dart';

/// Kaaba side-profile icon — CMS override via more.kaaba_icon / pilgrimage.featured_kaaba.
class KaabaIcon extends ConsumerWidget {
  const KaabaIcon({super.key, this.size = 48, this.pageKey = 'more', this.slotKey = 'kaaba_icon'});

  final double size;
  final String pageKey;
  final String slotKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppMediaImage(
      pageKey: pageKey,
      slotKey: slotKey,
      width: size,
      height: size,
      fit: BoxFit.contain,
      fallbackAsset: AppAssets.kaabaIcon,
    );
  }
}

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../config/env_config.dart';

abstract final class DeepLinkService {
  static final _appLinks = AppLinks();

  static Future<void> init(GoRouter router) async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) await _navigate(router, initial);
      _appLinks.uriLinkStream.listen((uri) => _navigate(router, uri));
    } catch (e) {
      if (kDebugMode) debugPrint('Deep links unavailable: $e');
    }
  }

  static Future<void> _navigate(GoRouter router, Uri uri) async {
    if (await _handleRecovery(router, uri)) return;
    final path = _mapPath(uri);
    if (path != null) router.go(path);
  }

  static Future<bool> _handleRecovery(GoRouter router, Uri uri) async {
    final isRecovery = uri.path.contains('reset-password') ||
        uri.fragment.contains('type=recovery') ||
        uri.queryParameters['type'] == 'recovery';
    if (!isRecovery) return false;

    final client = EnvConfig.supabase;
    if (client == null) {
      router.go('/reset-password');
      return true;
    }
    try {
      await client.auth.getSessionFromUrl(uri);
      router.go('/reset-password');
    } catch (e) {
      if (kDebugMode) debugPrint('Recovery link failed: $e');
      router.go('/reset-password');
    }
    return true;
  }

  static String? _mapPath(Uri uri) {
    if (uri.scheme == 'https' && uri.host.contains('donatequran')) {
      return uri.path.isEmpty ? '/home' : uri.path;
    }
    if (uri.scheme == 'donatequran') {
      if (uri.host == 'reset-password') return '/reset-password';
      final segment = uri.host.isNotEmpty ? '/${uri.host}' : uri.path;
      return segment.isEmpty ? '/home' : segment;
    }
    return uri.path.isNotEmpty ? uri.path : null;
  }
}

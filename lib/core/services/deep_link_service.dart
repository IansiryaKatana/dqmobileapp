import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../config/env_config.dart';
import 'auth_repository.dart';

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
    if (await _handleAuthCallback(router, uri)) return;
    final path = _mapPath(uri);
    if (path != null) router.go(path);
  }

  static Future<bool> _handleAuthCallback(GoRouter router, Uri uri) async {
    final type = _param(uri, 'type');
    final isRecovery = type == 'recovery' ||
        uri.path.contains('reset-password') ||
        uri.host == 'reset-password' ||
        uri.fragment.contains('type=recovery');
    final hasAuthPayload = uri.fragment.contains('access_token') ||
        uri.queryParameters.containsKey('code') ||
        type == 'signup' ||
        type == 'magiclink' ||
        type == 'email_change' ||
        type == 'invite';

    if (!isRecovery && !hasAuthPayload) return false;

    final client = EnvConfig.supabase;
    if (client == null) {
      router.go(isRecovery ? '/reset-password' : '/login');
      return true;
    }
    try {
      if (isRecovery) {
        AuthRepository.recoveryPending = true;
      }
      await client.auth.getSessionFromUrl(uri);
      router.go(isRecovery ? '/reset-password' : '/home');
    } catch (e) {
      if (kDebugMode) debugPrint('Auth callback failed: $e');
      router.go(isRecovery ? '/reset-password' : '/login');
    }
    return true;
  }

  static String? _param(Uri uri, String key) {
    final fromQuery = uri.queryParameters[key];
    if (fromQuery != null && fromQuery.isNotEmpty) return fromQuery;
    final fragment = uri.fragment;
    if (fragment.isEmpty) return null;
    final query = fragment.contains('?') ? fragment.split('?').last : fragment;
    return Uri.splitQueryString(query)[key];
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

import 'dart:io';

import 'package:flutter/foundation.dart';

import '../config/env_config.dart';

abstract final class DeviceTokenService {
  static Future<void> syncToken({
    required String token,
    required String userId,
  }) async {
    final client = EnvConfig.supabase;
    if (client == null) return;
    try {
      await client.from('device_tokens').upsert({
        'user_id': userId,
        'token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Device token sync failed: $e');
    }
  }
}

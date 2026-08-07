import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/env_config.dart';
import 'core/services/crash_reporting.dart';
import 'core/services/purchase_service.dart';
import 'core/services/push_notification_service.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  CrashReporting.init();
  await EnvConfig.load();
  await EnvConfig.initSupabase();
  await PushNotificationService.init();
  await CrashReporting.enableCrashlyticsIfConfigured();
  await PurchaseService.init();
}

void main() {
  CrashReporting.runGuarded(() async {
    await bootstrap();
    runApp(const ProviderScope(child: DonateQuranApp()));
  });
}

import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../config/firebase_options.dart';

/// Crash / error capture.
///
/// When Firebase is configured (`flutterfire configure`), errors go to Crashlytics
/// in release builds. Until then, debug prints only.
abstract final class CrashReporting {
  static bool _crashlyticsReady = false;

  /// True when Crashlytics is active (configured Firebase + non-debug).
  static bool get isProductionReportingEnabled =>
      _crashlyticsReady && !kDebugMode;

  static void init() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      _log('FlutterError', details.exception, details.stack, fatal: true);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      _log('Uncaught', error, stack, fatal: true);
      return true;
    };
  }

  /// Call after Firebase.initializeApp when options are real.
  static Future<void> enableCrashlyticsIfConfigured() async {
    if (!DefaultFirebaseOptions.isConfigured) return;
    try {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
      _crashlyticsReady = true;
      final previous = FlutterError.onError;
      FlutterError.onError = (details) {
        previous?.call(details);
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      };
      if (kDebugMode) {
        debugPrint('Crashlytics ready (collection enabled in release only)');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Crashlytics enable failed: $e');
    }
  }

  static void runGuarded(Future<void> Function() app) {
    runZonedGuarded(
      () async => app(),
      (error, stack) => _log('Zone', error, stack, fatal: true),
    );
  }

  static void recordError(Object error, [StackTrace? stack]) {
    _log('Recorded', error, stack);
  }

  static void _log(
    String label,
    Object error,
    StackTrace? stack, {
    bool fatal = false,
  }) {
    if (_crashlyticsReady && !kDebugMode) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          error,
          stack,
          fatal: fatal,
          reason: label,
        ),
      );
      return;
    }
    if (kDebugMode) {
      debugPrint(
        'CrashReporting[$label]${_crashlyticsReady ? '' : ' (stub — run flutterfire configure)'}: $error',
      );
      if (stack != null) debugPrint('$stack');
    }
  }
}

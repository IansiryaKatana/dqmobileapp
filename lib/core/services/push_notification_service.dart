import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/firebase_options.dart';
import 'device_token_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!DefaultFirebaseOptions.isConfigured) return;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

/// Push status for UI — never claim notifications work when Firebase is a placeholder.
enum PushServiceStatus {
  /// Real FlutterFire options present and Firebase initialized.
  ready,
  /// `firebase_options.dart` still has REPLACE_WITH placeholders.
  notConfigured,
  /// Options look valid but init / permission failed.
  unavailable,
}

abstract final class PushNotificationService {
  static bool _firebaseReady = false;
  static PushServiceStatus _status = PushServiceStatus.notConfigured;
  static const _enabledKey = 'notifications_enabled';

  static PushServiceStatus get status => _status;
  static bool get isAvailable => _status == PushServiceStatus.ready;

  static String get statusMessage => switch (_status) {
        PushServiceStatus.ready => 'Push notifications are available on this device.',
        PushServiceStatus.notConfigured =>
          'Push notifications are not configured yet. Run flutterfire configure before release.',
        PushServiceStatus.unavailable =>
          'Push notifications could not be started on this device.',
      };

  static Future<void> _ensureFirebase() async {
    if (_firebaseReady) return;
    if (!DefaultFirebaseOptions.isConfigured) {
      _status = PushServiceStatus.notConfigured;
      throw StateError('Firebase not configured — run flutterfire configure');
    }
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    _firebaseReady = true;
    _status = PushServiceStatus.ready;
  }

  /// Initialize Firebase only — does not request OS permission (needs user action).
  static Future<void> init() async {
    if (!DefaultFirebaseOptions.isConfigured) {
      _status = PushServiceStatus.notConfigured;
      if (kDebugMode) {
        debugPrint(
          'Firebase placeholders detected — skipping FCM init. '
          'Run: dart pub global activate flutterfire_cli && flutterfire configure',
        );
      }
      return;
    }
    try {
      await _ensureFirebase();
      // Keep device_tokens in sync when FCM rotates the token.
      FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
        if (kDebugMode) debugPrint('FCM token refreshed');
        // User id is applied on next syncTokenForUser / login; store prefs token only here.
      });
    } catch (e) {
      _status = PushServiceStatus.unavailable;
      if (kDebugMode) debugPrint('Firebase init failed: $e');
    }
  }

  static Future<bool> isEnabledInPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  static Future<void> _setEnabledInPrefs(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
  }

  static Future<bool> hasOsPermission() async {
    if (!DefaultFirebaseOptions.isConfigured) return false;
    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.notification.status;
      if (status.isGranted || status.isLimited) return true;
    }
    try {
      await _ensureFirebase();
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (_) {
      return false;
    }
  }

  /// Request OS notification permission — call from a user tap (settings or onboarding).
  static Future<bool> requestPermission() async {
    if (!DefaultFirebaseOptions.isConfigured) {
      _status = PushServiceStatus.notConfigured;
      return false;
    }
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final status = await Permission.notification.request();
        final granted = status.isGranted || status.isLimited;
        await _setEnabledInPrefs(granted);
        if (granted) {
          await _syncFcmToken();
        }
        return granted;
      }

      await _ensureFirebase();
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      await _setEnabledInPrefs(granted);
      if (granted) await _syncFcmToken();
      return granted;
    } catch (e) {
      _status = PushServiceStatus.unavailable;
      if (kDebugMode) debugPrint('Notification permission error: $e');
      return false;
    }
  }

  static Future<void> _syncFcmToken() async {
    try {
      await _ensureFirebase();
      final token = await FirebaseMessaging.instance.getToken();
      if (kDebugMode) debugPrint('FCM token: $token');
    } catch (e) {
      if (kDebugMode) debugPrint('FCM token unavailable: $e');
    }
  }

  static Future<void> syncTokenForUser(String userId) async {
    if (!DefaultFirebaseOptions.isConfigured) return;
    if (!await hasOsPermission()) return;
    try {
      await _ensureFirebase();
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await DeviceTokenService.syncToken(token: token, userId: userId);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('FCM token sync failed: $e');
    }
  }

  static Future<String?> getToken() async {
    if (!DefaultFirebaseOptions.isConfigured) return null;
    if (!await hasOsPermission()) return null;
    try {
      await _ensureFirebase();
      return FirebaseMessaging.instance.getToken();
    } catch (_) {
      return null;
    }
  }
}

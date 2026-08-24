import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class EnvConfig {
  static bool _loaded = false;

  static String _get(String key, String fromDefine) {
    if (fromDefine.isNotEmpty) return fromDefine;
    if (!_loaded) return '';
    return dotenv.env[key] ?? '';
  }

  static String get supabaseUrl =>
      _get('SUPABASE_URL', const String.fromEnvironment('SUPABASE_URL'));
  static String get supabaseAnonKey =>
      _get('SUPABASE_ANON_KEY', const String.fromEnvironment('SUPABASE_ANON_KEY'));
  static String get revenueCatAndroidKey => _get(
        'REVENUECAT_API_KEY_ANDROID',
        const String.fromEnvironment('REVENUECAT_API_KEY_ANDROID'),
      );
  static String get revenueCatIosKey => _get(
        'REVENUECAT_API_KEY_IOS',
        const String.fromEnvironment('REVENUECAT_API_KEY_IOS'),
      );
  static String get stripePublishableKey => _get(
        'STRIPE_PUBLISHABLE_KEY',
        const String.fromEnvironment('STRIPE_PUBLISHABLE_KEY'),
      );

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      !supabaseUrl.contains('your-project');

  static bool get hasStripe =>
      stripePublishableKey.isNotEmpty &&
      stripePublishableKey.startsWith('pk_') &&
      !stripePublishableKey.contains('your-stripe');

  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env', isOptional: true);
      _loaded = true;
    } catch (_) {
      _loaded = dotenv.isInitialized;
    }
    if (!_loaded && kDebugMode) {
      debugPrint(
        'No .env asset loaded — using --dart-define / --dart-define-from-file values if provided.',
      );
    }
  }

  static Future<void> initSupabase() async {
    if (!hasSupabase) return;
    await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseAnonKey);
  }

  static SupabaseClient? get supabase => hasSupabase ? Supabase.instance.client : null;
}

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class EnvConfig {
  static bool _loaded = false;

  static String _get(String key) {
    if (!_loaded) return '';
    return dotenv.env[key] ?? '';
  }

  static String get supabaseUrl => _get('SUPABASE_URL');
  static String get supabaseAnonKey => _get('SUPABASE_ANON_KEY');
  static String get revenueCatAndroidKey => _get('REVENUECAT_API_KEY_ANDROID');
  static String get revenueCatIosKey => _get('REVENUECAT_API_KEY_IOS');

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty && !supabaseUrl.contains('your-project');

  static Future<void> load() async {
    for (final file in ['.env', '.env.example']) {
      try {
        await dotenv.load(fileName: file);
        _loaded = true;
        if (file == '.env.example' && kDebugMode) {
          debugPrint(
            'No .env file found — using .env.example placeholders. '
            'Copy .env.example to .env, add your keys, and list .env in pubspec.yaml assets.',
          );
        }
        return;
      } catch (_) {}
    }
    _loaded = false;
    if (kDebugMode) {
      debugPrint('No env file loaded — app will run with offline/placeholder features only.');
    }
  }

  static Future<void> initSupabase() async {
    if (!hasSupabase) return;
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  static SupabaseClient? get supabase => hasSupabase ? Supabase.instance.client : null;
}

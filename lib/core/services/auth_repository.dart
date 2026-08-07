import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env_config.dart';
import '../providers/app_state_provider.dart';
import 'push_notification_service.dart';

class AuthRepository {
  AuthRepository(this._client, this._notifier);

  final SupabaseClient? _client;
  final AppStateNotifier _notifier;

  bool get isAvailable => _client != null;

  Future<void> restoreSession() async {
    if (_client == null) return;
    final session = _client.auth.currentSession;
    final user = session?.user;
    if (user == null) return;
    final profile = await _client
        .from('profiles')
        .select('name, email')
        .eq('id', user.id)
        .maybeSingle();
    _notifier.login(AppUser(
      name: profile?['name'] as String? ?? user.email?.split('@').first ?? 'User',
      email: profile?['email'] as String? ?? user.email ?? '',
      id: user.id,
    ));
    await PushNotificationService.syncTokenForUser(user.id);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    if (_client == null) {
      if (kReleaseMode) {
        throw Exception('Sign up requires Supabase configuration');
      }
      _notifier.login(AppUser(name: name, email: email));
      return;
    }
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
    final user = response.user;
    if (user != null) {
      await _client.from('profiles').upsert({
        'id': user.id,
        'name': name,
        'email': email,
      });
      _notifier.login(AppUser(name: name, email: email, id: user.id));
      await PushNotificationService.syncTokenForUser(user.id);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    if (_client == null) {
      if (kReleaseMode) {
        throw Exception('Sign in requires Supabase configuration');
      }
      _notifier.login(AppUser(name: email.split('@').first, email: email));
      return;
    }
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user != null) {
      final profile = await _client
          .from('profiles')
          .select('name, email')
          .eq('id', user.id)
          .maybeSingle();
      _notifier.login(AppUser(
        name: profile?['name'] as String? ?? email.split('@').first,
        email: profile?['email'] as String? ?? email,
        id: user.id,
      ));
      await PushNotificationService.syncTokenForUser(user.id);
    }
  }

  Future<void> signOut() async {
    if (_client != null) await _client.auth.signOut();
    _notifier.logout();
  }

  Future<void> resetPassword(String email) async {
    if (_client == null) {
      throw Exception('Password reset requires Supabase configuration');
    }
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'donatequran://reset-password',
    );
  }

  Future<void> handleRecoveryUri(Uri uri) async {
    if (_client == null) {
      throw Exception('Password reset requires Supabase configuration');
    }
    await _client.auth.getSessionFromUrl(uri);
  }

  Future<void> updatePassword(String password) async {
    if (_client == null) {
      throw Exception('Password update requires Supabase configuration');
    }
    await _client.auth.updateUser(UserAttributes(password: password));
  }

  /// Updates display name on `profiles` and local app state. Name only (no auth email change).
  Future<void> updateProfile({required String name}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw Exception('Name cannot be empty');
    }
    final sessionUser = _client?.auth.currentUser;
    final current = _notifier.currentUser;
    final userId = sessionUser?.id ?? current?.id;
    final email = current?.email ?? sessionUser?.email ?? '';
    if (userId == null) {
      throw Exception('Sign in to update your profile');
    }
    if (_client == null) {
      if (kReleaseMode) {
        throw Exception('Profile update requires Supabase configuration');
      }
      _notifier.login(AppUser(name: trimmed, email: email, id: userId));
      return;
    }
    await _client.from('profiles').update({
      'name': trimmed,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
    _notifier.login(AppUser(name: trimmed, email: email, id: userId));
  }

  bool get hasRecoverySession {
    if (_client == null) return false;
    return _client.auth.currentSession != null;
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(EnvConfig.supabase, ref.read(appStateProvider.notifier));
});

final authBootstrapProvider = FutureProvider<void>((ref) async {
  await ref.read(authRepositoryProvider).restoreSession();
});

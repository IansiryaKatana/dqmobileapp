import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env_config.dart';
import '../providers/app_state_provider.dart';
import 'purchase_service.dart';
import 'push_notification_service.dart';

enum SignUpResult { signedIn, needsEmailConfirmation }

class EmailNotConfirmedException implements Exception {
  EmailNotConfirmedException(this.email);
  final String email;
  @override
  String toString() => 'Email not confirmed';
}

class AuthRepository {
  AuthRepository(this._client, this._notifier);

  final SupabaseClient? _client;
  final AppStateNotifier _notifier;

  static final recoveryPendingListenable = ValueNotifier<bool>(false);

  static bool get recoveryPending => recoveryPendingListenable.value;
  static set recoveryPending(bool value) => recoveryPendingListenable.value = value;

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

  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    if (_client == null) {
      if (kReleaseMode) {
        throw Exception('Sign up requires Supabase configuration');
      }
      _notifier.login(AppUser(name: name, email: email));
      return SignUpResult.signedIn;
    }
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
    final user = response.user;
    if (user == null) {
      throw Exception('Sign up could not be completed. Please try again.');
    }
    if (response.session == null) {
      return SignUpResult.needsEmailConfirmation;
    }
    await _client.from('profiles').upsert({
      'id': user.id,
      'name': name,
      'email': email,
    });
    _notifier.login(AppUser(name: name, email: email, id: user.id));
    await PushNotificationService.syncTokenForUser(user.id);
    return SignUpResult.signedIn;
  }

  Future<void> signIn({required String email, required String password}) async {
    if (_client == null) {
      if (kReleaseMode) {
        throw Exception('Sign in requires Supabase configuration');
      }
      _notifier.login(AppUser(name: email.split('@').first, email: email));
      return;
    }
    try {
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
    } on AuthException catch (e) {
      if (_isEmailNotConfirmed(e)) {
        throw EmailNotConfirmedException(email);
      }
      rethrow;
    }
  }

  Future<void> resendSignupEmail(String email) async {
    if (_client == null) {
      throw Exception('Email confirmation requires Supabase configuration');
    }
    await _client.auth.resend(type: OtpType.signup, email: email);
  }

  Future<void> signOut() async {
    recoveryPending = false;
    if (_client != null) await _client.auth.signOut();
    _notifier.logout();
  }

  /// Permanently deletes the Auth user (Apple 5.1.1(v)). Release fail-closed.
  Future<void> deleteAccount() async {
    if (_client == null) {
      throw Exception('Account deletion requires an online connection.');
    }
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Sign in to delete your account');
    }
    final res = await _client.functions.invoke('delete-account');
    final data = res.data;
    if (res.status >= 400) {
      final message = data is Map ? data['error']?.toString() : null;
      throw Exception(message ?? 'Could not delete your account. Please try again.');
    }
    await PurchaseService.logOut();
    await _client.auth.signOut();
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
    recoveryPending = true;
    await _client.auth.getSessionFromUrl(uri);
  }

  Future<void> updatePassword(String password) async {
    if (_client == null) {
      throw Exception('Password update requires Supabase configuration');
    }
    await _client.auth.updateUser(UserAttributes(password: password));
    recoveryPending = false;
    await _client.auth.signOut();
    _notifier.logout();
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
    return recoveryPending && _client.auth.currentSession != null;
  }

  static bool _isEmailNotConfirmed(AuthException error) {
    final message = error.message.toLowerCase();
    final code = error.code?.toLowerCase() ?? '';
    return message.contains('email not confirmed') ||
        code.contains('email_not_confirmed');
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(EnvConfig.supabase, ref.read(appStateProvider.notifier));
});

final authBootstrapProvider = FutureProvider<void>((ref) async {
  await ref.read(authRepositoryProvider).restoreSession();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env_config.dart';
import '../providers/app_state_provider.dart';
import 'auth_repository.dart';

final authSessionProvider = Provider<void>((ref) {
  final client = EnvConfig.supabase;
  if (client == null) return;

  final sub = client.auth.onAuthStateChange.listen((event) async {
    if (event.event == AuthChangeEvent.signedOut) {
      AuthRepository.recoveryPending = false;
      ref.read(appStateProvider.notifier).logout();
      return;
    }
    if (event.event == AuthChangeEvent.passwordRecovery) {
      AuthRepository.recoveryPending = true;
      return;
    }
    if (event.event == AuthChangeEvent.signedIn && event.session?.user != null) {
      if (AuthRepository.recoveryPending) return;
      await ref.read(authRepositoryProvider).restoreSession();
    }
  });

  ref.onDispose(sub.cancel);
});

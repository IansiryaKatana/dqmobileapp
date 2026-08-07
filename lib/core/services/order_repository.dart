import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env_config.dart';

class OrderRepository {
  OrderRepository(this._client);

  final SupabaseClient? _client;

  /// Inserts an order after postage payment has succeeded (caller responsibility).
  /// Release builds require Supabase — no fake ORD- success without a backend.
  Future<String> createOrder({
    required String title,
    required int quantity,
    required String language,
    required Map<String, dynamic> address,
    String? userId,
    int postagePence = 399,
    String status = 'pending',
  }) async {
    if (_client == null) {
      if (kReleaseMode) {
        throw Exception('Orders require Supabase configuration');
      }
      return 'DQ-ORD-DEBUG-${DateTime.now().millisecondsSinceEpoch}';
    }

    final reference = 'DQ-ORD-${DateTime.now().millisecondsSinceEpoch}';
    await _client.from('orders').insert({
      'user_id': userId,
      'reference': reference,
      'quantity': quantity,
      'language': language,
      'status': status,
      'postage_pence': postagePence,
      'address': {
        ...address,
        'title': title,
      },
    });
    return reference;
  }
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(EnvConfig.supabase);
});

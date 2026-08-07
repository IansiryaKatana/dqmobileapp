import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env_config.dart';

class DonationRepository {
  DonationRepository(this._client);

  final SupabaseClient? _client;

  /// Creates a donation row. Returns a receipt id.
  ///
  /// Release builds require Supabase — no fake DQ- success without a backend.
  /// Debug may return a local stub receipt when Supabase is not configured.
  Future<String> createDonation({
    required int amountPence,
    required String frequency,
    String? userId,
    String status = 'completed',
    Map<String, dynamic>? metadata,
  }) async {
    if (_client == null) {
      if (kReleaseMode) {
        throw Exception('Donations require Supabase configuration');
      }
      return 'DQ-DEBUG-${DateTime.now().millisecondsSinceEpoch}';
    }

    final payload = <String, dynamic>{
      'user_id': userId,
      'amount_pence': amountPence,
      'frequency': frequency,
      'status': status,
      if (metadata != null && metadata.isNotEmpty) 'metadata': metadata,
    };

    final row = await _client.from('donations').insert(payload).select('id, receipt_id').single();
    var receiptId = row['receipt_id'] as String?;
    if (receiptId == null || receiptId.isEmpty) {
      receiptId = 'DQ-${row['id']}';
      await _client.from('donations').update({'receipt_id': receiptId}).eq('id', row['id']);
    }

    if (status == 'completed') {
      final email = metadata?['donor_email'] as String?;
      if (email != null && email.contains('@')) {
        try {
          await _client.functions.invoke(
            'donation-email',
            body: {
              'receipt_id': receiptId,
              'amount_pence': amountPence,
              'currency': 'GBP',
              'email': email,
              'donor_name': metadata?['donor_name'],
              'status': status,
            },
          );
        } catch (e) {
          debugPrint('Donation email invoke failed: $e');
        }
      }
    }

    return receiptId;
  }
}

final donationRepositoryProvider = Provider<DonationRepository>((ref) {
  return DonationRepository(EnvConfig.supabase);
});

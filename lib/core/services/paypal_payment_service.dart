import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/widgets/paypal_checkout_web_view.dart';
import '../config/env_config.dart';
import 'order_pricing.dart';
import 'order_repository.dart';

/// PayPal Checkout for physical Quran orders (not store IAP).
abstract final class PaypalPaymentService {
  static bool get isConfigured => EnvConfig.hasPaypal && EnvConfig.hasSupabase;

  /// Charges Cost + Postage (Total) then inserts the order via Edge Function.
  /// Debug without PayPal returns a local stub reference (caller may continue).
  static Future<String> payAndCreateOrder({
    required BuildContext context,
    required String title,
    required int quantity,
    required OrderPackKind kind,
    required String language,
    required String line1,
    required String city,
    required String postcode,
    String? userId,
  }) async {
    final quote = OrderPricing.quote(kind, quantity);
    if (!isConfigured) {
      if (kReleaseMode) {
        throw Exception('Postage payment is not available yet. Please try again later.');
      }
      return OrderRepository(EnvConfig.supabase).createOrder(
        title: title,
        quantity: quote.quranCount,
        language: language,
        userId: userId,
        costPence: quote.costPence,
        postagePence: quote.postagePence,
        status: 'pending',
        address: {
          'line1': line1,
          'city': city,
          'postcode': postcode,
          'pack_kind': kind.apiValue,
          'pack_quantity': quantity,
        },
      );
    }

    final client = EnvConfig.supabase!;
    final created = await _invoke(client, 'create-paypal-payment', {
      'kind': kind.apiValue,
      'quantity': quantity,
    });
    final approvalUrl = created['approval_url'] as String?;
    final paypalOrderId = created['order_id'] as String?;
    if (approvalUrl == null || approvalUrl.isEmpty || paypalOrderId == null) {
      throw Exception('Postage payment could not be started. Please try again.');
    }

    if (!context.mounted) {
      throw Exception('Postage payment was cancelled.');
    }
    final approved = await PaypalCheckoutWebView.open(context, approvalUrl: approvalUrl);
    if (!approved) {
      throw Exception('Postage payment was cancelled.');
    }

    final completed = await _invoke(client, 'complete-paypal-order', {
      'paypal_order_id': paypalOrderId,
      'title': title,
      'kind': kind.apiValue,
      'quantity': quantity,
      'language': language,
      'address': {
        'line1': line1,
        'city': city,
        'postcode': postcode,
      },
    });
    final reference = completed['reference'] as String?;
    if (reference == null || reference.isEmpty) {
      throw Exception('Payment succeeded but the order could not be saved. Contact support.');
    }
    return reference;
  }

  static Future<Map<String, dynamic>> _invoke(
    SupabaseClient client,
    String name,
    Map<String, dynamic> body,
  ) async {
    final res = await client.functions.invoke(name, body: body);
    final data = res.data;
    if (res.status >= 400) {
      final message = data is Map ? data['error']?.toString() : null;
      throw Exception(message ?? 'Postage payment failed. Please try again.');
    }
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw Exception('Unexpected postage response. Please try again.');
  }
}

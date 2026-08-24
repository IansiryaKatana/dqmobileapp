import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env_config.dart';
import 'order_repository.dart';

/// Stripe PaymentSheet for physical Quran postage (not store IAP).
abstract final class PostagePaymentService {
  static bool _initialized = false;

  static const postagePence = 399;

  static bool get isConfigured => _initialized && EnvConfig.hasStripe && EnvConfig.hasSupabase;

  static Future<void> init() async {
    if (_initialized) return;
    if (!EnvConfig.hasStripe) {
      if (kDebugMode) debugPrint('Stripe publishable key not configured');
      return;
    }
    Stripe.publishableKey = EnvConfig.stripePublishableKey;
    await Stripe.instance.applySettings();
    _initialized = true;
  }

  /// Charges postage then inserts the order via Edge Function.
  /// Debug without Stripe returns a local stub reference (caller may continue).
  static Future<String> payAndCreateOrder({
    required String title,
    required int quantity,
    required String language,
    required String line1,
    required String city,
    required String postcode,
    String? userId,
  }) async {
    if (!isConfigured) {
      if (kReleaseMode) {
        throw Exception('Postage payment is not available yet. Please try again later.');
      }
      return OrderRepository(EnvConfig.supabase).createOrder(
        title: title,
        quantity: quantity,
        language: language,
        userId: userId,
        postagePence: postagePence,
        status: 'pending',
        address: {'line1': line1, 'city': city, 'postcode': postcode},
      );
    }

    final client = EnvConfig.supabase!;
    final created = await _invoke(client, 'create-postage-payment', {});
    final clientSecret = created['client_secret'] as String?;
    final paymentIntentId = created['payment_intent_id'] as String?;
    if (clientSecret == null || clientSecret.isEmpty || paymentIntentId == null) {
      throw Exception('Postage payment could not be started. Please try again.');
    }

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Donate Quran',
          style: ThemeMode.system,
        ),
      );
      await Stripe.instance.presentPaymentSheet();
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        throw Exception('Postage payment was cancelled.');
      }
      if (kDebugMode) debugPrint('Stripe postage failed: ${e.error.message}');
      throw Exception('Postage payment was not completed. Please try again.');
    }

    final completed = await _invoke(client, 'complete-postage-order', {
      'payment_intent_id': paymentIntentId,
      'title': title,
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

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:donate_quran/core/services/paypal_amount.dart';

void main() {
  test('pence converts to a two-decimal PayPal amount', () {
    expect(PaypalAmount.fromPence(0), '0.00');
    expect(PaypalAmount.fromPence(750), '7.50');
    expect(PaypalAmount.fromPence(1250), '12.50');
    expect(PaypalAmount.fromPence(26000), '260.00');
  });

  test('PayPal amount converts back to pence', () {
    expect(PaypalAmount.toPence('7.50'), 750);
    expect(PaypalAmount.toPence('12.50'), 1250);
    expect(PaypalAmount.toPence('260.00'), 26000);
  });

  test('Edge Function helper uses the same two-decimal format', () {
    final ts = File('supabase/functions/_shared/paypal.ts').readAsStringSync();
    expect(ts.contains('return (pence / 100).toFixed(2);'), isTrue);
  });
}

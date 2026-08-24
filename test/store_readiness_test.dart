import 'package:flutter_test/flutter_test.dart';
import 'package:donate_quran/core/services/purchase_service.dart';
import 'package:donate_quran/core/services/content_repository.dart';
import 'package:donate_quran/core/services/content_service.dart';

void main() {
  test('donation product ids map amount and frequency', () {
    expect(
      PurchaseService.donationProductId(amountPounds: 25, monthly: false),
      'dq_donate_25_once',
    );
    expect(
      PurchaseService.donationProductId(amountPounds: 10, monthly: true),
      'dq_donate_10_monthly',
    );
  });

  test('postage display is Stripe not IAP', () {
    expect(PostageCopy.fallback.productId, 'stripe_postage_399');
    expect(PostageCopy.fallback.displayPence, 399);
  });

  test('donation copy does not claim 100 percent', () {
    expect(DonateCopy.fallback.tagline.toLowerCase().contains('100%'), isFalse);
    expect(ContentService.faq.first.answer.toLowerCase().contains('100%'), isFalse);
  });
}

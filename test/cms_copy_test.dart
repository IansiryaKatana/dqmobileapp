import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:donate_quran/core/services/content_repository.dart';
import 'package:donate_quran/core/services/purchase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled legal markdown still loads as fallback', () async {
    final privacy = await rootBundle.loadString('store/privacy_policy.md');
    final terms = await rootBundle.loadString('store/terms.md');
    final support = await rootBundle.loadString('store/support.md');
    expect(privacy.contains('Privacy Policy'), isTrue);
    expect(terms.contains('Terms'), isTrue);
    expect(support.contains('Support'), isTrue);
    expect(LegalDocumentsCopy.fromJson(null).markdownFor('privacy'), isNull);
    expect(LegalDocumentsCopy.fromJson({'privacy_md': '  '}).markdownFor('privacy'), isNull);
    expect(LegalDocumentsCopy.fromJson({'privacy_md': '# Hello'}).markdownFor('privacy'), '# Hello');
  });

  test('donate copy parse keeps tagline and fills missing chrome fields', () {
    final copy = DonateCopy.fromJson({
      'tagline': 'Custom tagline',
      'guest_message': 'Guest hi',
    });
    expect(copy.tagline, 'Custom tagline');
    expect(copy.guestMessage, 'Guest hi');
    expect(copy.heroTitle, DonateCopy.fallback.heroTitle);
    expect(copy.heroSubtitle, DonateCopy.fallback.heroSubtitle);
    expect(copy.impactCards, isNotEmpty);
    expect(copy.checkoutStoreNote, DonateCopy.fallback.checkoutStoreNote);
    expect(copy.successTitle, DonateCopy.fallback.successTitle);
    expect(
      interpolateCmsCopy(copy.successSubtitle, amount: 25),
      'Your donation of £25 has been received.',
    );
  });

  test('RevenueCat offering lookup uses named id when present', () {
    expect(
      PurchaseService.offeringIdToUse(configuredId: 'promo', availableIds: {'promo', 'default'}),
      'promo',
    );
    expect(
      PurchaseService.offeringIdToUse(configuredId: 'default', availableIds: {'promo'}),
      isNull,
    );
    expect(
      PurchaseService.offeringIdToUse(configuredId: '', availableIds: {'promo'}),
      isNull,
    );
    expect(
      PurchaseService.offeringIdToUse(configuredId: 'missing', availableIds: {'promo'}),
      isNull,
    );
  });

  test('logistics empty JSON uses fallback groups', () {
    expect(LogisticsCopy.fromJson(null).groups, isNotEmpty);
    expect(LogisticsCopy.fromJson({}).groups, isNotEmpty);
    final parsed = LogisticsCopy.fromJson({
      'groups': [
        {
          'label': 'Test',
          'items': [
            {'title': 'Visa', 'snippet': 'x', 'icon': 'mosque_outlined', 'kind': 'visaGrid'},
          ],
        },
      ],
    });
    expect(parsed.groups.single.label, 'Test');
    expect(parsed.groups.single.items.single.kind, LogisticsBodyKind.visaGrid);
  });
}

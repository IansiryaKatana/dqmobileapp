import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:donate_quran/core/services/order_pricing.dart';

void main() {
  test('copy rows match Cost + Postage totals', () {
    final expected = <int, List<int>>{
      1: [0, 750, 750],
      2: [1000, 250, 1250],
      3: [1300, 200, 1500],
      4: [1300, 200, 1500],
      5: [1500, 250, 1750],
      6: [1800, 200, 2000],
      7: [1800, 200, 2000],
      8: [1800, 200, 2000],
      9: [1800, 200, 2000],
    };
    for (final e in expected.entries) {
      final q = OrderPricing.quote(OrderPackKind.copies, e.key);
      expect(q.costPence, e.value[0]);
      expect(q.postagePence, e.value[1]);
      expect(q.totalPence, e.value[2]);
      expect(q.quranCount, e.key);
    }
    expect(OrderPricing.tryQuote(OrderPackKind.copies, 0), isNull);
    expect(OrderPricing.tryQuote(OrderPackKind.copies, 10), isNull);
  });

  test('box rows match Cost + Postage including 5-box £55', () {
    final quote = OrderPricing.quote(OrderPackKind.boxes, 5);
    expect(quote.costPence, 4500);
    expect(quote.postagePence, 1000);
    expect(quote.totalPence, 5500);
    expect(quote.quranCount, 50);

    expect(OrderPricing.quote(OrderPackKind.boxes, 1).totalPence, 2500);
    expect(OrderPricing.quote(OrderPackKind.boxes, 15).totalPence, 26000);
    expect(OrderPricing.quote(OrderPackKind.boxes, 15).quranCount, 150);
    expect(OrderPricing.tryQuote(OrderPackKind.boxes, 16), isNull);
  });

  test('Dart table stays in sync with Edge Function helper', () {
    final ts = File('supabase/functions/_shared/order_pricing.ts').readAsStringSync();
    expect(_tuples(ts, 'COPIES'), OrderPricing.copyRows);
    expect(_tuples(ts, 'BOXES'), OrderPricing.boxRows);
  });
}

List<List<int>> _tuples(String source, String name) {
  final start = source.indexOf('export const $name');
  expect(start, greaterThanOrEqualTo(0), reason: 'missing $name');
  final slice = source.substring(start, source.indexOf('];', start) + 2);
  return RegExp(r'\[(\d+), (\d+), (\d+)\]')
      .allMatches(slice)
      .map((m) => [int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!)])
      .toList();
}

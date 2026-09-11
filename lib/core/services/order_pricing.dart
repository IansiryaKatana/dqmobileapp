/// Canonical Quran order prices in pence (GBP).
///
/// Keep in sync with `supabase/functions/_shared/order_pricing.ts`.
/// PayPal charges [OrderPriceQuote.totalPence]; the client cannot override it.
enum OrderPackKind {
  copies,
  boxes;

  String get apiValue => name;

  static OrderPackKind? tryParse(String? raw) {
    switch (raw?.trim().toLowerCase()) {
      case 'copies':
        return OrderPackKind.copies;
      case 'boxes':
        return OrderPackKind.boxes;
      default:
        return null;
    }
  }
}

class OrderPriceQuote {
  const OrderPriceQuote({
    required this.kind,
    required this.quantity,
    required this.quranCount,
    required this.costPence,
    required this.postagePence,
  });

  /// Picker value: copy count (1–9) or box count (1–15).
  final OrderPackKind kind;
  final int quantity;
  final int quranCount;
  final int costPence;
  final int postagePence;

  int get totalPence => costPence + postagePence;
}

abstract final class OrderPricing {
  static const copiesPerBox = 10;
  static const minCopyQuantity = 1;
  static const maxCopyQuantity = 9;
  static const minBoxQuantity = 1;
  static const maxBoxQuantity = 15;

  /// [quantity, costPence, postagePence]
  static const copyRows = <List<int>>[
    [1, 0, 750],
    [2, 1000, 250],
    [3, 1300, 200],
    [4, 1300, 200],
    [5, 1500, 250],
    [6, 1800, 200],
    [7, 1800, 200],
    [8, 1800, 200],
    [9, 1800, 200],
  ];

  static const boxRows = <List<int>>[
    [1, 2000, 500],
    [2, 2500, 500],
    [3, 3000, 500],
    [4, 4000, 500],
    [5, 4500, 1000],
    [6, 5000, 1500],
    [7, 5500, 2000],
    [8, 6000, 2500],
    [9, 6500, 3000],
    [10, 7000, 3500],
    [11, 10000, 5000],
    [12, 12000, 6000],
    [13, 13000, 7500],
    [14, 14000, 8500],
    [15, 16000, 10000],
  ];

  static String formatPence(int pence) =>
      '£${(pence / 100).toStringAsFixed(2)}';

  static OrderPriceQuote? tryQuote(OrderPackKind kind, int quantity) {
    final rows = kind == OrderPackKind.copies ? copyRows : boxRows;
    for (final row in rows) {
      if (row[0] == quantity) {
        return OrderPriceQuote(
          kind: kind,
          quantity: quantity,
          quranCount: kind == OrderPackKind.boxes ? quantity * copiesPerBox : quantity,
          costPence: row[1],
          postagePence: row[2],
        );
      }
    }
    return null;
  }

  static OrderPriceQuote quote(OrderPackKind kind, int quantity) {
    final found = tryQuote(kind, quantity);
    if (found == null) {
      throw ArgumentError('Invalid ${kind.apiValue} quantity: $quantity');
    }
    return found;
  }
}

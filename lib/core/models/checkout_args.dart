import '../services/order_pricing.dart';

class DonateCheckoutArgs {
  const DonateCheckoutArgs({required this.amount, required this.frequency});

  final int amount;
  final String frequency;
}

class DonateSuccessArgs {
  const DonateSuccessArgs({
    required this.amount,
    required this.receiptId,
    this.email,
  });

  final int amount;
  final String receiptId;
  final String? email;
}

class OrderProductArgs {
  const OrderProductArgs({
    required this.title,
    required this.kind,
    required this.minQuantity,
    required this.maxQuantity,
  });

  final String title;
  final OrderPackKind kind;
  final int minQuantity;
  final int maxQuantity;
}

class OrderCheckoutArgs {
  const OrderCheckoutArgs({
    required this.title,
    required this.language,
    required this.quantity,
    required this.kind,
  });

  final String title;
  final String language;
  final int quantity;
  final OrderPackKind kind;
}

class OrderSuccessArgs {
  const OrderSuccessArgs({required this.reference});

  final String reference;
}

class ScholarSuccessArgs {
  const ScholarSuccessArgs({required this.referenceId});

  final String referenceId;
}

class ReceiptDetailArgs {
  const ReceiptDetailArgs({
    required this.receiptId,
    required this.amountPence,
    required this.frequency,
    required this.status,
    required this.createdAt,
  });

  final String receiptId;
  final int amountPence;
  final String frequency;
  final String status;
  final DateTime createdAt;
}

class OrderDetailArgs {
  const OrderDetailArgs({
    required this.reference,
    required this.quantity,
    required this.language,
    required this.status,
    required this.createdAt,
    this.address,
    this.postagePence = 0,
    this.costPence = 0,
  });

  final String reference;
  final int quantity;
  final String language;
  final String status;
  final DateTime createdAt;
  final Map<String, dynamic>? address;
  final int postagePence;
  final int costPence;
}

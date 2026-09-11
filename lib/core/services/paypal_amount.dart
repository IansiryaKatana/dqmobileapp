abstract final class PaypalAmount {
  static String fromPence(int pence) {
    if (pence < 0) {
      throw ArgumentError.value(pence, 'pence', 'must be zero or positive');
    }
    return (pence / 100).toStringAsFixed(2);
  }

  static int toPence(String value) {
    return (double.parse(value) * 100).round();
  }
}

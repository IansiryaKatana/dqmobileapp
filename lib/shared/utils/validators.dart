abstract final class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final email = value.trim();
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Enter your full name';
    return null;
  }

  static String? amount(String? value, {int min = 1, int max = 100000}) {
    if (value == null || value.trim().isEmpty) return 'Amount is required';
    final amount = int.tryParse(value.trim());
    if (amount == null) return 'Enter a valid amount';
    if (amount < min) return 'Minimum donation is £$min';
    if (amount > max) return 'Maximum donation is £$max';
    return null;
  }

  static String? postcode(String? value) {
    if (value == null || value.trim().isEmpty) return 'Postcode is required';
    return null;
  }
}

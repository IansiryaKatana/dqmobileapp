import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:donate_quran/shared/utils/validators.dart';
import 'package:donate_quran/shared/widgets/dq_logo.dart';

void main() {
  testWidgets('DqLogo renders brand text', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DqLogo())));
    expect(find.byType(DqLogo), findsOneWidget);
  });

  test('email validator rejects invalid email', () {
    expect(Validators.email('bad'), isNotNull);
    expect(Validators.email('user@example.com'), isNull);
  });

  test('password validator enforces minimum length', () {
    expect(Validators.password('short'), isNotNull);
    expect(Validators.password('longenough'), isNull);
  });
}

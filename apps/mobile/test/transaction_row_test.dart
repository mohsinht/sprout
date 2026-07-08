import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout_mobile/src/domain/sprout_models.dart';
import 'package:sprout_mobile/src/theme/sprout_theme.dart';
import 'package:sprout_mobile/src/widgets/transaction_row.dart';

void main() {
  testWidgets('TransactionRow wraps review chips on narrow screens',
      (tester) async {
    final transaction = SproutTransaction(
      id: 'narrow-email-review',
      merchant: 'Carrefour',
      amount: 12500,
      currency: 'PKR',
      date: DateTime(2026, 7, 5),
      category: 'Groceries',
      note: '',
      type: TransactionType.expense,
      source: TransactionSource.email,
      needsReview: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildSproutTheme(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: TransactionRow(transaction: transaction),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Carrefour'), findsOneWidget);
    expect(find.text('Needs review'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

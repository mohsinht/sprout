import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  testWidgets('audit_d4_injection_description_renders_as_inert_text',
      (tester) async {
    const shaped = '<script>alert("wealth")</script>';
    final transaction = SproutTransaction(
      id: 'inert',
      merchant: shaped,
      amount: 1,
      currency: 'PKR',
      date: DateTime(2026, 7, 15),
      category: "'); DROP TABLE users; --",
      note: '',
      type: TransactionType.expense,
      source: TransactionSource.manual,
      needsReview: false,
    );
    await tester.pumpWidget(MaterialApp(
        theme: buildSproutTheme(),
        home: Scaffold(body: TransactionRow(transaction: transaction))));
    expect(find.text(shaped), findsOneWidget);
    expect(find.byType(Text), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('FUNC-UNCERTAIN-01 review asks one calm question',
      (tester) async {
    final transaction = SproutTransaction(
      id: 'uncertain',
      merchant: 'Corner shop',
      amount: 850,
      currency: 'PKR',
      date: DateTime(2026, 7, 15),
      category: 'Other',
      note: '',
      type: TransactionType.expense,
      source: TransactionSource.statement,
      needsReview: true,
    );
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: buildSproutTheme(),
        home: Scaffold(body: TransactionRow(transaction: transaction)),
      ),
    ));

    await tester.tap(find.text('Needs review'));
    await tester.pumpAndSettle();

    expect(find.text('Is this transaction correct?'), findsOneWidget);
    expect(find.text('Yes, count it'), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);
    expect(find.text('This is not mine'), findsOneWidget);
  });
}

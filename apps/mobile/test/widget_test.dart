import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout_mobile/src/app/sprout_app.dart';

void main() {
  testWidgets('Sprout opens on the Today screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SproutApp()));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Salaam, Mohsin 👋'), findsOneWidget);
    expect(find.text('TOTAL WEALTH'), findsOneWidget);
    expect(find.text('Add PKR 25k to car fund'), findsOneWidget);
    expect(find.text('Only PKR 2 lakh to go'), findsOneWidget);
    expect(find.text('Today'), findsWidgets);
    expect(find.text('Money'), findsOneWidget);
    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Sprout opens Insights from the symmetric nav',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SproutApp()));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 2));

    await tester.tap(find.text('Insights'));
    await tester.pumpAndSettle();

    expect(find.text('Insights'), findsWidgets);
    expect(
      find.text('A few things worth knowing about your money this week.'),
      findsOneWidget,
    );
    expect(find.text('Policy rate eased'), findsOneWidget);
    expect(find.text('Al Meezan funds'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

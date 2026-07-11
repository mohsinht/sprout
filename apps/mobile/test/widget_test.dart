import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout_mobile/src/app/sprout_app.dart';
import 'package:sprout_mobile/src/presentation/shell/nav_metrics.dart';

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
    expect(find.bySemanticsLabel('Quick Add'), findsOneWidget);

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

    await tester.scrollUntilVisible(
      find.text('Car prices moved up'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Car prices moved up'));
    await tester.pumpAndSettle();
    expect(find.text('What it means for you'), findsOneWidget);
    expect(find.text('Adjust goal'), findsOneWidget);
    await tester.tap(find.text('Adjust goal'));
    await tester.pumpAndSettle();
    expect(find.text('Edit goal'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('shell pages remain usable at 1.3x text scale',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          textScaler: TextScaler.linear(1.3),
          padding: EdgeInsets.only(bottom: 34),
        ),
        child: const ProviderScope(child: SproutApp()),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    for (final label in ['Money', 'Insights', 'Settings', 'Today']) {
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    await tester.binding.setSurfaceSize(null);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('content inset includes nav height and safe area',
      (WidgetTester tester) async {
    double? inset;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(padding: EdgeInsets.only(bottom: 34)),
        child: Builder(
          builder: (context) {
            inset = NavMetrics.bottomContentPadding(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(inset, 82 + 10 + 34 + 24);
  });
}

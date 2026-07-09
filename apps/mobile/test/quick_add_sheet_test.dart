import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout_mobile/src/presentation/add/quick_add_sheet.dart';
import 'package:sprout_mobile/src/theme/sprout_theme.dart';

void main() {
  testWidgets('Quick Add logs a default expense and reaches closure',
      (tester) async {
    await _pumpHost(tester);

    await tester.tap(find.text('Open quick add'));
    await tester.pumpAndSettle();

    expect(find.text('Quick add'), findsOneWidget);
    await tester.tap(find.text('Chai'));
    await tester.pumpAndSettle();

    expect(find.text('Chai'), findsOneWidget);
    expect(find.text('PKR 200'), findsWidgets);
    expect(find.text('Log PKR 200 Chai'), findsOneWidget);

    await tester.ensureVisible(find.text('Log PKR 200 Chai'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log PKR 200 Chai'));
    await tester.pumpAndSettle();

    expect(find.text('Logged! ☕ PKR 200'), findsOneWidget);
    expect(find.text('Add another'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('Quick Add validates an empty first-use category gently',
      (tester) async {
    await _pumpHost(tester);

    await tester.tap(find.text('Open quick add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zakat'));
    await tester.pumpAndSettle();

    expect(find.text('Tap to enter'), findsOneWidget);
    await tester.ensureVisible(find.text('Log Zakat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log Zakat'));
    await tester.pumpAndSettle();

    expect(find.text('Add an amount to log this.'), findsOneWidget);
  });

  testWidgets('Quick Add date affordance changes the visible log date',
      (tester) async {
    await _pumpHost(tester);

    await tester.tap(find.text('Open quick add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chai'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byIcon(Icons.more_horiz_rounded).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_horiz_rounded).last);
    await tester.pumpAndSettle();

    expect(find.text('Log date'), findsOneWidget);
    await tester.tap(find.text('Yesterday'));
    await tester.pumpAndSettle();

    expect(find.text('Yesterday'), findsOneWidget);
  });
}

Future<void> _pumpHost(WidgetTester tester) {
  tester.view.physicalSize = const Size(430, 980);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  return tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildSproutTheme(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => QuickAddSheet.open(context),
                child: const Text('Open quick add'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

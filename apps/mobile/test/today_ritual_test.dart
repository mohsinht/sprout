import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout_mobile/src/presentation/today/today_screen.dart';
import 'package:sprout_mobile/src/presentation/today/today_widgets.dart';
import 'package:sprout_mobile/src/theme/sprout_theme.dart';

void main() {
  testWidgets('daily ritual completes and persists for the session',
      (tester) async {
    await _pumpToday(tester);
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Salaam, Mohsin 👋'), findsOneWidget);
    expect(find.text('78'), findsOneWidget);
    expect(find.text('Garden Health'), findsOneWidget);
    expect(find.text('Your money'), findsOneWidget);
    expect(find.text('Ready Wallet'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Plant it now'), findsOneWidget);

    await tester.tap(find.text('Plant it now'));
    await tester.pump();

    expect(find.text('Quest planted! 🌱'), findsOneWidget);
    expect(find.text('13'), findsOneWidget);
    expect(find.byType(ConfettiBurst), findsOneWidget);
    expect(find.text('+20 XP'), findsWidgets);

    await tester.pump(const Duration(milliseconds: 900));
    expect(find.text('81'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.byType(ConfettiBurst), findsNothing);

    await _pumpToday(tester);
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Quest planted! 🌱'), findsOneWidget);
    expect(find.text('81'), findsOneWidget);
    expect(find.text('13'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

Future<void> _pumpToday(WidgetTester tester) {
  tester.view.physicalSize = const Size(430, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  return tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildSproutTheme(),
        home: const Scaffold(
          body: SafeArea(child: TodayScreen()),
        ),
      ),
    ),
  );
}

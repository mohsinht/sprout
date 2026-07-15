import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout_mobile/src/presentation/today/today_screen.dart';
import 'package:sprout_mobile/src/theme/sprout_theme.dart';

void main() {
  testWidgets('Today shows wealth hero, holdings, goals, and provenance',
      (tester) async {
    await _pumpToday(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Greeting
    expect(find.text('Salaam, Mohsin 👋'), findsOneWidget);

    // Wealth hero label
    expect(find.text('TOTAL WEALTH'), findsOneWidget);

    // One step
    expect(find.text('Add PKR 25k to car fund'), findsOneWidget);
    expect(find.text('Only PKR 2 lakh to go'), findsOneWidget);

    // Streak
    expect(find.text('12'), findsOneWidget);

    // What's happening tiles
    expect(find.text("What's happening"), findsOneWidget);

    // Salary timing is context/depth, never an extra locked Today part.
    expect(find.textContaining('Salary in'), findsNothing);

    // Scroll down to reveal below-fold content.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
    await tester.pump(const Duration(milliseconds: 500));

    // Holdings section
    expect(find.text('Your holdings'), findsOneWidget);
    expect(find.text('Al Meezan funds'), findsOneWidget);
    expect(find.text('Wise EUR cash'), findsOneWidget);
    expect(find.text('Wise USD cash'), findsOneWidget);
    expect(find.text('PKR cash'), findsOneWidget);

    // Why it moved
    expect(find.text('Why it moved today'), findsOneWidget);

    // Scroll more for goals.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
    await tester.pump(const Duration(milliseconds: 500));

    // Goals
    expect(find.text('Your goals'), findsOneWidget);
    expect(find.text('Car fund'), findsOneWidget);
    expect(find.text('Emergency fund'), findsOneWidget);

    // Scroll more for learn later.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
    await tester.pump(const Duration(milliseconds: 500));

    // Learn later
    expect(find.text('Learn later'), findsOneWidget);
    expect(find.text('Why did my funds dip today?'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Today renders required content in dark theme', (tester) async {
    await _pumpToday(tester, brightness: Brightness.dark);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('TOTAL WEALTH'), findsOneWidget);
    expect(find.textContaining('PKR'), findsWidgets);
    expect(find.text("What's happening"), findsOneWidget);
    expect(find.text('Add PKR 25k to car fund'), findsOneWidget);

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -700));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Your holdings'), findsOneWidget);
    expect(find.text('Why it moved today'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

Future<void> _pumpToday(
  WidgetTester tester, {
  Brightness brightness = Brightness.light,
}) {
  tester.view.physicalSize = const Size(430, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  return tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildSproutTheme(brightness: brightness),
        home: MediaQuery(
          data: MediaQueryData.fromView(tester.view)
              .copyWith(disableAnimations: true),
          child: const Scaffold(
            body: SafeArea(child: TodayScreen()),
          ),
        ),
      ),
    ),
  );
}

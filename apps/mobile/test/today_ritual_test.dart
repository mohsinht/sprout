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
    expect(find.text('Add PKR 25k → only 2 lakh to your car'), findsOneWidget);

    // Streak
    expect(find.text('12'), findsOneWidget);

    // What's happening tiles
    expect(find.text("What's happening"), findsOneWidget);

    // Salary countdown strip
    expect(find.textContaining('Salary in'), findsOneWidget);

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

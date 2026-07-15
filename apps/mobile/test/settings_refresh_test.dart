import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprout_mobile/src/presentation/settings/settings_screen.dart';
import 'package:sprout_mobile/src/theme/sprout_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('FUNC-REFRESH-01 Settings exposes honest manual refresh actions',
      (tester) async {
    await _pumpSettings(tester);

    final todayButton = find.byKey(const ValueKey('refresh-today-button'));
    await tester.scrollUntilVisible(
      todayButton,
      240,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();
    expect(find.text('CONTENT REFRESH'), findsOneWidget);
    expect(todayButton, findsOneWidget);
    expect(
        find.byKey(const ValueKey('refresh-insights-button')), findsOneWidget);

    await tester.tap(todayButton);
    await tester.pumpAndSettle();
    expect(
      find.text('Today re-read your saved entries. Online AI was not used.'),
      findsOneWidget,
    );

    final insightsButton =
        find.byKey(const ValueKey('refresh-insights-button'));
    await tester.ensureVisible(insightsButton);
    await tester.pumpAndSettle();
    await tester.tap(insightsButton);
    await tester.pumpAndSettle();
    expect(
      find.text('Insights rechecked saved data. Online AI was not used.'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('FUNC-REFRESH-02 refresh rows fit 360px at 1.3x text',
      (tester) async {
    await _pumpSettings(tester, textScale: 1.3);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('refresh-insights-button')),
      240,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}

Future<void> _pumpSettings(
  WidgetTester tester, {
  double textScale = 1,
}) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: buildSproutTheme(),
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: const SettingsScreen(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

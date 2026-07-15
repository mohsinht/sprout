import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprout_mobile/src/app/sprout_app.dart';
import 'package:sprout_mobile/src/app/theme_mode_controller.dart';
import 'package:sprout_mobile/src/domain/today_models.dart';
import 'package:sprout_mobile/src/presentation/add/quick_add_sheet.dart';
import 'package:sprout_mobile/src/presentation/onboarding/onboarding_screen.dart';
import 'package:sprout_mobile/src/presentation/shell/app_shell.dart';
import 'package:sprout_mobile/src/presentation/shell/nav_metrics.dart';
import 'package:sprout_mobile/src/presentation/today/today_controller.dart';
import 'package:sprout_mobile/src/presentation/today/today_screen.dart';
import 'package:sprout_mobile/src/theme/sprout_copy_guard.dart';
import 'package:sprout_mobile/src/theme/sprout_strings.dart';
import 'package:sprout_mobile/src/theme/sprout_theme.dart';
import 'package:sprout_mobile/src/widgets/sprout_mascot.dart';
import 'package:sprout_mobile/src/widgets/sprout_mascot_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('UX-C2-PKR-01 whole-rupee and lakh formatting', () {
    expect(SproutFormat.compactCurrency(0), 'PKR 0');
    expect(SproutFormat.compactCurrency(125000), 'PKR 1.3 lakh');
    expect(SproutFormat.currency(0), 'PKR 0');
  });

  test('UX-C1-TODAY-GREETING does not repeat the API salutation', () {
    expect(firstNameFromBriefingGreeting('Salaam, friend'), 'friend');
    expect(firstNameFromBriefingGreeting('Good morning, Ayesha'), 'Ayesha');
  });

  test('UX-S1-MONEY-01 empty financial copy rejects fabricated pace', () {
    expect(
      SproutCopyGuard.isHonestForEmptyFinancialState(
        'No budget picture yet — log income and spending to build one',
      ),
      isTrue,
    );
    expect(
      SproutCopyGuard.isHonestForEmptyFinancialState(
        'Looking comfortable. Nice pace.',
      ),
      isFalse,
    );
  });

  testWidgets('UX-P0-TODAY-13 renders exactly the locked 13 parts',
      (tester) async {
    final data = _zeroData();
    await _pumpToday(tester, data, height: 5200);

    final keys = [
      for (var i = 1; i <= 13; i++)
        find.byKey(ValueKey(
          'today-part-${i.toString().padLeft(2, '0')}-${[
            'greeting-streak',
            'mascot',
            'wealth',
            'movement',
            'read',
            'action',
            'whats-happening',
            'holdings',
            'depth-door',
            'why',
            'goals',
            'learn-later',
            'provenance',
          ][i - 1]}',
        )),
    ];
    for (final finder in keys) {
      expect(finder, findsOneWidget);
    }
    expect(find.byKey(const ValueKey('today-salary-strip')), findsNothing);
    expect(find.textContaining('Salary in'), findsNothing);
    expect(find.text('Add your first cash entry'), findsOneWidget);
    expect(find.text('No movement yet'), findsNWidgets(2));
    final landingMascot =
        tester.widget<SproutMascot>(find.byType(SproutMascot));
    expect(landingMascot.state, SproutMascotState.peek);
    expect(landingMascot.animate, isFalse);
    expect(landingMascot.playOnMount, isFalse);

    final tops = keys.map((finder) => tester.getTopLeft(finder).dy).toList();
    for (var i = 1; i < tops.length; i++) {
      expect(tops[i], greaterThanOrEqualTo(tops[i - 1]));
    }
  });

  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 1.3]) {
      final theme = brightness.name;
      final scaleName = scale.toStringAsFixed(1).replaceAll('.', 'x');
      testWidgets(
        'UX-L1-TODAY-ZERO golden $theme $scale',
        (tester) async {
          final data = _zeroData();
          await _pumpToday(
            tester,
            data,
            brightness: brightness,
            textScale: scale,
          );
          await expectLater(
            find.byType(TodayScreen),
            matchesGoldenFile(
              'goldens/UX-L1-TODAY-ZERO-$theme-$scaleName.png',
            ),
          );
        },
        tags: 'golden',
      );
    }
  }

  testWidgets('UX-L1-QUICK-VALIDATION save target never jumps', (tester) async {
    await _pumpQuickAdd(tester);
    await tester.tap(find.text('Open quick add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zakat'));
    await tester.pumpAndSettle();
    final save = find.text('Log Zakat');
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    final before = tester.getTopLeft(save).dy;
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(save).dy, before);
    expect(find.text('Add an amount to log this.'), findsOneWidget);
  });

  testWidgets('UX-A4-ONBOARDING visible actions have exact semantics',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSproutTheme(),
        home: const ProviderScope(child: OnboardingScreen()),
      ),
    );
    await tester.tap(find.bySemanticsLabel('Continue'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Continue'), findsOneWidget);
    expect(find.bySemanticsLabel('Just call me friend'), findsOneWidget);
    semantics.dispose();
  });

  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 1.3]) {
      for (final tab in ['Today', 'Money', 'Insights', 'Settings']) {
        final theme = brightness.name;
        final scaleName = scale.toStringAsFixed(1).replaceAll('.', 'x');
        testWidgets(
          'UX-L2-NAV-$tab golden clearance $theme $scale',
          (tester) async {
            await _pumpShell(
              tester,
              brightness: brightness,
              textScale: scale,
            );
            await tester.tap(find.text(tab).last);
            await tester.pumpAndSettle();
            await tester.scrollUntilVisible(
              find.byKey(const ValueKey('primary-tab-content-end')),
              700,
              scrollable: find.byType(Scrollable).first,
            );
            await tester.pump(const Duration(seconds: 3));

            final nav = tester.getRect(
              find.byKey(const ValueKey('floating-primary-nav')),
            );
            final end = tester.getRect(
              find.byKey(const ValueKey('primary-tab-content-end')),
            );
            expect(end.top, lessThanOrEqualTo(nav.top - NavMetrics.contentGap));
            await expectLater(
              find.byType(AppShell),
              matchesGoldenFile(
                'goldens/UX-L2-NAV-${tab.toLowerCase()}-$theme-$scaleName.png',
              ),
            );
            await tester.pumpWidget(const SizedBox.shrink());
            await tester.pump(const Duration(seconds: 2));
          },
          tags: 'golden',
        );
      }
    }
  }
}

TodayData _zeroData() {
  return TodayData(
    user: const SproutUser(firstName: 'friend', level: 1, xp: 0, dayStreak: 0),
    currency: 'PKR',
    salary: SalaryInfo(
      nextPayday: DateTime(2026, 7, 31),
      daysUntilSalary: 0,
      isKnown: false,
    ),
    health: const FinancialHealthScore(
      score: 0,
      status: 'insufficient_data',
      summary: 'Sprout is still getting to know your money.',
      positiveFactors: [],
      attentionFactors: [],
      scoreAvailable: false,
      scoreExplanation: 'Add one cash entry to begin.',
      recommendedAction: RecommendedAction(
        title: 'Add your first cash entry',
        xp: 0,
        impact: 'Start with money you can see',
        completionKind: 'logCash',
      ),
    ),
    autoCapture: const [],
    snapshot: const TodaySnapshot(
      availableCash: 0,
      monthSpent: 0,
      budgetRemaining: 0,
      upcomingBills: 0,
      unconfirmedTransactions: 0,
    ),
    quickActions: const [],
    wealthSnapshot: const WealthSnapshot(
      date: '2026-07-15',
      totalPkr: 0,
      holdings: [],
      changeVsYesterday: 0,
      changeMtd: 0,
      mainReason: 'No movement yet',
      interpretation: [],
      provenanceSummary: 'No money added yet',
    ),
    wealthEvents: const [],
    goals: const [],
    learnThreads: const [],
    provenanceSummary: 'No money added yet · manual entry is ready',
  );
}

Future<void> _pumpToday(
  WidgetTester tester,
  TodayData data, {
  Brightness brightness = Brightness.light,
  double textScale = 1,
  double height = 800,
}) async {
  tester.view.physicalSize = Size(360, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [todayControllerProvider.overrideWith((ref) async => data)],
      child: MaterialApp(
        theme: buildSproutTheme(brightness: brightness),
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(360, height),
            textScaler: TextScaler.linear(textScale),
            disableAnimations: true,
          ),
          child: const Scaffold(body: SafeArea(child: TodayScreen())),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 800));
}

Future<void> _pumpQuickAdd(WidgetTester tester) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
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

Future<void> _pumpShell(
  WidgetTester tester, {
  required Brightness brightness,
  required double textScale,
}) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: const Size(360, 800),
        textScaler: TextScaler.linear(textScale),
        disableAnimations: true,
      ),
      child: ProviderScope(
        overrides: [
          themeModeProvider.overrideWith(
            (ref) => brightness == Brightness.dark
                ? ThemeMode.dark
                : ThemeMode.light,
          ),
        ],
        child: const SproutApp(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(seconds: 2));
}

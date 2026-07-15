import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprout_mobile/src/app/sprout_app.dart';
import 'package:sprout_mobile/src/data/auth_store.dart';

const apiBase = String.fromEnvironment('API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8787');

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> waitFor(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (finder.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    if (finder.evaluate().isNotEmpty) return;
    final visibleText = tester
        .widgetList<Text>(find.byType(Text))
        .map((widget) => widget.data)
        .whereType<String>()
        .where((text) => text.trim().isNotEmpty)
        .take(20)
        .join(' | ');
    fail('Timed out waiting for $finder. Visible text: $visibleText');
  }

  setUpAll(() async {
    await binding.convertFlutterSurfaceToImage();
  });

  Future<ProviderContainer> startPersona(WidgetTester tester, String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    try {
      await const FlutterSecureStorage().deleteAll();
    } catch (_) {}
    final container = ProviderContainer();
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container, child: const SproutApp()));
    await waitFor(tester, find.text('Create an account'));
    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), id);
    await tester.enterText(fields.at(1),
        '${id.toLowerCase()}-${DateTime.now().microsecondsSinceEpoch}@device.sprout.test');
    await tester.enterText(fields.at(2), 'Persona!246810');
    await tester.tap(find.text('Create account'));
    await waitFor(tester, find.text("Hi, I'm Sprout."));
    expect(find.text("Hi, I'm Sprout."), findsOneWidget);
    await tester.tap(find.text('Skip for now'));
    final seeToday = find.byKey(const ValueKey('onboarding-see-today'));
    await waitFor(tester, seeToday);
    expect(find.text('See my Today'), findsOneWidget);
    await tester.tap(seeToday);
    await waitFor(tester, find.text('Today'));
    return container;
  }

  Future<Map<String, dynamic>> api(ProviderContainer container, String path,
      {String method = 'GET', Object? body}) async {
    final token = container.read(authSessionProvider)!.accessToken;
    final request = http.Request(method, Uri.parse('$apiBase$path'));
    request.headers.addAll(
        {'authorization': 'Bearer $token', 'content-type': 'application/json'});
    request.body = body == null ? '' : jsonEncode(body);
    final streamed = await request.send();
    final text = await streamed.stream.bytesToString();
    expect(streamed.statusCode, anyOf(200, 201));
    return text.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(text) as Map<String, dynamic>;
  }

  Future<void> shot(String name) async => binding.takeScreenshot(name);

  testWidgets('P1 empty-handed real UI', (tester) async {
    final container = await startPersona(tester, 'P1');
    addTearDown(container.dispose);
    expect(find.text('Today'), findsWidgets);
    await shot('P1-empty-today');
  });

  testWidgets('P2 salaried monthly real UI', (tester) async {
    final container = await startPersona(tester, 'P2');
    addTearDown(container.dispose);
    await api(container, '/v1/profile',
        method: 'PATCH', body: {'incomeType': 'salaried', 'salaryDate': 1});
    final goal = await api(container, '/v1/goals', method: 'POST', body: {
      'name': 'Payday goal',
      'type': 'custom',
      'targetAmount': 300000
    });
    for (final date in ['2026-04-01', '2026-05-01', '2026-06-01']) {
      await api(container, '/v1/goals/${goal['id']}/contribute',
          method: 'POST',
          body: {
            'amount': 10000,
            'source': 'manual',
            'contributionDate': date,
            'idempotencyKey': 'P2-$date-${goal['id']}'
          });
    }
    await api(container, '/v1/briefing/refresh',
        method: 'POST', body: {'contextChanged': true});
    await shot('P2-payday-today');
  });

  testWidgets('P3 cash-only first-class Today', (tester) async {
    final container = await startPersona(tester, 'P3');
    addTearDown(container.dispose);
    await api(container, '/v1/holdings', method: 'POST', body: {
      'kind': 'cash',
      'institution': 'Manual',
      'label': 'Cash',
      'currency': 'PKR',
      'valuePkr': 75000,
      'freshness': 'manual'
    });
    await api(container, '/v1/briefing/refresh',
        method: 'POST', body: {'contextChanged': true});
    await shot('P3-cash-only-today');
  });

  testWidgets('P4 wealth-down calm UI', (tester) async {
    final container = await startPersona(tester, 'P4');
    addTearDown(container.dispose);
    final holding = await api(container, '/v1/holdings', method: 'POST', body: {
      'kind': 'cash',
      'institution': 'Manual',
      'label': 'Cash',
      'currency': 'PKR',
      'valuePkr': 100000,
      'freshness': 'manual'
    });
    await api(container, '/v1/briefing/refresh',
        method: 'POST', body: {'contextChanged': true});
    await api(container, '/v1/holdings/${holding['id']}',
        method: 'PATCH', body: {'valuePkr': 90000});
    await api(container, '/v1/briefing/refresh',
        method: 'POST', body: {'contextChanged': true});
    await shot('P4-wealth-down-calm');
  });

  testWidgets('P5 fallback shell remains usable', (tester) async {
    final container = await startPersona(tester, 'P5');
    addTearDown(container.dispose);
    await tester.tap(find.text('Money').last);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Money'), findsWidgets);
    await shot('P5-money-usable');
  });

  testWidgets('P6 hidden balances across tabs', (tester) async {
    final container = await startPersona(tester, 'P6');
    addTearDown(container.dispose);
    await api(container, '/v1/profile',
        method: 'PATCH', body: {'hideBalances': true});
    for (final tab in ['Today', 'Money', 'Insights', 'Settings']) {
      await tester.tap(find.text(tab).last);
      await tester.pump(const Duration(seconds: 2));
      await shot('P6-hidden-${tab.toLowerCase()}');
    }
  });

  testWidgets('P7 multi-currency provenance and goal UI', (tester) async {
    final container = await startPersona(tester, 'P7');
    addTearDown(container.dispose);
    for (final currency in ['USD', 'EUR']) {
      await api(container, '/v1/holdings', method: 'POST', body: {
        'kind': 'cash',
        'institution': 'Wise',
        'label': 'Wise $currency',
        'currency': currency,
        'valueNative': 100,
        'valuePkr': 30000,
        'priceAsOf': '2026-07-10',
        'priceSource': 'Harness FX',
        'freshness': 'stale'
      });
    }
    await api(container, '/v1/goals', method: 'POST', body: {
      'name': 'Car',
      'type': 'car',
      'targetAmount': 2500000,
      'isPrimary': true
    });
    await api(container, '/v1/briefing/refresh',
        method: 'POST', body: {'contextChanged': true});
    await tester.tap(find.text('Money').last);
    await tester.pump(const Duration(seconds: 2));
    await shot('P7-multicurrency-money');
    await tester.tap(find.text('Insights').last);
    await tester.pump(const Duration(seconds: 2));
    await shot('P7-personal-insights');
  });
}

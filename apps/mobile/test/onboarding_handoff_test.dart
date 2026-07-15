import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprout_mobile/src/app/sprout_app.dart';
import 'package:sprout_mobile/src/data/api/sprout_api_client.dart';
import 'package:sprout_mobile/src/data/auth_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpUntil(
    WidgetTester tester,
    Finder finder, {
    int attempts = 40,
  }) async {
    for (var attempt = 0; attempt < attempts; attempt++) {
      if (finder.evaluate().isNotEmpty) return;
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('S1 onboarding keeps the celebration handoff before Today',
      (tester) async {
    SharedPreferences.setMockInitialValues({'auth.guest.v1': true});
    final client = SproutApiClient(
      baseUrl: 'https://onboarding.test',
      httpClient: MockClient((request) async {
        if (request.url.path == '/ready') {
          return http.Response(
            jsonEncode({'ok': true, 'database': 'ready'}),
            200,
          );
        }
        return http.Response('{}', 200);
      }),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(client),
          authSessionProvider.overrideWith(
            (ref) => AuthSessionStore.forTesting(
              client,
              const AuthSession(
                accessToken: '',
                refreshToken: '',
                userId: 'handoff-test',
                onboardingComplete: false,
                isGuest: true,
              ),
            ),
          ),
        ],
        child: const SproutApp(),
      ),
    );
    await pumpUntil(tester, find.text("Hi, I'm Sprout."));
    expect(find.text("Hi, I'm Sprout."), findsOneWidget);

    await tester.tap(find.text('Skip for now'));
    final handoff = find.byKey(const ValueKey('onboarding-see-today'));
    await pumpUntil(tester, handoff);
    expect(handoff, findsOneWidget);
    expect(find.text('See my Today'), findsOneWidget);
  });
}

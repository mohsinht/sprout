import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout_mobile/src/app/sprout_app.dart';
import 'package:sprout_mobile/src/data/api/sprout_api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget app(AuthSession? session) => ProviderScope(
    child: MaterialApp.router(routerConfig: buildSproutRouter(session)));

void main() {
  testWidgets('audit_a3_unauthenticated_redirects_to_auth', (tester) async {
    await tester.pumpWidget(app(null));
    await tester.pumpAndSettle();
    expect(find.text('Create an account'), findsOneWidget);
  });

  testWidgets('audit_a3_today_deeplink_redirects_to_onboarding',
      (tester) async {
    const session = AuthSession(
        accessToken: 'a',
        refreshToken: 'r',
        userId: 'u',
        onboardingComplete: false);
    final router = buildSproutRouter(session);
    router.go('/today');
    await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)));
    await tester.pumpAndSettle();
    expect(find.text("Hi, I'm Sprout."), findsOneWidget);
  });

  testWidgets('audit_b8_completed_skip_all_reaches_populated_today',
      (tester) async {
    const session = AuthSession(
        accessToken: 'a',
        refreshToken: 'r',
        userId: 'u',
        onboardingComplete: true);
    final router = buildSproutRouter(session);
    await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)));
    await tester.pumpAndSettle();
    expect(find.text('TOTAL WEALTH'), findsOneWidget);
  });
}

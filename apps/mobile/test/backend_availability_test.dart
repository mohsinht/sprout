import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprout_mobile/src/app/sprout_app.dart';
import 'package:sprout_mobile/src/data/api/sprout_api_client.dart';
import 'package:sprout_mobile/src/data/backend_availability.dart';

class _SequenceProbe implements BackendReadinessProbe {
  _SequenceProbe(this.values);
  final List<bool> values;
  var calls = 0;

  @override
  Future<bool> isReady() async => values[calls++];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('COLD-01 readiness probe requires API and database readiness', () async {
    final readyClient = SproutApiClient(
      baseUrl: 'https://sprout.test',
      httpClient: MockClient((request) async => http.Response(
            jsonEncode({'ok': true, 'database': 'ready'}),
            200,
          )),
    );
    final coldClient = SproutApiClient(
      baseUrl: 'https://sprout.test',
      httpClient: MockClient((request) async => http.Response(
            jsonEncode({'ok': false, 'database': 'unavailable'}),
            503,
          )),
    );

    expect(await readyClient.isBackendReady(), isTrue);
    expect(await coldClient.isBackendReady(), isFalse);
  });

  test('COLD-02 controller reports warming then recovery', () async {
    final probe = _SequenceProbe([false, true]);
    final controller = BackendAvailabilityController(
      probe,
      retryDelay: const Duration(milliseconds: 1),
      warmingWindow: const Duration(seconds: 1),
    );
    addTearDown(controller.dispose);

    await Future<void>.delayed(const Duration(milliseconds: 1));
    expect(controller.state, BackendAvailability.warming);
    await Future<void>.delayed(const Duration(milliseconds: 5));
    expect(controller.state, BackendAvailability.ready);
  });

  test('COLD-03 API exceptions never expose transport details to users', () {
    const error = SproutApiException(
      'Request failed for POST /v1/auth/login: SocketException',
    );
    expect(error.userMessage, contains('waking up'));
    expect(error.userMessage, isNot(contains('SocketException')));
  });

  testWidgets('COLD-04 warming toast is visible above the real app shell',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          backendAvailabilityProvider.overrideWith(
            (ref) => BackendAvailabilityController(
              _SequenceProbe([false]),
              retryDelay: const Duration(seconds: 10),
            ),
          ),
        ],
        child: MaterialApp(
          scaffoldMessengerKey: sproutMessengerKey,
          home: const BackendAvailabilityNotice(
            child: Scaffold(body: Text('Sprout')),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 20));
    expect(
      find.text('Sprout is waking up. Saved entries are still available.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('backend-warming-toast')), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sprout_mobile/src/data/api/sprout_api_client.dart';

void main() {
  late HttpServer server;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  });

  tearDown(() async {
    await server.close(force: true);
  });

  test('GET decodes a briefing response and sends auth', () async {
    server.listen((request) {
      expect(request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer test-token');
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'freshness': 'fresh'}))
        ..close();
    });

    final client = SproutApiClient(
      baseUrl: 'http://127.0.0.1:${server.port}',
      authToken: 'test-token',
    );
    final response = await client.get('/v1/briefing');

    expect(response['freshness'], 'fresh');
  });

  test('non-success responses throw instead of returning fallback data',
      () async {
    server.listen((request) {
      request.response
        ..statusCode = HttpStatus.serviceUnavailable
        ..close();
    });

    final client = SproutApiClient(
      baseUrl: 'http://127.0.0.1:${server.port}',
    );

    expect(
      () => client.get('/v1/briefing'),
      throwsA(isA<SproutApiException>()),
    );
  });

  test('non-object JSON throws a schema error', () async {
    server.listen((request) {
      request.response
        ..statusCode = HttpStatus.ok
        ..write(jsonEncode(['not', 'a', 'briefing']))
        ..close();
    });

    final client = SproutApiClient(
      baseUrl: 'http://127.0.0.1:${server.port}',
    );

    expect(
      () => client.get('/v1/briefing'),
      throwsA(isA<SproutApiException>()),
    );
  });

  test('FUNC-AUTH-02 expired refresh session notifies the app to sign out',
      () async {
    var invalidated = false;
    server.listen((request) {
      request.response
        ..statusCode = HttpStatus.unauthorized
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'error': 'Invalid or expired refresh token'}))
        ..close();
    });
    final client = SproutApiClient(
      baseUrl: 'http://127.0.0.1:${server.port}',
    );
    client.setDeviceIdentity('device-identity-123456', 'Test');
    client.setAuthSession(
      'expired-access',
      'expired-refresh',
      onInvalid: () async => invalidated = true,
    );

    await expectLater(
      client.get('/v1/briefing'),
      throwsA(isA<SproutApiException>()),
    );
    expect(invalidated, isTrue);
  });
}

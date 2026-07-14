import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// API client for the Sprout backend.
///
/// Base URL is configured via --dart-define=API_BASE_URL=...
/// Transport and response failures are thrown so the caller can render its
/// explicit unavailable/error state. Mock data is selected only through the
/// USE_MOCK build flag; it is never a silent network fallback.
final apiClientProvider = Provider<SproutApiClient>((ref) {
  const authToken = String.fromEnvironment('AUTH_TOKEN', defaultValue: '');
  return SproutApiClient(authToken: authToken.isEmpty ? null : authToken);
});

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
  });

  final String accessToken;
  final String refreshToken;
  final String userId;
}

class SproutApiClient {
  SproutApiClient({String? baseUrl, String? authToken})
      : _baseUrl = baseUrl ?? _defaultBaseUrl,
        _authToken = authToken;

  final String _baseUrl;
  String? _authToken;
  String? _refreshToken;
  String? _deviceId;
  String? _deviceName;
  Future<void> Function(String accessToken, String refreshToken)?
      _onSessionRefreshed;

  static String get _defaultBaseUrl {
    const url = String.fromEnvironment('API_BASE_URL',
        defaultValue: 'http://localhost:8787');
    return url;
  }

  void setAuthSession(
    String accessToken,
    String refreshToken, {
    Future<void> Function(String accessToken, String refreshToken)? onRefreshed,
  }) {
    _authToken = accessToken;
    _refreshToken = refreshToken;
    _onSessionRefreshed = onRefreshed;
  }

  void setDeviceIdentity(String deviceId, String deviceName) {
    _deviceId = deviceId;
    _deviceName = deviceName;
  }

  void setAuthToken(String token) => _authToken = token;
  void clearAuthToken() {
    _authToken = null;
    _refreshToken = null;
    _onSessionRefreshed = null;
  }

  Future<AuthSession> register(
      {required String email, required String password, String? name}) async {
    final deviceId = _requireDeviceId();
    final json = await post('/v1/auth/register', {
      'email': email.trim(),
      'password': password,
      if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
      'deviceId': deviceId,
      if (_deviceName != null) 'deviceName': _deviceName,
    });
    return _sessionFromJson(json);
  }

  Future<AuthSession> login(
      {required String email, required String password}) async {
    final deviceId = _requireDeviceId();
    final json = await post('/v1/auth/login', {
      'email': email.trim(),
      'password': password,
      'deviceId': deviceId,
      if (_deviceName != null) 'deviceName': _deviceName,
    });
    return _sessionFromJson(json);
  }

  Future<void> logout(String refreshToken) async {
    await post('/v1/auth/logout', {
      'refreshToken': refreshToken,
      'deviceId': _requireDeviceId(),
    });
  }

  String _requireDeviceId() {
    final id = _deviceId;
    if (id == null) {
      throw const SproutApiException('Device identity is unavailable');
    }
    return id;
  }

  AuthSession _sessionFromJson(Map<String, dynamic> json) {
    final accessToken = json['accessToken'] as String?;
    final refreshToken = json['refreshToken'] as String?;
    final userId = json['userId'] as String?;
    if (accessToken == null || refreshToken == null || userId == null) {
      throw const SproutApiException('Authentication response was incomplete');
    }
    return AuthSession(
        accessToken: accessToken, refreshToken: refreshToken, userId: userId);
  }

  /// Completes the small, personalization-only onboarding contract.
  ///
  /// This deliberately does not connect sources or collect income context.
  Future<Map<String, dynamic>?> completeOnboarding({
    String? name,
    String? goalName,
    String? goalType,
    int? targetAmount,
  }) {
    return post('/v1/profile/onboarding', {
      if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
      if (goalName != null && goalType != null && targetAmount != null)
        'goal': {
          'name': goalName,
          'type': goalType,
          'targetAmount': targetAmount,
        },
    });
  }

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  /// GET request. Throws [SproutApiException] on transport, status, or JSON
  /// shape failures so financial data cannot silently become mock data.
  Future<Map<String, dynamic>> get(String path) async {
    try {
      var res = await http
          .get(Uri.parse('$_baseUrl$path'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 401 && await _refreshSession()) {
        res = await http
            .get(Uri.parse('$_baseUrl$path'), headers: _headers)
            .timeout(const Duration(seconds: 10));
      }
      return _decodeResponse(path, res, expectedStatus: 200);
    } on SproutApiException {
      rethrow;
    } catch (error, stackTrace) {
      debugPrint('API GET $path failed: $error');
      Error.throwWithStackTrace(
        SproutApiException('Request failed for GET $path: $error'),
        stackTrace,
      );
    }
  }

  /// POST request. Throws [SproutApiException] on transport, status, or JSON
  /// shape failures.
  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      var res = await http
          .post(
            Uri.parse('$_baseUrl$path'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 401 &&
          path != '/v1/auth/refresh' &&
          await _refreshSession()) {
        res = await http
            .post(Uri.parse('$_baseUrl$path'),
                headers: _headers, body: jsonEncode(body))
            .timeout(const Duration(seconds: 15));
      }
      return _decodeResponse(path, res);
    } on SproutApiException {
      rethrow;
    } catch (error, stackTrace) {
      debugPrint('API POST $path failed: $error');
      Error.throwWithStackTrace(
        SproutApiException('Request failed for POST $path: $error'),
        stackTrace,
      );
    }
  }

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body) =>
      _send('PATCH', path, body: body);

  Future<Map<String, dynamic>> delete(String path) => _send('DELETE', path);

  Future<Map<String, dynamic>> _send(String method, String path,
      {Map<String, dynamic>? body}) async {
    try {
      var response = await _sendOnce(method, path, body);
      if (response.statusCode == 401 && await _refreshSession()) {
        response = await _sendOnce(method, path, body);
      }
      return _decodeResponse(path, response);
    } on SproutApiException {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
          SproutApiException('Request failed for $method $path: $error'),
          stackTrace);
    }
  }

  Future<http.Response> _sendOnce(
      String method, String path, Map<String, dynamic>? body) async {
    final request = http.Request(method, Uri.parse('$_baseUrl$path'));
    request.headers.addAll(_headers);
    if (body != null) request.body = jsonEncode(body);
    final streamed = await request.send().timeout(const Duration(seconds: 15));
    return http.Response.fromStream(streamed);
  }

  Future<bool> _refreshSession() async {
    final refreshToken = _refreshToken;
    if (refreshToken == null) return false;
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/v1/auth/refresh'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'refreshToken': refreshToken,
              'deviceId': _requireDeviceId(),
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return false;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return false;
      final access = decoded['accessToken'] as String?;
      final refresh = decoded['refreshToken'] as String?;
      if (access == null || refresh == null) return false;
      _authToken = access;
      _refreshToken = refresh;
      await _onSessionRefreshed?.call(access, refresh);
      return true;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> _decodeResponse(
    String path,
    http.Response response, {
    int? expectedStatus,
  }) {
    final statusIsValid = expectedStatus != null
        ? response.statusCode == expectedStatus
        : response.statusCode >= 200 && response.statusCode < 300;
    if (!statusIsValid) {
      throw SproutApiException(
        'API returned HTTP ${response.statusCode} for $path',
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw SproutApiException('API returned an invalid JSON object for $path');
    }
    return decoded;
  }
}

class SproutApiException implements Exception {
  const SproutApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

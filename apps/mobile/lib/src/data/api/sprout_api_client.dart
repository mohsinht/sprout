import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// API client for the Sprout backend.
///
/// Base URL is configured via --dart-define=API_BASE_URL=...
/// If the API is unreachable, methods return null so the UI falls back
/// to cached/mock data (per the failure/fallback spec).
final apiClientProvider = Provider<SproutApiClient>((ref) {
  return SproutApiClient();
});

class SproutApiClient {
  SproutApiClient({String? baseUrl, String? authToken})
      : _baseUrl = baseUrl ?? _defaultBaseUrl,
        _authToken = authToken;

  final String _baseUrl;
  String? _authToken;

  static String get _defaultBaseUrl {
    const url = String.fromEnvironment('API_BASE_URL',
        defaultValue: 'http://localhost:8787');
    return url;
  }

  void setAuthToken(String token) => _authToken = token;

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  /// GET request. Returns parsed JSON or null on failure.
  Future<Map<String, dynamic>?> get(String path) async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl$path'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) return null;
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('API GET $path failed: $e');
      return null;
    }
  }

  /// POST request. Returns parsed JSON or null on failure.
  Future<Map<String, dynamic>?> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl$path'),
        headers: _headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode < 200 || res.statusCode >= 300) return null;
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('API POST $path failed: $e');
      return null;
    }
  }
}
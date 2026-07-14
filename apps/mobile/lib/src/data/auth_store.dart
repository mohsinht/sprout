import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/sprout_api_client.dart';

final authSessionProvider =
    StateNotifierProvider<AuthSessionStore, AuthSession?>((ref) {
  return AuthSessionStore(ref.read(apiClientProvider));
});

class AuthSessionStore extends StateNotifier<AuthSession?> {
  AuthSessionStore(this._client) : super(null) {
    _restore();
  }

  static const _accessKey = 'auth.accessToken';
  static const _refreshKey = 'auth.refreshToken';
  static const _userIdKey = 'auth.userId';
  static const _secureStorage = FlutterSecureStorage();
  final SproutApiClient _client;

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    String? access;
    String? refresh;
    try {
      access = await _secureStorage.read(key: _accessKey);
      refresh = await _secureStorage.read(key: _refreshKey);
      // One-time migration from the pre-hardening SharedPreferences storage.
      access ??= prefs.getString(_accessKey);
      refresh ??= prefs.getString(_refreshKey);
      if (access != null && refresh != null) {
        await _writeTokens(access, refresh);
      }
    } catch (_) {
      if (!kReleaseMode) {
        access = prefs.getString(_accessKey);
        refresh = prefs.getString(_refreshKey);
      }
    }
    final userId = prefs.getString(_userIdKey);
    if (access != null && refresh != null && userId != null) {
      _client.setAuthSession(access, refresh, onRefreshed: _saveRefreshed);
      state = AuthSession(
          accessToken: access, refreshToken: refresh, userId: userId);
    }
  }

  Future<void> register(
      {required String email, required String password, String? name}) async {
    final result =
        await _client.register(email: email, password: password, name: name);
    await _save(result);
  }

  Future<void> login({required String email, required String password}) async {
    final result = await _client.login(email: email, password: password);
    await _save(result);
  }

  Future<void> _save(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await _writeTokens(session.accessToken, session.refreshToken);
    await prefs.setString(_userIdKey, session.userId);
    _client.setAuthSession(
      session.accessToken,
      session.refreshToken,
      onRefreshed: _saveRefreshed,
    );
    state = session;
  }

  Future<void> _saveRefreshed(String accessToken, String refreshToken) async {
    final current = state;
    if (current == null) return;
    final refreshed = AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: current.userId,
    );
    await _writeTokens(accessToken, refreshToken);
    state = refreshed;
  }

  Future<void> logout() async {
    final session = state;
    if (session != null) {
      try {
        await _client.logout(session.refreshToken);
      } catch (_) {
        // Local sign-out must remain available while offline or expired.
      }
    }
    final prefs = await SharedPreferences.getInstance();
    try {
      await _secureStorage.delete(key: _accessKey);
      await _secureStorage.delete(key: _refreshKey);
    } catch (_) {}
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
    await prefs.remove(_userIdKey);
    _client.clearAuthToken();
    state = null;
  }

  Future<void> _writeTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await _secureStorage.write(key: _accessKey, value: accessToken);
      await _secureStorage.write(key: _refreshKey, value: refreshToken);
      await prefs.remove(_accessKey);
      await prefs.remove(_refreshKey);
    } catch (_) {
      if (kReleaseMode) rethrow;
      // Desktop/web debug harnesses may not expose the native keychain plugin.
      await prefs.setString(_accessKey, accessToken);
      await prefs.setString(_refreshKey, refreshToken);
    }
  }
}

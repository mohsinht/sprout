import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appLockProvider =
    StateNotifierProvider<AppLockStore, AppLockState>((ref) => AppLockStore());

class AppLockState {
  const AppLockState({
    this.enabled = false,
    this.supported = false,
    this.locked = false,
    this.busy = false,
  });

  final bool enabled;
  final bool supported;
  final bool locked;
  final bool busy;

  AppLockState copyWith({
    bool? enabled,
    bool? supported,
    bool? locked,
    bool? busy,
  }) =>
      AppLockState(
        enabled: enabled ?? this.enabled,
        supported: supported ?? this.supported,
        locked: locked ?? this.locked,
        busy: busy ?? this.busy,
      );
}

class AppLockStore extends StateNotifier<AppLockState> {
  AppLockStore() : super(const AppLockState()) {
    _initialize();
  }

  static const _enabledKey = 'security.biometricLock.v1';
  final LocalAuthentication _auth = LocalAuthentication();

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_enabledKey) ?? false;
    var supported = false;
    if (!kIsWeb) {
      try {
        supported =
            await _auth.isDeviceSupported() || await _auth.canCheckBiometrics;
      } catch (_) {}
    }
    state = AppLockState(
      enabled: enabled && supported,
      supported: supported,
      locked: enabled && supported,
    );
  }

  Future<bool> enable() async {
    if (!state.supported) return false;
    final authenticated = await _authenticate();
    if (!authenticated) return false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, true);
    state = state.copyWith(enabled: true, locked: false, busy: false);
    return true;
  }

  Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, false);
    state = state.copyWith(enabled: false, locked: false, busy: false);
  }

  void lock() {
    if (state.enabled) state = state.copyWith(locked: true);
  }

  Future<bool> unlock() async {
    if (!state.enabled) return true;
    final authenticated = await _authenticate();
    state = state.copyWith(locked: !authenticated, busy: false);
    return authenticated;
  }

  Future<bool> _authenticate() async {
    if (state.busy) return false;
    state = state.copyWith(busy: true);
    try {
      return await _auth.authenticate(
        localizedReason: 'Unlock your private Sprout money picture',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    } finally {
      if (mounted) state = state.copyWith(busy: false);
    }
  }
}

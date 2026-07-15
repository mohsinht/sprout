import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/sprout_api_client.dart';
import 'auth_store.dart';

final balancesVisibleProvider =
    StateNotifierProvider<BalancePrivacyStore, bool>((ref) {
  final store = BalancePrivacyStore(ref);
  ref.listen(authSessionProvider, (_, session) {
    if (session != null && !session.isGuest) store.refreshFromProfile();
  });
  return store;
});

class BalancePrivacyStore extends StateNotifier<bool> {
  BalancePrivacyStore(this._ref) : super(true) {
    _restore();
  }

  static const _key = 'privacy.balancesVisible.v1';
  final Ref _ref;

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? true;
    if (_hasRemoteSession) await refreshFromProfile();
  }

  Future<void> refreshFromProfile() async {
    try {
      final profile = await _ref.read(apiClientProvider).get('/v1/profile');
      state = !(profile['hideBalances'] as bool? ?? false);
      await _persist();
    } catch (_) {}
  }

  Future<void> setVisible(bool visible) async {
    state = visible;
    await _persist();
    if (!_hasRemoteSession) return;
    try {
      await _ref
          .read(apiClientProvider)
          .patch('/v1/profile', {'hideBalances': !visible});
    } catch (_) {
      // The local privacy choice remains effective while offline.
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, state);
  }

  bool get _hasRemoteSession {
    final session = _ref.read(authSessionProvider);
    return session != null && !session.isGuest;
  }
}

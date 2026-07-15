import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final reduceMotionProvider = StateNotifierProvider<ReduceMotionStore, bool>(
    (ref) => ReduceMotionStore());

class ReduceMotionStore extends StateNotifier<bool> {
  ReduceMotionStore() : super(false) {
    _restore();
  }

  static const _key = 'accessibility.reduceMotion.v1';

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, enabled);
  }
}

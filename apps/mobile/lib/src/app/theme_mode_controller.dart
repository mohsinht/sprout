import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// User-selectable theme mode preference for Sprout.
///
/// Persists in-memory for now; swap to `SharedPreferences` when persistence
/// is wired up. Defaults to light so the app opens in the calmer daytime theme.
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.light;
});

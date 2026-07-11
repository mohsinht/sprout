import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/goal_store.dart';
import '../../data/context_refresh.dart';
import '../../data/http_today_repository.dart';
import '../../domain/today_models.dart';

/// Builds Today's data. Watches [goalStoreProvider] so that goal edits
/// (add/edit/complete/delete/reorder from Settings or Money) are reflected
/// in the next briefing's goal tiles and recommended action. Goals are the
/// input the AI uses — editing a goal changes the next recommendation.
final todayControllerProvider = FutureProvider<TodayData>((ref) async {
  ref.watch(briefingRevisionProvider);
  final storeGoals = ref.watch(goalStoreProvider);
  final base = await ref.watch(todayRepositoryProvider).fetchToday();
  const useMock = bool.fromEnvironment('USE_MOCK', defaultValue: true);

  // If the user has managed goals in the store, use those instead of the
  // mock briefing goals. This makes the "goals drive the AI" connection
  // real: edits in Settings/Money appear on Today immediately.
  if (storeGoals.isNotEmpty || !useMock) {
    return base.copyWith(goals: storeGoals);
  }
  return base;
});

/// Session state for today's completed ritual.
///
/// This intentionally lives beside the Today controller so the completion
/// survives screen rebuilds and tab navigation until real local persistence is
/// introduced.
final todayQuestCompletedProvider = StateProvider<bool>((ref) => false);

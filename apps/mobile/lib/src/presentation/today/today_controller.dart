import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock_today_repository.dart';
import '../../domain/today_models.dart';

final todayControllerProvider = FutureProvider<TodayData>((ref) {
  return ref.watch(todayRepositoryProvider).fetchToday();
});

/// Session state for today's completed ritual.
///
/// This intentionally lives beside the Today controller so the completion
/// survives screen rebuilds and tab navigation until real local persistence is
/// introduced.
final todayQuestCompletedProvider = StateProvider<bool>((ref) => false);

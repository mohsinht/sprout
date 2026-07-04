import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock_today_repository.dart';
import '../../domain/today_models.dart';

final todayControllerProvider = FutureProvider<TodayData>((ref) {
  return ref.watch(todayRepositoryProvider).fetchToday();
});

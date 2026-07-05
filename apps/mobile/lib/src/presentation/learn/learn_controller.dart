import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock_learn_repository.dart';
import '../../domain/learn_models.dart';

/// Loads Learn data through the repository boundary used by the future API client.
final learnControllerProvider = FutureProvider<LearnData>((ref) {
  return ref.watch(learnRepositoryProvider).fetchLearn();
});

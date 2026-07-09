import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/today_models.dart';

/// In-memory goal store. In production this persists locally and syncs.
/// Goals drive the AI's recommended action — editing a goal changes the
/// next briefing's recommendation.
///
/// Regression invariant: goals are never write-once. A user can always
/// add, edit, contribute to, complete, delete, and reorder goals.

final goalStoreProvider = StateNotifierProvider<GoalStore, List<Goal>>((ref) {
  return GoalStore();
});

class GoalStore extends StateNotifier<List<Goal>> {
  GoalStore()
      : super([
          const Goal(
            id: 'car',
            name: 'Car fund',
            type: 'car',
            targetAmount: 2500000,
            currentAmount: 2300000,
            status: 'active',
            pace: 'on_track',
            nextStep: 'Add PKR 25k to car fund',
            remainingToTarget: 200000,
            paceNote: 'Only PKR 2 lakh to go — closest goal.',
            isPrimary: true,
          ),
          const Goal(
            id: 'emergency',
            name: 'Emergency fund',
            type: 'emergency',
            targetAmount: 1500000,
            currentAmount: 1500000,
            status: 'complete',
            pace: 'ahead',
            nextStep: 'Fully funded. Doing its job.',
            remainingToTarget: 0,
            paceNote: '6 months of cover. Doing its job.',
          ),
        ]);

  /// Add a new goal.
  void add(Goal goal) {
    state = [...state, goal];
  }

  /// Update an existing goal by ID.
  void update(String id, Goal updated) {
    state = [
      for (final g in state)
        if (g.id == id) updated else g,
    ];
  }

  /// Contribute to a goal (increase currentAmount).
  void contribute(String id, int amount) {
    state = [
      for (final g in state)
        if (g.id == id)
          g.copyWith(
            currentAmount: g.currentAmount + amount,
            remainingToTarget:
                (g.targetAmount - (g.currentAmount + amount)).clamp(0, 999999999),
            status: (g.currentAmount + amount) >= g.targetAmount
                ? 'complete'
                : g.status,
          )
        else
          g,
    ];
  }

  /// Mark a goal as complete.
  void complete(String id) {
    state = [
      for (final g in state)
        if (g.id == id)
          g.copyWith(
            status: 'complete',
            currentAmount: g.targetAmount,
            remainingToTarget: 0,
          )
        else
          g,
    ];
  }

  /// Delete a goal by ID.
  void delete(String id) {
    state = state.where((g) => g.id != id).toList();
  }

  /// Set a goal as the primary (hero) goal. Only one primary at a time.
  void setPrimary(String id) {
    state = [
      for (final g in state)
        g.copyWith(isPrimary: g.id == id),
    ];
  }

  /// Reorder goals (move a goal to a new index).
  void reorder(int oldIndex, int newIndex) {
    final goals = [...state];
    final goal = goals.removeAt(oldIndex);
    goals.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, goal);
    state = goals;
  }

  /// Get the primary goal, or the closest active goal if none is marked.
  Goal? get primaryGoal {
    final primary = state.where((g) => g.isPrimary && g.status == 'active');
    if (primary.isNotEmpty) return primary.first;
    final active = state.where((g) => g.status == 'active');
    if (active.isEmpty) return null;
    // Closest = most progress (highest currentAmount / targetAmount ratio).
    return active.reduce((a, b) {
      final aRatio = a.targetAmount > 0
          ? a.currentAmount / a.targetAmount
          : 0.0;
      final bRatio = b.targetAmount > 0
          ? b.currentAmount / b.targetAmount
          : 0.0;
      return aRatio >= bRatio ? a : b;
    });
  }
}
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/today_models.dart';
import 'api/sprout_api_client.dart';
import 'auth_store.dart';
import 'context_refresh.dart';

final goalStoreProvider = StateNotifierProvider<GoalStore, List<Goal>>((ref) {
  final store = GoalStore(ref);
  ref.listen(authSessionProvider, (_, session) {
    if (session != null) store.syncFromServer();
  });
  return store;
});

class GoalStore extends StateNotifier<List<Goal>> {
  GoalStore(this._ref) : super(_mockInitial) {
    _restore();
  }

  static const _storageKey = 'goals.local.v1';
  static const _useMock = bool.fromEnvironment('USE_MOCK', defaultValue: true);
  final Ref _ref;

  static final List<Goal> _mockInitial = _useMock
      ? const [
          Goal(
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
              isPrimary: true),
          Goal(
              id: 'emergency',
              name: 'Emergency fund',
              type: 'emergency',
              targetAmount: 1500000,
              currentAmount: 1500000,
              status: 'complete',
              pace: 'ahead',
              nextStep: 'Fully funded. Doing its job.',
              remainingToTarget: 0,
              paceNote: '6 months of cover. Doing its job.'),
        ]
      : const [];

  Future<void> _restore() async {
    if (_useMock) return;
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_storageKey);
    if (encoded != null) {
      try {
        state = (jsonDecode(encoded) as List)
            .map((item) => _fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {
        state = const [];
      }
    }
    if (_ref.read(authSessionProvider) != null) await syncFromServer();
  }

  Future<void> _persist() async {
    if (_useMock) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(state.map(_toJson).toList()));
  }

  Future<void> syncFromServer() async {
    if (_useMock || _ref.read(authSessionProvider) == null) return;
    try {
      final response = await _ref.read(apiClientProvider).get('/v1/goals');
      final remote = (response['goals'] as List? ?? const [])
          .map((item) => _fromJson(item as Map<String, dynamic>))
          .toList();
      state = remote;
      await _persist();
    } catch (_) {
      // The local copy remains usable offline.
    }
  }

  Future<void> add(Goal goal) async {
    if (goal.isPrimary) {
      state = [for (final g in state) g.copyWith(isPrimary: false)];
    }
    state = [...state, goal];
    await _persist();
    if (_useMock || _ref.read(authSessionProvider) == null) return;
    try {
      final created = await _ref.read(apiClientProvider).post('/v1/goals', {
        'name': goal.name,
        'type': goal.type,
        'targetAmount': goal.targetAmount,
        'currentAmount': goal.currentAmount,
        'isPrimary': goal.isPrimary,
      });
      state = [
        for (final g in state)
          if (g.id == goal.id) _fromJson(created) else g
      ];
      await _persist();
      _refreshBriefing();
    } catch (_) {}
  }

  Future<void> update(String id, Goal updated) async {
    if (updated.isPrimary) {
      state = [for (final g in state) g.copyWith(isPrimary: g.id == id)];
    }
    state = [
      for (final g in state)
        if (g.id == id) updated else g
    ];
    await _persist();
    await _remotePatch(id, {
      'name': updated.name,
      'targetAmount': updated.targetAmount,
      'currentAmount': updated.currentAmount,
      'status': updated.status,
      'isPrimary': updated.isPrimary
    });
  }

  Future<void> contribute(String id, int amount) async {
    state = [
      for (final g in state)
        if (g.id == id) _withAmount(g, g.currentAmount + amount) else g
    ];
    await _persist();
    if (!_isRemoteId(id)) return;
    try {
      final updated = await _ref
          .read(apiClientProvider)
          .post('/v1/goals/$id/contribute', {'amount': amount});
      state = [
        for (final g in state)
          if (g.id == id) _fromJson(updated) else g
      ];
      await _persist();
      _refreshBriefing();
    } catch (_) {}
  }

  Future<void> complete(String id) async {
    final goal = state.where((g) => g.id == id).firstOrNull;
    if (goal == null) return;
    final completed =
        _withAmount(goal, goal.targetAmount).copyWith(status: 'complete');
    await update(id, completed);
  }

  Future<void> delete(String id) async {
    state = state.where((g) => g.id != id).toList();
    await _persist();
    if (!_isRemoteId(id)) return;
    try {
      await _ref.read(apiClientProvider).delete('/v1/goals/$id');
      _refreshBriefing();
    } catch (_) {}
  }

  Future<void> setPrimary(String id) async {
    state = [for (final g in state) g.copyWith(isPrimary: g.id == id)];
    await _persist();
    await _remotePatch(id, {'isPrimary': true});
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final goals = [...state];
    final goal = goals.removeAt(oldIndex);
    goals.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, goal);
    state = goals;
    await _persist();
    final ids = goals.where((g) => _isRemoteId(g.id)).map((g) => g.id).toList();
    if (ids.length != goals.length) return;
    try {
      await _ref
          .read(apiClientProvider)
          .post('/v1/goals/reorder', {'ids': ids});
    } catch (_) {}
  }

  Future<void> _remotePatch(String id, Map<String, dynamic> body) async {
    if (!_isRemoteId(id)) return;
    try {
      final updated =
          await _ref.read(apiClientProvider).patch('/v1/goals/$id', body);
      state = [
        for (final g in state)
          if (g.id == id) _fromJson(updated) else g
      ];
      await _persist();
      _refreshBriefing();
    } catch (_) {}
  }

  Future<void> _refreshBriefing() async {
    try {
      await _ref
          .read(apiClientProvider)
          .post('/v1/briefing/refresh', {'contextChanged': true});
      _ref.read(briefingRevisionProvider.notifier).state++;
    } catch (_) {}
  }

  bool _isRemoteId(String id) =>
      RegExp(r'^[0-9a-f-]{36}$').hasMatch(id) &&
      _ref.read(authSessionProvider) != null;

  Goal _withAmount(Goal g, int amount) {
    final current = amount.clamp(0, g.targetAmount);
    return g.copyWith(
        currentAmount: current,
        remainingToTarget: (g.targetAmount - current).clamp(0, 999999999),
        status: current >= g.targetAmount ? 'complete' : g.status);
  }

  Goal? get primaryGoal {
    final primary = state.where((g) => g.isPrimary && g.status == 'active');
    if (primary.isNotEmpty) return primary.first;
    final active = state.where((g) => g.status == 'active');
    if (active.isEmpty) return null;
    return active.reduce((a, b) => a.targetAmount > 0 &&
            b.targetAmount > 0 &&
            a.currentAmount / a.targetAmount >= b.currentAmount / b.targetAmount
        ? a
        : b);
  }

  static Goal _fromJson(Map<String, dynamic> json) {
    final target = (json['targetAmount'] as num?)?.toInt() ?? 0;
    final current = (json['currentAmount'] as num?)?.toInt() ?? 0;
    final remaining = (target - current).clamp(0, 999999999);
    return Goal(
        id: json['id'] as String,
        name: json['name'] as String,
        type: json['type'] as String? ?? 'custom',
        targetAmount: target,
        currentAmount: current,
        status: json['status'] as String? ?? 'active',
        pace: 'on_track',
        nextStep: remaining == 0 ? 'Goal complete.' : 'Add to ${json['name']}',
        remainingToTarget: remaining,
        paceNote: remaining == 0 ? 'Target reached.' : 'PKR $remaining to go.',
        deadline: json['deadline'] as String?,
        isPrimary: json['isPrimary'] as bool? ?? false);
  }

  static Map<String, dynamic> _toJson(Goal g) => {
        'id': g.id,
        'name': g.name,
        'type': g.type,
        'targetAmount': g.targetAmount,
        'currentAmount': g.currentAmount,
        'status': g.status,
        'deadline': g.deadline,
        'isPrimary': g.isPrimary
      };
}

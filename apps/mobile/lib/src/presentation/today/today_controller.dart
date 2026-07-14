import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/goal_store.dart';
import '../../data/context_refresh.dart';
import '../../data/http_today_repository.dart';
import '../../data/manual_money_store.dart';
import '../../domain/sprout_models.dart';
import '../../domain/today_models.dart';

/// Builds Today's data. Watches [goalStoreProvider] so that goal edits
/// (add/edit/complete/delete/reorder from Settings or Money) are reflected
/// in the next briefing's goal tiles and recommended action. Goals are the
/// input the AI uses — editing a goal changes the next recommendation.
final todayControllerProvider = FutureProvider<TodayData>((ref) async {
  ref.watch(briefingRevisionProvider);
  final storeGoals = ref.watch(goalStoreProvider);
  TodayData base;
  try {
    base = await ref.watch(todayRepositoryProvider).fetchToday();
  } catch (_) {
    base = _localToday(
      accounts: ref.watch(accountsProvider),
      transactions: ref.watch(manualTransactionsProvider),
      goals: storeGoals,
    );
  }
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
final todayQuestCompletedProvider =
    StateNotifierProvider<TodayQuestCompletion, bool>(
        (ref) => TodayQuestCompletion());

class TodayQuestCompletion extends StateNotifier<bool> {
  TodayQuestCompletion() : super(false);

  String? _activeKey;

  Future<void> load(RecommendedAction action) async {
    final key = _key(action);
    if (_activeKey == key) return;
    _activeKey = key;
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(key) ?? false;
  }

  Future<void> complete(RecommendedAction action) async {
    final key = _key(action);
    _activeKey = key;
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, true);
  }

  String _key(RecommendedAction action) {
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return 'today.completed.$date.${action.targetId ?? action.title}';
  }
}

TodayData _localToday({
  required List<SproutAccount> accounts,
  required List<SproutTransaction> transactions,
  required List<Goal> goals,
}) {
  final now = DateTime.now();
  final date = now.toIso8601String().substring(0, 10);
  final total = accounts.fold<int>(0, (sum, account) => sum + account.balance);
  bool sameDay(DateTime value) =>
      value.year == now.year &&
      value.month == now.month &&
      value.day == now.day;
  bool sameMonth(DateTime value) =>
      value.year == now.year && value.month == now.month;
  int movement(Iterable<SproutTransaction> rows) => rows.fold<int>(
      0,
      (sum, tx) =>
          sum + (tx.type == TransactionType.income ? tx.amount : -tx.amount));
  final todayMovement = movement(transactions.where((tx) => sameDay(tx.date)));
  final monthMovement =
      movement(transactions.where((tx) => sameMonth(tx.date)));
  final active = goals.where((goal) => goal.status == 'active').firstOrNull;
  final action = active == null
      ? const RecommendedAction(
          title: 'Add your first goal',
          xp: 0,
          impact: 'A goal gives Sprout context for future suggestions.')
      : RecommendedAction(
          title: 'Add PKR 25k to ${active.name}',
          xp: 0,
          impact: 'This updates your chosen goal only after you confirm.',
          completionKind: 'contributeToGoal',
          targetId: active.id);
  final holdings = accounts
      .map((account) => Holding(
            id: account.id,
            kind: account.type == AccountType.investment
                ? HoldingKind.mutualFund
                : HoldingKind.cash,
            institution: account.name,
            label: account.name,
            currency: account.currency,
            valuePkr: account.balance,
            valueNative: account.balance,
            priceAsOf: date,
            priceSource: 'Manual entry on this device',
            freshness: 'manual',
          ))
      .toList();
  return TodayData(
    user: const SproutUser(firstName: 'friend', level: 1, xp: 0, dayStreak: 0),
    currency: 'PKR',
    salary: SalaryInfo(nextPayday: now, daysUntilSalary: 0, isKnown: false),
    health: FinancialHealthScore(
      score: 0,
      status: 'unavailable',
      summary:
          'You are offline. This picture uses entries saved on this device.',
      positiveFactors: const [],
      attentionFactors: const [],
      recommendedAction: action,
    ),
    autoCapture: const [],
    snapshot: TodaySnapshot(
      availableCash: total,
      monthSpent: transactions
          .where(
              (tx) => sameMonth(tx.date) && tx.type == TransactionType.expense)
          .fold(0, (sum, tx) => sum + tx.amount),
      budgetRemaining: monthMovement,
      upcomingBills: 0,
      unconfirmedTransactions: 0,
    ),
    quickActions: const [],
    wealthSnapshot: WealthSnapshot(
      date: date,
      totalPkr: total,
      holdings: holdings,
      changeVsYesterday: todayMovement,
      changeMtd: monthMovement,
      mainReason: 'Manual activity saved on this device',
      interpretation: const [
        'Live valuation and server analysis are unavailable while offline.'
      ],
      provenanceSummary:
          'Manual entries saved on this device. Waiting to sync.',
    ),
    wealthEvents: const [],
    goals: goals,
    learnThreads: const [],
    provenanceSummary: 'Manual entries saved on this device. Waiting to sync.',
  );
}

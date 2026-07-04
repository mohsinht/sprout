import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/today_models.dart';

final todayRepositoryProvider = Provider<TodayRepository>((ref) {
  return MockTodayRepository();
});

abstract interface class TodayRepository {
  Future<TodayData> fetchToday();
}

class MockTodayRepository implements TodayRepository {
  @override
  Future<TodayData> fetchToday() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return TodayData(
      user: const SproutUser(
        firstName: 'Mohsin',
        level: 6,
        xp: 1840,
        dayStreak: 12,
      ),
      currency: 'PKR',
      salary: SalaryInfo(
        nextPayday: DateTime(2026, 7, 6),
        daysUntilSalary: 3,
      ),
      health: const FinancialHealthScore(
        score: 78,
        status: 'healthy',
        summary: "You are on track, but today's spending is slightly fast.",
        positiveFactors: [
          'Emergency buffer is strong',
          'Salary lands in 3 days',
          'Al Meezan NAV updated yesterday',
        ],
        attentionFactors: [
          'Spending pace is slightly high',
          '3 transactions need confirmation',
        ],
        recommendedAction: RecommendedAction(
          title: 'Move PKR 10,000 to Emergency Fund',
          xp: 20,
          impact: '+3 health score',
        ),
      ),
      autoCapture: const [
        AutoCaptureSource(
          label: 'Gmail connected',
          status: 'connected',
          detail: 'Finance senders only',
        ),
        AutoCaptureSource(
          label: 'Meezan alerts detected',
          status: 'detected',
          detail: '2 alerts today',
        ),
        AutoCaptureSource(
          label: 'Wise balance imported',
          status: 'imported',
          detail: 'USD and EUR balances',
        ),
        AutoCaptureSource(
          label: 'Al Meezan NAV updated',
          status: 'updated',
          detail: 'Updated yesterday',
        ),
        AutoCaptureSource(
          label: '3 transactions need confirmation',
          status: 'needs_review',
          detail: 'Tap to review',
        ),
      ],
      snapshot: const TodaySnapshot(
        availableCash: 168500,
        monthSpent: 216400,
        budgetRemaining: 83500,
        upcomingBills: 42000,
        unconfirmedTransactions: 3,
      ),
      quickActions: const [
        'Chai',
        'Fuel',
        'Groceries',
        'IBFT',
        'Utility Bill',
        'JazzCash',
        'Easypaisa',
        'Al Meezan Top-up',
        'Wise Transfer',
      ],
    );
  }
}

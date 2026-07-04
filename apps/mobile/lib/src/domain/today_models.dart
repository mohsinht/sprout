class TodayData {
  const TodayData({
    required this.user,
    required this.currency,
    required this.salary,
    required this.health,
    required this.autoCapture,
    required this.snapshot,
    required this.quickActions,
  });

  final SproutUser user;
  final String currency;
  final SalaryInfo salary;
  final FinancialHealthScore health;
  final List<AutoCaptureSource> autoCapture;
  final TodaySnapshot snapshot;
  final List<String> quickActions;
}

class SproutUser {
  const SproutUser({
    required this.firstName,
    required this.level,
    required this.xp,
    required this.dayStreak,
  });

  final String firstName;
  final int level;
  final int xp;
  final int dayStreak;
}

class SalaryInfo {
  const SalaryInfo({required this.nextPayday, required this.daysUntilSalary});

  final DateTime nextPayday;
  final int daysUntilSalary;
}

class FinancialHealthScore {
  const FinancialHealthScore({
    required this.score,
    required this.status,
    required this.summary,
    required this.positiveFactors,
    required this.attentionFactors,
    required this.recommendedAction,
  });

  final int score;
  final String status;
  final String summary;
  final List<String> positiveFactors;
  final List<String> attentionFactors;
  final RecommendedAction recommendedAction;
}

class RecommendedAction {
  const RecommendedAction({
    required this.title,
    required this.xp,
    required this.impact,
  });

  final String title;
  final int xp;
  final String impact;
}

class AutoCaptureSource {
  const AutoCaptureSource({
    required this.label,
    required this.status,
    required this.detail,
  });

  final String label;
  final String status;
  final String detail;
}

class TodaySnapshot {
  const TodaySnapshot({
    required this.availableCash,
    required this.monthSpent,
    required this.budgetRemaining,
    required this.upcomingBills,
    required this.unconfirmedTransactions,
  });

  final int availableCash;
  final int monthSpent;
  final int budgetRemaining;
  final int upcomingBills;
  final int unconfirmedTransactions;
}

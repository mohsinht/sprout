/// Domain models for the parts of Sprout outside the Today screen.
///
/// Today has its own models in `today_models.dart` and is finalised
/// separately. These models back the Add, Money, Learn and Settings
/// screens. Money is stored as `int` in minor units (PKR) to avoid
/// floating-point drift in a financial app.
library;

enum TransactionType { expense, income, transfer }

enum TransactionSource { manual, email, statement, sms }

enum AccountType { cash, bank, wallet, wise, investment, other }

enum GoalStatus { active, complete, paused }

/// A single money movement. May come from manual entry, email parsing,
/// a statement import, or SMS detection. `needsReview` is true when the
/// source is uncertain and the user must confirm before it counts.
class SproutTransaction {
  const SproutTransaction({
    required this.id,
    required this.amount,
    required this.currency,
    required this.type,
    required this.category,
    required this.merchant,
    required this.note,
    required this.date,
    required this.source,
    required this.needsReview,
    this.confidence,
    this.accountId,
  });

  final String id;
  final int amount;
  final String currency;
  final TransactionType type;
  final String category;
  final String merchant;
  final String note;
  final DateTime date;
  final TransactionSource source;
  final bool needsReview;
  final double? confidence;
  final String? accountId;
}

/// A money bucket the user tracks: cash, a bank, a wallet, Wise, an
/// investment, or something else. `isManual` is true for buckets the
/// user maintains by hand (the default, since Sprout works with zero
/// connected accounts).
class SproutAccount {
  const SproutAccount({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
    required this.lastUpdatedLabel,
    required this.isManual,
  });

  final String id;
  final String name;
  final AccountType type;
  final int balance;
  final String currency;
  final String lastUpdatedLabel;
  final bool isManual;
}

/// A savings goal with a target, current progress, and one tiny next step.
class SproutGoal {
  const SproutGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.currency,
    required this.deadline,
    required this.status,
    required this.nextStep,
  });

  final String id;
  final String name;
  final int targetAmount;
  final int currentAmount;
  final String currency;
  final DateTime? deadline;
  final GoalStatus status;
  final String nextStep;
}

/// A simple monthly budget. No category breakdown — just one calm
/// progress bar showing safe-to-spend vs spent.
class SproutBudget {
  const SproutBudget({
    required this.monthlyIncome,
    required this.safeToSpend,
    required this.spent,
    required this.remaining,
    required this.month,
  });

  final int monthlyIncome;
  final int safeToSpend;
  final int spent;
  final int remaining;
  final String month;

  /// 0..1 — how much of the safe-to-spend pool has been used.
  double get progress =>
      safeToSpend <= 0 ? 0 : (spent / safeToSpend).clamp(0, 1);
}

/// A tiny financial literacy lesson. One concept, one example, one
/// action. Deliberately short — never a course.
class SproutLesson {
  const SproutLesson({
    required this.id,
    required this.title,
    required this.benefit,
    required this.durationSeconds,
    required this.xp,
    required this.completed,
    required this.concept,
    required this.example,
    required this.tinyAction,
  });

  final String id;
  final String title;
  final String benefit;
  final int durationSeconds;
  final int xp;
  final bool completed;

  /// Lesson detail content.
  final String concept;
  final String example;
  final String tinyAction;
}
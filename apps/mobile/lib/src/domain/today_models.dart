class TodayData {
  const TodayData({
    required this.user,
    required this.currency,
    required this.salary,
    required this.health,
    required this.autoCapture,
    required this.snapshot,
    required this.quickActions,
    required this.wealthSnapshot,
    required this.wealthEvents,
    required this.goals,
    required this.learnThreads,
    required this.provenanceSummary,
  });

  final SproutUser user;
  final String currency;
  final SalaryInfo salary;
  final FinancialHealthScore health;
  final List<AutoCaptureSource> autoCapture;
  final TodaySnapshot snapshot;
  final List<String> quickActions;

  /// The wealth hero object — total net worth + today/MTD movement + breakdown.
  final WealthSnapshot wealthSnapshot;

  /// Dated events that moved wealth, with plain-language "why" for each.
  final List<WealthEvent> wealthEvents;

  /// Goals with progress and remaining-to-target.
  final List<Goal> goals;

  /// Learn-later threads attached to wealth events.
  final List<LearnThread> learnThreads;

  /// One-line provenance summary for the trust footer.
  final String provenanceSummary;
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

// ── Wealth models (per spec/data_model_contract.md) ──

/// A dated unit price or NAV with its source. Provenance is first-class.
class PriceQuote {
  const PriceQuote({
    required this.value,
    required this.asOf,
    required this.source,
    this.currency = 'PKR',
  });

  final double value;
  final String asOf;
  final String source;
  final String currency;
}

/// A dated FX rate from a named source.
class FxRate {
  const FxRate({
    required this.pair,
    required this.value,
    required this.asOf,
    required this.source,
  });

  final String pair;
  final double value;
  final String asOf;
  final String source;
}

/// One position the user owns: a mutual fund, cash balance, equity, etc.
class Holding {
  const Holding({
    required this.id,
    required this.kind,
    required this.institution,
    required this.label,
    required this.currency,
    required this.valuePkr,
    required this.priceAsOf,
    required this.priceSource,
    this.valueNative,
    this.units,
    this.price,
    this.fxRate,
    this.freshness = 'fresh',
    this.changeVsYesterday = 0,
    this.changeMtd = 0,
    this.detail,
  });

  final String id;
  final HoldingKind kind;
  final String institution;
  final String label;
  final String currency;
  final int valuePkr;
  final String priceAsOf;
  final String priceSource;
  final int? valueNative;
  final double? units;
  final PriceQuote? price;
  final FxRate? fxRate;
  final String freshness;
  final int changeVsYesterday;
  final int changeMtd;
  final String? detail;
}

enum HoldingKind { mutualFund, cash, equity, other }

/// The daily snapshot of total wealth — the hero object of Today.
class WealthSnapshot {
  const WealthSnapshot({
    required this.date,
    required this.totalPkr,
    required this.holdings,
    required this.changeVsYesterday,
    required this.changeMtd,
    required this.mainReason,
    required this.interpretation,
    required this.provenanceSummary,
  });

  final String date;
  final int totalPkr;
  final List<Holding> holdings;
  final int changeVsYesterday;
  final int changeMtd;
  final String mainReason;
  final List<String> interpretation;
  final String provenanceSummary;
}

/// A real, dated event that moved wealth or marks a goal milestone.
class WealthEvent {
  const WealthEvent({
    required this.id,
    required this.date,
    required this.kind,
    required this.magnitudePkr,
    required this.direction,
    required this.plainWhy,
    this.holdingId,
    this.learnMoreId,
    this.severity = 'heads_up',
  });

  final String id;
  final String date;
  final WealthEventKind kind;
  final int magnitudePkr;
  final String direction;
  final String plainWhy;
  final String? holdingId;
  final String? learnMoreId;
  final String severity;
}

enum WealthEventKind {
  navMove,
  fxMove,
  contribution,
  withdrawal,
  bill,
  goalMilestone,
  newsContext,
}

/// A goal with progress and remaining-to-target.
class Goal {
  const Goal({
    required this.id,
    required this.name,
    required this.type,
    required this.targetAmount,
    required this.currentAmount,
    required this.status,
    required this.pace,
    required this.nextStep,
    required this.remainingToTarget,
    required this.paceNote,
  });

  final String id;
  final String name;
  final String type;
  final int targetAmount;
  final int currentAmount;
  final String status;
  final String pace;
  final String nextStep;
  final int remainingToTarget;
  final String paceNote;
}

/// A retrievable "learn later" thread attached to a wealth event.
class LearnThread {
  const LearnThread({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.relatedEventId,
  });

  final String id;
  final String title;
  final String summary;
  final String body;
  final String relatedEventId;
}

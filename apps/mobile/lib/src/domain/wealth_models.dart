/// Domain models for the wealth-health tracker realignment.
///
/// These models back the Today wealth hero, the Money holdings breakdown,
/// and the Sprout Explains provenance depth. They are additive to the
/// existing `today_models.dart` and `sprout_models.dart` — the existing
/// transaction/account/budget models remain for the cash/expense use case.
library;

/// A dated unit price or NAV with its source. Provenance is first-class.
class PriceQuote {
  const PriceQuote({
    required this.value,
    required this.asOf,
    required this.source,
    required this.currency,
    this.sourceUrl,
  });

  final double value;
  final String asOf;
  final String source;
  final String currency;
  final String? sourceUrl;
}

/// A dated FX rate from a named source. Required for any non-PKR holding.
class FxRate {
  const FxRate({
    required this.pair,
    required this.value,
    required this.asOf,
    required this.source,
    this.sourceUrl,
  });

  final String pair;
  final double value;
  final String asOf;
  final String source;
  final String? sourceUrl;
}

/// One position the user owns: a mutual fund, cash, equity, or other asset.
/// Every valuation carries dated provenance.
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
    required this.freshness,
    this.fundCode,
    this.units,
    this.price,
    this.fxRate,
    this.valueNative,
  });

  final String id;
  final HoldingKind kind;
  final String institution;
  final String label;
  final String? fundCode;
  final String currency;
  final double? units;
  final PriceQuote? price;
  final FxRate? fxRate;
  final int valuePkr;
  final double? valueNative;
  final String priceAsOf;
  final String priceSource;
  final HoldingFreshness freshness;
}

enum HoldingKind { mutualFund, cash, equity, other }

enum HoldingFreshness { fresh, stale, manual, unavailable }

/// One point in the 6-day wealth trend.
class WealthTrendPoint {
  const WealthTrendPoint({
    required this.date,
    required this.totalPkr,
    required this.perHolding,
  });

  final String date;
  final int totalPkr;
  final List<WealthTrendHolding> perHolding;
}

class WealthTrendHolding {
  const WealthTrendHolding({required this.holdingId, required this.valuePkr});

  final String holdingId;
  final int valuePkr;
}

/// The daily snapshot of total wealth — the hero object of Today.
class WealthSnapshot {
  const WealthSnapshot({
    required this.date,
    required this.totalPkr,
    required this.perHoldingBreakdown,
    required this.changeVsYesterday,
    required this.changeMtd,
    required this.mainReason,
    required this.interpretation,
    required this.trend,
    required this.provenanceSummary,
  });

  final String date;
  final int totalPkr;
  final List<WealthHoldingBreakdown> perHoldingBreakdown;
  final int changeVsYesterday;
  final int changeMtd;
  final String mainReason;
  final List<String> interpretation;
  final List<WealthTrendPoint> trend;
  final String provenanceSummary;
}

class WealthHoldingBreakdown {
  const WealthHoldingBreakdown({
    required this.holdingId,
    required this.label,
    required this.valuePkr,
    required this.changeVsYesterday,
    required this.changeMtd,
  });

  final String holdingId;
  final String label;
  final int valuePkr;
  final int changeVsYesterday;
  final int changeMtd;
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
    required this.severity,
    this.holdingId,
    this.learnMoreId,
  });

  final String id;
  final String date;
  final String? holdingId;
  final WealthEventKind kind;
  final int magnitudePkr;
  final WealthEventDirection direction;
  final String plainWhy;
  final String? learnMoreId;
  final WealthEventSeverity severity;
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

enum WealthEventDirection { up, down, flat }

enum WealthEventSeverity { allGood, headsUp, worthDoing, needsAttention }

/// A retrievable "learn later" thread attached to a WealthEvent.
class LearnThread {
  const LearnThread({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.relatedEventId,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String summary;
  final String body;
  final String relatedEventId;
  final String createdAt;
}

/// A savings goal with remaining-to-target and pace note.
class WealthGoal {
  const WealthGoal({
    required this.id,
    required this.name,
    required this.type,
    required this.targetAmount,
    required this.currentAmount,
    required this.currency,
    required this.status,
    required this.pace,
    required this.nextStep,
    required this.remainingToTarget,
    required this.paceNote,
    this.deadline,
  });

  final String id;
  final String name;
  final WealthGoalType type;
  final int targetAmount;
  final int currentAmount;
  final String currency;
  final String? deadline;
  final WealthGoalStatus status;
  final WealthGoalPace pace;
  final String nextStep;
  final int remainingToTarget;
  final String paceNote;
}

enum WealthGoalType {
  emergency,
  car,
  home,
  education,
  eidi,
  zakat,
  travel,
  custom,
}

enum WealthGoalStatus { active, complete, paused }

enum WealthGoalPace { ahead, onTrack, watch, behind }

/// The goal-relative recommended action.
class WealthBriefingAction {
  const WealthBriefingAction({
    required this.id,
    required this.label,
    required this.severity,
    required this.effect,
    required this.xp,
    required this.completionKind,
    this.targetId,
    this.goalRelativeNote,
  });

  final String id;
  final String label;
  final WealthEventSeverity severity;
  final String effect;
  final int xp;
  final WealthActionCompletionKind completionKind;
  final String? targetId;
  final String? goalRelativeNote;
}

enum WealthActionCompletionKind {
  confirmTransaction,
  logCash,
  moveMoney,
  review,
  setGoal,
  contributeToGoal,
  rebalance,
}

/// The full daily wealth briefing — the target contract for Today.
class WealthBriefing {
  const WealthBriefing({
    required this.id,
    required this.userId,
    required this.briefingDate,
    required this.generatedAt,
    required this.freshness,
    required this.mascotMood,
    required this.greeting,
    required this.summary,
    required this.healthScore,
    required this.healthStatus,
    required this.wealthSnapshot,
    required this.wealthEvents,
    required this.learnThreads,
    required this.recommendedAction,
    required this.goals,
    required this.holdings,
    required this.streak,
    required this.xp,
    required this.level,
  });

  final String id;
  final String userId;
  final String briefingDate;
  final String generatedAt;
  final WealthBriefingFreshness freshness;
  final WealthMascotMood mascotMood;
  final String greeting;
  final String summary;
  final int healthScore;
  final WealthHealthStatus healthStatus;
  final WealthSnapshot wealthSnapshot;
  final List<WealthEvent> wealthEvents;
  final List<LearnThread> learnThreads;
  final WealthBriefingAction recommendedAction;
  final List<WealthGoal> goals;
  final List<Holding> holdings;
  final int streak;
  final int xp;
  final int level;
}

enum WealthBriefingFreshness { fresh, stale, localFallback, unavailable }

enum WealthMascotMood { thriving, content, watchful, concerned }

enum WealthHealthStatus { strong, healthy, watch, urgent }
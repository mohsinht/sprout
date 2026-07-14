import 'wealth_models.dart' as wealth;

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

  /// Copy with — used to merge live goal-store changes into the briefing
  /// so goal edits (add/edit/complete/delete) are reflected on Today.
  TodayData copyWith({
    List<Goal>? goals,
    FinancialHealthScore? health,
    String? provenanceSummary,
  }) {
    return TodayData(
      user: user,
      currency: currency,
      salary: salary,
      health: health ?? this.health,
      autoCapture: autoCapture,
      snapshot: snapshot,
      quickActions: quickActions,
      wealthSnapshot: wealthSnapshot,
      wealthEvents: wealthEvents,
      goals: goals ?? this.goals,
      learnThreads: learnThreads,
      provenanceSummary: provenanceSummary ?? this.provenanceSummary,
    );
  }
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
  const SalaryInfo(
      {required this.nextPayday,
      required this.daysUntilSalary,
      this.isKnown = true});

  final DateTime nextPayday;
  final int daysUntilSalary;
  final bool isKnown;
}

class FinancialHealthScore {
  const FinancialHealthScore({
    required this.score,
    required this.status,
    required this.summary,
    required this.positiveFactors,
    required this.attentionFactors,
    required this.recommendedAction,
    this.scoreAvailable = true,
    this.scoreExplanation = '',
  });

  final int score;
  final String status;
  final String summary;
  final List<String> positiveFactors;
  final List<String> attentionFactors;
  final RecommendedAction recommendedAction;
  final bool scoreAvailable;
  final String scoreExplanation;
}

class RecommendedAction {
  const RecommendedAction({
    required this.title,
    required this.xp,
    required this.impact,
    this.completionKind,
    this.targetId,
  });

  final String title;
  final int xp;
  final String impact;
  final String? completionKind;
  final String? targetId;
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
    this.sixDayTrend = const [],
  });

  final String date;
  final int totalPkr;
  final List<Holding> holdings;
  final int changeVsYesterday;
  final int changeMtd;
  final String mainReason;
  final List<String> interpretation;
  final String provenanceSummary;
  final List<int> sixDayTrend;
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
    this.isPrimary = false,
    this.deadline,
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

  /// Whether this is the user-chosen "hero" goal that Today references.
  /// The closest active goal is used if no explicit primary is set.
  final bool isPrimary;

  /// Optional deadline (ISO date string). Null means no deadline.
  final String? deadline;

  Goal copyWith({
    String? id,
    String? name,
    String? type,
    int? targetAmount,
    int? currentAmount,
    String? status,
    String? pace,
    String? nextStep,
    int? remainingToTarget,
    String? paceNote,
    bool? isPrimary,
    String? deadline,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      status: status ?? this.status,
      pace: pace ?? this.pace,
      nextStep: nextStep ?? this.nextStep,
      remainingToTarget: remainingToTarget ?? this.remainingToTarget,
      paceNote: paceNote ?? this.paceNote,
      isPrimary: isPrimary ?? this.isPrimary,
      deadline: deadline ?? this.deadline,
    );
  }
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

// ── Bridge: WealthBriefing → TodayData ─────────────────────────────────────────
// Maps the backend's WealthBriefing contract (wealth_models.dart) to the
// TodayData shape the Today screen consumes. This lets the HTTP repository
// parse the API response into WealthBriefing and convert it here, without
// changing any screen code.

TodayData todayDataFromWealthBriefing(wealth.WealthBriefing b) {
  // Map wealth goals to today goals
  final goals = b.goals
      .map((g) => Goal(
            id: g.id,
            name: g.name,
            type: g.type.name,
            targetAmount: g.targetAmount,
            currentAmount: g.currentAmount,
            status: g.status.name,
            pace: g.pace.name,
            nextStep: g.nextStep,
            remainingToTarget: g.remainingToTarget,
            paceNote: g.paceNote,
            deadline: g.deadline,
          ))
      .toList();

  // Map wealth events to today events
  final events = b.wealthEvents
      .map((e) => WealthEvent(
            id: e.id,
            date: e.date,
            kind: _bridgeEventKind(e.kind),
            magnitudePkr: e.magnitudePkr,
            direction: e.direction.name,
            plainWhy: e.plainWhy,
            holdingId: e.holdingId,
            learnMoreId: e.learnMoreId,
            severity: e.severity.name,
          ))
      .toList();

  // Map wealth holdings to today holdings (with changeVsYesterday/changeMtd
  // from the snapshot breakdown)
  final breakdownMap = {
    for (final bd in b.wealthSnapshot.perHoldingBreakdown) bd.holdingId: bd,
  };

  final holdings = b.holdings
      .map((h) => Holding(
            id: h.id,
            kind: _bridgeHoldingKind(h.kind),
            institution: h.institution,
            label: h.label,
            currency: h.currency,
            valuePkr: h.valuePkr,
            valueNative: h.valueNative?.round(),
            units: h.units,
            price: h.price != null
                ? PriceQuote(
                    value: h.price!.value,
                    asOf: h.price!.asOf,
                    source: h.price!.source,
                    currency: h.price!.currency,
                  )
                : null,
            fxRate: h.fxRate != null
                ? FxRate(
                    pair: h.fxRate!.pair,
                    value: h.fxRate!.value,
                    asOf: h.fxRate!.asOf,
                    source: h.fxRate!.source,
                  )
                : null,
            priceAsOf: h.priceAsOf,
            priceSource: h.priceSource,
            freshness: h.freshness.name,
            changeVsYesterday: breakdownMap[h.id]?.changeVsYesterday ?? 0,
            changeMtd: breakdownMap[h.id]?.changeMtd ?? 0,
            detail: h.fundCode ?? h.institution,
          ))
      .toList();

  // Map learn threads
  final learnThreads = b.learnThreads
      .map((t) => LearnThread(
            id: t.id,
            title: t.title,
            summary: t.summary,
            body: t.body,
            relatedEventId: t.relatedEventId,
          ))
      .toList();

  // Build the wealth snapshot (today_models shape)
  final wealthSnapshot = WealthSnapshot(
    date: b.wealthSnapshot.date,
    totalPkr: b.wealthSnapshot.totalPkr,
    holdings: holdings,
    changeVsYesterday: b.wealthSnapshot.changeVsYesterday,
    changeMtd: b.wealthSnapshot.changeMtd,
    mainReason: b.wealthSnapshot.mainReason,
    interpretation: b.wealthSnapshot.interpretation,
    provenanceSummary: b.wealthSnapshot.provenanceSummary,
    sixDayTrend: b.wealthSnapshot.trend.map((point) => point.totalPkr).toList(),
  );

  // Map recommended action
  final recommendedAction = RecommendedAction(
    title: b.recommendedAction.label,
    xp: b.recommendedAction.xp,
    impact: b.recommendedAction.effect,
    completionKind: b.recommendedAction.completionKind.name,
    targetId: b.recommendedAction.targetId,
  );

  // Map health score
  final health = FinancialHealthScore(
    score: b.healthScore ?? 0,
    status: b.healthStatus?.name ?? 'insufficient_data',
    summary: b.scoreState == 'insufficient_data'
        ? 'Sprout is still getting to know your money.'
        : b.summary,
    positiveFactors: const [],
    attentionFactors: const [],
    recommendedAction: recommendedAction,
    scoreAvailable: b.scoreState == 'available',
    scoreExplanation: b.scoreExplanation,
  );

  return TodayData(
    user: SproutUser(
      firstName: b.greeting
          .replaceAll(RegExp(r'^Good (morning|afternoon|evening),\s*'), ''),
      level: b.level,
      xp: b.xp,
      dayStreak: b.streak,
    ),
    currency: 'PKR',
    salary: SalaryInfo(
      nextPayday: DateTime.now(),
      daysUntilSalary: 0,
      isKnown: false,
    ),
    health: health,
    autoCapture: const [],
    snapshot: const TodaySnapshot(
      availableCash: 0,
      monthSpent: 0,
      budgetRemaining: 0,
      upcomingBills: 0,
      unconfirmedTransactions: 0,
    ),
    quickActions: const [],
    wealthSnapshot: wealthSnapshot,
    wealthEvents: events,
    goals: goals,
    learnThreads: learnThreads,
    provenanceSummary: b.wealthSnapshot.provenanceSummary,
  );
}

WealthEventKind _bridgeEventKind(wealth.WealthEventKind k) {
  return switch (k) {
    wealth.WealthEventKind.navMove => WealthEventKind.navMove,
    wealth.WealthEventKind.fxMove => WealthEventKind.fxMove,
    wealth.WealthEventKind.contribution => WealthEventKind.contribution,
    wealth.WealthEventKind.withdrawal => WealthEventKind.withdrawal,
    wealth.WealthEventKind.bill => WealthEventKind.bill,
    wealth.WealthEventKind.goalMilestone => WealthEventKind.goalMilestone,
    wealth.WealthEventKind.newsContext => WealthEventKind.newsContext,
  };
}

HoldingKind _bridgeHoldingKind(wealth.HoldingKind k) {
  return switch (k) {
    wealth.HoldingKind.mutualFund => HoldingKind.mutualFund,
    wealth.HoldingKind.cash => HoldingKind.cash,
    wealth.HoldingKind.equity => HoldingKind.equity,
    wealth.HoldingKind.other => HoldingKind.other,
  };
}

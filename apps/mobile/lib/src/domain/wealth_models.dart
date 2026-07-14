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

enum HoldingFreshness { fresh, stale, manual, unavailable, estimated }

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
    required this.scoreState,
    required this.scoreExplanation,
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
  final String scoreState;
  final String scoreExplanation;
  final int? healthScore;
  final WealthHealthStatus? healthStatus;
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

// ── fromApiJson factories ─────────────────────────────────────────────────────
// These parse the backend's JSON response (from GET /v1/briefing) into the
// typed domain models. The backend serves camelCase JSON matching the
// WealthBriefingSchema in packages/shared/src/wealth.ts.

PriceQuote priceQuoteFromApiJson(Map<String, dynamic> json) {
  return PriceQuote(
    value: (json['value'] as num).toDouble(),
    asOf: json['asOf'] as String,
    source: json['source'] as String,
    currency: json['currency'] as String? ?? 'PKR',
    sourceUrl: json['sourceUrl'] as String?,
  );
}

FxRate fxRateFromApiJson(Map<String, dynamic> json) {
  return FxRate(
    pair: json['pair'] as String,
    value: (json['value'] as num).toDouble(),
    asOf: json['asOf'] as String,
    source: json['source'] as String,
    sourceUrl: json['sourceUrl'] as String?,
  );
}

Holding holdingFromApiJson(Map<String, dynamic> json) {
  return Holding(
    id: json['id'] as String,
    kind: _holdingKindFromString(json['kind'] as String),
    institution: json['institution'] as String,
    label: json['label'] as String,
    fundCode: json['fundCode'] as String?,
    currency: json['currency'] as String,
    units: (json['units'] as num?)?.toDouble(),
    price: json['price'] != null
        ? priceQuoteFromApiJson(json['price'] as Map<String, dynamic>)
        : null,
    fxRate: json['fxRate'] != null
        ? fxRateFromApiJson(json['fxRate'] as Map<String, dynamic>)
        : null,
    valuePkr: json['valuePkr'] as int,
    valueNative: (json['valueNative'] as num?)?.toDouble(),
    priceAsOf: json['priceAsOf'] as String,
    priceSource: json['priceSource'] as String,
    freshness: _holdingFreshnessFromString(json['freshness'] as String),
  );
}

WealthTrendHolding wealthTrendHoldingFromApiJson(Map<String, dynamic> json) {
  return WealthTrendHolding(
    holdingId: json['holdingId'] as String,
    valuePkr: json['valuePkr'] as int,
  );
}

WealthTrendPoint wealthTrendPointFromApiJson(Map<String, dynamic> json) {
  return WealthTrendPoint(
    date: json['date'] as String,
    totalPkr: json['totalPkr'] as int,
    perHolding: (json['perHolding'] as List<dynamic>)
        .map((e) => wealthTrendHoldingFromApiJson(e as Map<String, dynamic>))
        .toList(),
  );
}

WealthHoldingBreakdown wealthHoldingBreakdownFromApiJson(
    Map<String, dynamic> json) {
  return WealthHoldingBreakdown(
    holdingId: json['holdingId'] as String,
    label: json['label'] as String,
    valuePkr: json['valuePkr'] as int,
    changeVsYesterday: json['changeVsYesterday'] as int,
    changeMtd: json['changeMtd'] as int,
  );
}

WealthSnapshot wealthSnapshotFromApiJson(Map<String, dynamic> json) {
  return WealthSnapshot(
    date: json['date'] as String,
    totalPkr: json['totalPkr'] as int,
    perHoldingBreakdown: (json['perHoldingBreakdown'] as List<dynamic>)
        .map(
            (e) => wealthHoldingBreakdownFromApiJson(e as Map<String, dynamic>))
        .toList(),
    changeVsYesterday: json['changeVsYesterday'] as int,
    changeMtd: json['changeMtd'] as int,
    mainReason: json['mainReason'] as String,
    interpretation: (json['interpretation'] as List<dynamic>)
        .map((e) => e as String)
        .toList(),
    trend: (json['trend'] as List<dynamic>)
        .map((e) => wealthTrendPointFromApiJson(e as Map<String, dynamic>))
        .toList(),
    provenanceSummary: json['provenanceSummary'] as String,
  );
}

WealthEvent wealthEventFromApiJson(Map<String, dynamic> json) {
  return WealthEvent(
    id: json['id'] as String,
    date: json['date'] as String,
    holdingId: json['holdingId'] as String?,
    kind: _wealthEventKindFromString(json['kind'] as String),
    magnitudePkr: json['magnitudePkr'] as int,
    direction: _wealthEventDirectionFromString(json['direction'] as String),
    plainWhy: json['plainWhy'] as String,
    learnMoreId: json['learnMoreId'] as String?,
    severity: _wealthEventSeverityFromString(json['severity'] as String),
  );
}

LearnThread learnThreadFromApiJson(Map<String, dynamic> json) {
  return LearnThread(
    id: json['id'] as String,
    title: json['title'] as String,
    summary: json['summary'] as String,
    body: json['body'] as String,
    relatedEventId: json['relatedEventId'] as String,
    createdAt: json['createdAt'] as String,
  );
}

WealthGoal wealthGoalFromApiJson(Map<String, dynamic> json) {
  return WealthGoal(
    id: json['id'] as String,
    name: json['name'] as String,
    type: _wealthGoalTypeFromString(json['type'] as String),
    targetAmount: json['targetAmount'] as int,
    currentAmount: json['currentAmount'] as int,
    currency: json['currency'] as String,
    deadline: json['deadline'] as String?,
    status: _wealthGoalStatusFromString(json['status'] as String),
    pace: _wealthGoalPaceFromString(json['pace'] as String),
    nextStep: json['nextStep'] as String,
    remainingToTarget: json['remainingToTarget'] as int,
    paceNote: json['paceNote'] as String,
  );
}

WealthBriefingAction wealthBriefingActionFromApiJson(
    Map<String, dynamic> json) {
  return WealthBriefingAction(
    id: json['id'] as String,
    label: json['label'] as String,
    severity: _wealthEventSeverityFromString(json['severity'] as String),
    effect: json['effect'] as String,
    xp: json['xp'] as int,
    completionKind:
        _wealthActionCompletionKindFromString(json['completionKind'] as String),
    targetId: json['targetId'] as String?,
    goalRelativeNote: json['goalRelativeNote'] as String?,
  );
}

WealthBriefing wealthBriefingFromApiJson(Map<String, dynamic> json) {
  return WealthBriefing(
    id: json['id'] as String,
    userId: json['userId'] as String,
    briefingDate: json['briefingDate'] as String,
    generatedAt: json['generatedAt'] as String,
    freshness: _wealthBriefingFreshnessFromString(json['freshness'] as String),
    mascotMood: _wealthMascotMoodFromString(json['mascotMood'] as String),
    greeting: json['greeting'] as String,
    summary: json['summary'] as String,
    scoreState: json['scoreState'] as String? ?? 'available',
    scoreExplanation: json['scoreExplanation'] as String? ?? '',
    healthScore: json['healthScore'] as int?,
    healthStatus: json['healthStatus'] == null
        ? null
        : _wealthHealthStatusFromString(json['healthStatus'] as String),
    wealthSnapshot: wealthSnapshotFromApiJson(
      json['wealthSnapshot'] as Map<String, dynamic>,
    ),
    wealthEvents: (json['wealthEvents'] as List<dynamic>)
        .map((e) => wealthEventFromApiJson(e as Map<String, dynamic>))
        .toList(),
    learnThreads: (json['learnThreads'] as List<dynamic>)
        .map((e) => learnThreadFromApiJson(e as Map<String, dynamic>))
        .toList(),
    recommendedAction: wealthBriefingActionFromApiJson(
      json['recommendedAction'] as Map<String, dynamic>,
    ),
    goals: (json['goals'] as List<dynamic>)
        .map((e) => wealthGoalFromApiJson(e as Map<String, dynamic>))
        .toList(),
    holdings: (json['holdings'] as List<dynamic>)
        .map((e) => holdingFromApiJson(e as Map<String, dynamic>))
        .toList(),
    streak: json['streak'] as int,
    xp: json['xp'] as int,
    level: json['level'] as int,
  );
}

// ── String-to-enum helpers ────────────────────────────────────────────────────

HoldingKind _holdingKindFromString(String s) {
  return switch (s) {
    'mutual_fund' => HoldingKind.mutualFund,
    'cash' => HoldingKind.cash,
    'equity' => HoldingKind.equity,
    _ => HoldingKind.other,
  };
}

HoldingFreshness _holdingFreshnessFromString(String s) {
  return switch (s) {
    'fresh' => HoldingFreshness.fresh,
    'stale' => HoldingFreshness.stale,
    'manual' => HoldingFreshness.manual,
    'estimated' => HoldingFreshness.estimated,
    _ => HoldingFreshness.unavailable,
  };
}

WealthEventKind _wealthEventKindFromString(String s) {
  return switch (s) {
    'nav_move' => WealthEventKind.navMove,
    'fx_move' => WealthEventKind.fxMove,
    'contribution' => WealthEventKind.contribution,
    'withdrawal' => WealthEventKind.withdrawal,
    'bill' => WealthEventKind.bill,
    'goal_milestone' => WealthEventKind.goalMilestone,
    'news_context' => WealthEventKind.newsContext,
    _ => WealthEventKind.contribution,
  };
}

WealthEventDirection _wealthEventDirectionFromString(String s) {
  return switch (s) {
    'up' => WealthEventDirection.up,
    'down' => WealthEventDirection.down,
    _ => WealthEventDirection.flat,
  };
}

WealthEventSeverity _wealthEventSeverityFromString(String s) {
  return switch (s) {
    'all_good' => WealthEventSeverity.allGood,
    'heads_up' => WealthEventSeverity.headsUp,
    'worth_doing' => WealthEventSeverity.worthDoing,
    'needs_attention' => WealthEventSeverity.needsAttention,
    _ => WealthEventSeverity.allGood,
  };
}

WealthGoalType _wealthGoalTypeFromString(String s) {
  return switch (s) {
    'emergency' => WealthGoalType.emergency,
    'car' => WealthGoalType.car,
    'home' => WealthGoalType.home,
    'education' => WealthGoalType.education,
    'eidi' => WealthGoalType.eidi,
    'zakat' => WealthGoalType.zakat,
    'travel' => WealthGoalType.travel,
    _ => WealthGoalType.custom,
  };
}

WealthGoalStatus _wealthGoalStatusFromString(String s) {
  return switch (s) {
    'active' => WealthGoalStatus.active,
    'complete' => WealthGoalStatus.complete,
    _ => WealthGoalStatus.paused,
  };
}

WealthGoalPace _wealthGoalPaceFromString(String s) {
  return switch (s) {
    'ahead' => WealthGoalPace.ahead,
    'on_track' => WealthGoalPace.onTrack,
    'watch' => WealthGoalPace.watch,
    _ => WealthGoalPace.behind,
  };
}

WealthActionCompletionKind _wealthActionCompletionKindFromString(String s) {
  return switch (s) {
    'confirm_transaction' => WealthActionCompletionKind.confirmTransaction,
    'log_cash' => WealthActionCompletionKind.logCash,
    'move_money' => WealthActionCompletionKind.moveMoney,
    'review' => WealthActionCompletionKind.review,
    'set_goal' => WealthActionCompletionKind.setGoal,
    'contribute_to_goal' => WealthActionCompletionKind.contributeToGoal,
    'rebalance' => WealthActionCompletionKind.rebalance,
    _ => WealthActionCompletionKind.review,
  };
}

WealthBriefingFreshness _wealthBriefingFreshnessFromString(String s) {
  return switch (s) {
    'fresh' => WealthBriefingFreshness.fresh,
    'stale' => WealthBriefingFreshness.stale,
    'local_fallback' => WealthBriefingFreshness.localFallback,
    _ => WealthBriefingFreshness.unavailable,
  };
}

WealthMascotMood _wealthMascotMoodFromString(String s) {
  return switch (s) {
    'thriving' => WealthMascotMood.thriving,
    'content' => WealthMascotMood.content,
    'watchful' => WealthMascotMood.watchful,
    _ => WealthMascotMood.concerned,
  };
}

WealthHealthStatus _wealthHealthStatusFromString(String s) {
  return switch (s) {
    'strong' => WealthHealthStatus.strong,
    'healthy' => WealthHealthStatus.healthy,
    'watch' => WealthHealthStatus.watch,
    _ => WealthHealthStatus.urgent,
  };
}

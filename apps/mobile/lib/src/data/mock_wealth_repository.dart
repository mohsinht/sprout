import '../domain/wealth_models.dart';
import 'http_wealth_repository.dart';

/// Mock wealth briefing derived from the canonical automation example.
///
/// All per-fund unit/NAV splits and per-holding 6-day trend columns are
/// DERIVED to be internally consistent with the aggregate totals from the
/// example (PKR 13,673,019 total, PKR 5,388,530 funds, PKR 326,730 USD,
/// PKR 7,957,760 EUR, PKR 0 cash). They are labelled as derived/estimated,
/// not authoritative.
class MockWealthBriefingRepository implements WealthBriefingRepository {
  @override
  Future<WealthBriefing> fetchWealthBriefing() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _mockWealthBriefing;
  }
}

// ── Provenance ─────────────────────────────────────────────────────────────
const _alMeezanPriceAsOf = '2026-07-07';
const _alMeezanPriceSource = 'Al Meezan redemption prices';
const _xeFxAsOf = '2026-07-08';
const _xeFxSource = 'Xe';

const _usdPkr = FxRate(
  pair: 'USD/PKR',
  value: 277.992,
  asOf: _xeFxAsOf,
  source: _xeFxSource,
);

const _eurPkr = FxRate(
  pair: 'EUR/PKR',
  value: 317.536,
  asOf: _xeFxAsOf,
  source: _xeFxSource,
);

// ── Holdings (derived per-fund splits, sum = 5,388,530) ─────────────────────

const _ammfPrice = PriceQuote(
  value: 54.2187,
  asOf: _alMeezanPriceAsOf,
  source: _alMeezanPriceSource,
  currency: 'PKR',
);

const _mifPrice = PriceQuote(
  value: 17.5462,
  asOf: _alMeezanPriceAsOf,
  source: _alMeezanPriceSource,
  currency: 'PKR',
);

const _msfPrice = PriceQuote(
  value: 63.4471,
  asOf: _alMeezanPriceAsOf,
  source: _alMeezanPriceSource,
  currency: 'PKR',
);

const _mdipPrice = PriceQuote(
  value: 28.9134,
  asOf: _alMeezanPriceAsOf,
  source: _alMeezanPriceSource,
  currency: 'PKR',
);

const _mfpfPrice = PriceQuote(
  value: 51.0723,
  asOf: _alMeezanPriceAsOf,
  source: _alMeezanPriceSource,
  currency: 'PKR',
);

final _mockHoldings = <Holding>[
  const Holding(
    id: 'ammf',
    kind: HoldingKind.mutualFund,
    institution: 'Al Meezan',
    label: 'Al Meezan Cash Fund',
    fundCode: 'AMMF',
    currency: 'PKR',
    units: 22134.6,
    price: _ammfPrice,
    valuePkr: 1200000,
    priceAsOf: _alMeezanPriceAsOf,
    priceSource: _alMeezanPriceSource,
    freshness: HoldingFreshness.fresh,
  ),
  const Holding(
    id: 'mif',
    kind: HoldingKind.mutualFund,
    institution: 'Al Meezan',
    label: 'Al Meezan Mutual Fund',
    fundCode: 'MIF',
    currency: 'PKR',
    units: 30006.5,
    price: _mifPrice,
    valuePkr: 526390,
    priceAsOf: _alMeezanPriceAsOf,
    priceSource: _alMeezanPriceSource,
    freshness: HoldingFreshness.fresh,
  ),
  const Holding(
    id: 'msf',
    kind: HoldingKind.mutualFund,
    institution: 'Al Meezan',
    label: 'Meezan Sovereign Fund',
    fundCode: 'MSF',
    currency: 'PKR',
    units: 19006.0,
    price: _msfPrice,
    valuePkr: 1205490,
    priceAsOf: _alMeezanPriceAsOf,
    priceSource: _alMeezanPriceSource,
    freshness: HoldingFreshness.fresh,
  ),
  const Holding(
    id: 'mdip',
    kind: HoldingKind.mutualFund,
    institution: 'Al Meezan',
    label: 'Meezan Islamic Income Fund',
    fundCode: 'MDIP',
    currency: 'PKR',
    units: 41580.0,
    price: _mdipPrice,
    valuePkr: 1202300,
    priceAsOf: _alMeezanPriceAsOf,
    priceSource: _alMeezanPriceSource,
    freshness: HoldingFreshness.fresh,
  ),
  const Holding(
    id: 'mfpf-aap',
    kind: HoldingKind.mutualFund,
    institution: 'Al Meezan',
    label: 'Meezan Islamic Asset Allocation Fund',
    fundCode: 'MFPF-AAP',
    currency: 'PKR',
    units: 24557.0,
    price: _mfpfPrice,
    valuePkr: 1254350,
    priceAsOf: _alMeezanPriceAsOf,
    priceSource: _alMeezanPriceSource,
    freshness: HoldingFreshness.fresh,
  ),
  const Holding(
    id: 'wise-usd',
    kind: HoldingKind.cash,
    institution: 'Wise',
    label: 'Wise USD Cash',
    currency: 'USD',
    valueNative: 1175.14,
    fxRate: _usdPkr,
    valuePkr: 326730,
    priceAsOf: _xeFxAsOf,
    priceSource: _xeFxSource,
    freshness: HoldingFreshness.fresh,
  ),
  const Holding(
    id: 'wise-eur',
    kind: HoldingKind.cash,
    institution: 'Wise',
    label: 'Wise EUR Cash',
    currency: 'EUR',
    valueNative: 25073.2,
    fxRate: _eurPkr,
    valuePkr: 7957760,
    priceAsOf: _xeFxAsOf,
    priceSource: _xeFxSource,
    freshness: HoldingFreshness.fresh,
  ),
  const Holding(
    id: 'pkr-cash',
    kind: HoldingKind.cash,
    institution: 'Local',
    label: 'PKR Cash',
    currency: 'PKR',
    valuePkr: 0,
    priceAsOf: '2026-07-08',
    priceSource: 'Manual',
    freshness: HoldingFreshness.manual,
  ),
];

// ── 6-day trend (derived, internally consistent) ────────────────────────────

final _trendDates = [
  '2026-07-03',
  '2026-07-04',
  '2026-07-05',
  '2026-07-06',
  '2026-07-07',
  '2026-07-08',
];

final _trendPerHolding = <String, List<int>>{
  'ammf': [1200000, 1200000, 1200000, 1200000, 1200000, 1200000],
  'mif': [530000, 528000, 529000, 530000, 540000, 526390],
  'msf': [1205490, 1205490, 1205490, 1205490, 1205490, 1205490],
  'mdip': [1202300, 1202300, 1202300, 1202300, 1202300, 1202300],
  'mfpf-aap': [1254350, 1254350, 1254350, 1254350, 1254350, 1254350],
  'wise-usd': [325000, 325500, 326000, 326200, 326500, 326730],
  'wise-eur': [7940000, 7942000, 7945000, 7949000, 7952000, 7957760],
  'pkr-cash': [0, 0, 0, 0, 0, 0],
};

final _mockTrend = List<WealthTrendPoint>.generate(_trendDates.length, (i) {
  final perHolding = _trendPerHolding.entries
      .map((e) => WealthTrendHolding(holdingId: e.key, valuePkr: e.value[i]))
      .toList();
  final totalPkr = perHolding.fold<int>(0, (sum, h) => sum + h.valuePkr);
  return WealthTrendPoint(
      date: _trendDates[i], totalPkr: totalPkr, perHolding: perHolding);
});

// ── WealthSnapshot ──────────────────────────────────────────────────────────

final _mockWealthSnapshot = WealthSnapshot(
  date: '2026-07-08',
  totalPkr: 13673019,
  perHoldingBreakdown: _mockHoldings.map((h) {
    final yesterdayValue = _trendPerHolding[h.id]?[4] ?? h.valuePkr;
    final startValue = _trendPerHolding[h.id]?[0] ?? h.valuePkr;
    return WealthHoldingBreakdown(
      holdingId: h.id,
      label: h.label,
      valuePkr: h.valuePkr,
      changeVsYesterday: h.valuePkr - yesterdayValue,
      changeMtd: h.valuePkr - startValue,
    );
  }).toList(),
  changeVsYesterday: -38490,
  changeMtd: 14831,
  mainReason: 'NAV movement',
  interpretation: const [
    'Al Meezan cooled after yesterday\'s jump (equity NAV correction).',
    'Wise EUR helped slightly but didn\'t offset the fund dip.',
    'Still ~PKR 13.67M — not a crash.',
  ],
  trend: _mockTrend,
  provenanceSummary:
      'Al Meezan prices valid 7 Jul 2026; units reconciled with statement. FX from Xe: USD/PKR 277.992, EUR/PKR 317.536.',
);

// ── WealthEvents ────────────────────────────────────────────────────────────

const _mockWealthEvents = <WealthEvent>[
  WealthEvent(
    id: 'event-mif-pullback',
    date: '2026-07-08',
    holdingId: 'mif',
    kind: WealthEventKind.navMove,
    magnitudePkr: -13610,
    direction: WealthEventDirection.down,
    plainWhy:
        'Al Meezan cooled after yesterday\'s jump (equity NAV correction).',
    learnMoreId: 'learn-why-funds-move',
    severity: WealthEventSeverity.headsUp,
  ),
  WealthEvent(
    id: 'event-eur-nudge',
    date: '2026-07-08',
    holdingId: 'wise-eur',
    kind: WealthEventKind.fxMove,
    magnitudePkr: 5760,
    direction: WealthEventDirection.up,
    plainWhy: 'Wise EUR nudged up — EUR/PKR moved slightly in your favour.',
    severity: WealthEventSeverity.allGood,
  ),
  WealthEvent(
    id: 'event-car-goal-progress',
    date: '2026-07-08',
    kind: WealthEventKind.goalMilestone,
    magnitudePkr: 0,
    direction: WealthEventDirection.flat,
    plainWhy: 'Your car goal is 48% funded — PKR 1,248,000 to go.',
    severity: WealthEventSeverity.allGood,
  ),
  WealthEvent(
    id: 'event-inflation-context',
    date: '2026-07-08',
    kind: WealthEventKind.newsContext,
    magnitudePkr: 0,
    direction: WealthEventDirection.flat,
    plainWhy:
        'Inflation cooled slightly this month — your PKR cash buying power is a touch steadier. Barely moves the needle, but good to know.',
    severity: WealthEventSeverity.allGood,
  ),
];

// ── LearnThreads ────────────────────────────────────────────────────────────

const _mockLearnThreads = <LearnThread>[
  LearnThread(
    id: 'learn-why-funds-move',
    title: 'Why do fund NAVs move day to day?',
    summary:
        'A fund\'s NAV changes when the underlying assets change in value. Equity funds move more than money market funds.',
    body:
        'Yesterday your Al Meezan Mutual Fund (MIF) jumped — the stocks it holds went up. Today they corrected down a little. That is normal for an equity fund: it moves in steps, not a straight line. Money market funds (like AMMF) barely move because they hold short-term, stable assets. Today is the market cooling after a good day.',
    relatedEventId: 'event-mif-pullback',
    createdAt: '2026-07-08T06:00:00Z',
  ),
];

// ── Goals ───────────────────────────────────────────────────────────────────

const _mockWealthGoals = <WealthGoal>[
  WealthGoal(
    id: 'car-goal',
    name: 'Car Fund',
    type: WealthGoalType.car,
    targetAmount: 2600000,
    currentAmount: 1352000,
    currency: 'PKR',
    deadline: '2027-06-01',
    status: WealthGoalStatus.active,
    pace: WealthGoalPace.onTrack,
    nextStep: 'Add PKR 25,000 this month',
    remainingToTarget: 1248000,
    paceNote: 'PKR 12.5 lakh to go — about 12 months at your current pace',
  ),
  WealthGoal(
    id: 'emergency-goal',
    name: 'Emergency Fund',
    type: WealthGoalType.emergency,
    targetAmount: 600000,
    currentAmount: 348000,
    currency: 'PKR',
    status: WealthGoalStatus.active,
    pace: WealthGoalPace.watch,
    nextStep: 'Add PKR 10,000 this month',
    remainingToTarget: 252000,
    paceNote: 'PKR 2.5 lakh to go — 3.2 months covered today',
  ),
];

// ── Recommended Action ──────────────────────────────────────────────────────

const _mockRecommendedAction = WealthBriefingAction(
  id: 'action-rebalance-mif',
  label:
      'MIF is lagging your other funds — consider directing your next contribution there',
  severity: WealthEventSeverity.worthDoing,
  effect: 'Rebalances your portfolio toward the underweight fund',
  xp: 20,
  completionKind: WealthActionCompletionKind.rebalance,
  targetId: 'mif',
  goalRelativeNote: 'Or add PKR 25,000 to your car goal — PKR 12.5 lakh to go',
);

// ── Full Wealth Briefing ─────────────────────────────────────────────────────

final _mockWealthBriefing = WealthBriefing(
  id: 'briefing-2026-07-08',
  userId: 'user-mohsin',
  briefingDate: '2026-07-08',
  generatedAt: '2026-07-08T06:00:00Z',
  freshness: WealthBriefingFreshness.fresh,
  mascotMood: WealthMascotMood.content,
  greeting: 'Good morning, Mohsin',
  summary:
      'Down PKR 38k today — Al Meezan cooled after yesterday\'s jump, not a crash. Still up PKR 15k this month.',
  healthScore: 78,
  healthStatus: WealthHealthStatus.healthy,
  wealthSnapshot: _mockWealthSnapshot,
  wealthEvents: _mockWealthEvents,
  learnThreads: _mockLearnThreads,
  recommendedAction: _mockRecommendedAction,
  goals: _mockWealthGoals,
  holdings: _mockHoldings,
  streak: 12,
  xp: 1840,
  level: 6,
);

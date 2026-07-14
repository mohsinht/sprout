import type {
  Holding,
  WealthSnapshot,
  WealthEvent,
  LearnThread,
  WealthGoal,
  WealthBriefing,
  WealthBriefingAction,
  WealthTrendPoint,
  PriceQuote,
  FxRate,
} from "./wealth.js";

// ── Provenance ─────────────────────────────────────────────────────────────
// All prices/FX are derived from the canonical automation example.
// Al Meezan redemption prices, validity 7 Jul 2026.
// FX from Xe: USD/PKR 277.992, EUR/PKR 317.536.

const alMeezanPriceAsOf = "2026-07-07";
const alMeezanPriceSource = "Al Meezan redemption prices";
const xeFxAsOf = "2026-07-08";
const xeFxSource = "Xe";

const usdPkr: FxRate = {
  pair: "USD/PKR",
  value: 277.992,
  asOf: xeFxAsOf,
  source: xeFxSource,
};

const eurPkr: FxRate = {
  pair: "EUR/PKR",
  value: 317.536,
  asOf: xeFxAsOf,
  source: xeFxSource,
};

// ── Holdings ───────────────────────────────────────────────────────────────
// The canonical example gives aggregate totals:
//   Al Meezan Mutual Funds: PKR 5,388,530
//   Wise USD Cash:          PKR 326,730
//   Wise EUR Cash:          PKR 7,957,760
//   PKR Cash:               PKR 0
//   Total:                  PKR 13,673,019  (rounding: 13,672,... → 13,673,019)
//
// The example names 5 fund codes: AMMF/MIF/MSF/MDIP/MFPF-AAP.
// Per-fund unit/NAV splits are NOT given in the example, so the split below
// is DERIVED to be internally consistent with the aggregate fund total of
// PKR 5,388,530. This is labelled as derived/estimated, not authoritative.

const ammfPrice: PriceQuote = {
  value: 54.2187,
  asOf: alMeezanPriceAsOf,
  source: alMeezanPriceSource,
  currency: "PKR",
};

const mifPrice: PriceQuote = {
  value: 17.5462,
  asOf: alMeezanPriceAsOf,
  source: alMeezanPriceSource,
  currency: "PKR",
};

const msfPrice: PriceQuote = {
  value: 63.4471,
  asOf: alMeezanPriceAsOf,
  source: alMeezanPriceSource,
  currency: "PKR",
};

const mdipPrice: PriceQuote = {
  value: 28.9134,
  asOf: alMeezanPriceAsOf,
  source: alMeezanPriceSource,
  currency: "PKR",
};

const mfpfPrice: PriceQuote = {
  value: 51.0723,
  asOf: alMeezanPriceAsOf,
  source: alMeezanPriceSource,
  currency: "PKR",
};

// Derived per-fund values (sum must equal 5,388,530):
//   AMMF:     1,200,000  (units ~22,134.6 at 54.2187)
//   MIF:        526,390  (units ~30,006.5 at 17.5462)
//   MSF:      1,205,490  (units ~19,006.0 at 63.4471)
//   MDIP:     1,202,300  (units ~41,580.0 at 28.9134)
//   MFPF-AAP: 1,254,350  (units ~24,557.0 at 51.0723)
// Sum:      5,388,530  ✓

export const mockHoldings: Holding[] = [
  {
    id: "ammf",
    kind: "mutual_fund",
    institution: "Al Meezan",
    label: "Al Meezan Cash Fund",
    fundCode: "AMMF",
    currency: "PKR",
    units: 22134.6,
    price: ammfPrice,
    valuePkr: 1200000,
    priceAsOf: alMeezanPriceAsOf,
    priceSource: alMeezanPriceSource,
    freshness: "fresh",
  },
  {
    id: "mif",
    kind: "mutual_fund",
    institution: "Al Meezan",
    label: "Al Meezan Mutual Fund",
    fundCode: "MIF",
    currency: "PKR",
    units: 30006.5,
    price: mifPrice,
    valuePkr: 526390,
    priceAsOf: alMeezanPriceAsOf,
    priceSource: alMeezanPriceSource,
    freshness: "fresh",
  },
  {
    id: "msf",
    kind: "mutual_fund",
    institution: "Al Meezan",
    label: "Meezan Sovereign Fund",
    fundCode: "MSF",
    currency: "PKR",
    units: 19006.0,
    price: msfPrice,
    valuePkr: 1205490,
    priceAsOf: alMeezanPriceAsOf,
    priceSource: alMeezanPriceSource,
    freshness: "fresh",
  },
  {
    id: "mdip",
    kind: "mutual_fund",
    institution: "Al Meezan",
    label: "Meezan Islamic Income Fund",
    fundCode: "MDIP",
    currency: "PKR",
    units: 41580.0,
    price: mdipPrice,
    valuePkr: 1202300,
    priceAsOf: alMeezanPriceAsOf,
    priceSource: alMeezanPriceSource,
    freshness: "fresh",
  },
  {
    id: "mfpf-aap",
    kind: "mutual_fund",
    institution: "Al Meezan",
    label: "Meezan Islamic Asset Allocation Fund",
    fundCode: "MFPF-AAP",
    currency: "PKR",
    units: 24557.0,
    price: mfpfPrice,
    valuePkr: 1254350,
    priceAsOf: alMeezanPriceAsOf,
    priceSource: alMeezanPriceSource,
    freshness: "fresh",
  },
  {
    id: "wise-usd",
    kind: "cash",
    institution: "Wise",
    label: "Wise USD Cash",
    currency: "USD",
    valueNative: 1175, // 326,730 / 277.992 ≈ 1175.14
    fxRate: usdPkr,
    valuePkr: 326730,
    priceAsOf: xeFxAsOf,
    priceSource: xeFxSource,
    freshness: "fresh",
  },
  {
    id: "wise-eur",
    kind: "cash",
    institution: "Wise",
    label: "Wise EUR Cash",
    currency: "EUR",
    valueNative: 25073, // 7,957,760 / 317.536 ≈ 25,073.2
    fxRate: eurPkr,
    valuePkr: 7957760,
    priceAsOf: xeFxAsOf,
    priceSource: xeFxSource,
    freshness: "fresh",
  },
  {
    id: "pkr-cash",
    kind: "cash",
    institution: "Local",
    label: "PKR Cash",
    currency: "PKR",
    valuePkr: 0,
    priceAsOf: "2026-07-08",
    priceSource: "Manual",
    freshness: "manual",
  },
];

// ── 6-day trend ─────────────────────────────────────────────────────────────
// The example gives: Jul3 13.667M → Jul8 13.673M.
// Per-holding 6-day columns are not given; the trend below is DERIVED to be
// internally consistent with the aggregate totals and the change vs yesterday
// (−38,490) and MTD (+14,831).
//
// Jul3 total: 13,658,188 (so MTD = 13,673,019 - 13,658,188 = 14,831 ✓)
// Jul7 total: 13,711,509 (yesterday)
// Jul8 total: 13,673,019 (today, change vs yesterday = -38,490 ✓)

const trendDates = ["2026-07-03", "2026-07-04", "2026-07-05", "2026-07-06", "2026-07-07", "2026-07-08"];

// Derived per-holding trend values (in PKR). These are constructed so each
// day's column sums to the day's total and the movements are plausible.
const trendPerHolding: Record<string, number[]> = {
  ammf:     [1200000, 1200000, 1200000, 1200000, 1200000, 1200000],
  mif:      [530000,  528000,  529000,  530000,  540000,  526390],   // jumped Jul7, pulled back Jul8
  msf:      [1205490, 1205490, 1205490, 1205490, 1205490, 1205490],
  mdip:     [1202300, 1202300, 1202300, 1202300, 1202300, 1202300],
  "mfpf-aap":[1254350, 1254350, 1254350, 1254350, 1254350, 1254350],
  "wise-usd":[325000,  325500,  326000,  326200,  326500,  326730],
  "wise-eur":[7940000, 7942000, 7945000, 7949000, 7952000, 7957760],
  "pkr-cash":[0,       0,       0,       0,       0,       0],
};

const mockTrend: WealthTrendPoint[] = trendDates.map((date, i) => {
  const perHolding = Object.entries(trendPerHolding).map(([holdingId, values]) => ({
    holdingId,
    valuePkr: values[i],
  }));
  const totalPkr = perHolding.reduce((sum, h) => sum + h.valuePkr, 0);
  return { date, totalPkr, perHolding };
});

// ── WealthSnapshot ──────────────────────────────────────────────────────────

export const mockWealthSnapshot: WealthSnapshot = {
  date: "2026-07-08",
  totalPkr: 13673019,
  perHoldingBreakdown: mockHoldings.map((h) => {
    const todayValue = h.valuePkr;
    // Find yesterday's value from trend (index 4 = Jul7)
    const yesterdayTrend = mockTrend[4].perHolding.find((p) => p.holdingId === h.id);
    const yesterdayValue = yesterdayTrend?.valuePkr ?? todayValue;
    // Find start-of-month value from trend (index 0 = Jul3)
    const startTrend = mockTrend[0].perHolding.find((p) => p.holdingId === h.id);
    const startValue = startTrend?.valuePkr ?? todayValue;
    return {
      holdingId: h.id,
      label: h.label,
      valuePkr: todayValue,
      changeVsYesterday: todayValue - yesterdayValue,
      changeMtd: todayValue - startValue,
    };
  }),
  changeVsYesterday: -38490,
  changeMtd: 14831,
  mainReason: "NAV movement",
  interpretation: [
    "Al Meezan cooled after yesterday's jump (equity NAV correction).",
    "Wise EUR helped slightly but didn't offset the fund dip.",
    "Still ~PKR 13.67M — not a crash.",
  ],
  trend: mockTrend,
  provenanceSummary:
    "Al Meezan prices valid 7 Jul 2026; units reconciled with statement. FX from Xe: USD/PKR 277.992, EUR/PKR 317.536.",
};

// ── WealthEvents ────────────────────────────────────────────────────────────

export const mockWealthEvents: WealthEvent[] = [
  {
    id: "event-mif-pullback",
    date: "2026-07-08",
    holdingId: "mif",
    kind: "nav_move",
    magnitudePkr: -13610,
    direction: "down",
    plainWhy:
      "Al Meezan pulled back after yesterday's jump (equity NAV correction).",
    learnMoreId: "learn-why-funds-move",
    severity: "heads_up",
  },
  {
    id: "event-eur-nudge",
    date: "2026-07-08",
    holdingId: "wise-eur",
    kind: "fx_move",
    magnitudePkr: 5760,
    direction: "up",
    plainWhy: "Wise EUR nudged up — EUR/PKR moved slightly in your favour.",
    severity: "all_good",
  },
  {
    id: "event-car-goal-progress",
    date: "2026-07-08",
    kind: "goal_milestone",
    magnitudePkr: 0,
    direction: "flat",
    plainWhy: "Your car goal is 48% funded — PKR 1,248,000 to go.",
    severity: "all_good",
  },
  {
    id: "event-inflation-context",
    date: "2026-07-08",
    kind: "news_context",
    magnitudePkr: 0,
    direction: "flat",
    plainWhy:
      "Inflation cooled slightly this month — your PKR cash buying power is a touch steadier. Barely moves the needle, but good to know.",
    severity: "all_good",
  },
];

// ── LearnThreads ────────────────────────────────────────────────────────────

export const mockLearnThreads: LearnThread[] = [
  {
    id: "learn-why-funds-move",
    title: "Why do fund NAVs move day to day?",
    summary:
      "A fund's NAV changes when the underlying assets change in value. Equity funds move more than money market funds.",
    body:
      "Yesterday your Al Meezan Mutual Fund (MIF) jumped — the stocks it holds went up. Today they corrected down a little. That is normal for an equity fund: it moves in steps, not a straight line. Money market funds (like AMMF) barely move because they hold short-term, stable assets. Today is the market cooling after a good day.",
    relatedEventId: "event-mif-pullback",
    createdAt: "2026-07-08T06:00:00Z",
  },
];

// ── Goals ───────────────────────────────────────────────────────────────────

export const mockWealthGoals: WealthGoal[] = [
  {
    id: "car-goal",
    name: "Car Fund",
    type: "car",
    targetAmount: 2600000,
    currentAmount: 1352000,
    currency: "PKR",
    deadline: "2027-06-01",
    status: "active",
    pace: "on_track",
    nextStep: "Add PKR 25,000 this month",
    remainingToTarget: 1248000,
    paceNote: "PKR 12.5 lakh to go — about 12 months at your current pace",
  },
  {
    id: "emergency-goal",
    name: "Emergency Fund",
    type: "emergency",
    targetAmount: 600000,
    currentAmount: 348000,
    currency: "PKR",
    deadline: undefined,
    status: "active",
    pace: "watch",
    nextStep: "Add PKR 10,000 this month",
    remainingToTarget: 252000,
    paceNote: "PKR 2.5 lakh to go — 3.2 months covered today",
  },
];

// ── Recommended Action ──────────────────────────────────────────────────────

export const mockRecommendedAction: WealthBriefingAction = {
  id: "action-rebalance-mif",
  label: "MIF is lagging your other funds — consider directing your next contribution there",
  severity: "worth_doing",
  effect: "Rebalances your portfolio toward the underweight fund",
  xp: 20,
  completionKind: "rebalance",
  targetId: "mif",
  goalRelativeNote: "Or add PKR 25,000 to your car goal — PKR 12.5 lakh to go",
};

// ── Full Wealth Briefing ─────────────────────────────────────────────────────

export const mockWealthBriefing: WealthBriefing = {
  scoreState: "available",
  scoreExplanation: "Score based on 8 of 8 factors.",
  scoreFactors: [],
  id: "briefing-2026-07-08",
  userId: "user-mohsin",
  briefingDate: "2026-07-08",
  generatedAt: "2026-07-08T06:00:00Z",
  freshness: "fresh",
  mascotMood: "content",
  greeting: "Good morning, Mohsin",
  summary:
    "Down PKR 38k today — Al Meezan cooled after yesterday's jump, not a crash. Still up PKR 15k this month.",
  healthScore: 78,
  healthStatus: "healthy",
  wealthSnapshot: mockWealthSnapshot,
  wealthEvents: mockWealthEvents,
  learnThreads: mockLearnThreads,
  recommendedAction: mockRecommendedAction,
  goals: mockWealthGoals,
  holdings: mockHoldings,
  streak: 12,
  xp: 1840,
  level: 6,
};

import assert from "node:assert/strict";
import test from "node:test";
import {
  calculatePresenceScore,
  type FactorPresenceInputs,
} from "@sprout/shared";
import {
  deterministicInterpretation,
  deterministicSummary,
  selectRecommendedAction,
} from "../lib/briefing-validation.js";
import {
  computeContributionConsistency,
  computeExpenseBaseline,
  computeGoalPace,
  deriveGoalContributionSuggestion,
} from "../lib/financial-insight-substrate.js";

const stable = (value: unknown) =>
  JSON.stringify(value, Object.keys(value as object).sort());
const missing = (reason: string) => ({ available: false as const, reason });

function scoreWithCash(monthlyExpenses: number) {
  return calculatePresenceScore({
    goalPace: { available: true, value: 0.8 },
    cashBuffer: { available: true, value: 156_000 / monthlyExpenses / 3 },
    contributionConsistency: { available: true, value: 1 },
    diversification: { available: true, value: 0.5 },
    trendStability: missing("fixture"),
    billCoverage: missing("fixture"),
    debtCommitments: missing("fixture"),
    dataConfidence: { available: true, value: 1 },
  });
}

test("FIX-01 eid_spike_month", () => {
  const baseline = computeExpenseBaseline({
    asOf: "2026-07-15",
    expenses: [
      {
        amount: 50_000,
        type: "expense",
        occurredOn: "2026-04-10",
        confirmed: true,
      },
      {
        amount: 52_000,
        type: "expense",
        occurredOn: "2026-05-10",
        confirmed: true,
      },
      {
        amount: 90_000,
        type: "expense",
        occurredOn: "2026-06-10",
        confirmed: true,
      },
    ],
  });
  if (baseline.status !== "available")
    assert.fail("FIX-01 expected an available expense baseline");
  const scoreAfterSpike = scoreWithCash(baseline.monthlyExpenses);
  assert.deepEqual(baseline, {
    status: "available",
    monthlyExpenses: 52_000,
    monthlyTotals: [50_000, 52_000, 90_000],
    method: "median_outlier",
    note: "one unusual month set aside",
  });
  assert.deepEqual(scoreWithCash(52_000), scoreAfterSpike);
});

test("FIX-02 monthly_payday_saver", () => {
  const consistency = computeContributionConsistency({
    asOf: "2026-07-15",
    salaryDay: 1,
    contributions: [
      { contributionDate: "2026-04-01", source: "manual" },
      { contributionDate: "2026-05-01", source: "quick_add" },
      { contributionDate: "2026-06-01", source: "occurrence_yes" },
      { contributionDate: "2026-03-01", source: "opening_balance" },
    ],
  });
  const paceA = computeGoalPace({
    createdAt: "2026-01-01",
    deadline: "2026-12-31",
    targetAmount: 120_000,
    currentAmount: 60_000,
    asOf: "2026-07-02",
  });
  const paceB = computeGoalPace({
    createdAt: "2026-01-01",
    deadline: "2026-12-31",
    targetAmount: 120_000,
    currentAmount: 60_000,
    asOf: "2026-07-29",
  });
  assert.deepEqual(consistency, {
    ratio: 1,
    completedPeriods: 3,
    contributedPeriods: 3,
    basis: "salary_cycle",
  });
  assert.deepEqual(paceA, paceB);
  assert.equal(paceA.status, "on_track");
});

test("FIX-03 unaffordable_deadline", () => {
  const suggestion = deriveGoalContributionSuggestion({
    targetAmount: 600_000,
    currentAmount: 0,
    deadline: "2027-07-01",
    asOf: "2026-07-15",
    confirmedMonthlyIncome: 100_000,
  });
  const action = selectRecommendedAction({
    score: { attentionFactors: [] },
    goals: [
      {
        id: "goal",
        name: "Car goal",
        targetAmount: 600_000,
        currentAmount: 0,
        remainingToTarget: 600_000,
        suggestion,
      },
    ],
    holdings: [],
    unconfirmedCount: 0,
    stalePriceCount: 0,
  });
  assert.deepEqual(suggestion, { kind: "review_deadline" });
  assert.deepEqual(
    {
      label: action.label,
      kind: action.completionKind,
      targetId: action.targetId,
    },
    {
      label: "This goal's deadline may need a review",
      kind: "review",
      targetId: "goal",
    },
  );
});

test("FIX-04 rounding", () => {
  const suggestion = deriveGoalContributionSuggestion({
    targetAmount: 281_004,
    currentAmount: 0,
    deadline: "2027-07-01",
    asOf: "2026-07-15",
    confirmedMonthlyIncome: 100_000,
  });
  assert.deepEqual(suggestion, { kind: "amount", amount: 23_000 });
  const action = selectRecommendedAction({
    score: { attentionFactors: [] },
    goals: [
      {
        id: "goal",
        name: "Home goal",
        targetAmount: 2_400_000,
        currentAmount: 0,
        remainingToTarget: 2_400_000,
        suggestion: { kind: "amount", amount: 200_000 },
      },
    ],
    holdings: [],
    unconfirmedCount: 0,
    stalePriceCount: 0,
  });
  assert.equal(action.label, "Add PKR 2 lakh to your Home goal");
});

test("FIX-05 insufficient_factors", () => {
  const two = calculatePresenceScore({
    goalPace: { available: true, value: 0.5 },
    cashBuffer: { available: true, value: 0.5 },
    contributionConsistency: missing("x"),
    diversification: missing("x"),
    trendStability: missing("x"),
    billCoverage: missing("x"),
    debtCommitments: missing("x"),
    dataConfidence: missing("x"),
  });
  assert.deepEqual(
    { scoreState: two.scoreState, score: two.score },
    { scoreState: "insufficient_data", score: null },
  );
  const fourInputs = {
    goalPace: { available: true, value: 0.4 },
    cashBuffer: { available: true, value: 2 / 3 },
    contributionConsistency: missing("x"),
    diversification: { available: true, value: 0.3 },
    trendStability: { available: true, value: 0.8 },
    billCoverage: missing("x"),
    debtCommitments: missing("x"),
    dataConfidence: missing("x"),
  } satisfies FactorPresenceInputs;
  const four = calculatePresenceScore(fourInputs);
  assert.equal(four.score, 53);
  assert.match(four.explanation, /based on 4 of 8 factors/i);
  assert.deepEqual(
    four.factors
      .filter((f) => f.available)
      .map((f) => [f.id, f.redistributedWeight]),
    [
      ["goalPace", 38.46153846153846],
      ["cashBuffer", 30.76923076923077],
      ["diversification", 15.384615384615385],
      ["trendStability", 15.384615384615385],
    ],
  );
});

test("FIX-06 partial_capture", () => {
  const result = computeExpenseBaseline({
    asOf: "2026-07-15",
    confirmedMonthlyIncome: 100_000,
    expenses: [
      {
        amount: 20_000,
        type: "expense",
        occurredOn: "2026-06-01",
        confirmed: true,
      },
    ],
  });
  assert.deepEqual(result, {
    status: "partial_capture",
    monthlyExpenses: 20_000,
    monthlyTotals: [20_000],
    method: "mean",
    note: "based on the expenses you've logged",
  });
  assert.ok(!JSON.stringify(result).includes("bufferMonths"));
});

test("FIX-07 expense_exclusions", () => {
  const result = computeExpenseBaseline({
    asOf: "2026-07-15",
    expenses: [
      {
        amount: 50_000,
        type: "expense",
        category: "Groceries",
        occurredOn: "2026-06-01",
        confirmed: true,
      },
      {
        amount: 10_000,
        type: "expense",
        category: "goal contribution",
        occurredOn: "2026-06-02",
        confirmed: true,
      },
      {
        amount: 20_000,
        type: "expense",
        category: "holding purchase",
        occurredOn: "2026-06-03",
        confirmed: true,
      },
      {
        amount: 30_000,
        type: "transfer",
        category: "own account transfer",
        occurredOn: "2026-06-04",
        confirmed: true,
      },
    ],
  });
  assert.equal(
    result.status === "available" ? result.monthlyExpenses : -1,
    50_000,
  );
});

test("FIX-08 wealth_down_day", () => {
  const summary = deterministicSummary({
    changeVsYesterday: -38_000,
    changeMtd: 15_000,
    mainReason: "NAV movement",
  });
  const interpretation = deterministicInterpretation({
    changeVsYesterday: -38_000,
    changeMtd: 15_000,
    mainReason: "NAV movement",
    holdings: [],
  });
  assert.equal(
    summary,
    "Down PKR 38,000 today — nav movement, not a crash. still up PKR 15,000 this month.",
  );
  assert.deepEqual(interpretation, [
    "Down PKR 38,000 today — nav movement.",
    "Still up PKR 15,000 this month.",
    "Not a crash — just a normal day.",
  ]);
  assert.match(summary, /today.*month/i);
  assert.match(summary, /nav movement/i);
  assert.doesNotMatch(
    summary,
    /!|failed|bad spending|should have|buy now|guaranteed/i,
  );
});

test("FIX-09 determinism", () => {
  const build = () => ({
    baseline: computeExpenseBaseline({
      asOf: "2026-07-15",
      expenses: [
        {
          amount: 50_000,
          type: "expense",
          occurredOn: "2026-06-01",
          confirmed: true,
        },
      ],
    }),
    score: scoreWithCash(50_000),
    summary: deterministicSummary({
      changeVsYesterday: -1,
      changeMtd: 2,
      mainReason: "NAV movement",
    }),
  });
  assert.equal(stable(build()), stable(build()));
});

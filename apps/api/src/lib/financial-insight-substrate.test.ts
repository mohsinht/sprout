import assert from "node:assert/strict";
import test from "node:test";
import {
  computeContributionConsistency,
  computeExpenseBaseline,
  computeGoalPace,
  deriveGoalContributionSuggestion,
} from "./financial-insight-substrate.js";
import { PersonalInsightSchema } from "@sprout/shared";

test("pakistan fixture: Eid spike uses median without shame", () => {
  const result = computeExpenseBaseline({
    asOf: "2026-07-15",
    expenses: [
      {
        amount: 50_000,
        type: "expense",
        occurredOn: "2026-04-20",
        confirmed: true,
      },
      {
        amount: 52_000,
        type: "expense",
        occurredOn: "2026-05-20",
        confirmed: true,
      },
      {
        amount: 90_000,
        type: "expense",
        occurredOn: "2026-06-20",
        confirmed: true,
      },
    ],
  });
  assert.deepEqual(result, {
    status: "available",
    monthlyExpenses: 52_000,
    monthlyTotals: [50_000, 52_000, 90_000],
    method: "median_outlier",
    note: "one unusual month set aside",
  });
});

test("partial capture does not make a numeric buffer trustworthy", () => {
  const result = computeExpenseBaseline({
    asOf: "2026-07-15",
    confirmedMonthlyIncome: 100_000,
    expenses: [
      {
        amount: 20_000,
        type: "expense",
        occurredOn: "2026-06-20",
        confirmed: true,
      },
    ],
  });
  assert.equal(result.status, "partial_capture");
});

test("pakistan fixture: monthly payday saver scores every completed salary cycle", () => {
  const result = computeContributionConsistency({
    asOf: "2026-07-15",
    salaryDay: 1,
    contributions: [
      { contributionDate: "2026-04-01", source: "manual" },
      { contributionDate: "2026-05-01", source: "quick_add" },
      { contributionDate: "2026-06-01", source: "occurrence_yes" },
      { contributionDate: "2026-03-01", source: "opening_balance" },
    ],
  });
  assert.equal(result.ratio, 1);
  assert.equal(result.basis, "salary_cycle");
});

test("goal pace holds steady inside a month and uses grace bands", () => {
  const first = computeGoalPace({
    createdAt: "2026-01-15",
    deadline: "2026-12-15",
    targetAmount: 120_000,
    currentAmount: 40_000,
    asOf: "2026-07-02",
  });
  const later = computeGoalPace({
    createdAt: "2026-01-15",
    deadline: "2026-12-15",
    targetAmount: 120_000,
    currentAmount: 40_000,
    asOf: "2026-07-29",
  });
  assert.deepEqual(first, later);
  assert.equal(first.status, "slightly_behind");
});

test("pakistan fixture: unaffordable deadline becomes a review action", () => {
  const result = deriveGoalContributionSuggestion({
    targetAmount: 600_000,
    currentAmount: 0,
    deadline: "2027-07-01",
    asOf: "2026-07-15",
    confirmedMonthlyIncome: 100_000,
  });
  assert.deepEqual(result, { kind: "review_deadline" });
});

test("goal contribution rounds down to a practical denomination", () => {
  const result = deriveGoalContributionSuggestion({
    targetAmount: 281_000,
    currentAmount: 0,
    deadline: "2027-07-01",
    asOf: "2026-07-15",
    confirmedMonthlyIncome: 100_000,
  });
  assert.deepEqual(result, { kind: "amount", amount: 23_000 });
});

test("personal insight contract requires exactly one auditable origin", () => {
  const base = {
    id: "insight-1",
    userId: "user-1",
    headline: "Rate changed",
    personalMeaning: "Your PKR cash is directly relevant.",
    detail: "A sourced explanation.",
    deterministicHeadline: "Rate changed",
    deterministicPersonalMeaning: "Your PKR cash is directly relevant.",
    deterministicDetail: "A sourced explanation.",
    severity: "heads_up" as const,
    sourceLabel: "SBP",
    asOf: "2026-07-15",
    freshness: "fresh" as const,
    templateId: "policy-rate-pkr-cash",
    templateVersion: "1",
    presentationMode: "deterministic" as const,
    generatedAt: "2026-07-15T00:00:00.000Z",
  };
  assert.equal(
    PersonalInsightSchema.safeParse({ ...base, worldFactId: "fact-1" }).success,
    true,
  );
  assert.equal(PersonalInsightSchema.safeParse(base).success, false);
  assert.equal(
    PersonalInsightSchema.safeParse({
      ...base,
      worldFactId: "fact-1",
      wealthEventId: "event-1",
    }).success,
    false,
  );
});

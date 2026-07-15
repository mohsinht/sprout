export type ExpenseInput = {
  amount: number;
  type: "expense" | "income" | "transfer";
  occurredOn: string;
  confirmed: boolean;
  category?: string;
};

export type ExpenseBaseline =
  | { status: "unavailable"; reason: "no_complete_month" }
  | {
      status: "partial_capture";
      monthlyExpenses: number;
      monthlyTotals: number[];
      method: "mean" | "median_outlier";
      note: "based on the expenses you've logged";
    }
  | {
      status: "available";
      monthlyExpenses: number;
      monthlyTotals: number[];
      method: "mean" | "median_outlier";
      note?: "one unusual month set aside";
    };

const excludedExpenseCategories = new Set([
  "goal contribution",
  "goal_contribution",
  "investment",
  "investments",
  "holding purchase",
  "holding_purchase",
  "own account transfer",
  "own_account_transfer",
]);

function parseDate(value: string): Date {
  return new Date(`${value.slice(0, 10)}T00:00:00.000Z`);
}

function monthKey(date: Date): string {
  return `${date.getUTCFullYear()}-${String(date.getUTCMonth() + 1).padStart(2, "0")}`;
}

function addMonths(date: Date, delta: number): Date {
  return new Date(
    Date.UTC(date.getUTCFullYear(), date.getUTCMonth() + delta, 1),
  );
}

function median(values: number[]): number {
  const ordered = [...values].sort((a, b) => a - b);
  const middle = Math.floor(ordered.length / 2);
  return ordered.length % 2 === 0
    ? (ordered[middle - 1] + ordered[middle]) / 2
    : ordered[middle];
}

export function computeExpenseBaseline(params: {
  asOf: string;
  expenses: ExpenseInput[];
  confirmedMonthlyIncome?: number;
}): ExpenseBaseline {
  const currentMonth = new Date(
    Date.UTC(
      parseDate(params.asOf).getUTCFullYear(),
      parseDate(params.asOf).getUTCMonth(),
      1,
    ),
  );
  const completeMonthKeys = [3, 2, 1].map((monthsAgo) =>
    monthKey(addMonths(currentMonth, -monthsAgo)),
  );
  const totals = new Map(completeMonthKeys.map((key) => [key, 0]));
  const observed = new Set<string>();

  for (const row of params.expenses) {
    const key = row.occurredOn.slice(0, 7);
    if (!totals.has(key) || !row.confirmed) continue;
    observed.add(key);
    const category = row.category?.trim().toLowerCase();
    if (
      row.type === "expense" &&
      (!category || !excludedExpenseCategories.has(category))
    ) {
      totals.set(key, (totals.get(key) ?? 0) + row.amount);
    }
  }

  const monthlyTotals = completeMonthKeys
    .filter((key) => observed.has(key))
    .map((key) => totals.get(key) ?? 0);
  if (monthlyTotals.length === 0)
    return { status: "unavailable", reason: "no_complete_month" };

  const middle = median(monthlyTotals);
  const hasOutlier =
    monthlyTotals.length >= 3 &&
    middle > 0 &&
    monthlyTotals.some((value) => Math.abs(value - middle) / middle > 0.5);
  const monthlyExpenses = Math.round(
    hasOutlier
      ? middle
      : monthlyTotals.reduce((sum, value) => sum + value, 0) /
          monthlyTotals.length,
  );
  const method = hasOutlier ? ("median_outlier" as const) : ("mean" as const);

  if (
    params.confirmedMonthlyIncome != null &&
    monthlyExpenses < params.confirmedMonthlyIncome * 0.25
  ) {
    return {
      status: "partial_capture",
      monthlyExpenses,
      monthlyTotals,
      method,
      note: "based on the expenses you've logged",
    };
  }
  return hasOutlier
    ? {
        status: "available",
        monthlyExpenses,
        monthlyTotals,
        method,
        note: "one unusual month set aside",
      }
    : { status: "available", monthlyExpenses, monthlyTotals, method };
}

export type ContributionInput = {
  contributionDate: string;
  source: "opening_balance" | "manual" | "quick_add" | "occurrence_yes";
};

function clampedSalaryDay(
  year: number,
  month: number,
  salaryDay: number,
): Date {
  const lastDay = new Date(Date.UTC(year, month + 1, 0)).getUTCDate();
  return new Date(Date.UTC(year, month, Math.min(salaryDay, lastDay)));
}

export function computeContributionConsistency(params: {
  asOf: string;
  contributions: ContributionInput[];
  salaryDay?: number;
}): {
  ratio: number;
  completedPeriods: 3;
  contributedPeriods: number;
  basis: "salary_cycle" | "calendar_month";
} {
  const asOf = parseDate(params.asOf);
  const valid = params.contributions.filter(
    (item) => item.source !== "opening_balance",
  );
  const periods: Array<{ start: Date; end: Date }> = [];

  if (params.salaryDay != null) {
    const thisMonthPayday = clampedSalaryDay(
      asOf.getUTCFullYear(),
      asOf.getUTCMonth(),
      params.salaryDay,
    );
    const latestBoundary =
      thisMonthPayday <= asOf
        ? thisMonthPayday
        : clampedSalaryDay(
            asOf.getUTCFullYear(),
            asOf.getUTCMonth() - 1,
            params.salaryDay,
          );
    for (let index = 0; index < 3; index += 1) {
      const end = clampedSalaryDay(
        latestBoundary.getUTCFullYear(),
        latestBoundary.getUTCMonth() - index,
        params.salaryDay,
      );
      const start = clampedSalaryDay(
        end.getUTCFullYear(),
        end.getUTCMonth() - 1,
        params.salaryDay,
      );
      periods.push({ start, end });
    }
  } else {
    const currentMonth = new Date(
      Date.UTC(asOf.getUTCFullYear(), asOf.getUTCMonth(), 1),
    );
    for (let index = 0; index < 3; index += 1) {
      periods.push({
        start: addMonths(currentMonth, -(index + 1)),
        end: addMonths(currentMonth, -index),
      });
    }
  }

  const contributedPeriods = periods.filter(({ start, end }) =>
    valid.some((item) => {
      const date = parseDate(item.contributionDate);
      return date >= start && date < end;
    }),
  ).length;
  return {
    ratio: contributedPeriods / 3,
    completedPeriods: 3,
    contributedPeriods,
    basis: params.salaryDay != null ? "salary_cycle" : "calendar_month",
  };
}

export type GoalPace = {
  fundedRatio: number;
  expectedRatio: number | null;
  status: "on_track" | "slightly_behind" | "needs_review" | "no_deadline";
  evaluatedAt: string;
};

export function computeGoalPace(params: {
  createdAt: string;
  deadline?: string | null;
  targetAmount: number;
  currentAmount: number;
  asOf: string;
}): GoalPace {
  const fundedRatio =
    params.targetAmount > 0
      ? Math.min(1, params.currentAmount / params.targetAmount)
      : 0;
  const asOf = parseDate(params.asOf);
  const boundary = new Date(
    Date.UTC(asOf.getUTCFullYear(), asOf.getUTCMonth(), 1),
  );
  const evaluatedAt = boundary.toISOString().slice(0, 10);
  if (!params.deadline)
    return {
      fundedRatio,
      expectedRatio: null,
      status: "no_deadline",
      evaluatedAt,
    };

  const created = parseDate(params.createdAt);
  const deadline = parseDate(params.deadline);
  const total = deadline.getTime() - created.getTime();
  const elapsed = boundary.getTime() - created.getTime();
  const expectedRatio =
    total <= 0 ? 1 : Math.min(1, Math.max(0, elapsed / total));
  const paceRatio = expectedRatio === 0 ? 1 : fundedRatio / expectedRatio;
  const status =
    paceRatio >= 0.85
      ? "on_track"
      : paceRatio >= 0.6
        ? "slightly_behind"
        : "needs_review";
  return { fundedRatio, expectedRatio, status, evaluatedAt };
}

function contributionStep(amount: number): number {
  if (amount < 25_000) return 1_000;
  if (amount < 100_000) return 5_000;
  if (amount < 250_000) return 10_000;
  return 25_000;
}

export function deriveGoalContributionSuggestion(params: {
  targetAmount: number;
  currentAmount: number;
  deadline?: string | null;
  asOf: string;
  confirmedMonthlyIncome?: number;
  safeToSpend?: number;
}):
  | { kind: "amount"; amount: number }
  | { kind: "add_without_amount" }
  | { kind: "review_deadline" } {
  const remaining = Math.max(0, params.targetAmount - params.currentAmount);
  if (!params.deadline || remaining === 0)
    return { kind: "add_without_amount" };
  const asOf = parseDate(params.asOf);
  const deadline = parseDate(params.deadline);
  const remainingMonths = Math.max(
    1,
    (deadline.getUTCFullYear() - asOf.getUTCFullYear()) * 12 +
      deadline.getUTCMonth() -
      asOf.getUTCMonth(),
  );
  const raw = Math.min(remaining, remaining / remainingMonths);
  const rounded =
    Math.floor(raw / contributionStep(raw)) * contributionStep(raw);
  if (params.confirmedMonthlyIncome == null && params.safeToSpend == null)
    return { kind: "add_without_amount" };
  if (
    (params.confirmedMonthlyIncome != null &&
      rounded > params.confirmedMonthlyIncome * 0.4) ||
    (params.safeToSpend != null && rounded > params.safeToSpend)
  )
    return { kind: "review_deadline" };
  return rounded > 0
    ? { kind: "amount", amount: Math.min(remaining, rounded) }
    : { kind: "add_without_amount" };
}

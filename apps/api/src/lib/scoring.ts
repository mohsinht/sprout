/**
 * V0 Wealth-Health Score — deterministic, explainable, actionable.
 * Per spec/scoring_model.md. The AI may NOT change scores, thresholds, or action ranking.
 * Code owns the arithmetic; the model only writes words.
 *
 * Factors (total 100):
 *   Goal pace (25), Cash buffer (20), Contribution consistency (15),
 *   Diversification (10), Volatility-adjusted trend (10), Bill coverage (10),
 *   Debt/fixed commitments (5), Data confidence (5).
 */

export type ScoreBand = "strong" | "healthy" | "watch" | "urgent";
export type MascotMood = "thriving" | "content" | "watchful" | "concerned";
export type Severity = "all_good" | "heads_up" | "worth_doing" | "needs_attention";

export interface ScoreFactor {
  id: string;
  label: string;
  detail: string;
  contribution: number;
  maxContribution: number;
}

export interface ScoreInputs {
  goalPaceRatio: number; // 0..1, weighted avg of currentAmount/targetAmount
  emergencyBufferMonths: number;
  contributionConsistencyRatio: number; // 0..1, fraction of last 4 weeks with a contribution
  diversificationRatio: number; // 0..1, 1 - (largest holding / total)
  trendStabilityRatio: number; // 0..1, steadiness of wealth trend
  upcomingBillsCoverageRatio: number; // 0..1
  debtPaymentRatio: number; // 0..1, required debt / monthly income (0 if no debt)
  unconfirmedImportantTransactions: number;
  stalePriceCount: number;
}

export interface ScoreResult {
  score: number; // 0-100
  band: ScoreBand;
  mascotMood: MascotMood;
  delta: number; // change from previous score
  positiveFactors: ScoreFactor[];
  attentionFactors: ScoreFactor[];
}

const clamp = (v: number, min: number, max: number) => Math.min(max, Math.max(min, v));

function bandFromScore(score: number): ScoreBand {
  if (score >= 85) return "strong";
  if (score >= 70) return "healthy";
  if (score >= 50) return "watch";
  return "urgent";
}

function moodFromBand(band: ScoreBand): MascotMood {
  switch (band) {
    case "strong": return "thriving";
    case "healthy": return "content";
    case "watch": return "watchful";
    case "urgent": return "concerned";
  }
}

export function calculateWealthHealthScore(inputs: ScoreInputs): ScoreResult {
  // Goal pace, 25 points
  const goalPacePoints = clamp(inputs.goalPaceRatio, 0, 1) * 25;

  // Cash buffer, 20 points
  const cashBufferPoints = clamp(inputs.emergencyBufferMonths / 3, 0, 1) * 20;

  // Contribution consistency, 15 points
  const contributionPoints = clamp(inputs.contributionConsistencyRatio, 0, 1) * 15;

  // Diversification, 10 points
  const diversificationPoints = clamp(inputs.diversificationRatio, 0, 1) * 10;

  // Volatility-adjusted trend, 10 points
  const trendPoints = clamp(inputs.trendStabilityRatio, 0, 1) * 10;

  // Bill coverage, 10 points
  const billPoints = clamp(inputs.upcomingBillsCoverageRatio, 0, 1) * 10;

  // Debt/fixed commitments, 5 points
  const debtPoints = clamp(1 - inputs.debtPaymentRatio / 0.35, 0, 1) * 5;

  // Data confidence, 5 points
  const dataConfidencePoints =
    clamp(1 - (inputs.unconfirmedImportantTransactions + inputs.stalePriceCount) / 8, 0, 1) * 5;

  const score = Math.round(
    goalPacePoints +
      cashBufferPoints +
      contributionPoints +
      diversificationPoints +
      trendPoints +
      billPoints +
      debtPoints +
      dataConfidencePoints
  );

  const band = bandFromScore(score);
  const mascotMood = moodFromBand(band);

  const positiveFactors: ScoreFactor[] = [];
  const attentionFactors: ScoreFactor[] = [];

  // Goal pace
  if (inputs.goalPaceRatio >= 0.75) {
    positiveFactors.push({
      id: "goal_pace",
      label: "Goal pace is strong",
      detail: `Goals are ${Math.round(inputs.goalPaceRatio * 100)}% funded on average.`,
      contribution: Math.round(goalPacePoints),
      maxContribution: 25,
    });
  } else if (inputs.goalPaceRatio < 0.25) {
    attentionFactors.push({
      id: "goal_pace",
      label: "Goals need attention",
      detail: `Goals are only ${Math.round(inputs.goalPaceRatio * 100)}% funded on average.`,
      contribution: Math.round(goalPacePoints),
      maxContribution: 25,
    });
  }

  // Cash buffer
  if (inputs.emergencyBufferMonths >= 3) {
    positiveFactors.push({
      id: "cash_buffer",
      label: "Emergency buffer is strong",
      detail: `${inputs.emergencyBufferMonths.toFixed(1)} months covered.`,
      contribution: Math.round(cashBufferPoints),
      maxContribution: 20,
    });
  } else if (inputs.emergencyBufferMonths < 1) {
    attentionFactors.push({
      id: "cash_buffer",
      label: "Emergency fund is below one month",
      detail: `Only ${inputs.emergencyBufferMonths.toFixed(1)} months covered.`,
      contribution: Math.round(cashBufferPoints),
      maxContribution: 20,
    });
  }

  // Contribution consistency
  if (inputs.contributionConsistencyRatio >= 0.75) {
    positiveFactors.push({
      id: "contribution",
      label: "Consistent contributions",
      detail: "You've contributed in most recent weeks.",
      contribution: Math.round(contributionPoints),
      maxContribution: 15,
    });
  } else if (inputs.contributionConsistencyRatio < 0.25) {
    attentionFactors.push({
      id: "contribution",
      label: "Contributions are sparse",
      detail: "Adding to your goals regularly builds the habit.",
      contribution: Math.round(contributionPoints),
      maxContribution: 15,
    });
  }

  // Diversification
  if (inputs.diversificationRatio >= 0.6) {
    positiveFactors.push({
      id: "diversification",
      label: "Wealth is well spread",
      detail: "No single holding dominates your portfolio.",
      contribution: Math.round(diversificationPoints),
      maxContribution: 10,
    });
  } else if (inputs.diversificationRatio < 0.25) {
    attentionFactors.push({
      id: "diversification",
      label: "Wealth is concentrated",
      detail: "One holding is most of your wealth — consider spreading.",
      contribution: Math.round(diversificationPoints),
      maxContribution: 10,
    });
  }

  // Data confidence
  const dataIssues = inputs.unconfirmedImportantTransactions + inputs.stalePriceCount;
  if (dataIssues > 0) {
    attentionFactors.push({
      id: "data_confidence",
      label: `${dataIssues} item${dataIssues > 1 ? "s" : ""} need attention`,
      detail: `${inputs.unconfirmedImportantTransactions} unconfirmed, ${inputs.stalePriceCount} stale price${inputs.stalePriceCount !== 1 ? "s" : ""}.`,
      contribution: Math.round(dataConfidencePoints),
      maxContribution: 5,
    });
  }

  return {
    score,
    band,
    mascotMood,
    delta: 0, // set by caller comparing to previous briefing
    positiveFactors,
    attentionFactors,
  };
}

/** Compute trend stability ratio from daily total wealth values. */
export function computeTrendStability(dailyTotals: number[]): number {
  if (dailyTotals.length < 2) return 1; // not enough data = neutral

  const changes: number[] = [];
  for (let i = 1; i < dailyTotals.length; i++) {
    changes.push(dailyTotals[i] - dailyTotals[i - 1]);
  }

  const absChanges = changes.map((c) => Math.abs(c));
  const stdDev = Math.sqrt(
    absChanges.reduce((sum, v) => sum + (v - absChanges.reduce((a, b) => a + b, 0) / absChanges.length) ** 2, 0) /
      absChanges.length
  );
  const totalChange = Math.abs(dailyTotals[dailyTotals.length - 1] - dailyTotals[0]);

  if (totalChange === 0) return 1; // perfectly flat = stable
  return clamp(1 - stdDev / totalChange, 0, 1);
}

/** Compute diversification ratio: 1 - (largest holding / total). */
export function computeDiversification(holdingValues: number[]): number {
  const total = holdingValues.reduce((a, b) => a + b, 0);
  if (total === 0) return 1;
  const largest = Math.max(...holdingValues);
  return clamp(1 - largest / total, 0, 1);
}
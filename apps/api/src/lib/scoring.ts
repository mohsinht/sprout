export * from "@sprout/shared";

import { calculatePresenceScore, type FactorPresenceInputs } from "@sprout/shared";

export interface ScoreInputs {
  goalPaceRatio: number;
  emergencyBufferMonths: number;
  contributionConsistencyRatio: number;
  diversificationRatio: number;
  trendStabilityRatio: number;
  upcomingBillsCoverageRatio: number;
  debtPaymentRatio: number;
  unconfirmedImportantTransactions: number;
  stalePriceCount: number;
}

export function calculateWealthHealthScore(inputs: ScoreInputs) {
  const result = calculatePresenceScore({
    goalPace: { available: true, value: inputs.goalPaceRatio },
    cashBuffer: { available: true, value: inputs.emergencyBufferMonths / 3 },
    contributionConsistency: { available: true, value: inputs.contributionConsistencyRatio },
    diversification: { available: true, value: inputs.diversificationRatio },
    trendStability: { available: true, value: inputs.trendStabilityRatio },
    billCoverage: { available: true, value: inputs.upcomingBillsCoverageRatio },
    debtCommitments: { available: true, value: 1 - inputs.debtPaymentRatio / 0.35 },
    dataConfidence: { available: true, value: 1 - (inputs.unconfirmedImportantTransactions + inputs.stalePriceCount) / 8 },
  } satisfies FactorPresenceInputs);
  if (result.scoreState !== "available") throw new Error("All legacy score inputs must be available");
  const factor = (id: keyof FactorPresenceInputs) => result.factors.find((item) => item.id === id)!;
  return {
    ...result,
    delta: 0,
    positiveFactors: [],
    attentionFactors: inputs.emergencyBufferMonths < 1 ? [{
      id: "cash_buffer", label: "Emergency fund is below one month",
      detail: `Only ${inputs.emergencyBufferMonths.toFixed(1)} months covered.`,
      contribution: Math.round(factor("cashBuffer").points ?? 0), maxContribution: 20,
    }] : [],
  };
}

export function computeTrendStability(dailyTotals: number[]): number {
  if (dailyTotals.length < 2) return 1;
  const changes = dailyTotals.slice(1).map((value, index) => Math.abs(value - dailyTotals[index]));
  const mean = changes.reduce((a, b) => a + b, 0) / changes.length;
  const stdDev = Math.sqrt(changes.reduce((sum, value) => sum + (value - mean) ** 2, 0) / changes.length);
  const totalChange = Math.abs(dailyTotals.at(-1)! - dailyTotals[0]);
  return totalChange === 0 ? 1 : Math.min(1, Math.max(0, 1 - stdDev / totalChange));
}

export function computeDiversification(values: number[]): number {
  const total = values.reduce((a, b) => a + b, 0);
  return total === 0 ? 1 : Math.min(1, Math.max(0, 1 - Math.max(...values) / total));
}

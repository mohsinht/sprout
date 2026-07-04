import type { FinancialHealthScore } from "@sprout/shared";

export type ScoreInputs = {
  emergencyBufferMonths: number;
  spendingPaceRatio: number;
  savingsProgressRatio: number;
  debtPaymentRatio: number;
  upcomingBillsCoverageRatio: number;
  daysUntilSalary: number;
  investmentBuckets: number;
  unconfirmedTransactions: number;
  goalConsistencyRatio: number;
};

const clamp = (value: number, min: number, max: number) =>
  Math.min(max, Math.max(min, value));

const scoreBand = (score: number): FinancialHealthScore["status"] => {
  if (score >= 85) return "strong";
  if (score >= 70) return "healthy";
  if (score >= 50) return "watch";
  return "urgent";
};

export function calculateFinancialHealthScore(
  inputs: ScoreInputs
): FinancialHealthScore {
  // The model is intentionally transparent: every input maps to a visible behavior
  // Sprout can explain, instead of pretending to know the user's full financial life.
  const emergency = clamp(inputs.emergencyBufferMonths / 3, 0, 1) * 25;
  const spending = clamp((1.3 - inputs.spendingPaceRatio) / 0.35, 0, 1) * 20;
  const savings = clamp(inputs.savingsProgressRatio, 0, 1) * 15;
  const debt = clamp(1 - inputs.debtPaymentRatio / 0.35, 0, 1) * 10;
  const bills = clamp(inputs.upcomingBillsCoverageRatio, 0, 1) * 10;
  const salaryCalm = clamp((7 - inputs.daysUntilSalary) / 7, 0, 1) * 5;
  const diversification = clamp(inputs.investmentBuckets / 3, 0, 1) * 5;
  const confirmation = clamp(1 - inputs.unconfirmedTransactions / 8, 0, 1) * 5;
  const consistency = clamp(inputs.goalConsistencyRatio, 0, 1) * 5;

  const score = Math.round(
    emergency +
      spending +
      savings +
      debt +
      bills +
      salaryCalm +
      diversification +
      confirmation +
      consistency
  );

  const positiveFactors: string[] = [];
  const attentionFactors: string[] = [];

  if (inputs.emergencyBufferMonths >= 3) {
    positiveFactors.push("Emergency buffer is strong");
  } else {
    attentionFactors.push("Emergency fund needs more room");
  }

  if (inputs.spendingPaceRatio <= 1) {
    positiveFactors.push("Spending pace is under control");
  } else {
    attentionFactors.push("Spending pace is slightly high");
  }

  if (inputs.daysUntilSalary <= 3) {
    positiveFactors.push(`Salary lands in ${inputs.daysUntilSalary} days`);
  }

  if (inputs.investmentBuckets >= 2) {
    positiveFactors.push("Investments updated yesterday");
  }

  if (inputs.unconfirmedTransactions > 0) {
    attentionFactors.push(
      `${inputs.unconfirmedTransactions} transactions need confirmation`
    );
  }

  const recommendedAction =
    inputs.savingsProgressRatio < 0.8
      ? {
          title: "Move PKR 10,000 to Emergency Fund",
          xp: 20,
          impact: "+3 health score"
        }
      : inputs.unconfirmedTransactions > 0
        ? {
            title: "Confirm today's captured transactions",
            xp: 15,
            impact: "+2 health score"
          }
        : {
            title: "Review this week's spending pace",
            xp: 10,
            impact: "+1 health score"
          };

  return {
    score,
    status: scoreBand(score),
    summary:
      score >= 70
        ? "You are on track, but today's spending is slightly fast."
        : "You have a few money tasks to steady the week.",
    positiveFactors,
    attentionFactors,
    recommendedAction
  };
}

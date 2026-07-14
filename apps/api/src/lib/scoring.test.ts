import assert from "node:assert/strict";
import test from "node:test";
import { calculateWealthHealthScore } from "./scoring.js";
import { calculatePresenceScore } from "@sprout/shared";

test("audit_b2_score_golden_is_byte_identical", () => {
  const fixture = {
    goalPaceRatio: 0.4,
    emergencyBufferMonths: 2,
    contributionConsistencyRatio: 0.5,
    diversificationRatio: 0.3,
    trendStabilityRatio: 0.8,
    upcomingBillsCoverageRatio: 0.9,
    debtPaymentRatio: 0.1,
    unconfirmedImportantTransactions: 1,
    stalePriceCount: 1,
  };
  const first = calculateWealthHealthScore(fixture);
  const second = calculateWealthHealthScore(fixture);
  assert.equal(JSON.stringify(first), JSON.stringify(second));
  assert.equal(first.score, 58);
});

test("audit_b3_two_factors_produce_no_score", () => {
  const missing = (reason: string) => ({ available: false as const, reason });
  const result = calculatePresenceScore({
    goalPace: { available: true, value: 0.5 }, cashBuffer: { available: true, value: 0.5 },
    contributionConsistency: missing("missing"), diversification: missing("missing"),
    trendStability: missing("missing"), billCoverage: missing("missing"),
    debtCommitments: missing("missing"), dataConfidence: missing("missing"),
  });
  assert.equal(result.scoreState, "insufficient_data");
  assert.equal(result.score, null);
});

test("audit_b3_four_factors_redistribute_exactly", () => {
  const missing = (reason: string) => ({ available: false as const, reason });
  const result = calculatePresenceScore({
    goalPace: { available: true, value: 0.4 }, cashBuffer: { available: true, value: 2 / 3 },
    contributionConsistency: missing("missing"), diversification: { available: true, value: 0.3 },
    trendStability: { available: true, value: 0.8 }, billCoverage: missing("missing"),
    debtCommitments: missing("missing"), dataConfidence: missing("missing"),
  });
  assert.equal(result.scoreState, "available");
  assert.equal(result.score, 53);
  assert.match(result.explanation, /based on 4 of 8 factors/i);
});

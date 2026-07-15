import assert from "node:assert/strict";
import test from "node:test";
import {
  checkGuardrails,
  selectRecommendedAction,
} from "./briefing-validation.js";

test("audit_b7_movement_summary_requires_driver", () => {
  const briefing = {
    greeting: "Good evening, friend",
    summary: "Up PKR 500 today. flat PKR 0 this month.",
    recommendedAction: {
      completionKind: "review",
      label: "Review",
      effect: "Stay calm",
    },
    wealthSnapshot: {
      changeVsYesterday: 500,
      changeMtd: 0,
      mainReason: "Cash movement",
      interpretation: [],
    },
    wealthEvents: [],
  } as never;
  assert.ok(
    checkGuardrails(briefing).includes(
      "Movement summary is missing its plain-language driver",
    ),
  );
});

test("unaffordable goal suggestion opens review without an amount", () => {
  const action = selectRecommendedAction({
    score: { attentionFactors: [] },
    goals: [
      {
        id: "goal-1",
        name: "Car goal",
        targetAmount: 600_000,
        currentAmount: 0,
        remainingToTarget: 600_000,
        suggestion: { kind: "review_deadline" },
      },
    ],
    holdings: [],
    unconfirmedCount: 0,
    stalePriceCount: 0,
  });
  assert.equal(action.label, "This goal's deadline may need a review");
  assert.equal(action.completionKind, "review");
  assert.doesNotMatch(action.label, /PKR/);
});

import assert from "node:assert/strict";
import test from "node:test";
import { checkGuardrails } from "./briefing-validation.js";

test("audit_b7_movement_summary_requires_driver", () => {
  const briefing = {
    greeting: "Good evening, friend",
    summary: "Up PKR 500 today. flat PKR 0 this month.",
    recommendedAction: { completionKind: "review", label: "Review", effect: "Stay calm" },
    wealthSnapshot: {
      changeVsYesterday: 500,
      changeMtd: 0,
      mainReason: "Cash movement",
      interpretation: [],
    },
    wealthEvents: [],
  } as never;
  assert.ok(checkGuardrails(briefing).includes("Movement summary is missing its plain-language driver"));
});

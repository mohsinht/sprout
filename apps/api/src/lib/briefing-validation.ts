import type { WealthBriefing, WealthBriefingAction } from "@sprout/shared";
import { WealthBriefingSchema } from "@sprout/shared";
import type { ScoreResult, Severity } from "./scoring.js";

/** Validate the final briefing against the Zod schema. Reject invalid output. */
export function validateBriefing(briefing: unknown): WealthBriefing {
  return WealthBriefingSchema.parse(briefing);
}

/** Guardrail checks — enforced in code, not just the prompt. */
export function checkGuardrails(briefing: WealthBriefing): string[] {
  const violations: string[] = [];

  // Exactly one primary recommended action
  if (!briefing.recommendedAction) {
    violations.push("Missing recommended action");
  }

  // No "check-in" action
  if (briefing.recommendedAction.completionKind === "check_in" as never) {
    violations.push("Check-in action selected — opening the app is not an action");
  }

  // No shame/guilt/panic language
  const allText = [
    briefing.greeting,
    briefing.summary,
    briefing.recommendedAction.label,
    briefing.recommendedAction.effect,
    ...briefing.wealthSnapshot.interpretation,
    ...briefing.wealthEvents.map((e) => e.plainWhy),
  ].join(" ");

  const bannedPhrases = [
    "you failed",
    "bad spending",
    "you should have",
    "guaranteed",
    "buy now",
    "you will earn",
    "connect your bank to continue",
    "your score dropped because you are behind",
  ];
  for (const phrase of bannedPhrases) {
    if (allText.toLowerCase().includes(phrase)) {
      violations.push(`Banned phrase: "${phrase}"`);
    }
  }

  // No exclamation marks on gains (hype check)
  if (briefing.wealthSnapshot.changeVsYesterday > 0 && briefing.summary.includes("!")) {
    violations.push("Exclamation mark on a gain — no hype");
  }

  // Every wealth event has a plainWhy
  for (const event of briefing.wealthEvents) {
    if (!event.plainWhy || event.plainWhy.trim().length === 0) {
      violations.push(`WealthEvent ${event.id} missing plainWhy`);
    }
  }

  // changeVsYesterday and changeMtd both present (always shown together)
  if (briefing.wealthSnapshot.changeVsYesterday === undefined || briefing.wealthSnapshot.changeMtd === undefined) {
    violations.push("WealthSnapshot missing changeVsYesterday or changeMtd");
  }

  return violations;
}

/** Select the recommended action per scoring_model.md priority order. */
export function selectRecommendedAction(params: {
  score: ScoreResult;
  goals: { id: string; name: string; targetAmount: number; currentAmount: number; remainingToTarget: number }[];
  holdings: { id: string; label: string; valuePkr: number }[];
  unconfirmedCount: number;
  stalePriceCount: number;
}): WealthBriefingAction {
  const { score, goals, holdings, unconfirmedCount, stalePriceCount } = params;

  // Priority 1: needs_attention bill coverage or cash runway
  if (score.attentionFactors.some((f) => f.id === "cash_buffer" && f.contribution < 5)) {
    const emergencyGoal = goals.find((g) => g.name.toLowerCase().includes("emergency"));
    if (emergencyGoal) {
      return {
        id: "action-emergency",
        label: `Add PKR 10,000 to your ${emergencyGoal.name}`,
        severity: "needs_attention",
        effect: "Strengthens your cash buffer",
        xp: 25,
        completionKind: "contribute_to_goal",
        targetId: emergencyGoal.id,
        goalRelativeNote: `PKR ${emergencyGoal.remainingToTarget.toLocaleString()} to go`,
      };
    }
  }

  // Priority 2: needs_attention data quality (stale prices or unconfirmed)
  if (stalePriceCount > 0) {
    return {
      id: "action-stale-prices",
      label: `${stalePriceCount} price${stalePriceCount > 1 ? "s" : ""} need refreshing — check your fund data`,
      severity: "needs_attention",
      effect: "Improves data confidence",
      xp: 20,
      completionKind: "review",
    };
  }

  if (unconfirmedCount > 2) {
    return {
      id: "action-confirm",
      label: `Confirm ${unconfirmedCount} captured transactions`,
      severity: "heads_up",
      effect: "Improves data confidence",
      xp: 15,
      completionKind: "confirm_transaction",
    };
  }

  // Priority 3: worth_doing goal contribution
  const activeGoal = goals.find((g) => g.remainingToTarget > 0);
  if (activeGoal) {
    return {
      id: `action-goal-${activeGoal.id}`,
      label: `Add PKR 25,000 to your ${activeGoal.name}`,
      severity: "worth_doing",
      effect: `PKR ${activeGoal.remainingToTarget.toLocaleString()} to go`,
      xp: 20,
      completionKind: "contribute_to_goal",
      targetId: activeGoal.id,
      goalRelativeNote: `PKR ${activeGoal.remainingToTarget.toLocaleString()} to your ${activeGoal.name}`,
    };
  }

  // Priority 4: worth_doing rebalance suggestion
  if (holdings.length > 1) {
    const sorted = [...holdings].sort((a, b) => a.valuePkr - b.valuePkr);
    const smallest = sorted[0];
    return {
      id: `action-rebalance-${smallest.id}`,
      label: `${smallest.label} is lagging your other holdings — consider directing your next contribution there`,
      severity: "worth_doing",
      effect: "Rebalances your portfolio toward the underweight holding",
      xp: 20,
      completionKind: "rebalance",
      targetId: smallest.id,
    };
  }

  // Priority 6: all_good review today's wealth movement
  return {
    id: "action-review",
    label: "Review today's wealth movement",
    severity: "all_good",
    effect: "Stays on top of your money",
    xp: 5,
    completionKind: "review",
  };
}

/** Deterministic fallback interpretation when AI is unavailable. */
export function deterministicInterpretation(params: {
  changeVsYesterday: number;
  changeMtd: number;
  mainReason: string;
  holdings: { label: string; changeVsYesterday: number }[];
}): string[] {
  const lines: string[] = [];
  const { changeVsYesterday, changeMtd, mainReason } = params;

  const todayDir = changeVsYesterday > 0 ? "Up" : changeVsYesterday < 0 ? "Down" : "Steady";
  const mtdDir = changeMtd > 0 ? "up" : changeMtd < 0 ? "down" : "flat";

  lines.push(
    `${todayDir} PKR ${Math.abs(changeVsYesterday).toLocaleString()} today — ${mainReason.toLowerCase()}.`
  );
  lines.push(
    `Still ${mtdDir} PKR ${Math.abs(changeMtd).toLocaleString()} this month.`
  );

  if (changeVsYesterday < 0) {
    lines.push("Not a crash — just a normal day.");
  } else if (changeVsYesterday > 0) {
    lines.push("A good day, noted without hype.");
  } else {
    lines.push("Nothing moved much today.");
  }

  return lines;
}

/** Deterministic fallback greeting. */
export function deterministicGreeting(name: string, mood: string): string {
  const hour = new Date().getHours();
  const timeGreeting = hour < 12 ? "Good morning" : hour < 17 ? "Good afternoon" : "Good evening";
  return `${timeGreeting}, ${name}`;
}

/** Deterministic fallback summary. */
export function deterministicSummary(params: {
  changeVsYesterday: number;
  changeMtd: number;
  mainReason: string;
}): string {
  const { changeVsYesterday, changeMtd, mainReason } = params;
  const todayDir = changeVsYesterday > 0 ? "Up" : changeVsYesterday < 0 ? "Down" : "Steady";
  const mtdDir = changeMtd > 0 ? "still up" : changeMtd < 0 ? "still down" : "flat";

  if (changeVsYesterday < 0) {
    return `${todayDir} PKR ${Math.abs(changeVsYesterday).toLocaleString()} today — ${mainReason.toLowerCase()}, not a crash. ${mtdDir} PKR ${Math.abs(changeMtd).toLocaleString()} this month.`;
  }
  return `${todayDir} PKR ${Math.abs(changeVsYesterday).toLocaleString()} today. ${mtdDir} PKR ${Math.abs(changeMtd).toLocaleString()} this month.`;
}

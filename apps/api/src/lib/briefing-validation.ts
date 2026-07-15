import type { WealthBriefing, WealthBriefingAction } from "@sprout/shared";
import { WealthBriefingSchema } from "@sprout/shared";

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
  if (briefing.recommendedAction.completionKind === ("check_in" as never)) {
    violations.push(
      "Check-in action selected — opening the app is not an action",
    );
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
  if (
    briefing.wealthSnapshot.changeVsYesterday > 0 &&
    briefing.summary.includes("!")
  ) {
    violations.push("Exclamation mark on a gain — no hype");
  }

  // Every wealth event has a plainWhy
  for (const event of briefing.wealthEvents) {
    if (!event.plainWhy || event.plainWhy.trim().length === 0) {
      violations.push(`WealthEvent ${event.id} missing plainWhy`);
    }
  }

  // changeVsYesterday and changeMtd both present (always shown together)
  if (
    briefing.wealthSnapshot.changeVsYesterday === undefined ||
    briefing.wealthSnapshot.changeMtd === undefined
  ) {
    violations.push("WealthSnapshot missing changeVsYesterday or changeMtd");
  }

  const hasMovement =
    briefing.wealthSnapshot.changeVsYesterday !== 0 ||
    briefing.wealthSnapshot.changeMtd !== 0;
  if (hasMovement) {
    const reason = briefing.wealthSnapshot.mainReason.trim().toLowerCase();
    if (!reason || !briefing.summary.toLowerCase().includes(reason)) {
      violations.push("Movement summary is missing its plain-language driver");
    }
  }

  return violations;
}

/** Select the recommended action per scoring_model.md priority order. */
export function selectRecommendedAction(params: {
  score: { attentionFactors: { id: string; contribution: number }[] };
  goals: {
    id: string;
    name: string;
    targetAmount: number;
    currentAmount: number;
    remainingToTarget: number;
    suggestion:
      | { kind: "amount"; amount: number }
      | { kind: "add_without_amount" }
      | { kind: "review_deadline" };
  }[];
  holdings: { id: string; label: string; valuePkr: number }[];
  unconfirmedCount: number;
  stalePriceCount: number;
  paydayPriority?: boolean;
}): WealthBriefingAction {
  const { score, goals, holdings, unconfirmedCount, stalePriceCount } = params;

  const goalAction = (goal: (typeof goals)[number]): WealthBriefingAction => {
    if (goal.suggestion.kind === "review_deadline") {
      return {
        id: `action-goal-review-${goal.id}`,
        label: "This goal's deadline may need a review",
        severity: "worth_doing",
        effect: `Review the timeline for your ${goal.name}`,
        xp: 15,
        completionKind: "review",
        targetId: goal.id,
        goalRelativeNote: `PKR ${goal.remainingToTarget.toLocaleString()} to go`,
      };
    }
    const amount =
      goal.suggestion.kind === "amount" ? goal.suggestion.amount : null;
    return {
      id: `action-goal-${goal.id}`,
      label:
        amount == null
          ? `Add to your ${goal.name}`
          : `Add ${formatPkr(amount)} to your ${goal.name}`,
      severity: "worth_doing",
      effect: `PKR ${goal.remainingToTarget.toLocaleString()} to go`,
      xp: 20,
      completionKind: "contribute_to_goal",
      targetId: goal.id,
      goalRelativeNote:
        amount == null
          ? `Add to your ${goal.name}`
          : `${formatPkr(amount)} to your ${goal.name}`,
    };
  };

  const activeGoal = goals.find((goal) => goal.remainingToTarget > 0);
  if (params.paydayPriority && activeGoal) return goalAction(activeGoal);

  // Priority 1: needs_attention bill coverage or cash runway
  if (
    score.attentionFactors.some(
      (f) =>
        (f.id === "cashBuffer" || f.id === "billCoverage") &&
        f.contribution < 5,
    )
  ) {
    const emergencyGoal = goals.find((g) =>
      g.name.toLowerCase().includes("emergency"),
    );
    if (emergencyGoal) {
      const action = goalAction(emergencyGoal);
      return {
        ...action,
        severity: "needs_attention",
        effect: "Strengthens your cash buffer",
        xp: 25,
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
  if (activeGoal) {
    return goalAction(activeGoal);
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

function formatPkr(amount: number): string {
  if (amount >= 100_000 && amount % 100_000 === 0)
    return `PKR ${amount / 100_000} lakh`;
  return `PKR ${amount.toLocaleString("en-PK")}`;
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

  const todayDir =
    changeVsYesterday > 0 ? "Up" : changeVsYesterday < 0 ? "Down" : "Steady";
  const mtdDir = changeMtd > 0 ? "up" : changeMtd < 0 ? "down" : "flat";

  lines.push(
    `${todayDir} PKR ${Math.abs(changeVsYesterday).toLocaleString()} today — ${mainReason.toLowerCase()}.`,
  );
  lines.push(
    `Still ${mtdDir} PKR ${Math.abs(changeMtd).toLocaleString()} this month.`,
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
  const timeGreeting =
    hour < 12 ? "Good morning" : hour < 17 ? "Good afternoon" : "Good evening";
  return `${timeGreeting}, ${name}`;
}

/** Deterministic fallback summary. */
export function deterministicSummary(params: {
  changeVsYesterday: number;
  changeMtd: number;
  mainReason: string;
}): string {
  const { changeVsYesterday, changeMtd, mainReason } = params;
  const todayDir =
    changeVsYesterday > 0 ? "Up" : changeVsYesterday < 0 ? "Down" : "Steady";
  const mtdPhrase =
    changeMtd > 0
      ? `still up PKR ${Math.abs(changeMtd).toLocaleString()} this month`
      : changeMtd < 0
        ? `still down PKR ${Math.abs(changeMtd).toLocaleString()} this month`
        : "steady this month";

  if (changeVsYesterday < 0) {
    return `${todayDir} PKR ${Math.abs(changeVsYesterday).toLocaleString()} today — ${mainReason.toLowerCase()}, not a crash. ${mtdPhrase}.`;
  }
  if (changeVsYesterday > 0) {
    return `${todayDir} PKR ${Math.abs(changeVsYesterday).toLocaleString()} today — ${mainReason.toLowerCase()}. ${mtdPhrase}. Calm progress.`;
  }
  return `Steady today. ${mtdPhrase[0].toUpperCase()}${mtdPhrase.slice(1)}.`;
}

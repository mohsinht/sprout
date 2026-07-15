import type { WorldFact } from "@sprout/shared";

export const insightTemplateVersion = "1";

export type InsightMatch =
  | {
      kind: "holding";
      id: string;
      label: string;
      currency: string;
      valuePkr: number;
    }
  | { kind: "goal"; id: string; label: string; goalType: string }
  | { kind: "currency"; currency: string; label: string; valuePkr: number };

export type RenderedInsightTemplate = {
  templateId: string;
  templateVersion: string;
  headline: string;
  personalMeaning: string;
  detail: string;
};

const headlines: Record<WorldFact["kind"], string> = {
  policy_rate: "Policy rate changed",
  cpi: "Inflation changed",
  fx_move: "A currency you hold moved",
  nav_move: "A fund you hold moved",
  goal_cost_context: "New context for your goal",
};

export function renderInsightTemplate(
  fact: WorldFact,
  match: InsightMatch,
): RenderedInsightTemplate {
  const personalDelta =
    fact.kind === "fx_move" && fact.magnitude != null && "valuePkr" in match
      ? ` About PKR ${Math.round(Math.abs((match.valuePkr * fact.magnitude) / 100)).toLocaleString("en-PK")} of your current rupee value is tied to that move.`
      : "";
  const personalMeaning =
    match.kind === "goal"
      ? `${fact.plainSummary} This is relevant to your ${match.label}.`
      : `${fact.plainSummary} This is relevant to your ${match.label}.${personalDelta}`;
  return {
    templateId: `${fact.kind}-${match.kind}`,
    templateVersion: insightTemplateVersion,
    headline: headlines[fact.kind],
    personalMeaning,
    detail: `${personalMeaning} Source: ${fact.sourceLabel}, as of ${fact.observedOn}. This is context, not a buy or sell instruction.`,
  };
}

export const templateGuardrailSamples: WorldFact[] = [
  {
    id: "sample",
    kind: "policy_rate",
    observedOn: "2026-07-15",
    direction: "changed",
    sourceId: "sample",
    sourceLabel: "SBP",
    freshness: "fresh",
    plainSummary: "The policy rate changed.",
    affectsAssetClasses: ["mutual_fund"],
    affectsCurrencies: [],
    affectsGoalTypes: [],
    normalizer: "deterministic",
    normalizerVersion: "sample",
    createdAt: "2026-07-15T00:00:00Z",
  },
];

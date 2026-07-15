import { z } from "zod";

export const WorldFactSchema = z.object({
  id: z.string(),
  kind: z.enum([
    "policy_rate",
    "cpi",
    "fx_move",
    "nav_move",
    "goal_cost_context",
  ]),
  observedOn: z.string(),
  validFrom: z.string().optional(),
  magnitude: z.number().optional(),
  unit: z.enum(["percent", "percentage_point", "pkr", "index"]).optional(),
  direction: z.enum(["up", "down", "flat", "changed"]),
  sourceId: z.string(),
  sourceLabel: z.string(),
  sourceUrl: z.string().optional(),
  sourcePublishedAt: z.string().optional(),
  freshness: z.enum(["fresh", "recent", "stale", "unavailable"]),
  plainSummary: z.string(),
  affectsAssetClasses: z.array(z.string()),
  affectsCurrencies: z.array(z.string()),
  affectsGoalTypes: z.array(z.string()),
  normalizer: z.enum(["deterministic", "ai"]),
  normalizerVersion: z.string(),
  createdAt: z.string(),
});

export const PersonalInsightSchema = z
  .object({
    id: z.string(),
    stableKey: z.string(),
    userId: z.string(),
    worldFactId: z.string().optional(),
    wealthEventId: z.string().optional(),
    matchedHoldingId: z.string().optional(),
    matchedGoalId: z.string().optional(),
    matchedCurrency: z.string().optional(),
    headline: z.string(),
    personalMeaning: z.string(),
    detail: z.string(),
    deterministicHeadline: z.string(),
    deterministicPersonalMeaning: z.string(),
    deterministicDetail: z.string(),
    severity: z.enum([
      "all_good",
      "heads_up",
      "worth_doing",
      "needs_attention",
    ]),
    sourceLabel: z.string(),
    sourceUrl: z.string().optional(),
    asOf: z.string(),
    freshness: z.enum(["fresh", "recent", "stale"]),
    templateId: z.string(),
    templateVersion: z.string(),
    presentationMode: z.enum(["deterministic", "ai_rewrite"]),
    rewriteInputHash: z.string().optional(),
    generatedAt: z.string(),
  })
  .superRefine((value, context) => {
    if (
      Number(value.worldFactId != null) +
        Number(value.wealthEventId != null) !==
      1
    ) {
      context.addIssue({
        code: z.ZodIssueCode.custom,
        message: "Exactly one worldFactId or wealthEventId is required",
      });
    }
  });

export type WorldFact = z.infer<typeof WorldFactSchema>;
export type PersonalInsight = z.infer<typeof PersonalInsightSchema>;

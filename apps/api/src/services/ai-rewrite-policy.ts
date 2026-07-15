import { createHash } from "node:crypto";
import { eq, sql } from "drizzle-orm";
import type {
  AiBriefingInput,
  AiBriefingOutput,
  AiService,
} from "./ai-service.js";
import { validateAiBriefingOutput } from "./ai-service.js";
import { db, schema } from "../db/client.js";
import { config } from "../config.js";

export type AiRewriteResult = {
  output: AiBriefingOutput;
  costCents: number;
  model: string;
  mode: "deterministic" | "cache" | "ai" | "fallback";
};

export function shouldRewriteBriefing(
  input: AiBriefingInput,
  monthlyRecap = false,
): boolean {
  return (
    monthlyRecap ||
    input.recommendedAction.severity === "needs_attention" ||
    input.wealthEvents.some(
      (event) =>
        event.severity === "needs_attention" ||
        event.id.includes("goal-milestone"),
    )
  );
}

export function canonicalRewriteHash(input: AiBriefingInput): string {
  const canonical = {
    summary: input.summary,
    wealthSnapshot: input.wealthSnapshot,
    wealthEvents: input.wealthEvents.map(({ id: _id, ...event }) => event),
    recommendedAction: {
      label: input.recommendedAction.label,
      severity: input.recommendedAction.severity,
      effect: input.recommendedAction.effect,
      goalRelativeNote: input.recommendedAction.goalRelativeNote,
    },
    mascotMood: input.mascotMood,
    score: input.score,
    band: input.band,
  };
  return createHash("sha256").update(JSON.stringify(canonical)).digest("hex");
}

export async function rewriteBriefingWithinBudget(params: {
  date: string;
  input: AiBriefingInput;
  aiService: AiService;
  monthlyRecap?: boolean;
}): Promise<AiRewriteResult> {
  const deterministic = {
    greeting: params.input.greeting,
    summary: params.input.summary,
    interpretation: params.input.wealthSnapshot.interpretation,
  };
  if (!shouldRewriteBriefing(params.input, params.monthlyRecap))
    return {
      output: deterministic,
      costCents: 0,
      model: "deterministic",
      mode: "deterministic",
    };

  const inputHash = canonicalRewriteHash(params.input);
  const [cached] = await db
    .select()
    .from(schema.aiRewriteCache)
    .where(eq(schema.aiRewriteCache.inputHash, inputHash))
    .limit(1);
  if (cached) {
    const output = validateAiBriefingOutput(cached.outputJson);
    return {
      output: { ...output, greeting: params.input.greeting },
      costCents: 0,
      model: cached.model,
      mode: "cache",
    };
  }

  const cap = config.aiDailyCostCapCents;
  if (cap == null || !Number.isFinite(cap) || cap <= 0)
    return {
      output: deterministic,
      costCents: 0,
      model: "deterministic",
      mode: "deterministic",
    };
  const [usage] = await db
    .select()
    .from(schema.aiDailyUsage)
    .where(eq(schema.aiDailyUsage.usageDate, params.date))
    .limit(1);
  if ((usage?.costCents ?? 0) >= cap)
    return {
      output: deterministic,
      costCents: 0,
      model: "deterministic",
      mode: "deterministic",
    };

  try {
    const generated = await params.aiService.generateBriefingCopy(params.input);
    const validated = validateAiBriefingOutput(generated.output);
    await db.transaction(async (tx) => {
      await tx
        .insert(schema.aiRewriteCache)
        .values({
          inputHash,
          outputJson: validated,
          model: params.aiService.name,
          originalCostCents: generated.costCents,
        })
        .onConflictDoNothing();
      await tx
        .insert(schema.aiDailyUsage)
        .values({
          usageDate: params.date,
          costCents: generated.costCents,
          callCount: 1,
        })
        .onConflictDoUpdate({
          target: schema.aiDailyUsage.usageDate,
          set: {
            costCents: sql`${schema.aiDailyUsage.costCents} + ${generated.costCents}`,
            callCount: sql`${schema.aiDailyUsage.callCount} + 1`,
            updatedAt: new Date(),
          },
        });
    });
    return {
      output: { ...validated, greeting: params.input.greeting },
      costCents: generated.costCents,
      model: params.aiService.name,
      mode: "ai",
    };
  } catch {
    return {
      output: deterministic,
      costCents: 0,
      model: "fallback",
      mode: "fallback",
    };
  }
}

import { and, desc, eq } from "drizzle-orm";
import type { PersonalInsight, WorldFact } from "@sprout/shared";
import { db, schema } from "../db/client.js";
import {
  insightTemplateVersion,
  renderInsightTemplate,
  type InsightMatch,
} from "./template-registry.js";

const strings = (value: unknown): string[] =>
  Array.isArray(value)
    ? value.filter((item): item is string => typeof item === "string")
    : [];

function factFromRow(row: typeof schema.worldFacts.$inferSelect): WorldFact {
  return {
    id: row.id,
    kind: row.kind,
    observedOn: row.observedOn,
    validFrom: row.validFrom ?? undefined,
    magnitude: row.magnitude == null ? undefined : Number(row.magnitude),
    unit: row.unit as WorldFact["unit"],
    direction: row.direction as WorldFact["direction"],
    sourceId: row.sourceId,
    sourceLabel: row.sourceLabel,
    sourceUrl: row.sourceUrl ?? undefined,
    sourcePublishedAt: row.sourcePublishedAt?.toISOString(),
    freshness: row.freshness as WorldFact["freshness"],
    plainSummary: row.plainSummary,
    affectsAssetClasses: strings(row.affectsAssetClassesJson),
    affectsCurrencies: strings(row.affectsCurrenciesJson),
    affectsGoalTypes: strings(row.affectsGoalTypesJson),
    normalizer: row.normalizer as WorldFact["normalizer"],
    normalizerVersion: row.normalizerVersion,
    createdAt: row.createdAt.toISOString(),
  };
}

function matchesForFact(
  fact: WorldFact,
  holdings: (typeof schema.holdings.$inferSelect)[],
  goals: (typeof schema.goals.$inferSelect)[],
): InsightMatch[] {
  const matches: InsightMatch[] = [];
  for (const holding of holdings) {
    if (fact.affectsCurrencies.includes(holding.currency)) {
      matches.push({
        kind: "currency",
        currency: holding.currency,
        label: holding.label,
        valuePkr: holding.valuePkr,
      });
    } else if (fact.affectsAssetClasses.includes(holding.kind)) {
      matches.push({
        kind: "holding",
        id: holding.id,
        label: holding.label,
        currency: holding.currency,
        valuePkr: holding.valuePkr,
      });
    }
  }
  for (const goal of goals)
    if (fact.affectsGoalTypes.includes(goal.type))
      matches.push({
        kind: "goal",
        id: goal.id,
        label: goal.name,
        goalType: goal.type,
      });
  return matches;
}

export async function generatePersonalInsights(
  userId: string,
): Promise<PersonalInsight[]> {
  const [facts, holdings, goals] = await Promise.all([
    db
      .select()
      .from(schema.worldFacts)
      .orderBy(desc(schema.worldFacts.observedOn))
      .limit(100),
    db.select().from(schema.holdings).where(eq(schema.holdings.userId, userId)),
    db
      .select()
      .from(schema.goals)
      .where(
        and(eq(schema.goals.userId, userId), eq(schema.goals.status, "active")),
      ),
  ]);
  const generated: PersonalInsight[] = [];
  for (const row of facts) {
    const fact = factFromRow(row);
    if (fact.freshness === "unavailable") continue;
    for (const match of matchesForFact(fact, holdings, goals)) {
      if (generated.length >= 6) break;
      const copy = renderInsightTemplate(fact, match);
      const matchKey = match.kind === "currency" ? match.currency : match.id;
      const stableKey = `${userId}:${fact.id}:${match.kind}:${matchKey}:${insightTemplateVersion}`;
      const values = {
        stableKey,
        userId,
        worldFactId: fact.id,
        matchedHoldingId: match.kind === "holding" ? match.id : undefined,
        matchedGoalId: match.kind === "goal" ? match.id : undefined,
        matchedCurrency: match.kind === "currency" ? match.currency : undefined,
        headline: copy.headline,
        personalMeaning: copy.personalMeaning,
        detail: copy.detail,
        deterministicHeadline: copy.headline,
        deterministicPersonalMeaning: copy.personalMeaning,
        deterministicDetail: copy.detail,
        severity:
          fact.direction === "flat"
            ? ("all_good" as const)
            : ("heads_up" as const),
        sourceLabel: fact.sourceLabel,
        sourceUrl: fact.sourceUrl,
        asOf: fact.observedOn,
        freshness:
          fact.freshness === "fresh"
            ? "fresh"
            : fact.freshness === "recent"
              ? "recent"
              : "stale",
        templateId: copy.templateId,
        templateVersion: copy.templateVersion,
        presentationMode: "deterministic" as const,
      };
      const [saved] = await db
        .insert(schema.personalInsights)
        .values(values)
        .onConflictDoUpdate({
          target: schema.personalInsights.stableKey,
          set: { ...values, generatedAt: new Date() },
        })
        .returning();
      generated.push({
        id: saved.id,
        stableKey: saved.stableKey,
        userId: saved.userId,
        worldFactId: saved.worldFactId ?? undefined,
        matchedHoldingId: saved.matchedHoldingId ?? undefined,
        matchedGoalId: saved.matchedGoalId ?? undefined,
        matchedCurrency: saved.matchedCurrency ?? undefined,
        headline: saved.headline,
        personalMeaning: saved.personalMeaning,
        detail: saved.detail,
        deterministicHeadline: saved.deterministicHeadline,
        deterministicPersonalMeaning: saved.deterministicPersonalMeaning,
        deterministicDetail: saved.deterministicDetail,
        severity: saved.severity,
        sourceLabel: saved.sourceLabel,
        sourceUrl: saved.sourceUrl ?? undefined,
        asOf: saved.asOf,
        freshness: saved.freshness as PersonalInsight["freshness"],
        templateId: saved.templateId,
        templateVersion: saved.templateVersion,
        presentationMode: saved.presentationMode,
        rewriteInputHash: saved.rewriteInputHash ?? undefined,
        generatedAt: saved.generatedAt.toISOString(),
      });
    }
    if (generated.length >= 6) break;
  }
  return generated;
}

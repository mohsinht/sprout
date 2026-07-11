import { Hono } from "hono";
import { eq, desc } from "drizzle-orm";
import { db, schema } from "../db/client.js";
import { authMiddleware } from "../auth/middleware.js";
import {
  runOnDemandBriefing,
  getBriefingWithFallback,
} from "../services/job-runner.js";

export const briefingRoute = new Hono<{ Variables: { userId: string } }>();

briefingRoute.use("*", authMiddleware);

// ── GET /v1/briefing ──────────────────────────────────────────────────────────
// Returns the latest briefing. Falls back to last stored with freshness label.

briefingRoute.get("/", async (c) => {
  const userId = c.get("userId") as string;

  let { briefing, freshness } = await getBriefingWithFallback(userId);

  if (!briefing) {
    // A first-time/zero-connection user still receives the complete contract.
    // The pipeline produces a manual-first zero briefing without requiring a
    // connection or fabricating a wealth value.
    await runOnDemandBriefing(userId);
    ({ briefing, freshness } = await getBriefingWithFallback(userId));
    if (!briefing) {
      return c.json({ error: "Briefing unavailable" }, 503);
    }
  }

  return c.json({ ...briefing, freshness });
});

// ── POST /v1/briefing/refresh ────────────────────────────────────────────────
// On-demand refresh. Rate-limited (max N per user per hour).

briefingRoute.post("/refresh", async (c) => {
  const userId = c.get("userId") as string;

  const result = await runOnDemandBriefing(userId);

  if (result.status === "skipped") {
    // Rate limited or already run this hour — return current briefing
    const { briefing } = await getBriefingWithFallback(userId);
    return c.json({
      ...briefing,
      message: "Already refreshed recently — using the latest briefing.",
    });
  }

  if (result.status === "failed") {
    // Job failed — return last stored briefing with fallback freshness
    const { briefing } = await getBriefingWithFallback(userId);
    return c.json({
      ...briefing,
      freshness: "local_fallback",
      message: "I could not refresh the scan, so I am using what I already know.",
    });
  }

  const { briefing } = await getBriefingWithFallback(userId);
  return c.json(briefing);
});

// ── GET /v1/briefing/sources ─────────────────────────────────────────────────
// Data source status — shows connected sources, stale data, parser health.

briefingRoute.get("/sources", async (c) => {
  const userId = c.get("userId") as string;

  const sources = await db
    .select()
    .from(schema.dataSources)
    .where(eq(schema.dataSources.userId, userId));

  // Also check recent job runs for parser health
  const recentJobs = await db
    .select()
    .from(schema.jobRuns)
    .where(eq(schema.jobRuns.userId, userId))
    .orderBy(desc(schema.jobRuns.startedAt))
    .limit(10);

  const failedJobs = recentJobs.filter((j) => j.status === "failed");

  return c.json({
    sources: sources.map((s) => ({
      id: s.id,
      kind: s.kind,
      status: s.status,
      lastSyncedAt: s.lastSyncedAt?.toISOString() ?? null,
    })),
    jobHealth: {
      recentTotal: recentJobs.length,
      recentFailures: failedJobs.length,
      lastError: failedJobs[0]?.error ?? null,
    },
  });
});

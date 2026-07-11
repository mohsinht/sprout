import { eq, and, desc, count, gte } from "drizzle-orm";
import { db, schema } from "../db/client.js";
import { config } from "../config.js";
import { generateBriefing, storeBriefing, getLatestBriefing } from "./briefing-pipeline.js";

/**
 * Job runner with idempotency. The daily job can run twice without duplicating data.
 * Idempotency key: `${userId}:${date}` — a second run returns the existing briefing.
 */

export interface JobResult {
  briefingId: string;
  status: "succeeded" | "failed" | "skipped";
  error?: string;
}

/** Run the daily briefing job for a user. Idempotent. */
export async function runDailyBriefingJob(userId: string, date?: string): Promise<JobResult> {
  const briefingDate = date ?? new Date().toISOString().slice(0, 10);
  const idempotencyKey = `daily:${userId}:${briefingDate}`;

  // Check for existing job run with same idempotency key
  const existingJob = await db
    .select()
    .from(schema.jobRuns)
    .where(eq(schema.jobRuns.idempotencyKey, idempotencyKey))
    .limit(1);

  if (existingJob.length > 0 && existingJob[0].status === "succeeded") {
    return { briefingId: existingJob[0].id, status: "skipped" };
  }

  // Create job run record
  const [jobRun] = await db
    .insert(schema.jobRuns)
    .values({
      userId,
      type: "daily",
      status: "running",
      startedAt: new Date(),
      idempotencyKey,
    })
    .returning();

  try {
    const result = await generateBriefing({ userId, date: briefingDate });
    await storeBriefing(result.briefing, result.aiCostCents, result.aiModel);

    await db
      .update(schema.jobRuns)
      .set({ status: "succeeded", finishedAt: new Date() })
      .where(eq(schema.jobRuns.id, jobRun.id));

    return { briefingId: result.briefing.id, status: "succeeded" };
  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : String(error);
    await db
      .update(schema.jobRuns)
      .set({ status: "failed", finishedAt: new Date(), error: errorMsg })
      .where(eq(schema.jobRuns.id, jobRun.id));

    return { briefingId: jobRun.id, status: "failed", error: errorMsg };
  }
}

/** Run on-demand briefing refresh. Rate-limited per user per hour. */
export async function runOnDemandBriefing(userId: string): Promise<JobResult> {
  const now = new Date();
  const oneHourAgo = new Date(now.getTime() - 60 * 60 * 1000);
  const idempotencyKey = `on_demand:${userId}:${now.toISOString().slice(0, 13)}`; // hourly key

  // Rate limit: check how many on-demand jobs in the last hour
  const recentJobs = await db
    .select({ count: count() })
    .from(schema.jobRuns)
    .where(
      and(
        eq(schema.jobRuns.userId, userId),
        eq(schema.jobRuns.type, "on_demand"),
        eq(schema.jobRuns.status, "succeeded"),
        // Keep the limiter hourly; counting the user's lifetime refreshes
        // would permanently disable refresh after the first few uses.
        gte(schema.jobRuns.startedAt, oneHourAgo),
      )
    );

  const recentCount = recentJobs[0]?.count ?? 0;
  if (recentCount >= config.onDemandRateLimitPerHour) {
    // Rate limited — return the current briefing, don't error
    return { briefingId: "rate_limited", status: "skipped" };
  }

  // Check for existing job with same idempotency key (same hour)
  const existingJob = await db
    .select()
    .from(schema.jobRuns)
    .where(eq(schema.jobRuns.idempotencyKey, idempotencyKey))
    .limit(1);

  if (existingJob.length > 0 && existingJob[0].status === "succeeded") {
    return { briefingId: existingJob[0].id, status: "skipped" };
  }

  const [jobRun] = await db
    .insert(schema.jobRuns)
    .values({
      userId,
      type: "on_demand",
      status: "running",
      startedAt: now,
      idempotencyKey,
    })
    .returning();

  try {
    const result = await generateBriefing({ userId });
    await storeBriefing(result.briefing, result.aiCostCents, result.aiModel);

    await db
      .update(schema.jobRuns)
      .set({ status: "succeeded", finishedAt: new Date() })
      .where(eq(schema.jobRuns.id, jobRun.id));

    return { briefingId: result.briefing.id, status: "succeeded" };
  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : String(error);
    await db
      .update(schema.jobRuns)
      .set({ status: "failed", finishedAt: new Date(), error: errorMsg })
      .where(eq(schema.jobRuns.id, jobRun.id));

    return { briefingId: jobRun.id, status: "failed", error: errorMsg };
  }
}

/** Run the daily job for all active users (called by cron). */
export async function runDailyJobForAllUsers(): Promise<void> {
  const allUsers = await db.select().from(schema.users);

  for (const user of allUsers) {
    try {
      await runDailyBriefingJob(user.id);
    } catch (error) {
      // Log but continue — one user's failure shouldn't stop others
      console.error(`Daily job failed for user ${user.id}:`, error);
    }
  }
}

/** Get the latest briefing, with fallback to local_fallback freshness if job failed. */
export async function getBriefingWithFallback(userId: string): Promise<{
  briefing: import("@sprout/shared").WealthBriefing | null;
  freshness: "fresh" | "stale" | "local_fallback" | "unavailable";
}> {
  const latest = await getLatestBriefing(userId);
  if (!latest) {
    return { briefing: null, freshness: "unavailable" };
  }

  // Check if the briefing is from today
  const today = new Date().toISOString().slice(0, 10);
  if (latest.briefingDate === today) {
    return { briefing: latest, freshness: "fresh" };
  }

  // Check if the last job failed
  const lastJob = await db
    .select()
    .from(schema.jobRuns)
    .where(eq(schema.jobRuns.userId, userId))
    .orderBy(desc(schema.jobRuns.startedAt))
    .limit(1);

  if (lastJob[0]?.status === "failed") {
    return {
      briefing: { ...latest, freshness: "local_fallback" },
      freshness: "local_fallback",
    };
  }

  return { briefing: { ...latest, freshness: "stale" }, freshness: "stale" };
}

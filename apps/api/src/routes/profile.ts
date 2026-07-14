import { Hono } from "hono";
import { z } from "zod";
import { and, eq, ne } from "drizzle-orm";
import { db, schema } from "../db/client.js";
import { authMiddleware } from "../auth/middleware.js";
import { auditEvent } from "../lib/audit.js";

export const profileRoute = new Hono<{ Variables: { userId: string } }>();

profileRoute.use("*", authMiddleware);

// ── GET /v1/profile ──────────────────────────────────────────────────────────

profileRoute.get("/", async (c) => {
  const userId = c.get("userId") as string;

  const [profile] = await db
    .select()
    .from(schema.profiles)
    .where(eq(schema.profiles.userId, userId))
    .limit(1);

  if (!profile) {
    return c.json({ error: "Profile not found" }, 404);
  }

  return c.json({
    name: profile.name,
    incomeType: profile.incomeType,
    salaryDate: profile.salaryDate,
    locale: profile.locale,
    reduceMotion: profile.reduceMotion,
    hideBalances: profile.hideBalances,
    soundEffects: profile.soundEffects,
    haptics: profile.haptics,
    displayCurrency: profile.displayCurrency,
    notificationPreferences: profile.notificationPreferencesJson,
    onboardingComplete: profile.onboardingComplete,
  });
});

// ── PATCH /v1/profile ────────────────────────────────────────────────────────

const UpdateProfileSchema = z.object({
  name: z.string().min(1).max(100).optional(),
  incomeType: z.enum(["salaried", "freelance", "business", "student", "other"]).optional(),
  salaryDate: z.number().int().min(1).max(31).optional(),
  locale: z.string().max(10).optional(),
  reduceMotion: z.boolean().optional(),
  hideBalances: z.boolean().optional(),
  soundEffects: z.boolean().optional(),
  haptics: z.boolean().optional(),
  displayCurrency: z.string().length(3).optional(),
  notificationPreferences: z.record(z.boolean()).optional(),
});

profileRoute.patch("/", async (c) => {
  const userId = c.get("userId") as string;
  const body = UpdateProfileSchema.safeParse(await c.req.json());
  if (!body.success) {
    return c.json({ error: "Invalid input", details: body.error.flatten() }, 400);
  }

  const updates: Record<string, unknown> = { updatedAt: new Date() };
  for (const [key, val] of Object.entries(body.data)) {
    if (val !== undefined) {
      updates[key === "notificationPreferences" ? "notificationPreferencesJson" : key] = val;
    }
  }

  await db
    .update(schema.profiles)
    .set(updates)
    .where(eq(schema.profiles.userId, userId));

  return c.json({ ok: true });
});

// Delete imported/reconciled material while preserving manual entries.
profileRoute.delete("/imported-data", async (c) => {
  const userId = c.get("userId") as string;

  await db.delete(schema.baselines).where(eq(schema.baselines.userId, userId));
  await db.delete(schema.wealthEvents).where(eq(schema.wealthEvents.userId, userId));
  await db.delete(schema.wealthSnapshots).where(eq(schema.wealthSnapshots.userId, userId));
  await db.delete(schema.dailyBriefings).where(eq(schema.dailyBriefings.userId, userId));
  await db.delete(schema.transactions).where(
    and(eq(schema.transactions.userId, userId), ne(schema.transactions.source, "manual")),
  );

  auditEvent("imported_data_deleted", userId);

  return c.json({ ok: true, message: "Imported data removed. Manual entries were preserved." });
});

// ── POST /v1/profile/onboarding ──────────────────────────────────────────────

const OnboardingSchema = z.object({
  name: z.string().min(1).max(100).optional(),
  goal: z
    .object({
      name: z.string().min(1).max(100),
      type: z.enum(["emergency", "car", "home", "education", "eidi", "zakat", "travel", "custom"]),
      targetAmount: z.number().int().positive(),
    })
    .optional(),
});

profileRoute.post("/onboarding", async (c) => {
  const userId = c.get("userId") as string;
  const body = OnboardingSchema.safeParse(await c.req.json());
  if (!body.success) {
    return c.json({ error: "Invalid input", details: body.error.flatten() }, 400);
  }

  const { name, goal } = body.data;

  await db
    .update(schema.profiles)
    .set({
      name: name?.trim() || "friend",
      onboardingComplete: true,
      updatedAt: new Date(),
    })
    .where(eq(schema.profiles.userId, userId));

  if (goal) {
    const [existingGoal] = await db
      .select({ id: schema.goals.id })
      .from(schema.goals)
      .where(
        and(
          eq(schema.goals.userId, userId),
          eq(schema.goals.name, goal.name),
          eq(schema.goals.type, goal.type),
          eq(schema.goals.status, "active"),
        ),
      )
      .limit(1);

    if (!existingGoal) {
      await db.insert(schema.goals).values({
        userId,
        name: goal.name,
        type: goal.type,
        targetAmount: goal.targetAmount,
        currentAmount: 0,
        status: "active",
      });
    }
  }

  return c.json({ ok: true, onboardingComplete: true });
});

import { Hono } from "hono";
import { z } from "zod";
import { eq, and } from "drizzle-orm";
import { db, schema } from "../db/client.js";
import { authMiddleware } from "../auth/middleware.js";

export const goalsRoute = new Hono<{ Variables: { userId: string } }>();

goalsRoute.use("*", authMiddleware);

// ── GET /v1/goals ────────────────────────────────────────────────────────────

goalsRoute.get("/", async (c) => {
  const userId = c.get("userId") as string;

  const rows = await db
    .select()
    .from(schema.goals)
    .where(eq(schema.goals.userId, userId));

  return c.json({ goals: rows });
});

goalsRoute.get("/:id/contributions", async (c) => {
  const userId = c.get("userId") as string;
  const goalId = c.req.param("id");
  const rows = await db
    .select()
    .from(schema.goalContributions)
    .where(
      and(
        eq(schema.goalContributions.userId, userId),
        eq(schema.goalContributions.goalId, goalId),
      ),
    );
  return c.json({ contributions: rows });
});

// ── POST /v1/goals ───────────────────────────────────────────────────────────

const CreateGoalSchema = z.object({
  name: z.string().min(1).max(100),
  type: z.enum([
    "emergency",
    "car",
    "home",
    "education",
    "eidi",
    "zakat",
    "travel",
    "custom",
  ]),
  targetAmount: z.number().int().positive(),
  currentAmount: z.number().int().nonnegative().default(0),
  deadline: z.string().date().optional(),
  isPrimary: z.boolean().optional(),
});

goalsRoute.post("/", async (c) => {
  const userId = c.get("userId") as string;
  const body = CreateGoalSchema.safeParse(await c.req.json());
  if (!body.success) {
    return c.json(
      { error: "Invalid input", details: body.error.flatten() },
      400,
    );
  }

  const goal = await db.transaction(async (tx) => {
    if (body.data.isPrimary) {
      await tx
        .update(schema.goals)
        .set({ isPrimary: false })
        .where(eq(schema.goals.userId, userId));
    }
    const [created] = await tx
      .insert(schema.goals)
      .values({ userId, ...body.data })
      .returning();
    if (created.currentAmount > 0) {
      await tx.insert(schema.goalContributions).values({
        userId,
        goalId: created.id,
        amountPkr: created.currentAmount,
        contributionDate: created.createdAt.toISOString().slice(0, 10),
        source: "opening_balance",
        idempotencyKey: `opening-balance:${created.id}`,
      });
    }
    return created;
  });

  return c.json(goal, 201);
});

// ── PATCH /v1/goals/:id ──────────────────────────────────────────────────────

const UpdateGoalSchema = z.object({
  name: z.string().min(1).max(100).optional(),
  targetAmount: z.number().int().positive().optional(),
  deadline: z.string().date().optional(),
  status: z.enum(["active", "complete", "paused"]).optional(),
  isPrimary: z.boolean().optional(),
  sortOrder: z.number().int().nonnegative().optional(),
});

goalsRoute.patch("/:id", async (c) => {
  const userId = c.get("userId") as string;
  const goalId = c.req.param("id");
  const body = UpdateGoalSchema.safeParse(await c.req.json());
  if (!body.success) {
    return c.json(
      { error: "Invalid input", details: body.error.flatten() },
      400,
    );
  }

  const updates: Record<string, unknown> = { updatedAt: new Date() };
  if (body.data.isPrimary) {
    await db
      .update(schema.goals)
      .set({ isPrimary: false })
      .where(eq(schema.goals.userId, userId));
  }
  for (const [key, val] of Object.entries(body.data)) {
    if (val !== undefined) updates[key] = val;
  }

  const [updated] = await db
    .update(schema.goals)
    .set(updates)
    .where(and(eq(schema.goals.id, goalId), eq(schema.goals.userId, userId)))
    .returning();

  if (!updated) {
    return c.json({ error: "Goal not found" }, 404);
  }

  return c.json(updated);
});

const ContributeGoalSchema = z.object({
  amount: z.number().int().positive(),
  contributionDate: z.string().date().optional(),
  source: z.enum(["manual", "quick_add", "occurrence_yes"]).default("manual"),
  idempotencyKey: z.string().min(8).max(200),
});

goalsRoute.post("/:id/contribute", async (c) => {
  const userId = c.get("userId") as string;
  const goalId = c.req.param("id");
  const body = ContributeGoalSchema.safeParse(await c.req.json());
  if (!body.success)
    return c.json(
      { error: "Invalid input", details: body.error.flatten() },
      400,
    );

  const updated = await db.transaction(async (tx) => {
    const [existing] = await tx
      .select()
      .from(schema.goalContributions)
      .where(
        and(
          eq(schema.goalContributions.userId, userId),
          eq(schema.goalContributions.idempotencyKey, body.data.idempotencyKey),
        ),
      )
      .limit(1);
    const [goal] = await tx
      .select()
      .from(schema.goals)
      .where(and(eq(schema.goals.id, goalId), eq(schema.goals.userId, userId)))
      .limit(1);
    if (!goal) return null;
    if (existing) return goal;

    const currentAmount = Math.min(
      goal.targetAmount,
      goal.currentAmount + body.data.amount,
    );
    const amountApplied = currentAmount - goal.currentAmount;
    if (amountApplied > 0) {
      await tx.insert(schema.goalContributions).values({
        userId,
        goalId,
        amountPkr: amountApplied,
        contributionDate:
          body.data.contributionDate ?? new Date().toISOString().slice(0, 10),
        source: body.data.source,
        idempotencyKey: body.data.idempotencyKey,
      });
    }
    const [result] = await tx
      .update(schema.goals)
      .set({
        currentAmount,
        status: currentAmount >= goal.targetAmount ? "complete" : goal.status,
        updatedAt: new Date(),
      })
      .where(and(eq(schema.goals.id, goalId), eq(schema.goals.userId, userId)))
      .returning();
    return result;
  });
  if (!updated) return c.json({ error: "Goal not found" }, 404);
  return c.json(updated);
});

goalsRoute.post("/reorder", async (c) => {
  const userId = c.get("userId") as string;
  const body = z
    .object({ ids: z.array(z.string().uuid()).min(1) })
    .safeParse(await c.req.json());
  if (!body.success)
    return c.json(
      { error: "Invalid input", details: body.error.flatten() },
      400,
    );

  const goals = await db
    .select({ id: schema.goals.id })
    .from(schema.goals)
    .where(eq(schema.goals.userId, userId));
  const allowed = new Set(goals.map((goal) => goal.id));
  if (
    body.data.ids.some((id) => !allowed.has(id)) ||
    new Set(body.data.ids).size !== body.data.ids.length
  ) {
    return c.json({ error: "Goal order does not match this user" }, 400);
  }
  for (const [sortOrder, id] of body.data.ids.entries()) {
    await db
      .update(schema.goals)
      .set({ sortOrder, updatedAt: new Date() })
      .where(and(eq(schema.goals.id, id), eq(schema.goals.userId, userId)));
  }
  return c.json({ ok: true });
});

// ── DELETE /v1/goals/:id ──────────────────────────────────────────────────────

goalsRoute.delete("/:id", async (c) => {
  const userId = c.get("userId") as string;
  const goalId = c.req.param("id");

  const [deleted] = await db
    .delete(schema.goals)
    .where(and(eq(schema.goals.id, goalId), eq(schema.goals.userId, userId)))
    .returning();

  if (!deleted) {
    return c.json({ error: "Goal not found" }, 404);
  }

  return c.json({ ok: true });
});

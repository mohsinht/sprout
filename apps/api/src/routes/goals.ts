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

// ── POST /v1/goals ───────────────────────────────────────────────────────────

const CreateGoalSchema = z.object({
  name: z.string().min(1).max(100),
  type: z.enum(["emergency", "car", "home", "education", "eidi", "zakat", "travel", "custom"]),
  targetAmount: z.number().int().positive(),
  currentAmount: z.number().int().nonnegative().default(0),
  deadline: z.string().optional(),
});

goalsRoute.post("/", async (c) => {
  const userId = c.get("userId") as string;
  const body = CreateGoalSchema.safeParse(await c.req.json());
  if (!body.success) {
    return c.json({ error: "Invalid input", details: body.error.flatten() }, 400);
  }

  const [goal] = await db
    .insert(schema.goals)
    .values({ userId, ...body.data })
    .returning();

  return c.json(goal, 201);
});

// ── PATCH /v1/goals/:id ──────────────────────────────────────────────────────

const UpdateGoalSchema = z.object({
  name: z.string().min(1).max(100).optional(),
  targetAmount: z.number().int().positive().optional(),
  currentAmount: z.number().int().nonnegative().optional(),
  deadline: z.string().optional(),
  status: z.enum(["active", "complete", "paused"]).optional(),
});

goalsRoute.patch("/:id", async (c) => {
  const userId = c.get("userId") as string;
  const goalId = c.req.param("id");
  const body = UpdateGoalSchema.safeParse(await c.req.json());
  if (!body.success) {
    return c.json({ error: "Invalid input", details: body.error.flatten() }, 400);
  }

  const updates: Record<string, unknown> = { updatedAt: new Date() };
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
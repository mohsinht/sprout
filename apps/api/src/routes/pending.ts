import { Hono } from "hono";
import { z } from "zod";
import { eq, and, desc } from "drizzle-orm";
import { db, schema } from "../db/client.js";
import { authMiddleware } from "../auth/middleware.js";

export const pendingRoute = new Hono<{ Variables: { userId: string } }>();

pendingRoute.use("*", authMiddleware);

// ── GET /v1/pending ──────────────────────────────────────────────────────────

pendingRoute.get("/", async (c) => {
  const userId = c.get("userId") as string;

  const rows = await db
    .select()
    .from(schema.pendingInvestments)
    .where(eq(schema.pendingInvestments.userId, userId))
    .orderBy(desc(schema.pendingInvestments.initiatedOn));

  return c.json({ pending: rows });
});

// ── POST /v1/pending ──────────────────────────────────────────────────────────

const CreatePendingSchema = z.object({
  amountPkr: z.number().int().positive(),
  destination: z.string().min(1).max(300),
  initiatedOn: z.string().date(),
  note: z.string().max(500).optional(),
});

pendingRoute.post("/", async (c) => {
  const userId = c.get("userId") as string;
  const body = CreatePendingSchema.safeParse(await c.req.json());
  if (!body.success) {
    return c.json({ error: "Invalid input", details: body.error.flatten() }, 400);
  }

  const [pending] = await db
    .insert(schema.pendingInvestments)
    .values({
      userId,
      ...body.data,
      status: "pending",
    })
    .returning();

  return c.json(pending, 201);
});

// ── PATCH /v1/pending/:id ─────────────────────────────────────────────────────

const UpdatePendingSchema = z.object({
  status: z.enum(["pending", "unitized"]),
  resolvedByBaselineId: z.string().uuid().optional(),
});

pendingRoute.patch("/:id", async (c) => {
  const userId = c.get("userId") as string;
  const pendingId = c.req.param("id");
  const body = UpdatePendingSchema.safeParse(await c.req.json());
  if (!body.success) {
    return c.json({ error: "Invalid input", details: body.error.flatten() }, 400);
  }

  const [updated] = await db
    .update(schema.pendingInvestments)
    .set({ ...body.data, updatedAt: new Date() })
    .where(
      and(eq(schema.pendingInvestments.id, pendingId), eq(schema.pendingInvestments.userId, userId))
    )
    .returning();

  if (!updated) {
    return c.json({ error: "Pending investment not found" }, 404);
  }

  return c.json(updated);
});

// ── DELETE /v1/pending/:id ────────────────────────────────────────────────────

pendingRoute.delete("/:id", async (c) => {
  const userId = c.get("userId") as string;
  const pendingId = c.req.param("id");

  const [deleted] = await db
    .delete(schema.pendingInvestments)
    .where(
      and(eq(schema.pendingInvestments.id, pendingId), eq(schema.pendingInvestments.userId, userId))
    )
    .returning();

  if (!deleted) {
    return c.json({ error: "Pending investment not found" }, 404);
  }

  return c.json({ ok: true });
});

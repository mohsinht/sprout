import { Hono } from "hono";
import { z } from "zod";
import { eq, and, desc } from "drizzle-orm";
import { db, schema } from "../db/client.js";
import { authMiddleware } from "../auth/middleware.js";
import { createFxSource } from "../sources/fx-source.js";

export const incomeRoute = new Hono<{ Variables: { userId: string } }>();

incomeRoute.use("*", authMiddleware);

// ── GET /v1/income/projected ──────────────────────────────────────────────────
// Projected income is a SIDE NOTE ONLY — days-remaining + approx PKR value.
// It is NEVER added to confirmed or estimated current wealth.

incomeRoute.get("/projected", async (c) => {
  const userId = c.get("userId") as string;

  const rows = await db
    .select()
    .from(schema.projectedIncome)
    .where(eq(schema.projectedIncome.userId, userId))
    .orderBy(desc(schema.projectedIncome.expectedOn));

  // Compute days remaining for each
  const today = new Date();
  const enriched = rows.map((r) => {
    const expected = new Date(r.expectedOn);
    const daysRemaining = Math.ceil((expected.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));
    return {
      ...r,
      daysRemaining,
      // Emphasize: this is NOT in current wealth
      inCurrentWealth: false,
    };
  });

  return c.json({ projectedIncome: enriched });
});

// ── POST /v1/income/projected ────────────────────────────────────────────────

const CreateProjectedSchema = z.object({
  amount: z.number().positive(),
  currency: z.string().length(3).default("USD"),
  expectedOn: z.string(),
  note: z.string().max(500).optional(),
});

incomeRoute.post("/projected", async (c) => {
  const userId = c.get("userId") as string;
  const body = CreateProjectedSchema.safeParse(await c.req.json());
  if (!body.success) {
    return c.json({ error: "Invalid input", details: body.error.flatten() }, 400);
  }

  // Convert to PKR estimate using today's FX
  let convertedPkrEstimate: number | undefined;
  if (body.data.currency !== "PKR") {
    const fxSource = createFxSource();
    const fx = await fxSource.fetchRate(`${body.data.currency}/PKR`);
    if (fx) {
      convertedPkrEstimate = Math.round(body.data.amount * fx.value);
    }
  } else {
    convertedPkrEstimate = Math.round(body.data.amount);
  }

  const [income] = await db
    .insert(schema.projectedIncome)
    .values({
      userId,
      amount: body.data.amount.toString(),
      currency: body.data.currency,
      expectedOn: body.data.expectedOn,
      convertedPkrEstimate,
      source: "user_told_me",
      note: body.data.note,
    })
    .returning();

  return c.json(income, 201);
});

// ── DELETE /v1/income/projected/:id ───────────────────────────────────────────

incomeRoute.delete("/projected/:id", async (c) => {
  const userId = c.get("userId") as string;
  const incomeId = c.req.param("id");

  const [deleted] = await db
    .delete(schema.projectedIncome)
    .where(
      and(eq(schema.projectedIncome.id, incomeId), eq(schema.projectedIncome.userId, userId))
    )
    .returning();

  if (!deleted) {
    return c.json({ error: "Projected income not found" }, 404);
  }

  return c.json({ ok: true });
});
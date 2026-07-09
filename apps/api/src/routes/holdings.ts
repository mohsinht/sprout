import { Hono } from "hono";
import { z } from "zod";
import { eq, and } from "drizzle-orm";
import { db, schema } from "../db/client.js";
import { authMiddleware } from "../auth/middleware.js";
import { dedupeFingerprint } from "../lib/dedupe.js";

export const holdingsRoute = new Hono<{ Variables: { userId: string } }>();

holdingsRoute.use("*", authMiddleware);

// ── GET /v1/holdings ─────────────────────────────────────────────────────────

holdingsRoute.get("/", async (c) => {
  const userId = c.get("userId") as string;

  const rows = await db
    .select()
    .from(schema.holdings)
    .where(eq(schema.holdings.userId, userId));

  return c.json({ holdings: rows });
});

// ── POST /v1/holdings ────────────────────────────────────────────────────────

const CreateHoldingSchema = z.object({
  kind: z.enum(["mutual_fund", "cash", "equity", "other"]),
  institution: z.string().min(1).max(200),
  label: z.string().min(1).max(200),
  fundCode: z.string().max(50).optional(),
  currency: z.string().length(3).default("PKR"),
  units: z.number().nonnegative().optional(),
  valueNative: z.number().nonnegative().optional(),
  valuePkr: z.number().int().nonnegative().default(0),
  priceAsOf: z.string().optional(),
  priceSource: z.string().optional(),
  freshness: z.enum(["fresh", "stale", "manual", "unavailable"]).default("manual"),
});

holdingsRoute.post("/", async (c) => {
  const userId = c.get("userId") as string;
  const body = CreateHoldingSchema.safeParse(await c.req.json());
  if (!body.success) {
    return c.json({ error: "Invalid input", details: body.error.flatten() }, 400);
  }

  const [holding] = await db
    .insert(schema.holdings)
    .values({
      userId,
      ...body.data,
      units: body.data.units?.toString(),
      valueNative: body.data.valueNative?.toString(),
    })
    .returning();

  return c.json(holding, 201);
});

// ── PATCH /v1/holdings/:id ──────────────────────────────────────────────────

const UpdateHoldingSchema = z.object({
  units: z.number().nonnegative().optional(),
  valueNative: z.number().nonnegative().optional(),
  valuePkr: z.number().int().nonnegative().optional(),
  priceAsOf: z.string().optional(),
  priceSource: z.string().optional(),
  freshness: z.enum(["fresh", "stale", "manual", "unavailable"]).optional(),
  label: z.string().min(1).max(200).optional(),
  institution: z.string().min(1).max(200).optional(),
});

holdingsRoute.patch("/:id", async (c) => {
  const userId = c.get("userId") as string;
  const holdingId = c.req.param("id");
  const body = UpdateHoldingSchema.safeParse(await c.req.json());
  if (!body.success) {
    return c.json({ error: "Invalid input", details: body.error.flatten() }, 400);
  }

  const updates: Record<string, unknown> = { updatedAt: new Date() };
  if (body.data.units !== undefined) updates.units = body.data.units.toString();
  if (body.data.valueNative !== undefined) updates.valueNative = body.data.valueNative.toString();
  if (body.data.valuePkr !== undefined) updates.valuePkr = body.data.valuePkr;
  if (body.data.priceAsOf !== undefined) updates.priceAsOf = body.data.priceAsOf;
  if (body.data.priceSource !== undefined) updates.priceSource = body.data.priceSource;
  if (body.data.freshness !== undefined) updates.freshness = body.data.freshness;
  if (body.data.label !== undefined) updates.label = body.data.label;
  if (body.data.institution !== undefined) updates.institution = body.data.institution;

  const [updated] = await db
    .update(schema.holdings)
    .set(updates)
    .where(and(eq(schema.holdings.id, holdingId), eq(schema.holdings.userId, userId)))
    .returning();

  if (!updated) {
    return c.json({ error: "Holding not found" }, 404);
  }

  return c.json(updated);
});

// ── DELETE /v1/holdings/:id ──────────────────────────────────────────────────

holdingsRoute.delete("/:id", async (c) => {
  const userId = c.get("userId") as string;
  const holdingId = c.req.param("id");

  const [deleted] = await db
    .delete(schema.holdings)
    .where(and(eq(schema.holdings.id, holdingId), eq(schema.holdings.userId, userId)))
    .returning();

  if (!deleted) {
    return c.json({ error: "Holding not found" }, 404);
  }

  return c.json({ ok: true });
});
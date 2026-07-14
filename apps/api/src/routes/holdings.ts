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

const HoldingValuesSchema = z.object({
  kind: z.enum(["mutual_fund", "cash", "equity", "other"]),
  institution: z.string().min(1).max(200),
  label: z.string().min(1).max(200),
  fundCode: z.string().max(50).optional(),
  currency: z.string().length(3).default("PKR"),
  units: z.number().nonnegative().optional(),
  valueNative: z.number().nonnegative().optional(),
  valuePkr: z.number().int().nonnegative().default(0),
  priceAsOf: z.string().date().optional(),
  priceSource: z.string().optional(),
  freshness: z.enum(["fresh", "stale", "manual", "unavailable"]).default("manual"),
});

function provenanceIssue(value: {
  kind?: string;
  currency?: string;
  freshness?: string;
  priceAsOf?: string;
  priceSource?: string;
}): string | null {
  if (value.priceAsOf) {
    const asOf = new Date(`${value.priceAsOf}T00:00:00Z`);
    const ageDays = Math.floor((Date.now() - asOf.getTime()) / 86_400_000);
    if (ageDays < 0) return "Valuation dates cannot be in the future";
    if (ageDays > 400) return "Valuation date is beyond the supported history horizon";
  }
  if (value.kind === "cash" && value.currency === "PKR" && value.freshness === "fresh") {
    return "Manual PKR cash must use manual freshness";
  }
  if (value.freshness !== "fresh") return null;
  if (!value.priceAsOf?.trim() || !value.priceSource?.trim()) {
    return "Fresh valuations require a dated price/FX source";
  }
  return null;
}

function computedFreshness(value: { kind: string; currency: string; priceAsOf?: string }) {
  if (value.kind === "cash" && value.currency === "PKR") return "manual" as const;
  if (!value.priceAsOf) return "unavailable" as const;
  const ageDays = Math.floor((Date.now() - new Date(`${value.priceAsOf}T00:00:00Z`).getTime()) / 86_400_000);
  return ageDays <= (value.kind === "cash" ? 1 : 2) ? "fresh" as const : "stale" as const;
}

const CreateHoldingSchema = HoldingValuesSchema.superRefine((value, ctx) => {
  const issue = provenanceIssue(value);
  if (issue) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      path: ["freshness"],
      message: issue,
    });
  }
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
      freshness: computedFreshness(body.data),
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
  priceAsOf: z.string().date().optional(),
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

  const [existing] = await db
    .select()
    .from(schema.holdings)
    .where(and(eq(schema.holdings.id, holdingId), eq(schema.holdings.userId, userId)))
    .limit(1);
  if (!existing) return c.json({ error: "Holding not found" }, 404);

  const issue = provenanceIssue({
    kind: existing.kind,
    currency: existing.currency,
    freshness: body.data.freshness ?? existing.freshness,
    priceAsOf: body.data.priceAsOf ?? existing.priceAsOf ?? undefined,
    priceSource: body.data.priceSource ?? existing.priceSource ?? undefined,
  });
  if (issue) {
    return c.json({ error: issue }, 400);
  }

  const updates: Record<string, unknown> = { updatedAt: new Date() };
  if (body.data.units !== undefined) updates.units = body.data.units.toString();
  if (body.data.valueNative !== undefined) updates.valueNative = body.data.valueNative.toString();
  if (body.data.valuePkr !== undefined) updates.valuePkr = body.data.valuePkr;
  if (body.data.priceAsOf !== undefined) updates.priceAsOf = body.data.priceAsOf;
  if (body.data.priceSource !== undefined) updates.priceSource = body.data.priceSource;
  if (body.data.freshness !== undefined || body.data.priceAsOf !== undefined) {
    updates.freshness = computedFreshness({
      kind: existing.kind,
      currency: existing.currency,
      priceAsOf: body.data.priceAsOf ?? existing.priceAsOf ?? undefined,
    });
  }
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

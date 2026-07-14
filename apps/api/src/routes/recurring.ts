import { Hono } from "hono";
import { and, eq } from "drizzle-orm";
import { z } from "zod";
import { authMiddleware } from "../auth/middleware.js";
import { db, schema } from "../db/client.js";
import { dedupeFingerprint } from "../lib/dedupe.js";
import { generateRecurringOccurrences } from "../services/recurring-service.js";

export const recurringRoute = new Hono<{ Variables: { userId: string } }>();
recurringRoute.use("*", authMiddleware);

const TimeZoneSchema = z.string().refine((zone) => { try { new Intl.DateTimeFormat("en", { timeZone: zone }); return true; } catch { return false; } }, "Invalid IANA timezone");
const SeriesSchema = z.object({
  kind: z.enum(["liability", "expected_income"]), frequency: z.enum(["monthly", "on_salary_day"]),
  amount: z.number().int().positive(), label: z.string().min(1).max(120), timezone: TimeZoneSchema.optional(),
  anchorDay: z.number().int().min(1).max(31).optional(),
}).superRefine((value, ctx) => {
  if (value.frequency === "monthly" && value.anchorDay == null) ctx.addIssue({ code: "custom", path: ["anchorDay"], message: "Monthly series require an anchor day" });
});

recurringRoute.post("/series", async (c) => {
  const userId = c.get("userId");
  const parsed = SeriesSchema.safeParse(await c.req.json());
  if (!parsed.success) return c.json({ error: "Invalid input", details: parsed.error.flatten() }, 400);
  const [profile] = await db.select({ timezone: schema.profiles.timezone }).from(schema.profiles).where(eq(schema.profiles.userId, userId)).limit(1);
  const [created] = await db.insert(schema.recurringSeries).values({ userId, ...parsed.data, timezone: parsed.data.timezone ?? profile?.timezone ?? "Asia/Karachi" }).returning();
  return c.json(created, 201);
});

recurringRoute.post("/generate", async (c) => {
  const body = z.object({ instant: z.string().datetime({ offset: true }).optional() }).safeParse(await c.req.json());
  if (!body.success) return c.json({ error: "Invalid input", details: body.error.flatten() }, 400);
  await generateRecurringOccurrences(c.get("userId"), body.data.instant ? new Date(body.data.instant) : new Date());
  return c.json({ ok: true });
});

recurringRoute.get("/asks", async (c) => {
  const userId = c.get("userId");
  const rows = await db.select({ occurrence: schema.recurringOccurrences, series: schema.recurringSeries }).from(schema.recurringOccurrences)
    .innerJoin(schema.recurringSeries, eq(schema.recurringSeries.id, schema.recurringOccurrences.seriesId))
    .where(and(eq(schema.recurringOccurrences.userId, userId), eq(schema.recurringOccurrences.status, "ask_pending")));
  return c.json({ asks: rows.map(({ occurrence, series }) => ({
    id: occurrence.id, question: `${series.label} usually leaves around now. Did it this month?`,
    why: "So confirmed wealth changes only when the money really moved.", options: ["yes", "no", "stopped"],
  })) });
});

recurringRoute.post("/occurrences/:id/respond", async (c) => {
  const userId = c.get("userId");
  const id = z.string().uuid().safeParse(c.req.param("id"));
  const body = z.object({ outcome: z.enum(["yes", "no", "stopped"]), accountId: z.string().uuid().optional() }).safeParse(await c.req.json());
  if (!id.success || !body.success) return c.json({ error: "Invalid input" }, 400);
  const [row] = await db.select({ occurrence: schema.recurringOccurrences, series: schema.recurringSeries }).from(schema.recurringOccurrences)
    .innerJoin(schema.recurringSeries, eq(schema.recurringSeries.id, schema.recurringOccurrences.seriesId))
    .where(and(eq(schema.recurringOccurrences.id, id.data), eq(schema.recurringOccurrences.userId, userId))).limit(1);
  if (!row) return c.json({ error: "Occurrence not found" }, 404);
  if (row.occurrence.status !== "ask_pending") return c.json({ error: "Occurrence was already answered" }, 409);
  if (body.data.outcome === "no") {
    await db.update(schema.recurringOccurrences).set({ status: "skipped", askEmittedAt: new Date(), updatedAt: new Date() }).where(eq(schema.recurringOccurrences.id, id.data));
    return c.json({ status: "skipped" });
  }
  if (body.data.outcome === "stopped") {
    await db.transaction(async (tx) => {
      await tx.update(schema.recurringOccurrences).set({ status: "stopped", askEmittedAt: new Date(), updatedAt: new Date() }).where(eq(schema.recurringOccurrences.id, id.data));
      await tx.update(schema.recurringSeries).set({ active: false, updatedAt: new Date() }).where(eq(schema.recurringSeries.id, row.series.id));
    });
    return c.json({ status: "stopped" });
  }
  const occurredAt = new Date(`${row.occurrence.localDate}T12:00:00Z`);
  const fingerprint = dedupeFingerprint({ amount: row.series.amount, occurredAt, merchant: row.series.label });
  const [transaction] = await db.insert(schema.transactions).values({
    userId, accountId: body.data.accountId, amount: row.series.amount, currency: "PKR",
    type: row.series.kind === "liability" ? "expense" : "income", category: row.series.label,
    merchant: row.series.label, occurredAt, source: "manual", dedupeFingerprint: fingerprint, confidence: "1",
  }).returning();
  await db.update(schema.recurringOccurrences).set({ status: "confirmed", confirmedTransactionId: transaction.id, askEmittedAt: new Date(), updatedAt: new Date() }).where(eq(schema.recurringOccurrences.id, id.data));
  return c.json({ status: "confirmed", transactionId: transaction.id });
});

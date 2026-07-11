import { Hono } from "hono";
import { z } from "zod";
import { eq, and, desc } from "drizzle-orm";
import { db, schema } from "../db/client.js";
import { authMiddleware } from "../auth/middleware.js";
import { dedupeFingerprint } from "../lib/dedupe.js";

export const transactionsRoute = new Hono<{ Variables: { userId: string } }>();

transactionsRoute.use("*", authMiddleware);

// ── GET /v1/transactions ─────────────────────────────────────────────────────

transactionsRoute.get("/", async (c) => {
  const userId = c.get("userId") as string;
  const limit = Math.min(Number(c.req.query("limit") ?? 50), 200);

  const rows = await db
    .select()
    .from(schema.transactions)
    .where(eq(schema.transactions.userId, userId))
    .orderBy(desc(schema.transactions.occurredAt))
    .limit(limit);

  return c.json({ transactions: rows });
});

// ── POST /v1/transactions ────────────────────────────────────────────────────

const CreateTransactionSchema = z.object({
  amount: z.number().int().positive(),
  currency: z.string().length(3).default("PKR"),
  type: z.enum(["expense", "income", "transfer"]),
  category: z.string().min(1).max(100),
  merchant: z.string().max(200).optional(),
  note: z.string().max(500).optional(),
  occurredAt: z.string().optional(), // ISO; defaults to now
  source: z.enum(["manual", "sms", "email", "statement", "wise", "al_meezan"]).default("manual"),
  provider: z.string().max(200).optional(),
  confidence: z.number().min(0).max(1).default(1),
  needsReview: z.boolean().default(false),
  reviewReason: z.string().max(500).optional(),
  accountRef: z.string().optional(), // for dedupe fingerprint only
  accountId: z.string().uuid().optional(),
});

transactionsRoute.post("/", async (c) => {
  const userId = c.get("userId") as string;
  const body = CreateTransactionSchema.safeParse(await c.req.json());
  if (!body.success) {
    return c.json({ error: "Invalid input", details: body.error.flatten() }, 400);
  }

  const occurredAt = body.data.occurredAt
    ? new Date(body.data.occurredAt)
    : new Date();

  const fingerprint = dedupeFingerprint({
    amount: body.data.amount,
    occurredAt,
    merchant: body.data.merchant,
    accountRef: body.data.accountRef,
  });

  // Check for existing transaction with same fingerprint (dedupe)
  const existing = await db
    .select()
    .from(schema.transactions)
    .where(
      and(
        eq(schema.transactions.userId, userId),
        eq(schema.transactions.dedupeFingerprint, fingerprint)
      )
    )
    .limit(1);

  if (existing.length > 0) {
    return c.json(existing[0], 200); // idempotent: return existing
  }

  const { accountRef, accountId, ...txData } = body.data;

  if (accountId) {
    const [account] = await db
      .select({ id: schema.accounts.id })
      .from(schema.accounts)
      .where(and(eq(schema.accounts.id, accountId), eq(schema.accounts.userId, userId)))
      .limit(1);
    if (!account) return c.json({ error: "Account not found" }, 404);
  }

  const [tx] = await db
    .insert(schema.transactions)
    .values({
      userId,
      accountId,
      ...txData,
      occurredAt,
      dedupeFingerprint: fingerprint,
      confidence: txData.confidence.toString(),
    })
    .returning();

  return c.json(tx, 201);
});

// ── PATCH /v1/transactions/:id/confirm ────────────────────────────────────────

transactionsRoute.patch("/:id/confirm", async (c) => {
  const userId = c.get("userId") as string;
  const txId = c.req.param("id");

  const [updated] = await db
    .update(schema.transactions)
    .set({ needsReview: false, confidence: "1.00" })
    .where(
      and(eq(schema.transactions.id, txId), eq(schema.transactions.userId, userId))
    )
    .returning();

  if (!updated) {
    return c.json({ error: "Transaction not found" }, 404);
  }

  return c.json(updated);
});

// ── DELETE /v1/transactions/:id ───────────────────────────────────────────────

transactionsRoute.delete("/:id", async (c) => {
  const userId = c.get("userId") as string;
  const txId = c.req.param("id");

  const [deleted] = await db
    .delete(schema.transactions)
    .where(
      and(eq(schema.transactions.id, txId), eq(schema.transactions.userId, userId))
    )
    .returning();

  if (!deleted) {
    return c.json({ error: "Transaction not found" }, 404);
  }

  return c.json({ ok: true });
});

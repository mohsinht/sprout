import { Hono } from "hono";
import { and, eq, sql } from "drizzle-orm";
import { z } from "zod";
import { authMiddleware } from "../auth/middleware.js";
import { db, schema } from "../db/client.js";

export const accountsRoute = new Hono<{ Variables: { userId: string } }>();
accountsRoute.use("*", authMiddleware);

const AccountSchema = z.object({
  provider: z.string().min(1).max(100).default("Manual"),
  label: z.string().min(1).max(120),
  maskedRef: z.string().max(40).optional(),
  type: z.enum(["cash", "bank", "wallet", "wise", "investment", "foreign_balance", "other"]).default("cash"),
  openingBalance: z.number().int().default(0),
  currency: z.string().length(3).default("PKR"),
});

accountsRoute.get("/", async (c) => {
  const userId = c.get("userId") as string;
  const rows = await db
    .select({
      id: schema.accounts.id,
      provider: schema.accounts.provider,
      label: schema.accounts.label,
      maskedRef: schema.accounts.maskedRef,
      type: schema.accounts.type,
      openingBalance: schema.accounts.openingBalance,
      currency: schema.accounts.currency,
      isManual: schema.accounts.isManual,
      createdAt: schema.accounts.createdAt,
      transactionBalance: sql<number>`coalesce(sum(case when ${schema.transactions.type} = 'income' then ${schema.transactions.amount} when ${schema.transactions.type} = 'expense' then -${schema.transactions.amount} else 0 end), 0)`,
    })
    .from(schema.accounts)
    .leftJoin(schema.transactions, eq(schema.transactions.accountId, schema.accounts.id))
    .where(eq(schema.accounts.userId, userId))
    .groupBy(schema.accounts.id)
    .orderBy(schema.accounts.createdAt);

  return c.json({
    accounts: rows.map((row) => ({
      ...row,
      balance: row.openingBalance + Number(row.transactionBalance ?? 0),
      updatedLabel: "Tracked manually",
      freshness: "manual",
    })),
  });
});

accountsRoute.post("/", async (c) => {
  const userId = c.get("userId") as string;
  const body = AccountSchema.safeParse(await c.req.json());
  if (!body.success) return c.json({ error: "Invalid input", details: body.error.flatten() }, 400);

  const [account] = await db.insert(schema.accounts).values({ userId, ...body.data }).returning();
  return c.json({ ...account, balance: account.openingBalance, freshness: "manual", updatedLabel: "Tracked manually" }, 201);
});

accountsRoute.patch("/:id", async (c) => {
  const userId = c.get("userId") as string;
  const accountId = c.req.param("id");
  const body = AccountSchema.partial().safeParse(await c.req.json());
  if (!body.success) return c.json({ error: "Invalid input", details: body.error.flatten() }, 400);

  const [account] = await db
    .update(schema.accounts)
    .set({ ...body.data, updatedAt: new Date() })
    .where(and(eq(schema.accounts.id, accountId), eq(schema.accounts.userId, userId)))
    .returning();
  if (!account) return c.json({ error: "Account not found" }, 404);
  return c.json(account);
});

accountsRoute.delete("/:id", async (c) => {
  const userId = c.get("userId") as string;
  const accountId = c.req.param("id");
  const [deleted] = await db
    .delete(schema.accounts)
    .where(and(eq(schema.accounts.id, accountId), eq(schema.accounts.userId, userId)))
    .returning({ id: schema.accounts.id });
  if (!deleted) return c.json({ error: "Account not found" }, 404);
  return c.json({ ok: true });
});

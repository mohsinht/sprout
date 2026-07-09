import { Hono } from "hono";
import { z } from "zod";
import { eq, and, desc } from "drizzle-orm";
import { db, schema } from "../db/client.js";
import { authMiddleware } from "../auth/middleware.js";

/**
 * Statement/screenshot upload + re-anchor — the highest-trust event in the app.
 *
 * When a user uploads a new Al Meezan statement:
 *   - parse confirmed units → create a new baseline
 *   - mark matching pending_investments as unitized
 *   - update holdings with confirmed units + units_confirmed_as_of
 *   - the estimate resets to the new confirmed truth
 *
 * When a user uploads a new Wise screenshot:
 *   - new cash baseline → clear manual adjustments that predate it
 *   - update holding with confirmed balance
 *
 * File storage: by default, discard the file after parsing. Store only the
 * structured extract + provenance. The uploadedFileId is kept for reference
 * but the file itself is deleted.
 */

export const uploadRoute = new Hono<{ Variables: { userId: string } }>();

uploadRoute.use("*", authMiddleware);

// ── GET /v1/upload/baselines ──────────────────────────────────────────────────

uploadRoute.get("/baselines", async (c) => {
  const userId = c.get("userId") as string;

  const rows = await db
    .select()
    .from(schema.baselines)
    .where(eq(schema.baselines.userId, userId))
    .orderBy(desc(schema.baselines.capturedAsOf));

  return c.json({ baselines: rows });
});

// ── POST /v1/upload/statement ─────────────────────────────────────────────────
// Re-anchor from an Al Meezan statement. The client sends the parsed extract
// (units per fund, statement date). The backend creates a baseline, updates
// holdings with confirmed units, and marks matching pending investments as unitized.

const StatementExtractSchema = z.object({
  capturedAsOf: z.string(), // when the statement was captured
  printedOn: z.string().optional(), // date printed on the document
  confirmedValuePkr: z.number().int().nonnegative(),
  funds: z.array(
    z.object({
      holdingId: z.string().uuid().optional(), // existing holding to update
      fundCode: z.string(),
      fundName: z.string().optional(),
      units: z.number().nonnegative(),
      nav: z.number().positive().optional(),
      valuePkr: z.number().int().nonnegative().optional(),
    })
  ),
  rawExtract: z.record(z.unknown()).optional(), // full structured extract
});

uploadRoute.post("/statement", async (c) => {
  const userId = c.get("userId") as string;
  const body = StatementExtractSchema.safeParse(await c.req.json());
  if (!body.success) {
    return c.json({ error: "Invalid input", details: body.error.flatten() }, 400);
  }

  const { capturedAsOf, printedOn, confirmedValuePkr, funds, rawExtract } = body.data;

  // 1. Create a new baseline
  const [baseline] = await db
    .insert(schema.baselines)
    .values({
      userId,
      sourceKind: "al_meezan_statement",
      capturedAsOf,
      printedOn,
      confirmedValuePkr,
      rawExtractJson: rawExtract ?? { funds },
    })
    .returning();

  // 2. Update holdings with confirmed units
  for (const fund of funds) {
    if (fund.holdingId) {
      await db
        .update(schema.holdings)
        .set({
          units: fund.units.toString(),
          unitsConfirmedAsOf: capturedAsOf,
          valuationKind: "confirmed",
          baselineId: baseline.id,
          updatedAt: new Date(),
        })
        .where(
          and(eq(schema.holdings.id, fund.holdingId), eq(schema.holdings.userId, userId))
        );
    } else if (fund.fundCode) {
      // Try to find existing holding by fund code
      const existing = await db
        .select()
        .from(schema.holdings)
        .where(
          and(
            eq(schema.holdings.userId, userId),
            eq(schema.holdings.fundCode, fund.fundCode)
          )
        )
        .limit(1);

      if (existing[0]) {
        await db
          .update(schema.holdings)
          .set({
            units: fund.units.toString(),
            unitsConfirmedAsOf: capturedAsOf,
            valuationKind: "confirmed",
            baselineId: baseline.id,
            updatedAt: new Date(),
          })
          .where(eq(schema.holdings.id, existing[0].id));
      } else {
        // Create new holding from statement
        await db.insert(schema.holdings).values({
          userId,
          kind: "mutual_fund",
          institution: "Al Meezan",
          label: fund.fundName ?? fund.fundCode,
          fundCode: fund.fundCode,
          currency: "PKR",
          units: fund.units.toString(),
          unitsConfirmedAsOf: capturedAsOf,
          valuePkr: fund.valuePkr ?? 0,
          valuationKind: "confirmed",
          baselineId: baseline.id,
          freshness: "fresh",
        });
      }
    }
  }

  // 3. Mark matching pending investments as unitized
  const pendingRows = await db
    .select()
    .from(schema.pendingInvestments)
    .where(
      and(
        eq(schema.pendingInvestments.userId, userId),
        eq(schema.pendingInvestments.status, "pending")
      )
    );

  for (const p of pendingRows) {
    // If the pending investment was initiated before this statement, mark it unitized
    if (p.initiatedOn <= capturedAsOf) {
      await db
        .update(schema.pendingInvestments)
        .set({ status: "unitized", resolvedByBaselineId: baseline.id, updatedAt: new Date() })
        .where(eq(schema.pendingInvestments.id, p.id));
    }
  }

  return c.json({
    ok: true,
    baselineId: baseline.id,
    message: "Reconciled to your new statement. Your holdings are now confirmed.",
    fundsUpdated: funds.length,
    pendingUnitized: pendingRows.filter((p) => p.initiatedOn <= capturedAsOf).length,
  }, 201);
});

// ── POST /v1/upload/screenshot ────────────────────────────────────────────────
// Re-anchor from a Wise screenshot. The client sends the parsed balance.
// Creates a baseline, updates the cash holding with confirmed balance.

const ScreenshotExtractSchema = z.object({
  capturedAsOf: z.string(),
  holdingId: z.string().uuid().optional(),
  institution: z.string().default("Wise"),
  currency: z.string().length(3),
  confirmedBalance: z.number().nonnegative(),
  rawExtract: z.record(z.unknown()).optional(),
});

uploadRoute.post("/screenshot", async (c) => {
  const userId = c.get("userId") as string;
  const body = ScreenshotExtractSchema.safeParse(await c.req.json());
  if (!body.success) {
    return c.json({ error: "Invalid input", details: body.error.flatten() }, 400);
  }

  const { capturedAsOf, holdingId, institution, currency, confirmedBalance, rawExtract } = body.data;

  // Convert to PKR for the baseline confirmed value (rough — FX will be applied properly in estimation)
  const confirmedValuePkr = currency === "PKR" ? Math.round(confirmedBalance) : 0;

  const [baseline] = await db
    .insert(schema.baselines)
    .values({
      userId,
      sourceKind: "wise_screenshot",
      capturedAsOf,
      confirmedValuePkr,
      rawExtractJson: rawExtract ?? { institution, currency, confirmedBalance },
    })
    .returning();

  // Update or create the cash holding
  if (holdingId) {
    await db
      .update(schema.holdings)
      .set({
        valueNative: confirmedBalance.toString(),
        unitsConfirmedAsOf: capturedAsOf,
        valuationKind: "confirmed",
        baselineId: baseline.id,
        updatedAt: new Date(),
      })
      .where(
        and(eq(schema.holdings.id, holdingId), eq(schema.holdings.userId, userId))
      );
  } else {
    // Find existing holding by institution + currency
    const existing = await db
      .select()
      .from(schema.holdings)
      .where(
        and(
          eq(schema.holdings.userId, userId),
          eq(schema.holdings.institution, institution),
          eq(schema.holdings.currency, currency)
        )
      )
      .limit(1);

    if (existing[0]) {
      await db
        .update(schema.holdings)
        .set({
          valueNative: confirmedBalance.toString(),
          unitsConfirmedAsOf: capturedAsOf,
          valuationKind: "confirmed",
          baselineId: baseline.id,
          updatedAt: new Date(),
        })
        .where(eq(schema.holdings.id, existing[0].id));
    } else {
      await db.insert(schema.holdings).values({
        userId,
        kind: "cash",
        institution,
        label: `${institution} ${currency} Cash`,
        currency,
        valueNative: confirmedBalance.toString(),
        unitsConfirmedAsOf: capturedAsOf,
        valuationKind: "confirmed",
        baselineId: baseline.id,
        freshness: "fresh",
      });
    }
  }

  return c.json({
    ok: true,
    baselineId: baseline.id,
    message: "Reconciled to your new screenshot. Your cash balance is now confirmed.",
  }, 201);
});
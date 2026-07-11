import { and, eq, isNull } from "drizzle-orm";
import { closeDb, db, schema } from "../db/client.js";

/**
 * Seeds the one-user Phase 1 baseline without inventing missing values.
 *
 * Required environment:
 *   SEED_USER_ID, SEED_AS_OF
 *   WISE_USD_BALANCE, WISE_EUR_BALANCE
 *   CAR_TARGET_PKR, CAR_CURRENT_PKR
 *   EMERGENCY_TARGET_PKR, EMERGENCY_CURRENT_PKR
 *
 * Fund units are the confirmed values from spec/phase1_execution_plan.md.
 * Prices and FX are intentionally left unavailable for the later source
 * tickets to populate; a zero valuation must never be mistaken for a quote.
 */

type SeedValues = {
  userId: string;
  asOf: string;
  usdBalance: number;
  eurBalance: number;
  carTarget: number;
  carCurrent: number;
  emergencyTarget: number;
  emergencyCurrent: number;
};

const required = (name: string): string => {
  const value = process.env[name]?.trim();
  if (!value) throw new Error(`Missing required environment variable: ${name}`);
  return value;
};

const positiveNumber = (name: string): number => {
  const value = Number(required(name));
  if (!Number.isFinite(value) || value < 0) {
    throw new Error(`${name} must be a non-negative number`);
  }
  return value;
};

const isoDate = (name: string): string => {
  const value = required(name);
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) {
    throw new Error(`${name} must use YYYY-MM-DD`);
  }
  return value;
};

const readValues = (): SeedValues => ({
  userId: required("SEED_USER_ID"),
  asOf: isoDate("SEED_AS_OF"),
  usdBalance: positiveNumber("WISE_USD_BALANCE"),
  eurBalance: positiveNumber("WISE_EUR_BALANCE"),
  carTarget: positiveNumber("CAR_TARGET_PKR"),
  carCurrent: positiveNumber("CAR_CURRENT_PKR"),
  emergencyTarget: positiveNumber("EMERGENCY_TARGET_PKR"),
  emergencyCurrent: positiveNumber("EMERGENCY_CURRENT_PKR"),
});

const fundSeeds = [
  { fundCode: "AMMF", label: "Al Meezan Cash Fund", units: 28822.5265 },
  { fundCode: "MDIP", label: "Meezan Islamic Income Fund", units: 4.471 },
  {
    fundCode: "MFPF-AAP",
    label: "Meezan Islamic Asset Allocation Fund",
    units: 3352.5457,
  },
  { fundCode: "MIF", label: "Al Meezan Mutual Fund", units: 12139.0066 },
  {
    fundCode: "MSF-GROWTH-C",
    label: "Meezan Sovereign Fund Growth-C",
    units: 19741.7072,
  },
  {
    fundCode: "MSF-S-PLAN",
    label: "Meezan Sovereign Fund S-Plan",
    units: 1845.7239,
  },
] as const;

async function upsertHolding(
  userId: string,
  seed: {
    kind: "mutual_fund" | "cash";
    institution: string;
    label: string;
    fundCode?: string;
    currency: string;
    units?: number;
    unitsConfirmedAsOf?: string;
    valueNative?: number;
  },
) {
  const existing = await db
    .select({ id: schema.holdings.id })
    .from(schema.holdings)
    .where(
      seed.fundCode
        ? and(
            eq(schema.holdings.userId, userId),
            eq(schema.holdings.fundCode, seed.fundCode),
          )
        : and(
            eq(schema.holdings.userId, userId),
            eq(schema.holdings.label, seed.label),
            isNull(schema.holdings.fundCode),
          ),
    )
    .limit(1);

  const values = {
    userId,
    kind: seed.kind,
    institution: seed.institution,
    label: seed.label,
    fundCode: seed.fundCode,
    currency: seed.currency,
    units: seed.units?.toString(),
    unitsConfirmedAsOf: seed.unitsConfirmedAsOf,
    valueNative: seed.valueNative?.toString(),
    valuePkr: 0,
    priceAsOf: null,
    priceSource: null,
    freshness: "unavailable" as const,
    valuationKind: "estimated" as const,
    updatedAt: new Date(),
  };

  if (existing[0]) {
    await db
      .update(schema.holdings)
      .set(values)
      .where(eq(schema.holdings.id, existing[0].id));
    return "updated";
  }

  await db.insert(schema.holdings).values(values);
  return "inserted";
}

async function upsertGoal(
  userId: string,
  seed: {
    name: string;
    type: "car" | "emergency";
    targetAmount: number;
    currentAmount: number;
    status: "active" | "complete";
  },
) {
  const existing = await db
    .select({ id: schema.goals.id })
    .from(schema.goals)
    .where(
      and(eq(schema.goals.userId, userId), eq(schema.goals.type, seed.type)),
    )
    .limit(1);

  const values = { ...seed, userId, updatedAt: new Date() };
  if (existing[0]) {
    await db
      .update(schema.goals)
      .set(values)
      .where(eq(schema.goals.id, existing[0].id));
    return "updated";
  }

  await db.insert(schema.goals).values(values);
  return "inserted";
}

async function main(): Promise<void> {
  const values = readValues();

  for (const fund of fundSeeds) {
    await upsertHolding(values.userId, {
      ...fund,
      kind: "mutual_fund",
      institution: "Al Meezan",
      currency: "PKR",
      unitsConfirmedAsOf: values.asOf,
    });
  }

  await upsertHolding(values.userId, {
    kind: "cash",
    institution: "Wise",
    label: "Wise USD Cash",
    currency: "USD",
    valueNative: values.usdBalance,
  });
  await upsertHolding(values.userId, {
    kind: "cash",
    institution: "Wise",
    label: "Wise EUR Cash",
    currency: "EUR",
    valueNative: values.eurBalance,
  });
  await upsertHolding(values.userId, {
    kind: "cash",
    institution: "Local",
    label: "PKR Cash",
    currency: "PKR",
    valueNative: 0,
  });

  await upsertGoal(values.userId, {
    name: "Car Fund",
    type: "car",
    targetAmount: values.carTarget,
    currentAmount: values.carCurrent,
    status: values.carCurrent >= values.carTarget ? "complete" : "active",
  });
  await upsertGoal(values.userId, {
    name: "Emergency Fund",
    type: "emergency",
    targetAmount: values.emergencyTarget,
    currentAmount: values.emergencyCurrent,
    status:
      values.emergencyCurrent >= values.emergencyTarget ? "complete" : "active",
  });

  console.log(
    `Seeded holdings and goals for ${values.userId} as of ${values.asOf}.`,
  );
}

try {
  await main();
} finally {
  await closeDb();
}

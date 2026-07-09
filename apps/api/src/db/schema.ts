import {
  pgTable,
  uuid,
  varchar,
  text,
  integer,
  numeric,
  timestamp,
  date,
  boolean,
  jsonb,
  pgEnum,
  uniqueIndex,
  index,
} from "drizzle-orm/pg-core";

// ── Enums ───────────────────────────────────────────────────────────────────

export const incomeTypeEnum = pgEnum("income_type", [
  "salaried",
  "freelance",
  "business",
  "student",
  "other",
]);

export const holdingKindEnum = pgEnum("holding_kind", [
  "mutual_fund",
  "cash",
  "equity",
  "other",
]);

export const holdingFreshnessEnum = pgEnum("holding_freshness", [
  "fresh",
  "stale",
  "manual",
  "unavailable",
  "estimated",
]);

export const valuationKindEnum = pgEnum("valuation_kind", [
  "confirmed",
  "estimated",
]);

export const baselineSourceKindEnum = pgEnum("baseline_source_kind", [
  "al_meezan_statement",
  "wise_screenshot",
  "manual",
]);

export const pendingStatusEnum = pgEnum("pending_status", [
  "pending",
  "unitized",
]);

export const projectedIncomeSourceEnum = pgEnum("projected_income_source", [
  "user_told_me",
  "inferred",
]);

export const transactionSourceEnum = pgEnum("transaction_source", [
  "manual",
  "sms",
  "email",
  "statement",
  "wise",
  "al_meezan",
]);

export const transactionTypeEnum = pgEnum("transaction_type", [
  "expense",
  "income",
  "transfer",
]);

export const goalTypeEnum = pgEnum("goal_type", [
  "emergency",
  "car",
  "home",
  "education",
  "eidi",
  "zakat",
  "travel",
  "custom",
]);

export const goalStatusEnum = pgEnum("goal_status", [
  "active",
  "complete",
  "paused",
]);

export const jobStatusEnum = pgEnum("job_status", [
  "running",
  "succeeded",
  "failed",
]);

export const jobTypeEnum = pgEnum("job_type", ["daily", "on_demand"]);

export const briefingFreshnessEnum = pgEnum("briefing_freshness", [
  "fresh",
  "stale",
  "local_fallback",
  "unavailable",
]);

export const mascotMoodEnum = pgEnum("mascot_mood", [
  "thriving",
  "content",
  "watchful",
  "concerned",
]);

export const dataSourceKindEnum = pgEnum("data_source_kind", [
  "email",
  "fx",
  "nav",
  "wise",
  "statement",
  "sms",
]);

export const dataSourceStatusEnum = pgEnum("data_source_status", [
  "connected",
  "needs_review",
  "not_connected",
  "error",
]);

// ── Tables ──────────────────────────────────────────────────────────────────

export const users = pgTable("users", {
  id: uuid("id").defaultRandom().primaryKey(),
  email: varchar("email", { length: 255 }).notNull().unique(),
  passwordHash: text("password_hash").notNull(),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow().notNull(),
});

export const refreshTokens = pgTable(
  "refresh_tokens",
  {
    id: uuid("id").defaultRandom().primaryKey(),
    userId: uuid("user_id")
      .notNull()
      .references(() => users.id, { onDelete: "cascade" }),
    tokenHash: text("token_hash").notNull().unique(),
    expiresAt: timestamp("expires_at", { withTimezone: true }).notNull(),
    revokedAt: timestamp("revoked_at", { withTimezone: true }),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
  },
  (t) => [index("refresh_tokens_user_idx").on(t.userId)],
);

export const profiles = pgTable("profiles", {
  userId: uuid("user_id")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
  name: text("name").notNull().default("friend"),
  incomeType: incomeTypeEnum("income_type"),
  salaryDate: integer("salary_date"), // day of month 1-31
  locale: varchar("locale", { length: 10 }).notNull().default("en"),
  reduceMotion: boolean("reduce_motion").notNull().default(false),
  hideBalances: boolean("hide_balances").notNull().default(false),
  displayCurrency: varchar("display_currency", { length: 3 }).notNull().default("PKR"),
  onboardingComplete: boolean("onboarding_complete").notNull().default(false),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow().notNull(),
});

export const goals = pgTable("goals", {
  id: uuid("id").defaultRandom().primaryKey(),
  userId: uuid("user_id")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
  name: text("name").notNull(),
  type: goalTypeEnum("type").notNull(),
  targetAmount: integer("target_amount").notNull(),
  currentAmount: integer("current_amount").notNull().default(0),
  deadline: date("deadline"),
  status: goalStatusEnum("status").notNull().default("active"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow().notNull(),
});

export const holdings = pgTable("holdings", {
  id: uuid("id").defaultRandom().primaryKey(),
  userId: uuid("user_id")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
  kind: holdingKindEnum("kind").notNull(),
  institution: text("institution").notNull(),
  label: text("label").notNull(),
  fundCode: varchar("fund_code", { length: 50 }),
  currency: varchar("currency", { length: 3 }).notNull().default("PKR"),
  units: numeric("units", { precision: 20, scale: 4 }),
  unitsConfirmedAsOf: date("units_confirmed_as_of"),
  valueNative: numeric("value_native", { precision: 20, scale: 2 }),
  valuePkr: integer("value_pkr").notNull().default(0),
  priceAsOf: date("price_as_of"),
  priceSource: text("price_source"),
  freshness: holdingFreshnessEnum("freshness").notNull().default("manual"),
  valuationKind: valuationKindEnum("valuation_kind").notNull().default("confirmed"),
  baselineId: uuid("baseline_id"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow().notNull(),
});

export const priceQuotes = pgTable("price_quotes", {
  id: uuid("id").defaultRandom().primaryKey(),
  instrument: varchar("instrument", { length: 100 }).notNull(), // fund code or symbol
  value: numeric("value", { precision: 20, scale: 8 }).notNull(),
  asOf: date("as_of").notNull(),
  source: text("source").notNull(),
  sourceUrl: text("source_url"),
  currency: varchar("currency", { length: 3 }).notNull().default("PKR"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
});

export const fxRates = pgTable("fx_rates", {
  id: uuid("id").defaultRandom().primaryKey(),
  pair: varchar("pair", { length: 20 }).notNull(), // e.g. "USD/PKR"
  rate: numeric("rate", { precision: 20, scale: 6 }).notNull(),
  asOf: date("as_of").notNull(),
  source: text("source").notNull(),
  sourceUrl: text("source_url"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
});

export const transactions = pgTable("transactions", {
  id: uuid("id").defaultRandom().primaryKey(),
  userId: uuid("user_id")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
  amount: integer("amount").notNull(), // whole PKR
  currency: varchar("currency", { length: 3 }).notNull().default("PKR"),
  type: transactionTypeEnum("type").notNull(),
  category: text("category").notNull(),
  merchant: text("merchant"),
  note: text("note"),
  occurredAt: timestamp("occurred_at", { withTimezone: true }).notNull(),
  source: transactionSourceEnum("source").notNull().default("manual"),
  provider: text("provider"),
  parserVersion: text("parser_version"),
  dedupeFingerprint: text("dedupe_fingerprint").notNull(),
  confidence: numeric("confidence", { precision: 3, scale: 2 }).notNull().default("1.00"),
  needsReview: boolean("needs_review").notNull().default(false),
  reviewReason: text("review_reason"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
});

export const wealthSnapshots = pgTable("wealth_snapshots", {
  id: uuid("id").defaultRandom().primaryKey(),
  userId: uuid("user_id")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
  date: date("date").notNull(),
  totalPkr: integer("total_pkr").notNull(),
  perHoldingJson: jsonb("per_holding_json").notNull(),
  changeVsYesterday: integer("change_vs_yesterday").notNull().default(0),
  changeMtd: integer("change_mtd").notNull().default(0),
  mainReason: text("main_reason"),
  interpretationJson: jsonb("interpretation_json"),
  freshness: holdingFreshnessEnum("freshness").notNull().default("fresh"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
});

export const wealthEvents = pgTable("wealth_events", {
  id: uuid("id").defaultRandom().primaryKey(),
  userId: uuid("user_id")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
  date: date("date").notNull(),
  holdingId: uuid("holding_id"),
  kind: varchar("kind", { length: 50 }).notNull(),
  magnitudePkr: integer("magnitude_pkr").notNull().default(0),
  direction: varchar("direction", { length: 10 }).notNull(),
  plainWhy: text("plain_why").notNull(),
  learnMoreId: text("learn_more_id"),
  severity: varchar("severity", { length: 20 }).notNull(),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
});

export const dailyBriefings = pgTable("daily_briefings", {
  id: uuid("id").defaultRandom().primaryKey(),
  userId: uuid("user_id")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
  briefingDate: date("briefing_date").notNull(),
  generatedAt: timestamp("generated_at", { withTimezone: true }).notNull(),
  freshness: briefingFreshnessEnum("freshness").notNull().default("fresh"),
  mascotMood: mascotMoodEnum("mascot_mood").notNull().default("content"),
  greeting: text("greeting").notNull(),
  summary: text("summary").notNull(),
  healthScore: integer("health_score").notNull(),
  healthStatus: varchar("health_status", { length: 20 }).notNull(),
  wealthSnapshotJson: jsonb("wealth_snapshot_json").notNull(),
  wealthEventsJson: jsonb("wealth_events_json").notNull(),
  learnThreadsJson: jsonb("learn_threads_json"),
  recommendedActionJson: jsonb("recommended_action_json").notNull(),
  goalsJson: jsonb("goals_json").notNull(),
  holdingsJson: jsonb("holdings_json").notNull(),
  streak: integer("streak").notNull().default(0),
  xp: integer("xp").notNull().default(0),
  level: integer("level").notNull().default(1),
  aiModel: text("ai_model"),
  aiCostCents: integer("ai_cost_cents").notNull().default(0),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
});

export const dataSources = pgTable("data_sources", {
  id: uuid("id").defaultRandom().primaryKey(),
  userId: uuid("user_id")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
  kind: dataSourceKindEnum("kind").notNull(),
  status: dataSourceStatusEnum("status").notNull().default("not_connected"),
  lastSyncedAt: timestamp("last_synced_at", { withTimezone: true }),
  encryptedCredentials: text("encrypted_credentials"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow().notNull(),
});

export const jobRuns = pgTable(
  "job_runs",
  {
    id: uuid("id").defaultRandom().primaryKey(),
    userId: uuid("user_id").references(() => users.id, { onDelete: "cascade" }),
    type: jobTypeEnum("type").notNull(),
    status: jobStatusEnum("status").notNull().default("running"),
    startedAt: timestamp("started_at", { withTimezone: true }).notNull(),
    finishedAt: timestamp("finished_at", { withTimezone: true }),
    error: text("error"),
    idempotencyKey: varchar("idempotency_key", { length: 255 }).notNull(),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
  },
  (t) => [uniqueIndex("job_runs_idempotency_idx").on(t.idempotencyKey)],
);

// ── Reconciliation Model Tables ──────────────────────────────────────────────
// Sprout is a reconciliation engine: statements/screenshots are truth;
// between them, everything is a labelled estimate.

/** Baselines — the anchor points. The most recent baseline per account is truth. */
export const baselines = pgTable("baselines", {
  id: uuid("id").defaultRandom().primaryKey(),
  userId: uuid("user_id")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
  sourceKind: baselineSourceKindEnum("source_kind").notNull(),
  capturedAsOf: date("captured_as_of").notNull(), // when the statement/screenshot was captured
  printedOn: date("printed_on"), // date printed on the document
  confirmedValuePkr: integer("confirmed_value_pkr").notNull(),
  rawExtractJson: jsonb("raw_extract_json"), // structured extract from the statement
  uploadedFileId: text("uploaded_file_id"), // ref to object storage (deleted after parse by default)
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
});

/** Pending investments — in-transit money not yet unitized. */
export const pendingInvestments = pgTable("pending_investments", {
  id: uuid("id").defaultRandom().primaryKey(),
  userId: uuid("user_id")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
  amountPkr: integer("amount_pkr").notNull(),
  destination: text("destination").notNull(), // e.g. "MFPF Aggressive Allocation"
  initiatedOn: date("initiated_on").notNull(),
  status: pendingStatusEnum("status").notNull().default("pending"),
  resolvedByBaselineId: uuid("resolved_by_baseline_id"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow().notNull(),
});

/** Projected income — the salary countdown. NEVER added to current wealth. */
export const projectedIncome = pgTable("projected_income", {
  id: uuid("id").defaultRandom().primaryKey(),
  userId: uuid("user_id")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
  amount: numeric("amount", { precision: 20, scale: 2 }).notNull(),
  currency: varchar("currency", { length: 3 }).notNull().default("USD"),
  expectedOn: date("expected_on").notNull(),
  convertedPkrEstimate: integer("converted_pkr_estimate"), // estimated using that day's FX
  source: projectedIncomeSourceEnum("source").notNull().default("user_told_me"),
  note: text("note"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow().notNull(),
});
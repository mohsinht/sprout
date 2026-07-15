import "./env.js";

const isProduction = process.env.NODE_ENV === "production";
const jwtSecret = process.env.JWT_SECRET;
const databaseUrl = process.env.DATABASE_URL;
const databaseSsl = process.env.DATABASE_SSL === "true";
const cronSecret = process.env.CRON_SECRET;
const navSource = process.env.NAV_SOURCE ?? "unavailable";
const fxSource = process.env.FX_SOURCE ?? "unavailable";
const valuationExposureEnabled = process.env.ENABLE_REAL_VALUATIONS === "true";
const externalConnectorsEnabled =
  process.env.ENABLE_EXTERNAL_CONNECTORS === "true";
const structuredImportsEnabled =
  process.env.ENABLE_STRUCTURED_IMPORTS === "true";
const corsOrigins = (
  process.env.CORS_ORIGINS ?? "http://localhost:3000,http://localhost:5173"
)
  .split(",")
  .map((origin) => origin.trim())
  .filter(Boolean);

if (isProduction && (!jwtSecret || jwtSecret.length < 32)) {
  throw new Error("JWT_SECRET must be at least 32 characters in production");
}
if (
  isProduction &&
  (!databaseUrl || databaseUrl.includes("sprout:sprout@localhost"))
) {
  throw new Error(
    "DATABASE_URL must use production database credentials in production",
  );
}
if (isProduction && !databaseSsl) {
  throw new Error("DATABASE_SSL=true is required in production");
}
if (isProduction && (!cronSecret || cronSecret.length < 32)) {
  throw new Error("CRON_SECRET must be at least 32 characters in production");
}
if (
  isProduction &&
  corsOrigins.some(
    (origin) => origin === "*" || /localhost|127\.0\.0\.1/.test(origin),
  )
) {
  throw new Error(
    "CORS_ORIGINS must list only deployed application origins in production",
  );
}
if (isProduction && (navSource === "mock" || fxSource === "mock")) {
  throw new Error("Mock NAV/FX sources are forbidden in production");
}
if (isProduction && valuationExposureEnabled) {
  if (!process.env.VALUATION_BURN_IN_APPROVED_AT) {
    throw new Error(
      "Real valuation exposure requires VALUATION_BURN_IN_APPROVED_AT",
    );
  }
  if (navSource !== "al_meezan_validated" || fxSource !== "xe") {
    throw new Error(
      "Real valuations require validated Al Meezan NAV and Xe FX sources",
    );
  }
}

export const config = {
  port: Number(process.env.PORT ?? 8787),
  jwtSecret: jwtSecret ?? "dev-secret-change-in-production",
  jwtExpiresIn: "15m",
  refreshTokenExpiresInDays: 30,
  openaiApiKey: process.env.OPENAI_API_KEY ?? "",
  openaiModel: process.env.OPENAI_MODEL ?? "gpt-5.6-luna",
  aiDailyCostCapCents: process.env.AI_DAILY_COST_CAP_CENTS
    ? Number(process.env.AI_DAILY_COST_CAP_CENTS)
    : null,
  onDemandRateLimitPerHour: Number(process.env.ON_DEMAND_RATE_LIMIT ?? 3),
  corsOrigins,
  staleNavDays: 2, // NAV older than 2 market days = stale
  staleFxDays: 1, // FX older than 1 business day = stale
  trendDays: 6,
  isProduction,
  databaseSsl,
  openaiReasoningEffort: process.env.OPENAI_REASONING_EFFORT ?? "low",
  xeAccountId: process.env.XE_ACCOUNT_ID ?? "",
  xeApiKey: process.env.XE_API_KEY ?? "",
  navSource,
  fxSource,
  features: {
    valuationExposureEnabled,
    externalConnectorsEnabled,
    structuredImportsEnabled,
  },
};

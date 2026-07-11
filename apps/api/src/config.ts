import "./env.js";

const isProduction = process.env.NODE_ENV === "production";
const jwtSecret = process.env.JWT_SECRET;

if (isProduction && (!jwtSecret || jwtSecret.length < 32)) {
  throw new Error("JWT_SECRET must be at least 32 characters in production");
}

export const config = {
  port: Number(process.env.PORT ?? 8787),
  jwtSecret: jwtSecret ?? "dev-secret-change-in-production",
  jwtExpiresIn: "15m",
  refreshTokenExpiresInDays: 30,
  openaiApiKey: process.env.OPENAI_API_KEY ?? "",
  openaiModel: process.env.OPENAI_MODEL ?? "gpt-5.6-luna",
  onDemandRateLimitPerHour: Number(process.env.ON_DEMAND_RATE_LIMIT ?? 3),
  corsOrigins: (process.env.CORS_ORIGINS ?? "http://localhost:3000,http://localhost:5173").split(","),
  staleNavDays: 2, // NAV older than 2 market days = stale
  staleFxDays: 1, // FX older than 1 business day = stale
  trendDays: 6,
  isProduction,
  openaiReasoningEffort: process.env.OPENAI_REASONING_EFFORT ?? "low",
  xeAccountId: process.env.XE_ACCOUNT_ID ?? "",
  xeApiKey: process.env.XE_API_KEY ?? "",
};

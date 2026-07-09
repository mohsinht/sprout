export const config = {
  port: Number(process.env.PORT ?? 8787),
  jwtSecret: process.env.JWT_SECRET ?? "dev-secret-change-in-production",
  jwtExpiresIn: "15m",
  refreshTokenExpiresInDays: 30,
  openaiApiKey: process.env.OPENAI_API_KEY ?? "",
  openaiModel: process.env.OPENAI_MODEL ?? "gpt-4o-mini",
  onDemandRateLimitPerHour: Number(process.env.ON_DEMAND_RATE_LIMIT ?? 3),
  corsOrigins: (process.env.CORS_ORIGINS ?? "http://localhost:3000,http://localhost:5173").split(","),
  staleNavDays: 2, // NAV older than 2 market days = stale
  staleFxDays: 1, // FX older than 1 business day = stale
  trendDays: 6,
};
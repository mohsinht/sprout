import { serve } from "@hono/node-server";
import { Hono } from "hono";
import { cors } from "hono/cors";
import { config } from "./config.js";
import { authRoute } from "./auth/routes.js";
import { profileRoute } from "./routes/profile.js";
import { holdingsRoute } from "./routes/holdings.js";
import { accountsRoute } from "./routes/accounts.js";
import { goalsRoute } from "./routes/goals.js";
import { transactionsRoute } from "./routes/transactions.js";
import { briefingRoute } from "./routes/briefing.js";
import { pendingRoute } from "./routes/pending.js";
import { incomeRoute } from "./routes/income.js";
import { uploadRoute } from "./routes/upload.js";
import { runDailyJobForAllUsers } from "./services/job-runner.js";
import { pool } from "./db/client.js";

const app = new Hono();

// ── CORS ─────────────────────────────────────────────────────────────────────
app.use(
  "*",
  cors({
    origin: config.corsOrigins,
    allowMethods: ["GET", "POST", "PATCH", "DELETE", "OPTIONS"],
    allowHeaders: ["Content-Type", "Authorization"],
  })
);

// ── Health ───────────────────────────────────────────────────────────────────
app.get("/health", (c) =>
  c.json({
    ok: true,
    service: "sprout-api",
    version: "0.2.0",
  })
);

app.get("/ready", async (c) => {
  try {
    await pool.query("select 1");
    return c.json({ ok: true, database: "ready" });
  } catch {
    return c.json({ ok: false, database: "unavailable" }, 503);
  }
});

// ── Auth ──────────────────────────────────────────────────────────────────────
app.route("/v1/auth", authRoute);

// ── Profile + Onboarding ──────────────────────────────────────────────────────
app.route("/v1/profile", profileRoute);

// ── Manual Entry (the floor — app fully works here) ──────────────────────────
app.route("/v1/accounts", accountsRoute);
app.route("/v1/holdings", holdingsRoute);
app.route("/v1/goals", goalsRoute);
app.route("/v1/transactions", transactionsRoute);

// ── Reconciliation Model ──────────────────────────────────────────────────────
app.route("/v1/pending", pendingRoute);
app.route("/v1/income", incomeRoute);
app.route("/v1/upload", uploadRoute);

// ── Briefing (daily + on-demand) ─────────────────────────────────────────────
app.route("/v1/briefing", briefingRoute);

// ── Cron endpoint (secured by a shared secret) ───────────────────────────────
// Called by a scheduled job (host cron, GitHub Actions, or Supabase scheduled fn).
// Idempotent: running twice for the same user+date returns the existing briefing.
app.post("/v1/cron/daily", async (c) => {
  const cronSecret = c.req.header("X-Cron-Secret");
  if (!cronSecret || cronSecret !== process.env.CRON_SECRET) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  try {
    await runDailyJobForAllUsers();
    return c.json({ ok: true, message: "Daily job completed for all users" });
  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : String(error);
    return c.json({ error: "Daily job failed", detail: errorMsg }, 500);
  }
});

// ── Serve ────────────────────────────────────────────────────────────────────
serve(
  { fetch: app.fetch, port: config.port },
  (info) => {
    console.log(`Sprout API listening on http://localhost:${info.port}`);
    if (!config.openaiApiKey) {
      console.log("  ⚠ OPENAI_API_KEY not set — using mock AI (deterministic fallback copy)");
    }
    if (!process.env.DATABASE_URL || process.env.DATABASE_URL.includes("sprout:sprout@localhost")) {
      console.log("  ⚠ Using default DATABASE_URL — set DATABASE_URL for production");
    }
  }
);

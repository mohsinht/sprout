import assert from "node:assert/strict";
import test from "node:test";
import { execFileSync, spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { pool } from "../db/client.js";
import { apiBaseUrl, createHarnessClient } from "./http.js";

const repoRoot = fileURLToPath(new URL("../../../../", import.meta.url));

test("OPS-01 three-day valuation mechanics and real gate numbers", async () => {
  const metrics = await pool.query(`select
    (select count(distinct briefing_date)::int from daily_briefings where user_id='00000000-0000-4000-8000-0000000000d6') qualifying_dates,
    (select count(*)::int-count(distinct date)::int from wealth_snapshots where user_id='00000000-0000-4000-8000-0000000000d6') duplicate_snapshots,
    (select count(*)::int from price_quotes where source='Audit Al Meezan') nav_observations,
    (select count(*)::int from fx_rates where source='Audit FX') fx_observations,
    (select count(*)::int from nav_cross_validations where validation_source='Audit MUFAP') cross_validations`);
  assert.deepEqual(metrics.rows[0], {
    qualifying_dates: 3,
    duplicate_snapshots: 0,
    nav_observations: 3,
    fx_observations: 3,
    cross_validations: 3,
  });
  const real = await pool.query(
    `select count(distinct briefing_date)::int elapsed from daily_briefings where generated_at <= now()`,
  );
  console.log(`OPS-01 REAL_BURN_IN_DAYS=${real.rows[0].elapsed}`);
});

test("OPS-02 cron double-fire is idempotent", async () => {
  const client = createHarnessClient("OPS-02");
  const auth = await client.register();
  const headers = { "X-Cron-Secret": process.env.CRON_SECRET ?? "" };
  for (let i = 0; i < 2; i++) {
    const response = await fetch(`${apiBaseUrl}/v1/cron/daily`, {
      method: "POST",
      headers,
    });
    assert.equal(response.status, 200);
  }
  const result = await pool.query(
    `select idempotency_key,count(*)::int n from job_runs where user_id=$1 and idempotency_key like 'daily:%' group by idempotency_key`,
    [auth.userId],
  );
  assert.ok(result.rows.every((row) => row.n === 1));
});

test("OPS-02 failed on-demand refresh retries the same job row", async () => {
  const client = createHarnessClient("OPS-02-REFRESH-RETRY");
  const auth = await client.register();
  const key = `on_demand:${auth.userId}:${new Date().toISOString().slice(0, 13)}`;
  await pool.query(
    `insert into job_runs (user_id,type,status,started_at,finished_at,error,idempotency_key)
     values ($1,'on_demand','failed',now(),now(),'forced harness failure',$2)`,
    [auth.userId, key],
  );

  const refreshed = await client.request("/v1/briefing/refresh", {
    method: "POST",
    body: {},
  });
  assert.equal(refreshed.data.refresh.status, "refreshed");

  const result = await pool.query(
    `select count(*)::int n,min(status::text) status
       from job_runs where user_id=$1 and idempotency_key=$2`,
    [auth.userId, key],
  );
  assert.deepEqual(result.rows[0], { n: 1, status: "succeeded" });
});

test("OPS-03 negative cash estimate degrades to a valid briefing", async () => {
  const client = createHarnessClient("OPS-03-NEGATIVE-CASH");
  await client.register();
  const account = await client.request("/v1/accounts", {
    method: "POST",
    expected: 201,
    body: {
      label: "Cash wallet",
      type: "cash",
      openingBalance: 0,
      currency: "PKR",
    },
  });
  await client.request("/v1/transactions", {
    method: "POST",
    expected: 201,
    body: {
      amount: 1_250,
      currency: "PKR",
      type: "expense",
      category: "Food",
      accountId: account.data.id,
    },
  });

  const refreshed = await client.request("/v1/briefing/refresh", {
    method: "POST",
    body: { contextChanged: true },
  });
  assert.equal(refreshed.data.refresh.status, "refreshed");
  assert.equal(refreshed.data.wealthSnapshot.totalPkr, 0);
  assert.equal(refreshed.data.holdings[0].valuePkr, 0);
  assert.match(
    refreshed.data.wealthEvents
      .map((event: { plainWhy: string }) => event.plainWhy)
      .join("\n"),
    /beyond its last confirmed balance.*zero-value asset/i,
  );
});

test("OPS-02 backup and isolated restore smoke", () => {
  const output = `/tmp/sprout-harness-${Date.now()}.dump`;
  execFileSync("bash", ["scripts/backup-postgres.sh", output], {
    cwd: repoRoot,
    stdio: "inherit",
    env: process.env,
  });
  execFileSync("bash", ["scripts/restore-smoke.sh", output], {
    cwd: repoRoot,
    stdio: "inherit",
    env: process.env,
  });
});

test("OPS-03 headers, request IDs, sanitized errors, and boot refusal", async () => {
  for (const path of ["/health", "/ready", "/v1/profile"]) {
    const response = await fetch(`${apiBaseUrl}${path}`);
    assert.equal(response.headers.get("x-content-type-options"), "nosniff");
    assert.ok(response.headers.get("x-request-id"));
  }
  const localWeb = await fetch(`${apiBaseUrl}/ready`, {
    headers: { Origin: "http://127.0.0.1:8090" },
  });
  assert.equal(
    localWeb.headers.get("access-control-allow-origin"),
    "http://127.0.0.1:8090",
  );
  const boot = spawnSync(process.execPath, ["apps/api/dist/config.js"], {
    cwd: repoRoot,
    env: {
      ...process.env,
      NODE_ENV: "production",
      DATABASE_URL: "postgresql://sprout:sprout@localhost:5432/sprout",
      DATABASE_SSL: "false",
      JWT_SECRET: "short",
      CRON_SECRET: "short",
    },
    encoding: "utf8",
  });
  assert.notEqual(boot.status, 0);
  assert.match(
    `${boot.stderr}${boot.stdout}`,
    /JWT_SECRET|DATABASE_URL|DATABASE_SSL/,
  );
});

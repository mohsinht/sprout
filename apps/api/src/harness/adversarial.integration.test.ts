import assert from "node:assert/strict";
import test from "node:test";
import { spawnSync } from "node:child_process";
import { pool } from "../db/client.js";
import { createHarnessClient } from "./http.js";

test("ADV-01 provenance validation matrix", async () => {
  const client = createHarnessClient("ADV-01");
  await client.register();
  const base = {
    kind: "mutual_fund",
    institution: "Audit",
    label: "Fund",
    currency: "PKR",
    units: 1,
    valuePkr: 100,
    freshness: "fresh",
  };
  for (const body of [
    { ...base },
    { ...base, priceSource: "MUFAP" },
    { ...base, priceSource: "MUFAP", priceAsOf: "nope" },
    { ...base, priceSource: "MUFAP", priceAsOf: "2999-01-01" },
    { ...base, priceSource: "MUFAP", priceAsOf: "2000-01-01" },
  ])
    await client.request("/v1/holdings", {
      method: "POST",
      body,
      expected: 400,
    });
  const staleDate = new Date(Date.now() - 5 * 86_400_000)
    .toISOString()
    .slice(0, 10);
  const stored = await client.request("/v1/holdings", {
    method: "POST",
    expected: 201,
    body: { ...base, priceSource: "MUFAP", priceAsOf: staleDate },
  });
  assert.equal(stored.data.freshness, "stale");
});

test("ADV-02 endpoint fuzz returns zero 5xx", async () => {
  const client = createHarnessClient("ADV-02");
  await client.register();
  const payloads = [
    undefined,
    { amount: -1 },
    { amount: Number.MAX_SAFE_INTEGER, type: "expense", category: "x" },
    {
      amount: 1,
      type: "expense",
      category: "'); DROP TABLE users; --",
      occurredAt: "9999-99-99",
    },
  ];
  for (const body of payloads) {
    const result =
      body === undefined
        ? await client.request("/v1/transactions", {
            method: "POST",
            rawBody: "{",
            expected: [400, 413, 422],
          })
        : await client.request("/v1/transactions", {
            method: "POST",
            body,
            expected: [400, 413, 422],
          });
    assert.ok(result.response.status < 500);
  }
});

test("ADV-03 tenant isolation across object routes", async () => {
  const a = createHarnessClient("ADV-03-A");
  await a.register();
  const goal = await a.request("/v1/goals", {
    method: "POST",
    expected: 201,
    body: { name: "Private", type: "custom", targetAmount: 1000 },
  });
  const aToken = a.token;
  const b = createHarnessClient("ADV-03-B");
  await b.register();
  await b.request(`/v1/goals/${goal.data.id}`, {
    method: "PATCH",
    body: { name: "stolen" },
    expected: 404,
  });
  await b.request(`/v1/goals/${goal.data.id}`, {
    method: "DELETE",
    expected: 404,
  });
  await b.request(`/v1/goals/${goal.data.id}/contributions`, { expected: 404 });
  const leaked = await pool.query(
    `select count(*)::int n from goals where id=$1 and name='stolen'`,
    [goal.data.id],
  );
  assert.equal(leaked.rows[0].n, 0);
  assert.ok(aToken);
});

test("ADV-04 3x replay produces no duplicates", async () => {
  const client = createHarnessClient("ADV-04");
  const auth = await client.register();
  const body = {
    amount: 100,
    currency: "PKR",
    type: "expense",
    category: "Food",
    merchant: "Replay",
    occurredAt: "2026-07-15T12:00:00Z",
    source: "manual",
  };
  for (let i = 0; i < 3; i++)
    await client.request("/v1/transactions", {
      method: "POST",
      body,
      expected: [200, 201],
    });
  const count = await pool.query(
    `select count(*)::int n from transactions where user_id=$1 and merchant='Replay'`,
    [auth.user.id],
  );
  assert.equal(count.rows[0].n, 1);
});

test("ADV-05 concurrent goal contributions reconcile", async () => {
  const client = createHarnessClient("ADV-05");
  const auth = await client.register();
  const goal = await client.request("/v1/goals", {
    method: "POST",
    expected: 201,
    body: { name: "Concurrent", type: "custom", targetAmount: 1_000_000 },
  });
  await Promise.all(
    Array.from({ length: 10 }, (_, index) =>
      client.request(`/v1/goals/${goal.data.id}/contribute`, {
        method: "POST",
        body: {
          amount: 1000,
          source: "quick_add",
          idempotencyKey: `ADV-05-${index}`,
        },
      }),
    ),
  );
  const result = await pool.query(
    `select g.current_amount,coalesce(sum(c.amount_pkr),0)::int ledger from goals g left join goal_contributions c on c.goal_id=g.id where g.id=$1 and g.user_id=$2 group by g.id`,
    [goal.data.id, auth.user.id],
  );
  assert.deepEqual(result.rows[0], { current_amount: 10_000, ledger: 10_000 });
});

test("ADV-06 auth throttle and feature gates fail closed", async () => {
  const client = createHarnessClient("ADV-06");
  let last = 0;
  for (let i = 0; i < 25; i++) {
    const result = await client.request("/v1/auth/login", {
      method: "POST",
      auth: false,
      expected: [401, 429],
      body: {
        email: "missing@harness.test",
        password: "wrong-password",
        deviceId: "adv06",
      },
    });
    last = result.response.status;
  }
  assert.equal(last, 429);
  await client.register();
  const gate = await client.request("/v1/upload/baselines", { expected: 503 });
  assert.equal(gate.data.code, "FEATURE_DISABLED");
});

test("ADV-07 regulatory executable grep", () => {
  const scan = spawnSync(
    "rg",
    [
      "-n",
      "-i",
      "transfer now|pay this bill in sprout|top up .* here|initiate payment|accept customer payments",
      "apps/api/src",
      "apps/mobile/lib",
      "packages/shared/src",
    ],
    { cwd: process.cwd(), encoding: "utf8" },
  );
  assert.equal(
    scan.status,
    1,
    `ADV-07 forbidden regulated copy/code:\n${scan.stdout}`,
  );
});

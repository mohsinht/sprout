import assert from "node:assert/strict";
import test from "node:test";
import { pool } from "../db/client.js";
import { localDateAt, monthlyOccurrenceDate } from "../lib/recurring.js";
import { createHarnessClient } from "./http.js";

test("LED-01 ledger reconciles every goal", async () => {
  const client = createHarnessClient("LED-01");
  const auth = await client.register();
  const goal = await client.request("/v1/goals", {
    method: "POST",
    expected: 201,
    body: {
      name: "Emergency",
      type: "emergency",
      targetAmount: 300_000,
      currentAmount: 50_000,
    },
  });
  await client.request(`/v1/goals/${goal.data.id}/contribute`, {
    method: "POST",
    body: {
      amount: 25_000,
      source: "manual",
      idempotencyKey: `LED-01-${goal.data.id}`,
    },
  });
  const result = await pool.query(
    `select g.id,g.current_amount,coalesce(sum(c.amount_pkr),0)::int ledger_total from goals g left join goal_contributions c on c.goal_id=g.id where g.user_id=$1 group by g.id`,
    [auth.userId],
  );
  assert.ok(result.rows.length > 0);
  for (const row of result.rows)
    assert.equal(row.current_amount, row.ledger_total);
});

test("LED-02 contribution never mutates balances or wealth", async () => {
  const client = createHarnessClient("LED-02");
  await client.register();
  await client.request("/v1/holdings", {
    method: "POST",
    expected: 201,
    body: {
      kind: "cash",
      institution: "Manual",
      label: "Cash",
      currency: "PKR",
      valuePkr: 100_000,
      freshness: "manual",
    },
  });
  const goal = await client.request("/v1/goals", {
    method: "POST",
    expected: 201,
    body: { name: "Car", type: "car", targetAmount: 500_000 },
  });
  const before = await client.request("/v1/briefing/refresh", {
    method: "POST",
    body: { contextChanged: true },
  });
  await client.request(`/v1/goals/${goal.data.id}/contribute`, {
    method: "POST",
    body: {
      amount: 10_000,
      source: "manual",
      idempotencyKey: `LED-02-${goal.data.id}`,
    },
  });
  const after = await client.request("/v1/briefing/refresh", {
    method: "POST",
    body: { contextChanged: true },
  });
  assert.equal(
    after.data.wealthSnapshot.totalPkr,
    before.data.wealthSnapshot.totalPkr,
  );
});

test("REC-01 monthly clamp 29/30/31", () => {
  assert.equal(monthlyOccurrenceDate(2025, 2, 29), "2025-02-28");
  assert.equal(monthlyOccurrenceDate(2024, 2, 31), "2024-02-29");
  assert.equal(monthlyOccurrenceDate(2026, 4, 31), "2026-04-30");
});

test("REC-02 on_salary_day only materializes after confirmed salary", async () => {
  const client = createHarnessClient("REC-02");
  const auth = await client.register();
  await client.request("/v1/recurring/series", {
    method: "POST",
    expected: 201,
    body: {
      kind: "expected_income",
      frequency: "on_salary_day",
      amount: 100_000,
      label: "Salary",
      timezone: "Asia/Karachi",
    },
  });
  await client.request("/v1/recurring/generate", {
    method: "POST",
    body: { instant: "2026-07-15T12:00:00Z" },
  });
  let count = await pool.query(
    `select count(*)::int n from recurring_occurrences where user_id=$1`,
    [auth.userId],
  );
  assert.equal(count.rows[0].n, 0);
  await client.request("/v1/transactions", {
    method: "POST",
    expected: 201,
    body: {
      amount: 100_000,
      currency: "PKR",
      type: "income",
      category: "Salary",
      occurredAt: "2026-07-15T12:00:00Z",
      source: "manual",
    },
  });
  count = await pool.query(
    `select count(*)::int n from recurring_occurrences where user_id=$1`,
    [auth.userId],
  );
  assert.equal(count.rows[0].n, 1);
});

test("REC-03 REC-04 REC-05 ask outcomes, stored skip, and 3x replay", async () => {
  const client = createHarnessClient("REC-03-05");
  const auth = await client.register();
  await client.request("/v1/recurring/series", {
    method: "POST",
    expected: 201,
    body: {
      kind: "liability",
      frequency: "monthly",
      amount: 9_000,
      label: "Rent",
      anchorDay: 1,
      timezone: "Asia/Karachi",
    },
  });
  for (let i = 0; i < 3; i++)
    await client.request("/v1/recurring/generate", {
      method: "POST",
      body: { instant: "2026-07-15T12:00:00Z" },
    });
  const asks = await client.request("/v1/recurring/asks");
  assert.equal(asks.data.asks.length, 1);
  assert.deepEqual(asks.data.asks[0].options, ["yes", "no", "stopped"]);
  await client.request(
    `/v1/recurring/occurrences/${asks.data.asks[0].id}/respond`,
    { method: "POST", body: { outcome: "no" } },
  );
  const rows = await pool.query(
    `select status,count(*)::int n from recurring_occurrences where user_id=$1 group by status`,
    [auth.userId],
  );
  assert.deepEqual(rows.rows, [{ status: "skipped", n: 1 }]);
});

test("REC-06 New York midnight and DST use local date", () => {
  assert.equal(
    localDateAt(new Date("2026-03-08T04:30:00Z"), "America/New_York"),
    "2026-03-07",
  );
  assert.equal(
    localDateAt(new Date("2026-03-08T07:30:00Z"), "America/New_York"),
    "2026-03-08",
  );
});

test("REC-07 non-Yes lifecycle leaves wealth untouched", async () => {
  const client = createHarnessClient("REC-07");
  const auth = await client.register();
  await client.request("/v1/holdings", {
    method: "POST",
    expected: 201,
    body: {
      kind: "cash",
      institution: "Manual",
      label: "Cash",
      currency: "PKR",
      valuePkr: 50_000,
      freshness: "manual",
    },
  });
  const before = await client.request("/v1/briefing/refresh", {
    method: "POST",
    body: { contextChanged: true },
  });
  await client.request("/v1/recurring/series", {
    method: "POST",
    expected: 201,
    body: {
      kind: "liability",
      frequency: "monthly",
      amount: 5_000,
      label: "Utilities",
      anchorDay: 1,
    },
  });
  await client.request("/v1/recurring/generate", {
    method: "POST",
    body: { instant: "2026-07-15T12:00:00Z" },
  });
  const ask = (await client.request("/v1/recurring/asks")).data.asks[0];
  await client.request(`/v1/recurring/occurrences/${ask.id}/respond`, {
    method: "POST",
    body: { outcome: "stopped" },
  });
  const after = await client.request("/v1/briefing/refresh", {
    method: "POST",
    body: { contextChanged: true },
  });
  assert.equal(
    after.data.wealthSnapshot.totalPkr,
    before.data.wealthSnapshot.totalPkr,
  );
  const tx = await pool.query(
    `select count(*)::int n from transactions where user_id=$1`,
    [auth.userId],
  );
  assert.equal(tx.rows[0].n, 0);
});

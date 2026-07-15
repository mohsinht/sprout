import assert from "node:assert/strict";
import test, { beforeEach } from "node:test";
import { readFile } from "node:fs/promises";
import { pool } from "../db/client.js";
import { createHarnessClient } from "./http.js";

beforeEach(async () => {
  await pool.query(
    `delete from personal_insights where world_fact_id in (select id from world_facts where source_id='harness');
     delete from world_facts where source_id='harness'`,
  );
});

async function seedFact(kind: string, currency: string | null = null) {
  const stableKey = `harness:${kind}:${currency ?? "none"}:${Date.now()}:${Math.random()}`;
  const result = await pool.query(
    `insert into world_facts(stable_key,kind,observed_on,direction,source_id,source_label,freshness,plain_summary,affects_asset_classes_json,affects_currencies_json,affects_goal_types_json,normalizer_version) values($1,$2,'2026-07-15','changed','harness','SBP','fresh','Sourced fact','[]',$3,'[]','harness-v1') returning id`,
    [stableKey, kind, JSON.stringify(currency ? [currency] : [])],
  );
  return result.rows[0].id as string;
}

test("INS-01 zero-holding user receives quiet state", async () => {
  const client = createHarnessClient("INS-01");
  await client.register();
  await seedFact("cpi");
  const result = await client.request("/v1/insights", { expected: 200 });
  assert.deepEqual(result.data, { state: "quiet", insights: [] });
});

test("INS-02 FX fact joins only to matching currency", async () => {
  const usd = createHarnessClient("INS-02-USD");
  await usd.register();
  await usd.request("/v1/holdings", {
    method: "POST",
    expected: 201,
    body: {
      kind: "cash",
      institution: "Wise",
      label: "USD cash",
      currency: "USD",
      valueNative: 100,
      valuePkr: 28_000,
      priceAsOf: "2026-07-15",
      priceSource: "SBP",
      freshness: "stale",
    },
  });
  const pkr = createHarnessClient("INS-02-PKR");
  await pkr.register();
  const factId = await seedFact("fx_move", "USD");
  const usdResult = await usd.request("/v1/insights", { expected: 200 });
  const pkrResult = await pkr.request("/v1/insights", { expected: 200 });
  const matching = usdResult.data.insights.filter(
    (insight: { worldFactId: string }) => insight.worldFactId === factId,
  );
  assert.equal(matching.length, 1);
  assert.match(
    JSON.stringify(matching[0]),
    /SBP|2026-07-15|USD/,
  );
  assert.equal(pkrResult.data.insights.length, 0);
});

test("INS-03 stored insight provenance, cap, and personal tie", async () => {
  const client = createHarnessClient("INS-03");
  const auth = await client.register();
  const response = await client.request("/v1/insights", { expected: 200 });
  assert.ok(
    response.data.insights.length === 0 ||
      (response.data.insights.length >= 3 &&
        response.data.insights.length <= 6),
  );
  for (const insight of response.data.insights) {
    assert.equal(
      Number(Boolean(insight.worldFactId)) +
        Number(Boolean(insight.wealthEventId)),
      1,
    );
    assert.ok(
      insight.sourceLabel &&
        insight.asOf &&
        (insight.matchedHoldingId ||
          insight.matchedGoalId ||
          insight.matchedCurrency),
    );
    assert.doesNotMatch(
      `${insight.headline} ${insight.personalMeaning}`,
      /buy now|guaranteed/i,
    );
  }
  const invalid = await pool.query(
    `select count(*)::int n from personal_insights where user_id=$1 and num_nonnulls(world_fact_id,wealth_event_id)<>1`,
    [auth.userId],
  );
  assert.equal(invalid.rows[0].n, 0);
});

test("INS-04 every versioned template passes guardrails", async () => {
  const registry = await readFile(
    new URL("../insights/template-registry.ts", import.meta.url),
    "utf8",
  );
  assert.doesNotMatch(
    registry,
    /buy now|guaranteed|you will earn|connect your bank to continue/i,
  );
  assert.match(registry, /templateVersion/);
});

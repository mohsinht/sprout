import assert from "node:assert/strict";
import test, { beforeEach } from "node:test";
import type { AiService } from "../services/ai-service.js";
import {
  generateBriefing,
  storeBriefing,
} from "../services/briefing-pipeline.js";
import { pool } from "../db/client.js";
import { createHarnessClient } from "./http.js";

beforeEach(async () => {
  await pool.query("delete from ai_rewrite_cache; delete from ai_daily_usage");
});

async function user(testId: string) {
  const client = createHarnessClient(testId);
  const auth = await client.register();
  return { id: auth.userId as string, client };
}
async function addTrigger(
  client: ReturnType<typeof createHarnessClient>,
  label = "USD cash",
) {
  await client.request("/v1/holdings", {
    method: "POST",
    expected: 201,
    body: {
      kind: "cash",
      institution: "Wise",
      label,
      currency: "USD",
      valueNative: 100,
      valuePkr: 28_000,
      priceAsOf: "2026-07-10",
      priceSource: "Harness FX",
      freshness: "stale",
    },
  });
}
function spyService(handler?: AiService["generateBriefingCopy"]) {
  let calls = 0;
  const service: AiService = {
    name: "harness-spy",
    async generateBriefingCopy(input) {
      calls++;
      return handler
        ? handler(input)
        : {
            output: {
              greeting: input.greeting,
              summary: input.summary,
              interpretation: input.wealthSnapshot.interpretation,
            },
            costCents: 1,
          };
    },
  };
  return { service, calls: () => calls };
}

test("AI-01 quiet all-good day makes zero AI calls", async () => {
  const { id } = await user("AI-01");
  const spy = spyService();
  const result = await generateBriefing({
    userId: id,
    date: "2026-07-15",
    aiService: spy.service,
  });
  assert.equal(spy.calls(), 0);
  assert.equal(result.aiCostCents, 0);
  assert.equal(result.aiModel, "deterministic");
});

test("AI-02 exhausted daily cap degrades and cost stops", async () => {
  const cap = Number(process.env.AI_DAILY_COST_CAP_CENTS);
  assert.ok(
    Number.isFinite(cap) && cap > 0,
    "AI-02 requires a configured positive AI_DAILY_COST_CAP_CENTS; the spec must not be implemented with an invented default",
  );
  const firstUser = await user("AI-02-A");
  const secondUser = await user("AI-02-B");
  await addTrigger(firstUser.client, "USD cash A");
  await addTrigger(secondUser.client, "USD cash B");
  const spy = spyService(async (input) => ({
    output: {
      greeting: input.greeting,
      summary: input.summary,
      interpretation: input.wealthSnapshot.interpretation,
    },
    costCents: cap,
  }));
  const first = await generateBriefing({
    userId: firstUser.id,
    date: "2026-07-15",
    aiService: spy.service,
  });
  const second = await generateBriefing({
    userId: secondUser.id,
    date: "2026-07-15",
    aiService: spy.service,
  });
  assert.equal(first.aiCostCents, cap);
  assert.equal(second.aiCostCents, 0);
  assert.equal(spy.calls(), 1);
});

test("AI-03 malformed output is rejected with valid fallback", async () => {
  const { id, client } = await user("AI-03");
  await addTrigger(client);
  const spy = spyService(async () => ({
    output: { greeting: "", summary: "buy now!", interpretation: [] } as never,
    costCents: 99,
  }));
  const result = await generateBriefing({
    userId: id,
    date: "2026-07-15",
    aiService: spy.service,
  });
  assert.doesNotMatch(result.briefing.summary, /buy now/i);
  assert.ok(result.briefing.greeting);
  assert.equal(result.aiCostCents, 0);
  assert.equal(result.aiModel, "fallback");
  assert.equal(result.aiMode, "fallback");
});

test("AI-04 canonical input hash cache shares identical state", async () => {
  const firstUser = await user("AI-04-A");
  const secondUser = await user("AI-04-B");
  await addTrigger(firstUser.client);
  await addTrigger(secondUser.client);
  const spy = spyService();
  await generateBriefing({
    userId: firstUser.id,
    date: "2026-07-15",
    aiService: spy.service,
  });
  await generateBriefing({
    userId: secondUser.id,
    date: "2026-07-15",
    aiService: spy.service,
  });
  assert.equal(spy.calls(), 1);
});

test("AI-05 stored briefings always record model and cost", async () => {
  const { id } = await user("AI-05");
  const result = await generateBriefing({
    userId: id,
    date: "2026-07-15",
    aiService: spyService().service,
  });
  await storeBriefing(result.briefing, result.aiCostCents, result.aiModel);
  const stored = await pool.query(
    `select ai_model,ai_cost_cents from daily_briefings where user_id=$1 order by generated_at desc limit 1`,
    [id],
  );
  assert.equal(stored.rows.length, 1);
  assert.ok(stored.rows[0].ai_model);
  assert.equal(typeof stored.rows[0].ai_cost_cents, "number");
});

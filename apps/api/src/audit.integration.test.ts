import assert from "node:assert/strict";
import test, { before } from "node:test";

const base = process.env.API_BASE_URL ?? "http://127.0.0.1:8787";
let token = "";
async function request(path: string, init: { method?: string; body?: unknown; rawBody?: string } = {}) {
  const response = await fetch(`${base}${path}`, {
    method: init.method ?? "GET",
    headers: { ...(token ? { authorization: `Bearer ${token}` } : {}), ...((init.body !== undefined || init.rawBody !== undefined) ? { "content-type": "application/json" } : {}) },
    body: init.rawBody ?? (init.body === undefined ? undefined : JSON.stringify(init.body)),
  });
  const text = await response.text();
  let data: any; try { data = JSON.parse(text); } catch { data = text; }
  return { status: response.status, data };
}

before(async () => {
  const stamp = Date.now();
  const result = await request("/v1/auth/register", { method: "POST", body: {
    email: `api-audit-${stamp}@example.com`, password: "AuditPass!2468", name: "API Audit",
    deviceId: `api-audit-device-${stamp}`, deviceName: "API integration test",
  } });
  assert.equal(result.status, 201);
  token = result.data.accessToken;
});

test("audit_a6_provenance_matrix_is_cleanly_enforced", async () => {
  const common = { kind: "mutual_fund", institution: "Audit", currency: "PKR", units: 1, valuePkr: 100, freshness: "fresh" };
  assert.equal((await request("/v1/holdings", { method: "POST", body: { ...common, label: "missing" } })).status, 400);
  assert.equal((await request("/v1/holdings", { method: "POST", body: { ...common, label: "stale", priceAsOf: "2000-01-01", priceSource: "Audit" } })).status, 400);
  assert.equal((await request("/v1/holdings", { method: "POST", body: { ...common, label: "source", priceSource: "Audit" } })).status, 400);
  assert.equal((await request("/v1/holdings", { method: "POST", body: { ...common, label: "invalid", priceAsOf: "not-a-date", priceSource: "Audit" } })).status, 400);
});

test("audit_d4_client_shaped_fuzz_never_returns_5xx", async () => {
  const results = await Promise.all([
    request("/v1/transactions", { method: "POST", body: { amount: -1, type: "expense", category: "Food" } }),
    request("/v1/transactions", { method: "POST", body: { amount: 1, type: "expense", category: "Food", occurredAt: "not-a-date" } }),
    request("/v1/transactions", { method: "POST", rawBody: '{"amount":' }),
    request("/v1/transactions", { method: "POST", body: { amount: 1, type: "expense", category: "'); DROP TABLE users; --", merchant: "<script>alert(1)</script>" } }),
    request("/v1/transactions", { method: "POST", body: { amount: 1, type: "expense", category: "Food", merchant: "x".repeat(1_000_001) } }),
  ]);
  assert.deepEqual(results.map((result) => result.status), [400, 400, 400, 201, 400]);
  assert.ok(results.every((result) => result.status < 500));
});

test("audit_b5_occurrence_generation_is_idempotent_and_non_mutating", async () => {
  await request("/v1/profile/onboarding", { method: "POST", body: {} });
  const series = await request("/v1/recurring/series", { method: "POST", body: {
    kind: "liability", frequency: "monthly", amount: 5000, label: "Rent", anchorDay: 1, timezone: "America/New_York",
  } });
  assert.equal(series.status, 201);
  await request("/v1/recurring/generate", { method: "POST", body: { instant: "2026-07-15T04:30:00Z" } });
  await request("/v1/recurring/generate", { method: "POST", body: { instant: "2026-07-15T04:30:00Z" } });
  const asks = await request("/v1/recurring/asks");
  assert.equal(asks.data.asks.filter((ask: any) => ask.question.startsWith("Rent ")).length, 1);
});

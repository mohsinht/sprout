import assert from "node:assert/strict";
import test from "node:test";
import { determineFreshness, normalizeAssetBalance } from "./wealth.js";

test("audit_d6_simulated_job_freshness_uses_job_date", () => {
  assert.equal(determineFreshness("2026-07-12", "cash", "2026-07-12"), "fresh");
  assert.equal(determineFreshness("2026-07-12", "cash", "2026-07-14"), "stale");
});

test("negative account ledger balance becomes a zero asset with a visible shortfall", () => {
  assert.deepEqual(normalizeAssetBalance(-1_250), {
    assetBalance: 0,
    shortfall: 1_250,
  });
  assert.deepEqual(normalizeAssetBalance(8_000), {
    assetBalance: 8_000,
    shortfall: 0,
  });
});

import assert from "node:assert/strict";
import test from "node:test";
import { determineFreshness } from "./wealth.js";

test("audit_d6_simulated_job_freshness_uses_job_date", () => {
  assert.equal(determineFreshness("2026-07-12", "cash", "2026-07-12"), "fresh");
  assert.equal(determineFreshness("2026-07-12", "cash", "2026-07-14"), "stale");
});

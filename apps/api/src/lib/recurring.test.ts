import assert from "node:assert/strict";
import test from "node:test";
import { localDateAt, monthlyOccurrenceDate, occurrenceStatus } from "./recurring.js";

test("audit_b5_monthly_clamps_short_months", () => {
  assert.equal(monthlyOccurrenceDate(2026, 2, 31), "2026-02-28");
  assert.equal(monthlyOccurrenceDate(2024, 2, 31), "2024-02-29");
});

test("audit_b5_new_york_midnight_and_dst_use_local_date", () => {
  assert.equal(localDateAt(new Date("2026-03-08T04:30:00Z"), "America/New_York"), "2026-03-07");
  assert.equal(localDateAt(new Date("2026-03-08T07:30:00Z"), "America/New_York"), "2026-03-08");
  assert.equal(localDateAt(new Date("2026-11-01T05:30:00Z"), "America/New_York"), "2026-11-01");
});

test("audit_b5_missed_occurrence_never_auto_deducts", () => {
  assert.equal(occurrenceStatus("2026-07-01", "2026-07-02", false), "ask_pending");
  assert.equal(occurrenceStatus("2026-07-01", "2026-07-02", true), "confirmed");
});

import assert from "node:assert/strict";
import test from "node:test";
import { compareNavs } from "./nav-validation.js";

test("audit_d6_mufap_cross_validation_uses_half_percent_tolerance", () => {
  assert.equal(compareNavs(100, 100.5).matched, true);
  assert.equal(compareNavs(100, 100.51).matched, false);
});

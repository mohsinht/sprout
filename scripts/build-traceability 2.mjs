import { readFile, writeFile } from "node:fs/promises";

const sourcePath = new URL("../spec/screen_acceptance_criteria.md", import.meta.url);
const outputPath = new URL("../artifacts/acceptance-traceability.md", import.meta.url);
const lines = (await readFile(sourcePath, "utf8")).split("\n");
const human = new Set([29, 54, 57, 58, 59, 84, 115, 141, 225, 226, 241, 244, 245, 246, 250]);
const known = new Map([
  [18, ["AUDIT-A3-B8", "apps/mobile/test/audit_a3_router_guard_test.dart", "PASS"]],
  [19, ["AUDIT-A3-B8", "apps/mobile/test/audit_a3_router_guard_test.dart", "PASS"]],
  [21, ["AUDIT-C1-OFFLINE", "apps/mobile/test/offline_pending_sync_test.dart", "PASS"]],
  [27, ["AUDIT-B6", "scripts/e2e-local.mjs", "PASS"]],
  [31, ["AUDIT-B2", "apps/api/src/lib/scoring.test.ts", "PASS"]],
  [43, ["AUDIT-B4", "scripts/e2e-local.mjs", "PASS"]],
  [44, ["AUDIT-B4", "apps/api/src/audit.integration.test.ts", "PASS"]],
  [64, ["AUDIT-B7", "apps/api/src/lib/briefing-validation.test.ts", "PASS"]],
  [65, ["AUDIT-A6", "apps/api/src/audit.integration.test.ts", "PASS"]],
  [66, ["AUDIT-B2", "apps/api/src/lib/scoring.test.ts", "PASS"]],
  [67, ["AUDIT-A3-B8", "apps/mobile/test/audit_a3_router_guard_test.dart", "PASS"]],
  [119, ["AUDIT-B1", "apps/mobile/test/navigation_test.dart", "PASS"]],
  [120, ["AUDIT-B1", "apps/mobile/test/navigation_test.dart", "PASS"]],
  [145, ["AUDIT-B1", "apps/mobile/test/navigation_test.dart", "PASS"]],
  [149, ["AUDIT-C1-OFFLINE", "apps/mobile/test/offline_pending_sync_test.dart", "PASS"]],
  [172, ["AUDIT-A3-B8", "apps/mobile/test/audit_a3_router_guard_test.dart", "PASS"]],
  [177, ["AUDIT-A3-B8", "apps/mobile/test/audit_a3_router_guard_test.dart", "PASS"]],
  [202, ["AUDIT-B7", "apps/api/src/lib/briefing-validation.test.ts", "PASS"]],
  [203, ["AUDIT-C4", "scripts/e2e-local.mjs", "PASS"]],
  [205, ["AUDIT-B7", "apps/api/src/lib/briefing-validation.test.ts", "PASS"]],
  [207, ["AUDIT-B2-B3", "apps/api/src/lib/scoring.test.ts", "PASS"]],
  [209, ["AUDIT-B4", "apps/api/src/audit.integration.test.ts", "PASS"]],
  [210, ["AUDIT-B4", "apps/api/src/audit.integration.test.ts", "PASS"]],
  [211, ["AUDIT-A6", "apps/api/src/audit.integration.test.ts", "PASS"]],
  [212, ["AUDIT-A6", "apps/api/src/audit.integration.test.ts", "PASS"]],
  [213, ["AUDIT-B2", "apps/api/src/lib/scoring.test.ts", "PASS"]],
  [214, ["AUDIT-D6", "apps/api/src/audit.integration.test.ts", "PASS"]],
  [218, ["AUDIT-D6", "apps/api/src/lib/nav-validation.test.ts", "PASS"]],
  [240, ["AUDIT-A7", "apps/api/src/audit.integration.test.ts", "PASS"]],
  [242, ["AUDIT-D1", "apps/api/src/audit.integration.test.ts", "PASS"]],
  [243, ["AUDIT-D1", "scripts/e2e-local.mjs", "PASS"]],
  [247, ["AUDIT-B6", "scripts/e2e-local.mjs", "PASS"]],
  [248, ["AUDIT-D6", "apps/api/src/lib/nav-validation.test.ts", "PASS"]],
]);

const rows = [];
for (let index = 0; index < lines.length; index += 1) {
  if (!/^\s*- /.test(lines[index])) continue;
  const line = index + 1;
  const criterion = lines[index].replace(/^\s*- /, "").replaceAll("|", "\\|").trim();
  if (human.has(line)) rows.push([line, criterion, `MANUAL-SAC-${line}`, "Physical/deployed-device handoff", "HUMAN_HANDOFF"]);
  else if (known.has(line)) rows.push([line, criterion, ...known.get(line)]);
  else rows.push([line, criterion, `UNVERIFIED-SAC-${line}`, "No committed criterion-specific test located", "UNVERIFIED"]);
}

const header = `# Acceptance traceability\n\nGenerated from \`spec/screen_acceptance_criteria.md\`. PASS means the named committed test was run locally in the tranche-2 verification. Broad visual/copy criteria without criterion-specific evidence remain UNVERIFIED; they are not silently promoted to passes.\n\n| Spec line | Criterion | Stable test ID | Committed test/evidence | Last run |\n|---:|---|---|---|---|\n`;
await writeFile(outputPath, header + rows.map((row) => `| ${row.join(" | ")} |`).join("\n") + "\n");
console.log(`Wrote ${rows.length} acceptance rows to artifacts/acceptance-traceability.md`);

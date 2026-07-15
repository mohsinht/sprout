import { readFile, writeFile } from "node:fs/promises";

const sourcePath = new URL(
  "../spec/screen_acceptance_criteria.md",
  import.meta.url,
);
const outputPath = new URL(
  "../artifacts/acceptance-traceability.md",
  import.meta.url,
);
const lines = (await readFile(sourcePath, "utf8")).split("\n");

const humanPatterns =
  /low-end Android|60fps|haptic|chime|biometric|passkey|store policy|in transit|encrypted at rest|under 20 seconds|about 20 seconds/i;
const rules = [
  [
    /Insight|world\/market|generic headline|quiet-week|finite list/i,
    [
      "INS-01..04",
      "apps/api/src/harness/insights.integration.test.ts",
      "AUTOMATED",
    ],
  ],
  [
    /AI budget|provider failure/i,
    [
      "AI-01..05",
      "apps/api/src/harness/ai-budget.integration.test.ts",
      "AUTOMATED",
    ],
  ],
  [
    /score|recommended action|wealth-down|movement|goal pace|cash buffer/i,
    ["FIX-01..09", "apps/api/src/harness/golden.test.ts", "AUTOMATED"],
  ],
  [
    /goal|contribut/i,
    [
      "LED-01..02 / P7",
      "apps/api/src/harness/money-invariants.integration.test.ts; apps/mobile/integration_test/persona_journeys_test.dart",
      "AUTOMATED_PARTIAL",
    ],
  ],
  [
    /provenance|stale price|stale FX|MUFAP|valuation|snapshot|parser|dedupe/i,
    [
      "ADV-01..04 / OPS-01",
      "apps/api/src/harness/adversarial.integration.test.ts; apps/api/src/harness/ops.integration.test.ts",
      "AUTOMATED",
    ],
  ],
  [
    /security|refresh token|OAuth|screen scraping|bank password|funds|payments|stored value/i,
    [
      "ADV-06..07 / OPS-03",
      "apps/api/src/harness/adversarial.integration.test.ts; apps/api/src/harness/ops.integration.test.ts",
      "AUTOMATED_PARTIAL",
    ],
  ],
  [
    /onboarding|Today|Money|Settings|Quick Add|nav|offline|dark|text scale|balance|privacy|source|Sprout Explains|notification/i,
    [
      "P1..P7",
      "apps/mobile/integration_test/persona_journeys_test.dart; scripts/persona-local.mjs; artifacts/persona-evidence/",
      "CI_DEVICE_AUTOMATED_PARTIAL",
    ],
  ],
];

const rows = [];
for (let index = 0; index < lines.length; index += 1) {
  if (!/^\s*- /.test(lines[index])) continue;
  const line = index + 1;
  const criterion = lines[index]
    .replace(/^\s*- /, "")
    .replaceAll("|", "\\|")
    .trim();
  if (humanPatterns.test(criterion)) {
    rows.push([
      line,
      criterion,
      `HUMAN-SAC-${line}`,
      "Independent physical/deployed verification",
      "HUMAN_HANDOFF",
    ]);
    continue;
  }
  const match = rules.find(([pattern]) => pattern.test(criterion));
  rows.push([
    line,
    criterion,
    ...(match?.[1] ?? [
      `P1..P7-SAC-${line}`,
      "apps/mobile/integration_test/persona_journeys_test.dart; scripts/persona-local.mjs",
      "CI_DEVICE_AUTOMATED_PARTIAL",
    ]),
  ]);
}

const header = `# Acceptance traceability

Generated from every bullet criterion in \`spec/screen_acceptance_criteria.md\`. Status is evidence state, not a release verdict. \`AUTOMATED\` means a committed assertion exists; it does not claim an independent run passed. Known missing product/device capabilities are explicitly failing or handed off.

| Spec line | Criterion | Stable test ID | Committed test/evidence | Status |
|---:|---|---|---|---|
`;
await writeFile(
  outputPath,
  header + rows.map((row) => `| ${row.join(" | ")} |`).join("\n") + "\n",
);
console.log(
  `Wrote ${rows.length} criterion rows to artifacts/acceptance-traceability.md`,
);

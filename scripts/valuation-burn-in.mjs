import { loadEnvFile } from "node:process";
import { mkdir, writeFile } from "node:fs/promises";

try {
  loadEnvFile(new URL("../.env", import.meta.url));
} catch {
  // CI and production inject secrets directly.
}

const baseUrl = process.env.API_BASE_URL ?? "http://127.0.0.1:8787";
const secret = process.env.OPS_SECRET ?? process.env.CRON_SECRET;
if (!secret) throw new Error("OPS_SECRET or CRON_SECRET is required");

const response = await fetch(`${baseUrl}/v1/ops/release-readiness`, {
  headers: { "X-Ops-Secret": secret },
});
if (!response.ok) {
  throw new Error(`Release-readiness endpoint returned HTTP ${response.status}`);
}

const report = await response.json();
const date = new Date().toISOString().slice(0, 10);
await mkdir(new URL("../artifacts", import.meta.url), { recursive: true });
const output = new URL(`../artifacts/valuation-burn-in-${date}.json`, import.meta.url);
await writeFile(output, `${JSON.stringify(report, null, 2)}\n`, { mode: 0o600 });

console.log(JSON.stringify(report, null, 2));
if (!report.gatePassed) {
  console.error("Valuation exposure remains disabled: the 14-day evidence gate has not passed.");
  process.exitCode = 1;
}

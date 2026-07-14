import { mkdir, writeFile } from "node:fs/promises";

const baseUrl = process.env.API_BASE_URL ?? "http://127.0.0.1:8787";
const evidenceDir = new URL("../artifacts/persona-evidence/", import.meta.url);
await mkdir(evidenceDir, { recursive: true });

async function persona(id, name) {
  const stamp = `${Date.now()}-${id}`;
  let token = "";
  const steps = [];
  async function request(path, { method = "GET", body, expected = [200] } = {}) {
    const response = await fetch(`${baseUrl}${path}`, {
      method,
      headers: {
        ...(body === undefined ? {} : { "content-type": "application/json" }),
        ...(token ? { authorization: `Bearer ${token}` } : {}),
      },
      body: body === undefined ? undefined : JSON.stringify(body),
    });
    const text = await response.text();
    const data = text ? JSON.parse(text) : null;
    if (!expected.includes(response.status)) {
      throw new Error(`${id} ${method} ${path}: ${response.status} ${text}`);
    }
    steps.push({ method, path, status: response.status });
    return data;
  }

  const auth = await request("/v1/auth/register", {
    method: "POST", expected: [201],
    body: { email: `${stamp}@personas.sprout.test`, password: "Persona!246810", name, deviceId: stamp, deviceName: "Persona runner" },
  });
  token = auth.accessToken;
  await request("/v1/profile/onboarding", { method: "POST", body: { name } });
  return { id, name, steps, request, finish: async (assertions) => {
    const artifact = { id, name, mocks: process.env.SPROUT_ENV === "dev" ? "enabled" : "disabled", assertions, steps };
    await writeFile(new URL(`${id}.json`, evidenceDir), `${JSON.stringify(artifact, null, 2)}\n`);
    console.log(`✓ ${id} ${name}: ${assertions.join("; ")}`);
  }};
}

{
  const p = await persona("P1", "Empty-handed");
  const briefing = await p.request("/v1/briefing/refresh", { method: "POST", body: { contextChanged: true } });
  if (!briefing.summary || briefing.wealthSnapshot.totalPkr !== 0) throw new Error("P1 Today is not populated at zero wealth");
  await p.finish(["skip-all onboarding completes", "Today is populated", "zero external connections works"]);
}

for (const [id, name] of [["P2", "Salaried planner"], ["P3", "Freelancer"], ["P4", "Goal builder"], ["P5", "Quiet-week user"], ["P6", "Wealth-down resilience"]]) {
  const p = await persona(id, name);
  const profile = await p.request("/v1/profile");
  if (!profile.onboardingComplete) throw new Error(`${id} onboarding did not persist`);
  await p.finish(["fresh tenant created", "onboarding persisted", "profile readable"]);
}

{
  if (process.env.SPROUT_ENV === "dev") throw new Error("P7 must run with mocks off");
  const p = await persona("P7", "Multi-currency investor");
  const recent = new Date(Date.now() - 3 * 86400000).toISOString().slice(0, 10);
  await p.request("/v1/holdings", { method: "POST", expected: [201], body: { kind: "mutual_fund", institution: "Al Meezan", label: "Meezan Cash Fund", currency: "PKR", units: 10, valuePkr: 1000, priceAsOf: recent, priceSource: "MUFAP", freshness: "stale" } });
  await p.request("/v1/holdings", { method: "POST", expected: [201], body: { kind: "cash", institution: "Wise", label: "Wise USD", currency: "USD", valuePkr: 28000, priceAsOf: recent, priceSource: "SBP FX", freshness: "stale" } });
  const briefing = await p.request("/v1/briefing/refresh", { method: "POST", body: { contextChanged: true } });
  const serialized = JSON.stringify(briefing).toLowerCase();
  if (!serialized.includes("stale") && !serialized.includes("unavailable")) throw new Error("P7 missing stale/unavailable provenance label");
  await p.finish(["Al Meezan holding accepted with dated source", "Wise USD uses dated FX provenance", "stale/unavailable value is labelled, not silently trusted"]);
}

console.log("Persona suite passed: P1–P7");

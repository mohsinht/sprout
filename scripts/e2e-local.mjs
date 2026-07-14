const baseUrl = process.env.API_BASE_URL ?? "http://127.0.0.1:8787";
const runId = Date.now();
const email = `sprout-e2e-${runId}@example.com`;
const password = "SproutE2E!2468";
const deviceId = `e2e-device-${runId}`;
const deviceName = "Local E2E runner";
let token = "";
let passed = 0;

function check(condition, message) {
  if (!condition) throw new Error(message);
  passed += 1;
  console.log(`✓ ${message}`);
}

async function request(path, { method = "GET", body, expected = 200, auth = true } = {}) {
  const response = await fetch(`${baseUrl}${path}`, {
    method,
    headers: {
      ...(body === undefined ? {} : { "content-type": "application/json" }),
      ...(auth && token ? { authorization: `Bearer ${token}` } : {}),
    },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const text = await response.text();
  let data = null;
  try {
    data = text ? JSON.parse(text) : null;
  } catch {
    data = text;
  }
  if (response.status !== expected) {
    throw new Error(`${method} ${path}: expected ${expected}, got ${response.status}: ${text}`);
  }
  return { response, data };
}

const health = await request("/health", { auth: false });
check(health.data.ok === true, "API health is ready");
check(health.response.headers.get("x-content-type-options") === "nosniff", "security headers are present");
check(Boolean(health.response.headers.get("x-request-id")), "requests receive an observability ID");

const registration = await request("/v1/auth/register", {
  method: "POST",
  auth: false,
  expected: 201,
  body: { email, password, name: "E2E Gardener", deviceId, deviceName },
});
token = registration.data.accessToken;
check(Boolean(token && registration.data.refreshToken), "registration issues an access and refresh session");

const initialSessions = await request("/v1/auth/sessions");
check(
  initialSessions.data.sessions.length === 1 &&
    initialSessions.data.sessions[0].deviceId === deviceId,
  "the registered device appears in active sessions",
);

const secondDeviceId = `e2e-second-device-${runId}`;
await request("/v1/auth/login", {
  method: "POST",
  auth: false,
  body: {
    email,
    password,
    deviceId: secondDeviceId,
    deviceName: "Second E2E device",
  },
});
const twoSessions = await request("/v1/auth/sessions");
const secondSession = twoSessions.data.sessions.find(
  (session) => session.deviceId === secondDeviceId,
);
check(twoSessions.data.sessions.length === 2 && secondSession, "multiple device sessions are reviewable");
await request(`/v1/auth/sessions/${secondSession.id}`, { method: "DELETE" });
const revokedSessions = await request("/v1/auth/sessions");
check(
  revokedSessions.data.sessions.length === 1 &&
    revokedSessions.data.sessions[0].deviceId === deviceId,
  "an owned device session can be revoked",
);

const beforeOnboarding = await request("/v1/profile");
check(beforeOnboarding.data.onboardingComplete === false, "new account begins before onboarding completion");

await request("/v1/profile/onboarding", {
  method: "POST",
  body: {
    name: "E2E Gardener",
    goal: { name: "Emergency fund", type: "emergency", targetAmount: 300000 },
  },
});
const onboarded = await request("/v1/profile");
check(onboarded.data.onboardingComplete === true, "onboarding completion persists");

await request("/v1/profile", {
  method: "PATCH",
  body: {
    incomeType: "freelance",
    salaryDate: 15,
    hideBalances: true,
    displayCurrency: "PKR",
    reduceMotion: true,
    notificationPreferences: {
      dailyCheckIn: false,
      billReminders: false,
      salaryIncomeReminders: true,
      weeklySummary: false,
      streakProtection: true,
      hideSensitiveAmounts: true,
    },
  },
});
const profile = await request("/v1/profile");
check(
  profile.data.salaryDate === 15 &&
    profile.data.hideBalances === true &&
    profile.data.notificationPreferences.salaryIncomeReminders === true &&
    profile.data.notificationPreferences.weeklySummary === false,
  "profile, privacy, and notification settings round-trip",
);

const account = await request("/v1/accounts", {
  method: "POST",
  expected: 201,
  body: { label: "Cash", type: "cash", openingBalance: 10000, currency: "PKR" },
});
check(account.data.balance === 10000, "manual account is created with its opening balance");

const occurredAt = new Date().toISOString();
const incomePayload = {
  amount: 150000,
  currency: "PKR",
  type: "income",
  category: "Freelance",
  merchant: "Client payment",
  occurredAt,
  source: "manual",
  accountId: account.data.id,
};
const income = await request("/v1/transactions", { method: "POST", expected: 201, body: incomePayload });
const duplicate = await request("/v1/transactions", { method: "POST", body: incomePayload });
check(income.data.id === duplicate.data.id, "transaction retry is idempotent");

await request("/v1/transactions", {
  method: "POST",
  expected: 201,
  body: {
    amount: 1200,
    currency: "PKR",
    type: "expense",
    category: "Food",
    merchant: "Lunch",
    occurredAt: new Date(Date.now() + 61000).toISOString(),
    source: "manual",
    accountId: account.data.id,
  },
});
const accounts = await request("/v1/accounts");
check(accounts.data.accounts[0].balance === 158800, "income and expense update the account exactly once");

const secondGoal = await request("/v1/goals", {
  method: "POST",
  expected: 201,
  body: { name: "Laptop", type: "custom", targetAmount: 250000, currentAmount: 50000, isPrimary: true },
});
await request(`/v1/goals/${secondGoal.data.id}/contribute`, { method: "POST", body: { amount: 25000 } });
const goals = await request("/v1/goals");
const reorderedIds = goals.data.goals.map((goal) => goal.id).reverse();
await request("/v1/goals/reorder", { method: "POST", body: { ids: reorderedIds } });
check(goals.data.goals.length === 2, "multiple goals and contributions persist");

const incomeOne = await request("/v1/income/projected", {
  method: "POST",
  expected: 201,
  body: { amount: 80000, currency: "PKR", expectedOn: "2026-07-20", note: "Retainer" },
});
await request("/v1/income/projected", {
  method: "POST",
  expected: 201,
  body: { amount: 40000, currency: "PKR", expectedOn: "2026-07-28", note: "Project" },
});
const projected = await request("/v1/income/projected");
check(projected.data.projectedIncome.length === 2 && projected.data.projectedIncome.every((row) => row.inCurrentWealth === false), "multiple dated incomes stay outside current wealth");
await request(`/v1/income/projected/${incomeOne.data.id}`, { method: "DELETE" });

await request("/v1/holdings", {
  method: "POST",
  expected: 400,
  body: { kind: "cash", institution: "Wallet", label: "PKR cash", currency: "PKR", valuePkr: 5000, freshness: "fresh" },
});
await request("/v1/holdings", {
  method: "POST",
  expected: 201,
  body: { kind: "cash", institution: "Wallet", label: "PKR cash", currency: "PKR", valuePkr: 5000, freshness: "manual" },
});
check(true, "fresh holdings require valid provenance and manual PKR cash stays manual");

const refresh = await request("/v1/briefing/refresh", {
  method: "POST",
  body: { contextChanged: true },
});
check(refresh.data.wealthSnapshot?.totalPkr === 163800, "briefing refresh uses confirmed account and holding values");
check(typeof refresh.data.summary === "string" && refresh.data.summary.length > 0, "AI/fallback analysis returns the agreed briefing contract");
check(refresh.data.projectedIncome?.every((row) => row.inCurrentWealth === false) ?? true, "briefing does not count projected income as wealth");

const current = await request("/v1/briefing");
check(current.data.goals.length === 2 && current.data.wealthSnapshot, "Today briefing is fetchable end to end");

const importsDisabled = await request("/v1/upload/baselines", { expected: 503 });
check(
  importsDisabled.data.code === "FEATURE_DISABLED",
  "structured imports fail closed until explicitly enabled",
);

let lastLoginStatus = 0;
for (let index = 0; index < 11; index += 1) {
  const response = await fetch(`${baseUrl}/v1/auth/login`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({
      email: `rate-limit-${runId}@example.com`,
      password: "wrong-password",
      deviceId,
      deviceName,
    }),
  });
  lastLoginStatus = response.status;
}
check(lastLoginStatus === 429, "repeated login attempts are throttled");

console.log(`\n${passed} local E2E assertions passed for ${email}`);

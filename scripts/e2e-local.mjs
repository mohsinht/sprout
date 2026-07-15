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
await request(`/v1/accounts/${account.data.id}`, {
  method: "PATCH",
  body: { balance: 200000 },
});
const editedAccounts = await request("/v1/accounts");
check(
  editedAccounts.data.accounts[0].balance === 200000,
  "a visible balance edit updates the server ledger without double-counting transactions",
);
await request(`/v1/accounts/${account.data.id}`, {
  method: "PATCH",
  body: { balance: 158800 },
});

const uncertain = await request("/v1/transactions", {
  method: "POST",
  expected: 201,
  body: {
    amount: 800,
    currency: "PKR",
    type: "expense",
    category: "Other",
    merchant: "Unclear statement row",
    occurredAt: new Date(Date.now() + 122000).toISOString(),
    source: "statement",
    confidence: 0.45,
    needsReview: true,
    reviewReason: "Merchant was unclear",
    accountId: account.data.id,
  },
});
let reviewedAccounts = await request("/v1/accounts");
check(reviewedAccounts.data.accounts[0].balance === 158800, "uncertain transactions do not change balances before review");
await request(`/v1/transactions/${uncertain.data.id}/confirm`, { method: "PATCH", body: {} });
reviewedAccounts = await request("/v1/accounts");
check(reviewedAccounts.data.accounts[0].balance === 158000, "confirming an uncertain transaction updates its account once");
await request(`/v1/transactions/${uncertain.data.id}`, { method: "DELETE" });
reviewedAccounts = await request("/v1/accounts");
check(reviewedAccounts.data.accounts[0].balance === 158800, "removing a reviewed transaction restores the account picture");

const secondGoal = await request("/v1/goals", {
  method: "POST",
  expected: 201,
  body: { name: "Laptop", type: "custom", targetAmount: 250000, currentAmount: 50000, isPrimary: true },
});
await request(`/v1/goals/${secondGoal.data.id}/contribute`, {
  method: "POST",
  body: {
    amount: 25000,
    idempotencyKey: `e2e-goal-${secondGoal.data.id}`,
  },
});
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

await request("/v1/holdings", {
  method: "POST", expected: 400,
  body: { kind: "mutual_fund", institution: "Audit", label: "Stale", currency: "PKR", units: 1, valuePkr: 100, priceAsOf: "2000-01-01", priceSource: "Audit", freshness: "fresh" },
});
await request("/v1/holdings", {
  method: "POST", expected: 400,
  body: { kind: "mutual_fund", institution: "Audit", label: "Invalid", currency: "PKR", units: 1, valuePkr: 100, priceAsOf: "not-a-date", priceSource: "Audit", freshness: "fresh" },
});
await request("/v1/holdings", {
  method: "POST", expected: 400,
  body: { kind: "mutual_fund", institution: "Audit", label: "Source only", currency: "PKR", units: 1, valuePkr: 100, priceSource: "Audit", freshness: "fresh" },
});
check(true, "audit_a6_stale_provenance_rejected");

const refresh = await request("/v1/briefing/refresh", {
  method: "POST",
  body: { contextChanged: true },
});
check(refresh.data.wealthSnapshot?.totalPkr === 163800, "briefing refresh uses confirmed account and holding values");
check(typeof refresh.data.summary === "string" && refresh.data.summary.length > 0, "AI/fallback analysis returns the agreed briefing contract");
check(
  refresh.data.refresh?.status === "refreshed" &&
    typeof refresh.data.refresh.aiUsed === "boolean",
  "manual Today refresh reports whether an AI call was actually used",
);
check(refresh.data.projectedIncome?.every((row) => row.inCurrentWealth === false) ?? true, "briefing does not count projected income as wealth");

const refreshedInsights = await request("/v1/insights/refresh", {
  method: "POST",
  body: {},
});
check(
  ["quiet", "populated"].includes(refreshedInsights.data.state) &&
    refreshedInsights.data.refresh?.status === "refreshed" &&
    typeof refreshedInsights.data.refresh.aiUsed === "boolean",
  "manual Insights refresh returns an honest content and AI-use status",
);

const current = await request("/v1/briefing");
check(current.data.goals.length === 2 && current.data.wealthSnapshot, "Today briefing is fetchable end to end");

const wealthBeforeRecurring = current.data.wealthSnapshot.totalPkr;
await request("/v1/recurring/series", {
  method: "POST", expected: 201,
  body: { kind: "liability", frequency: "monthly", amount: 9000, label: "Rent", anchorDay: 1, timezone: "Asia/Karachi" },
});
await request("/v1/recurring/generate", { method: "POST", body: {} });
let asks = await request("/v1/recurring/asks");
const rentAsk = asks.data.asks.find((ask) => ask.question.startsWith("Rent "));
check(Boolean(rentAsk), "audit_b5_missed_occurrence_emits_one_contextual_ask");
await request(`/v1/recurring/occurrences/${rentAsk.id}/respond`, { method: "POST", body: { outcome: "no" } });
const afterSkip = await request("/v1/briefing/refresh", { method: "POST", body: { contextChanged: true } });
check(afterSkip.data.wealthSnapshot.totalPkr === wealthBeforeRecurring, "audit_b5_skip_does_not_mutate_wealth");

await request("/v1/recurring/series", {
  method: "POST", expected: 201,
  body: { kind: "liability", frequency: "monthly", amount: 9000, label: "Utilities", anchorDay: 1, timezone: "Asia/Karachi" },
});
await request("/v1/recurring/generate", { method: "POST", body: {} });
asks = await request("/v1/recurring/asks");
const utilityAsk = asks.data.asks.find((ask) => ask.question.startsWith("Utilities "));
await request(`/v1/recurring/occurrences/${utilityAsk.id}/respond`, { method: "POST", body: { outcome: "yes", accountId: account.data.id } });
const afterYes = await request("/v1/briefing/refresh", { method: "POST", body: { contextChanged: true } });
check(afterYes.data.wealthSnapshot.totalPkr === wealthBeforeRecurring - 9000, "audit_b5_only_yes_changes_wealth_via_confirmed_transaction");

const importsDisabled = await request("/v1/upload/baselines", { expected: 503 });
check(
  importsDisabled.data.code === "FEATURE_DISABLED",
  "structured imports fail closed until explicitly enabled",
);

await request("/v1/transactions", {
  method: "POST", expected: 400,
  body: { amount: -1, currency: "PKR", type: "expense", category: "Food" },
});
await request("/v1/transactions", {
  method: "POST", expected: 400,
  body: { amount: 1, currency: "PKR", type: "expense", category: "Food", occurredAt: "not-a-date" },
});
const malformed = await fetch(`${baseUrl}/v1/transactions`, {
  method: "POST",
  headers: { "content-type": "application/json", authorization: `Bearer ${token}` },
  body: '{"amount":',
});
check(malformed.status === 400, "audit_d4_malformed_input_never_500");

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

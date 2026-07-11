# Sprout API

The backend for Sprout — a personal wealth-health tracker built as a **reconciliation engine**.

## Architecture

Sprout anchors on user-uploaded statements/screenshots (source of truth), estimates forward daily using public prices/FX and manually-reported transactions, and re-anchors when a new statement arrives. It does not depend on live bank/broker access (which doesn't exist reliably in Pakistan).

```
CONFIRMED BASELINE (from uploaded statement/screenshot, as-of a date)
      │
      ├── + daily NAV × units      (price moves the fund value)
      ├── + daily FX × balances    (rate moves the cash value)
      ├── + manual transactions    (salary in, transfer out, spend)
      ├── + pending/in-transit     (money moved but not yet unitized)
      ▼
ESTIMATED TODAY'S TOTAL  ── shown with "estimated since <baseline date>" ──
      │
      ▼
RE-ANCHOR when a new statement/screenshot is uploaded → new CONFIRMED BASELINE
```

## Stack

- **Runtime:** Node.js + TypeScript
- **API:** Hono
- **DB:** PostgreSQL (via Drizzle ORM)
- **Auth:** argon2 password hashing + JWT access tokens + hashed refresh tokens
- **AI:** OpenAI API (gpt-4o-mini by default) — deterministic fallback if no API key
- **Scheduling:** Single cron endpoint (called by host cron / GitHub Actions / Supabase scheduled fn)

No Redis, no queues, no microservices, no Kubernetes. One Postgres, one process.

## Setup

```bash
# 1. Copy env
cp apps/api/.env.example apps/api/.env
# Edit .env with your DATABASE_URL and JWT_SECRET

# Start the local PostgreSQL service from the repository root.
docker compose up -d postgres

# 2. Install dependencies
pnpm install

# 3. Build shared packages
pnpm --filter @sprout/shared build
pnpm --filter @sprout/domain build

# 4. Apply the generated database migrations
cd apps/api
pnpm db:migrate

# 5. Run the API
pnpm --filter @sprout/api dev
```

## Phase 1 seed

The real one-user seed requires explicit values for fields that are not
defined in the product specs. It fails before writing if any value is missing.

```bash
SEED_USER_ID=<existing-user-uuid> \
SEED_AS_OF=YYYY-MM-DD \
WISE_USD_BALANCE=<confirmed-usd-balance> \
WISE_EUR_BALANCE=<confirmed-eur-balance> \
CAR_TARGET_PKR=<target> CAR_CURRENT_PKR=<current> \
EMERGENCY_TARGET_PKR=<target> EMERGENCY_CURRENT_PKR=<current> \
pnpm --filter @sprout/api seed:holdings
```

The seed is idempotent by user and holding/goal identity. Fund units are
stored with the supplied confirmation date; price and FX valuations remain
unavailable until the real source tickets populate them.

## API Endpoints

### Auth
- `POST /v1/auth/register` — register with email + password
- `POST /v1/auth/login` — login
- `POST /v1/auth/refresh` — refresh access token
- `POST /v1/auth/logout` — revoke refresh token

### Profile + Onboarding
- `GET /v1/profile` — get profile
- `PATCH /v1/profile` — update profile
- `POST /v1/profile/onboarding` — complete onboarding (name + optional goal)

### Manual Entry (the floor — app fully works here)
- `GET/POST /v1/accounts` — manual cash/account ledger
- `PATCH/DELETE /v1/accounts/:id`
- `GET/POST /v1/holdings` — manage holdings
- `PATCH/DELETE /v1/holdings/:id`
- `GET/POST /v1/goals` — manage goals
- `PATCH/DELETE /v1/goals/:id`
- `GET/POST /v1/transactions` — manage transactions (dedupe on fingerprint)
- `PATCH /v1/transactions/:id/confirm` — confirm a transaction
- `DELETE /v1/transactions/:id`

### Reconciliation Model
- `GET/POST /v1/pending` — pending/in-transit investments
- `PATCH/DELETE /v1/pending/:id`
- `GET/POST /v1/income/projected` — projected income (side note, never in wealth total)
- `DELETE /v1/income/projected/:id`
- `POST /v1/upload/statement` — re-anchor from Al Meezan statement (highest-trust event)
- `POST /v1/upload/screenshot` — re-anchor from Wise screenshot
- `GET /v1/upload/baselines` — list baselines

### Briefing
- `GET /v1/briefing` — latest briefing (with fallback to last stored)
- `POST /v1/briefing/refresh` — on-demand refresh (rate-limited)
- `GET /v1/briefing/sources` — data source status + parser health

### Cron
- `POST /v1/cron/daily` — run daily job for all users (secured by X-Cron-Secret header)

## Key Design Decisions

1. **Money as whole PKR rupees** (int) — paisa not meaningful in daily consumer use.
2. **Every valuation carries provenance** — source + as-of date. No black-box totals.
3. **Code owns the arithmetic** — the AI model only writes words, never computes numbers.
4. **Idempotent jobs** — `job_runs` table with `idempotency_key` (user+date). Running twice returns the existing briefing.
5. **Swappable sources** — FX, NAV, and email all sit behind interfaces with mock implementations.
6. **Manual is the floor** — the app produces a full daily analysis from manual data with zero live sources.
7. **Projected income is never in wealth** — it's a side note (days-remaining + approx PKR).
8. **Pending investments are in-transit** — included in total but flagged, never double-counted.
9. **Statements/screenshots are truth** — between them, everything is a labelled estimate.
10. **Missing market data is explicit** — an unavailable NAV or FX rate is never replaced with a fabricated valuation.
11. **AI writes copy only** — GPT-5.6 Luna receives deterministic facts and returns schema-validated greeting/summary/interpretation text; it cannot alter money, scores, sources, or actions.

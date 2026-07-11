# Phase 1 — Make It Real For One User

> **Goal:** Your real wealth (~PKR 13.67M) shows on the Today screen, reconciled
> from your real Al Meezan statement, with live FX and MUFAP NAVs, and a
> deterministic AI interpretation. Single user (you). No auth, no multi-user,
> no email crawling, no polish.
>
> **Done when:** You open the app in the morning and see your actual total
> wealth, today's movement, the "why," and one goal-relative next step — all
> from real data, not mock data.

---

## Standing rules (enforce on every ticket)

1. **Real-data tickets fail loudly, never silently fall back to mock.** If
   MUFAP is hard to parse, the ticket fails — it does not quietly use mock
   NAVs so the ticket "passes." A beautiful app showing a fabricated wealth
   number is the single most dangerous failure mode. Every real-data source
   must fail visibly and label the data stale/missing, never silently
   substitute mock.
2. **The done-check is the gate, not the agent saying "done."** Compilation is
   not correctness. For each ticket, *you* confirm the done-check with real
   eyes: for FX, is the rate today's actual rate? For MUFAP, does it match
   your known NAVs? For the pipeline, does it produce your real number?
3. **One ticket, verified, before the next.** Small commits, review each.
   Don't let the agent build ahead — hidden breakage lives in bulk work.

---

## Ticket 1 — Consolidate the Flutter domain models

**Why first:** The app has duplicate model classes (`today_models.dart` vs
`wealth_models.dart`) for `Holding`, `WealthSnapshot`, `WealthEvent`, etc.
The `wealth_models.dart` versions match the backend's `WealthBriefing`
contract. You can't wire the API until the app speaks the same shape.

**Build:**
- Make `wealth_models.dart` the single source of truth for wealth models.
- Add `fromApiJson` factory constructors (or a mapper) to each model in
  `wealth_models.dart` that parses the backend's JSON response.
- Update `TodayData` in `today_models.dart` to compose `WealthBriefing`
  from `wealth_models.dart` instead of duplicating the classes.
- Update the Today screen and controller to use the `wealth_models.dart`
  types.
- Keep `mock_today_repository.dart` working (it should still compile and
  return the same data, just through the consolidated types).

**Done-check:**
- [ ] `flutter analyze` passes with zero errors.
- [ ] Today screen renders identically (same data, same layout).
- [ ] `wealth_models.dart` has `fromApiJson` factories for `WealthBriefing`,
      `Holding`, `WealthSnapshot`, `WealthEvent`, `WealthGoal`,
      `WealthBriefingAction`, `PriceQuote`, `FxRate`.
- [ ] No duplicate class names remain between `today_models.dart` and
      `wealth_models.dart`.

---

## Ticket 2 — Add HTTP client + API repository implementations

**Why:** The app has zero networking code. Before it can talk to the backend,
it needs an HTTP client, base URL config, and real repository implementations
that sit alongside the mocks behind the same interfaces.

**Build:**
- Add `dio` (or `http`) to `apps/mobile/pubspec.yaml`.
- Create `apps/mobile/lib/src/data/api/sprout_api_client.dart`:
  - Base URL from environment (`--dart-define=API_BASE_URL=...`).
  - `get<T>(path)` and `post<T>(path, body)` methods.
  - Auth header injection (for now: a hardcoded dev token or no auth —
    single user, your app).
  - Error handling that surfaces transport/status/schema failures to the UI;
    mock data is selected only by the explicit `USE_MOCK` build flag.
- Create `HttpWealthBriefingRepository implements WealthBriefingRepository`:
  - Calls `GET /v1/briefing`.
  - Maps the JSON response to `WealthBriefing` via the `fromApiJson`
    factories from Ticket 1.
- Create `HttpTodayRepository implements TodayRepository`:
  - Calls `GET /v1/briefing` and maps to `TodayData`.
- Add an environment switch: `--dart-define=USE_MOCK=false` makes the
  providers return HTTP repositories; default stays mock.

**Done-check:**
- [ ] `flutter analyze` passes.
- [ ] With `USE_MOCK=true` (default), the app behaves exactly as before.
- [ ] With `USE_MOCK=false`, the app attempts to call `GET /v1/briefing`
      on the configured base URL.
- [ ] If the API is unreachable, the app shows the explicit unavailable/error
      state and does not substitute mock data or fabricate a wealth number.

---

## Ticket 3 — Seed your real holdings into the database

**Why:** The backend has empty tables. Before the briefing pipeline can
compute your real wealth, it needs your actual holdings: 5 Al Meezan funds
(AMMF, MIF, MSF, MDIP, MFPF-AAP) with real unit counts, plus Wise USD and
EUR cash balances.

**Build:**
- Start a local Postgres (or use Supabase/Neon free tier).
- Run `pnpm drizzle-kit push` in `apps/api` to create tables.
- Create a seed script (`apps/api/src/scripts/seed-holdings.ts`) that
  inserts your real holdings:
  - AMMF: 28,822.5265 units, Al Meezan, PKR
  - MDIP: 4.4710 units, Al Meezan, PKR
  - MFPF-AAP: 3,352.5457 units, Al Meezan, PKR
  - MIF: 12,139.0066 units, Al Meezan, PKR
  - MSF Growth-C: 19,741.7072 units, Al Meezan, PKR
  - MSF S-Plan: 1,845.7239 units, Al Meezan, PKR
  - Wise USD Cash: balance in USD, Wise, USD
  - Wise EUR Cash: balance in EUR, Wise, EUR
  - PKR Cash: 0, Local, PKR
- Also seed your goals (Car Fund, Emergency Fund) with real targets.
- Run the seed script.

**Done-check:**
- [ ] `SELECT * FROM holdings` returns your real holdings with correct
      unit counts and currencies.
- [ ] `SELECT * FROM goals` returns your real goals.
- [ ] The seed script is idempotent (running twice doesn't duplicate).

---

## Ticket 4 — Upload your real Al Meezan statement (re-anchor)

**Why:** This is the moment the app becomes real. Your statement is the
source of truth — the confirmed baseline. Everything else estimates forward
from it.

**Clarification:** For Phase 1 with one user, **hand-seeding your confirmed
units is completely fine and faster** — don't build a full PDF parser here.
You can insert the six unit counts directly via the API or a seed script.
Real automated statement parsing is a later ticket. The goal here is to get
the confirmed baseline into the database, not to build a parser.

**Build:**
- Use the `POST /v1/upload/statement` endpoint (already built).
- Send a JSON payload with your real statement data:
  - `capturedAsOf`: the date you captured the statement
  - `printedOn`: the date printed on the statement
  - `funds`: array of `{ fundCode, units, fundName }` for each fund
  - `confirmedValuePkr`: the total from the statement
- Verify the baseline was created: `GET /v1/upload/baselines`.
- Verify holdings were updated with `units_confirmed_as_of` and
  `valuation_kind: "confirmed"`.

**Done-check:**
- [ ] `SELECT * FROM baselines` shows one row with your statement data.
- [ ] `SELECT fund_code, units, units_confirmed_as_of, valuation_kind
      FROM holdings` shows all funds as `confirmed` with the correct date.
- [ ] Any pending investments (if seeded) are marked `unitized`.

---

## Ticket 5 — Make the FX fetch real

**Why:** Your Wise USD and EUR holdings need real FX rates to compute
valuePkr. The mock FX source returns the canonical example values; the real
source fetches live rates.

**Build:**
- Set `FX_SOURCE=real` in `.env`.
- Verify the `ExchangeRateHostFxSource` fetches real USD/PKR and EUR/PKR.
- Check `SELECT * FROM fx_rates` for the fetched rates with provenance.
- If the fetch fails, verify the app falls back to last-known + labels
  stale (does not crash or show wrong data).

**Done-check:**
- [ ] `SELECT pair, rate, as_of, source FROM fx_rates` shows real rates
      from `exchangerate.host` with today's date.
- [ ] The rates are plausible (not the mock 277.992 / 317.536 — actual
      current rates).
- [ ] If the FX API is down, the app uses last-known rates and labels
      them stale.

---

## Ticket 6 — Make the MUFAP NAV fetch real

**Why:** Your Al Meezan fund holdings need real NAVs to compute valuePkr.
MUFAP publishes daily NAVs for all Pakistani mutual funds. This is the
closest thing to an official source.

**Build:**
- Inspect the MUFAP daily NAV page structure (mufap.com.pk).
- Implement the real parser in `MufapNavSource.fetchNav()`:
  - Fetch the daily NAV table.
  - Match fund codes (AMMF, MIF, MSF, MDIP, MFPF-AAP).
  - Parse the NAV value and validity date.
  - Store provenance (source: "MUFAP", as_of: the validity date).
  - If the format doesn't match, fail loudly (return null → caller uses
    last-known + stale label).
- Add a parser version and a golden sample test.
- Set `NAV_SOURCE=mufap` in `.env`.
- Verify `SELECT * FROM price_quotes` shows real NAVs with provenance.

**Done-check:**
- [ ] `SELECT instrument, value, as_of, source FROM price_quotes` shows
      real NAVs from MUFAP for all 5 fund codes.
- [ ] The NAVs are plausible (not the mock values — actual current NAVs).
- [ ] If MUFAP is down or the format changes, the app uses last-known
      NAVs and labels them stale.
- [ ] The parser has a version string and at least one golden sample test.

---

## Ticket 7 — Run the briefing pipeline end-to-end

**Why:** This is the moment everything comes together. The pipeline gathers
your holdings, fetches real prices/FX, computes the WealthSnapshot, detects
events, computes the score, selects the action, and stores the briefing.

**Build:**
- Start the API: `pnpm --filter @sprout/api dev`.
- Call `POST /v1/cron/daily` with the cron secret (or trigger on-demand
  via `POST /v1/briefing/refresh`).
- Verify the briefing was generated:
  - `SELECT * FROM daily_briefings` — one row for today.
  - `SELECT * FROM wealth_snapshots` — one row for today.
  - `SELECT * FROM wealth_events` — events for today.
- Call `GET /v1/briefing` and verify the response:
  - `totalPkr` is close to your real ~13.67M.
  - `changeVsYesterday` and `changeMtd` are present.
  - `provenanceSummary` names the sources with dates.
  - `freshness` is `"fresh"`.
  - `mascotMood` matches the score band.
  - `recommendedAction` is goal-relative.
  - No guardrail violations.

**Done-check:**
- [ ] `GET /v1/briefing` returns a valid `WealthBriefing` with your real
      total wealth.
- [ ] **Reconciliation golden test:** the computed total matches the
      known-good automation figure for the same day within a small
      tolerance (e.g. ±2% for FX/NAV movement). If the pipeline says
      PKR 13.67M and your trusted automation says PKR 13.67M, good. If it
      says PKR 15M, stop — a confident wrong number is the one failure
      mode that destroys trust in a wealth tracker.
- [ ] The total is within a plausible range of your statement's confirmed
      value (adjusted for NAV/FX movement since the statement date).
- [ ] `provenanceSummary` states the dated sources used.
- [ ] `freshness` is `"fresh"` (or `"stale"` if a source failed, but
      never silently wrong).
- [ ] The recommended action is goal-relative (not a check-in).
- [ ] No guardrail violations in the job run.

---

## Ticket 7.5 — Verify the API output before touching Flutter

**Why:** A cheap intermediate check between the pipeline (7) and the Flutter
wiring (8). Look at the JSON the API returns for your account — is the number
right, the provenance present, the interpretation sane? Catch bugs at the API
layer where they're easy to see, before they're wrapped in UI where they're
harder to diagnose. It's a five-minute check that saves an hour of "is it the
backend or the wiring?"

**Build:**
- Start the API: `pnpm --filter @sprout/api dev`.
- Call `GET /v1/briefing` with your auth token.
- Inspect the full JSON response:
  - Is `totalPkr` correct (matches your known-good figure)?
  - Is `provenanceSummary` present and accurate?
  - Are `changeVsYesterday` and `changeMtd` both present?
  - Is the `interpretation` sane (in Sprout's voice, no hype/shame)?
  - Is `recommendedAction` goal-relative?
  - Are `holdings` populated with real data?
  - Is `freshness` correct?
- If anything is wrong, fix it here — not in the Flutter wiring.

**Done-check:**
- [ ] The JSON response from `GET /v1/briefing` is correct and complete.
- [ ] Every field that the Flutter app will consume is present and valid.
- [ ] No mock data appears in the response (all sources are real or
      labelled stale).

---

## Ticket 8 — Wire the Flutter app to the real backend

**Why:** This is the moment it becomes a product. Your real wealth appears
on the Today screen.

**Build:**
- Start the API on your machine.
- Run the Flutter app with `--dart-define=USE_MOCK=false
  --dart-define=API_BASE_URL=http://localhost:8787`.
- The Today screen should call `GET /v1/briefing` and render your real:
  - Total wealth figure (the hero number).
  - Today's change and MTD change.
  - The "why" interpretation.
  - The one goal-relative next step.
  - Provenance on tap.
- If the API is unreachable, the app falls back to mock data with
  `freshness: "local_fallback"`.

**Done-check:**
- [ ] The Today screen shows your real total wealth (~13.67M PKR).
- [ ] The wealth figure matches `GET /v1/briefing` from the API.
- [ ] Today's change and MTD change are both shown.
- [ ] The interpretation lines are present and in Sprout's voice.
- [ ] The recommended action is goal-relative.
- [ ] Provenance is visible (source + date).
- [ ] If the API is down, the app shows mock data with a "using what I
      already know" message — no crash.
- [ ] The 20-second daily loop works: glance → read → act → close.

---

## Ticket 9 — Add the salary countdown (projected income)

**Why:** High-delight, cheap. The salary strip is a side note that tells
you how many days until your next payday and the approximate PKR value.
It's never in the total wealth number.

**Build:**
- Use `POST /v1/income/projected` to add your real salary:
  - Amount: your real salary (e.g. USD 6,500).
  - Currency: USD.
  - Expected on: your real payday (e.g. 2026-07-20).
- The backend converts to PKR using today's FX.
- Wire the Flutter app to show the salary strip on Today:
  - Days remaining.
  - Approximate PKR value.
  - "Projected total after salary" (current wealth + projected income —
    labelled as projected, not current).
- Emphasize: this is NOT in the current wealth total.

**Done-check:**
- [ ] `GET /v1/income/projected` returns your salary with days remaining
      and converted PKR estimate.
- [ ] The Today screen shows the salary strip.
- [ ] The salary strip is clearly separate from the wealth total.
- [ ] The projected total after salary is labelled as projected.

---

## Ticket 10 — Add pending investments (in-transit money)

**Why:** If you've moved money toward new funds but the next statement
hasn't confirmed units yet, that money is "in transit." It stays in total
wealth but is flagged, and is reconciled out when the next statement arrives.

**Build:**
- Use `POST /v1/pending` to add any real pending investments:
  - Amount in PKR.
  - Destination (e.g. "MFPF Aggressive Allocation").
  - Initiated on date.
- Verify the briefing includes pending in the total.
- Wire the Flutter app to show pending investments:
  - In the per-holding breakdown as "In transit (pending)."
  - In the provenance summary as "PKR X in transit."
  - In the wealth events as a `contribution` event with a plainWhy.

**Done-check:**
- [ ] `GET /v1/pending` returns your pending investments.
- [ ] The briefing's `totalPkr` includes pending amounts.
- [ ] The per-holding breakdown shows "In transit (pending)."
- [ ] The provenance summary mentions the pending amount.
- [ ] Pending is never double-counted (once as pending, again as units).
- [ ] When a new statement is uploaded, matching pending investments are
      marked `unitized`.

---

## What comes after Phase 1

Phase 2 (harden): versioned parser health checks, dedupe verification,
stale-price labelling in the UI, every failure/fallback path tested,
up/flat/offline/zero-holdings states proven.

Phase 3 (safe for others): real auth (Supabase Auth), encryption at rest,
delete-my-data flow, crash reporting, regulatory boundary check.

Phase 4 (delight): haptics, wealth count-up, tile stagger, animated mascot,
completion celebration.

Phase 5 (ship to friends): TestFlight / Play internal testing with a
handful of real users. Then consider the store (Gmail CASA, Play SMS
permissions — both deferred until now on purpose).

---

## Rules for the agent

1. **One ticket at a time.** Small commits, review each.
2. **Foundations first.** Schema → seed → FX → NAV → pipeline → wire.
3. **Every ticket preserves the regression invariants.** Wealth is always
   the hero, no number without provenance, no shame, no check-in action.
4. **Don't fake data.** If a value is unknown, ask. If a source is down,
   label it stale. Never silently use mock data as if it were real.
5. **The done-check is the gate.** A ticket is not done until every
   checkbox is verified.

**VERDICT: BLOCK**
Sprout must not ship because provenance enforcement, malformed-input handling, missing-data scoring, production Insights isolation, onboarding route enforcement, and the mandatory valuation burn-in gate fail; several trust-critical UI/device journeys remain unverified.

# Blockers

1. **A2 — the default release build ships mock, user-specific holdings and literal “Mock” copy.**

   Reproduction: run `cd apps/mobile && flutter build web --release`, then `rg -a -n -o "Mock briefing|Mock Xe FX snapshot|Al Meezan|Wise USD|USE_MOCK" build/web/main.dart.js`. The release build contained `Mock briefing`, `Mock Xe FX snapshot`, `Wise USD`, and multiple `Al Meezan` strings. `http_today_repository.dart`, `http_wealth_repository.dart`, `mock_insights_repository.dart`, `manual_money_store.dart`, and `goal_store.dart` all define `USE_MOCK` with `defaultValue: true`. A normal release build therefore defaults to the mock repositories rather than the real user/API path. This directly fails the brand-new zero-holding-user requirement and makes the requested real UI → API → DB audit impossible without a special build flag.

2. **A3 — onboarding can be bypassed by direct routing.**

   Reproduction: inspect `apps/mobile/lib/src/app/sprout_app.dart`. `GoRouter` starts at `/today` and defines `/auth`, `/onboarding`, and the shell routes without a `redirect` or authentication/onboarding guard. Registration stores a session but does not route based on `onboardingComplete`. A user can address `/today` directly before completing onboarding. This is a Section A automatic block.

3. **A6 — stale and malformed valuation provenance is not rejected correctly.**

   Direct API reproduction with a fresh audit user:

   - Fresh valuation with neither source nor date: HTTP 400 (correct).
   - Source but no date: HTTP 400 (correct).
   - `priceAsOf: "2000-01-01"`, `priceSource: "Test source"`, `freshness: "fresh"`: HTTP **201**, stored as `fresh` (failure).
   - `priceAsOf: "not-a-date"` with a source and `freshness: "fresh"`: HTTP **500** (failure; must be a clean boundary rejection).

   `hasValidProvenance()` checks only non-empty strings; it does not validate the date or freshness threshold. Missing FX does numerically exclude non-PKR value by using zero, but unavailable FX is not counted by `stalePriceCount` and no required finding is produced. This is trust-critical and an automatic block.

4. **B3 — the required missing-data score contract is absent and unknown factors receive invented defaults.**

   `apps/api/src/lib/scoring.ts` always scores all eight factors and has no factor-presence model, minimum-factor suppression, weight redistribution, or “based on N of 8 factors” explanation. `apps/api/src/services/briefing-pipeline.ts` substitutes monthly expenses `100000`, contribution consistency `0.5`, bill coverage `1`, and debt ratio `0`. A zero-holding audit user received score 48 rather than a missing-score state. This fails both the two-factor and four-factor requirements and is a Section B automatic block.

5. **B5 — recurring-money behavior cannot be verified against its required ground truth.**

   `spec/recurring_money_contract.md` does not exist, and repository search found no recurring-liability occurrence engine. The mandatory non-mutation, contextual missed-occurrence ask, and non-PKT midnight behavior cannot pass. Section B failure is an automatic block.

6. **B7 — stored output violates the “every movement has a why” rule, and the validator does not catch it.**

   DB row `daily_briefings.id=76919aa2-9730-48f5-89c7-fae13cdea3d3` has summary `Up PKR 500 today. flat PKR 0 this month.` with no reason, while `mainReason` separately says `Cash movement`. `checkGuardrails()` verifies event `plainWhy` and paired fields but does not require the displayed summary movement to carry its driver. This is precisely an output-validator failure under B7.

7. **D4 — malformed Quick Add/API payloads cause 500 responses.**

   Direct API fuzz results: negative amount → 400; oversized body → 413; malformed JSON → **500**; transaction `occurredAt: "not-a-date"` → **500**. Client bodies were sanitized to `{"error":"Unexpected server error"}`, but the required clean rejection/no-500 rule fails. Injection-shaped strings were stored as data without SQL execution; that is not itself a server compromise, but downstream UI escaping was not physically verified.

8. **D6 — the valuation burn-in gate objectively fails.**

   Independent `pnpm ops:valuation-gate` result: 14-day window; 30 jobs, 27 succeeded, 2 failed, **0 distinct qualifying daily-job dates**; 2 snapshot dates, 1 stale/unavailable snapshot, **16 duplicates**; 0 NAV dates/sources; 0 FX dates/sources; cross-validation unimplemented; `prerequisitesPassed=false`; `gatePassed=false`. MUFAP match rate cannot be stated because cross-validation is not implemented. This is an automatic block regardless of all other results.

9. **A1/A4/A5/A7/B4/C1–C5/D7 — trust-critical device and real-user paths remain unverified.**

   No Android/iOS emulator or physical-device recording was produced for offline add/reconnect exact-once agreement, complete balance masking after restart, action durability under clock changes, native token storage inspection, persona journeys, or graceful UI fallback. The compiled app defaults to mocks, so the passing API suite cannot establish Flutter UI → API → DB behavior. Privacy, token-at-rest, provenance display, and money agreement are trust-critical; per the audit rules these evidence gaps block release.

# Beta-acceptable defects

- None are dispositioned as beta-acceptable while automatic A/B/D6 blockers remain.
- The Flutter web build emits Rive WASM compatibility warnings and a Cupertino icon/font warning. Web is an internal harness per spec, so these would not independently block a native closed beta, but they remain build-quality defects.

# Unverified items

- **A1:** cached Today behavior exists in code, and local transaction retry code exists, but no real Flutter outage/restart/reconnect run with DB duplicate count and Today/Money/server agreement was recorded.
- **A2:** DB scope query over the latest 20 briefings found 0 out-of-scope events/actions, but all 20 had zero events; this is vacuous and does not rescue the release-build mock failure.
- **A4:** `hideBalances` persists through a provider, but no restart plus rendered-output scan proved masking of every requested amount surface.
- **A5:** no force-close/clock manipulation/next-day UI test.
- **A7:** dependency audit, login throttle, sampled security headers, and production-secret boot refusal passed. Native device storage was not inspected, so token-at-rest remains unverified.
- **B1:** widget tests passed for shell navigation and 1.3× layout, but no full-screen real-device visual check proved every surface clears the floating nav.
- **B2:** one golden-like score fixture produced byte-identical outputs twice (score 58), and the active API engine uses the eight named factors. There is no committed golden test. A second, exported legacy score implementation in `packages/domain/src/financial-health-score.ts` uses nine different factors and advertises `+N health score`, so exclusive ownership is unverified.
- **B4:** DB schema makes both `change_vs_yesterday` and `change_mtd` non-null; the latest 20 JSON briefings contained both. Projected income exclusion passed local E2E. There were zero stored wealth events, so non-empty `plainWhy` durability was not meaningfully exercised.
- **B6:** exact forbidden phrases were not found in executable money-movement endpoints; no endpoint route matched transfer/payment/top-up initiation. Educational mock copy contains “move money,” which is not an in-app movement endpoint. Deployed regulatory behavior remains unverified.
- **B8:** no UI skip-everything onboarding run; code inspection shows the route can be bypassed and therefore fails the broader onboarding invariant.
- **C1–C5:** none of the requested fresh-account screenshot/screen-recorded journeys were produced.
- **D1:** transaction retry idempotency passed local E2E, but the disabled import path prevented a three-replay import/parse DB-count test.
- **D2:** cross-tenant holding PATCH/DELETE and session DELETE returned 404; user A’s holdings response was empty and did not expose user B. The API offers only self-scoped briefing/holding collection endpoints, so cross-user reads cannot be parameterized. This is positive local evidence, but no deployed isolation test was run.
- **D3:** two simultaneous goal contributions ended at the expected 300 and two simultaneous Quick Adds ended at the expected account balance 967 in this run. This is one run, not a sustained race test.
- **D5:** real valuation and structured-import flags are off by default; structured imports returned 503 `FEATURE_DISABLED`. There is no separate remote gate service to kill, so gate-service-unreachable behavior is not applicable/evidenced.
- **D7:** local backup and isolated restore smoke passed. Deployed TLS, encrypted retention, request-log ingestion, PII log review, and graceful shutdown mid-request were not proven.
- **E2:** local checks passed, but no `.github` workflow or other CI evidence was present; “all suites green in CI” is UNVERIFIED.

# Human handoffs

- Run the full A1/A3/A4/A5 and C1–C5 journeys on release-signed Android and iOS builds compiled with the intended production flags; record every step and DB reconciliation.
- Inspect actual Android/iOS app storage for tokens; verify Keychain/Keystore behavior, biometric/device lock, logout/revocation, and migration from old preferences.
- Measure low-end Android frame rate, launch time, memory, offline behavior, 1.3× text scale, screen reader labels, reduce motion, dark mode, and notification/deep-link delivery.
- Verify iOS operation without SMS capture and Android permission/store-policy behavior with optional SMS capture.
- Supply and verify store bundle IDs, signing identities, release signing, privacy/support URLs, screenshots, disclosures, and store configuration.
- Verify deployed secrets manager, production DB credentials/SSL, TLS termination, CORS/origins, encryption at rest, backup retention, isolated restore, monitoring, alerting, request-ID correlation, sanitized logs, and graceful shutdown under live traffic.
- Keep real NAV/FX and structured imports disabled until the 14-day gate, MUFAP cross-validation, discrepancy quarantine, parser drift, malware scanning, and object-retention controls are independently proven.

# Evidence appendix

## A1

- Code read: `apps/mobile/lib/src/data/http_today_repository.dart` caches a briefing and labels fallback `Offline cached briefing`; `manual_money_store.dart` persists unresolved local transactions and retries them.
- No real-device execution evidence. Result: **UNVERIFIED/BLOCK**.

## A2

- `flutter build web --release` → exit 0; output `✓ Built build/web` with WASM/font warnings.
- `rg -a ... build/web/main.dart.js` → matched `Mock briefing`, `Mock Xe FX snapshot`, `Wise USD`, and `Al Meezan`.
- Source search → `USE_MOCK` defaults true across production repositories.
- Result: **FAIL**.

## A3

- Read `apps/mobile/lib/src/app/sprout_app.dart`: initial location `/today`; no router redirect/guard.
- Result: **FAIL**.

## A4/A5

- No device restart/clock evidence. Result: **UNVERIFIED/BLOCK**.

## A6

- Direct authenticated POST matrix: missing provenance 400; stale-as-fresh 201; source/no-date 400; invalid date 500.
- Result: **FAIL**.

## A7

- `pnpm audit --audit-level=moderate` → `No known vulnerabilities found` (PASS).
- `pnpm test:e2e:local` → 22 assertions passed, including 11-attempt throttle returning 429 (PASS).
- Production config imports with short/default JWT and local default DB credentials → exit 1 with explicit boot errors (PASS).
- Sampled 200/201/400/401/413/500/503 responses carried `X-Request-ID`, HSTS, `nosniff`, and frame protection (PASS for sampled routes, not literally every route).
- Native storage inspection absent (UNVERIFIED/BLOCK).

## B1

- `flutter test` → 22 tests passed, including symmetric nav, 1.3× shell pages, and nav inset tests.
- Full-device visual sweep absent. Result: **PARTIAL/UNVERIFIED**.

## B2

- Executed `calculateWealthHealthScore(fixture)` twice → identical JSON both times; score 58.
- Repository grep found no active API check-in factor, but found a separate legacy nine-factor domain engine and health-impact copy.
- Result: determinism PASS; exclusive eight-factor path UNVERIFIED.

## B3

- Source read and zero-user API result described in blocker 4. Result: **FAIL**.

## B4

- Local E2E asserted two projected incomes have `inCurrentWealth === false` and briefing total excludes them.
- DB sample of 20 briefings: 0 missing paired-change rows; 0 events.
- Result: paired changes/projected income PASS; event durability UNVERIFIED.

## B5

- `wc spec/recurring_money_contract.md` → `No such file or directory`; repository search found no occurrence engine. Result: **FAIL**.

## B6

- `rg` over executable source found no exact `transfer now`, in-app pay, or top-up endpoint; route-pattern search returned none. Result: **PASS locally**.

## B7

- Latest-20 DB query: 20 sampled, 0 banned-phrase rows, 0 gain-exclamation rows, 0 missing paired-change rows, 0 events.
- Nonzero movement query found one summary without its why; validator missed it. Result: **FAIL**.

## B8

- No skip-everything UI run. Result: **UNVERIFIED**, with A3 routing failure.

## C1–C5

- No screenshot/screen-recorded end-to-end execution. Result: **UNVERIFIED**.

## D1

- E2E duplicate transaction retry returned the same transaction ID (PASS for transactions).
- Three-way import replay unavailable because the feature is disabled. Result: **UNVERIFIED**.

## D2

- Direct A→B attempts: holding PATCH 404, holding DELETE 404, session DELETE 404; A own holdings 200 empty. Result: **PASS locally for available object paths**.

## D3

- One concurrent run: goal contributions 100+200 → 300; Quick Adds 11+22 against 1000 → 967; all responses 200/201. Result: **PASS for one run**.

## D4

- Fuzz matrix: negative 400, oversized 413, injection-shaped text 201 as data, absurd date 500, malformed JSON 500. All client 500 bodies were sanitized. Result: **FAIL**.

## D5

- E2E structured import request → 503 `FEATURE_DISABLED`; configuration defaults real valuations and structured imports false. Result: default gates PASS; unreachable external gate UNVERIFIED/not implemented.

## D6

- `pnpm ops:valuation-gate` → exit 1 with the exact counts in blocker 8. Result: **FAIL/AUTOMATIC BLOCK**.

## D7

- `pnpm ops:backup` → exit 0; created `artifacts/backups/sprout-20260714T205035Z.dump`.
- `pnpm ops:restore-smoke -- artifacts/backups/sprout-20260714T205035Z.dump` → `Restore smoke test passed.`
- Local request IDs/security headers and sanitized client 500s passed; deployed TLS/log/PII/shutdown evidence absent.

## E1

- `artifacts/acceptance-traceability.md` exists, but it has no stable test-ID column and mostly maps requirement groups to commands or prose/manual claims. Therefore **every acceptance bullet lacks the required stable, named, passing, committed test mapping**. Unmapped bullet line numbers in `spec/screen_acceptance_criteria.md` are:

  `18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,39,40,41,42,43,44,45,46,47,51,52,53,54,57,58,59,60,64,65,66,67,68,69,70,71,75,81,82,83,84,85,89,90,91,92,93,94,95,96,97,98,99,100,104,105,106,108,109,111,112,113,114,115,119,120,121,122,123,128,129,130,131,132,133,134,135,139,140,141,145,146,147,148,149,150,151,152,153,157,158,159,160,161,162,163,164,168,169,170,171,172,173,174,175,176,177,178,182,183,184,185,186,187,188,189,193,194,195,196,197,198,202,203,204,205,206,207,208,209,210,211,212,213,214,216,218,223,224,225,226,227,228,232,233,234,235,236,240,241,242,243,244,245,246,247,248,250,253`.

## E2

- `pnpm check` → exit 0; all workspace TypeScript builds/typechecks passed.
- `flutter analyze` → `No issues found!`.
- `flutter test` → `All tests passed!` (22 tests).
- `pnpm audit --audit-level=moderate` → no known vulnerabilities.
- First E2E attempt failed `ECONNRESET` because no API remained listening; after explicitly starting `pnpm dev:api`, the rerun passed all 22 assertions.
- No CI workflow/evidence was found. Result: local PASS; CI **UNVERIFIED**.

## E3

- Human/deployment handoffs are listed in the dedicated section above; none are counted as passes.

## Additional database evidence

- Post-audit local counts: `users=23`, `goals=32`, `holdings=15`, `transactions=31`, `daily_briefings=19`, `wealth_snapshots=19`, `wealth_events=0`, `job_runs=30` before later fuzz/audit seed users increased some tables.
- `wealth_snapshots` has a unique `(user_id,date)` index and non-null paired change columns.
- The audit created only isolated local test users/data and build/ops artifacts; no source code was changed.

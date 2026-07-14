BLOCK
The release is blocked by a failed auth-abuse regression, an objectively failed valuation burn-in gate, and unverified trust-critical UI, isolation, privacy, provenance, and money-math journeys.

# Blockers

1. A7 — rapid failed-login throttling failed independently.

   Reproduction: run `pnpm test:e2e:local`. The run passed the preceding API, briefing, projected-income, and import-gate assertions, then failed at `repeated login attempts are throttled`; the script sends 11 invalid logins and the final response was not HTTP 429. The implementation declares a 10-attempt/15-minute bucket in `apps/api/src/auth/routes.ts`, but the required behavior is not evidenced by the release test. This is an automatic Section A block.

2. A7 — token-at-rest requirement is not verified and the code exposes an unsafe path.

   Evidence: `apps/mobile/lib/src/data/auth_store.dart:33-37` reads access and refresh tokens from `SharedPreferences` on web; lines 42-47 migrate them from `SharedPreferences`; lines 134-139 fall back to `SharedPreferences` in non-release mode. The requested actual emulator/device storage inspection was not performed. The production hardening acceptance requires encrypted refresh-token storage. Marked blocker because privacy/security evidence is incomplete.

3. D6 — valuation burn-in gate failed.

   Evidence: `artifacts/valuation-burn-in-2026-07-14.json` reports `dailyJobs.total=24`, `succeeded=22`, `failed=2`, `distinctDates=0`, `snapshots.distinctDates=2`, `staleOrUnavailable=1`, `duplicates=11`, `observations.navDates=0`, `observations.fxDates=0`, `crossValidationImplemented=false`, `prerequisitesPassed=false`, and `gatePassed=false`. The specification requires at least 14 consecutive qualifying days, zero silently stale snapshots, zero unresolved discrepancies, and MUFAP cross-validation before real valuation exposure. Automatic Section D6 block.

4. B3 — missing-data score behavior is not proven and the pipeline substitutes invented-looking defaults.

   Evidence: `apps/api/src/services/briefing-pipeline.ts:365-378` hard-codes monthly expenses to `100000`, contribution consistency to `0.5`, bills coverage to `1`, and debt ratio to `0`. No executed golden test demonstrated the minimum-factor replacement or four-factor proportional redistribution required by `spec/scoring_model.md`. This is trust-critical money/score math and therefore a blocker.

5. B4/B7 — durable wealth-event and briefing integrity is unverified in the live database.

   Evidence: a direct PostgreSQL query returned `daily_briefings|18`, `wealth_snapshots|18`, but `wealth_events|0`. The acceptance contract requires every movement to have a plain-language `why`, and the tone validator must be sampled against stored outputs. No 20-briefing tone sample or event-level database evidence was produced. Trust-critical unverified item; blocker.

6. D2 — tenant isolation is unverified.

   No direct cross-tenant API test was run for another user's holdings, briefing, and sessions. Since tenant isolation is explicitly an automatic blocker, this missing evidence blocks release.

7. A1/A2/A3/A4/A5/A6/B5/B8/C1-C5/D1/D3/D4/D5/D7 — required real-user, adversarial, and device journeys are unverified.

   No screen-recorded Flutter UI journey was produced for offline recovery, zero-holding Insights, onboarding deep-link enforcement, privacy masking after restart, same-day/next-day completion durability, API-boundary provenance rejection, recurring-liability timezone math, persona journeys, replay/concurrency/fuzz tests, gate-service outage, or graceful shutdown. The instructions explicitly classify unverified provenance, isolation, privacy, and money math as blockers.

# Beta-acceptable defects

- The release is not eligible for this category while automatic blockers remain.
- Local static/build evidence is positive but does not substitute for the missing production and real-device gates.
- The release traceability artifact itself says real valuation exposure, production secrets/TLS, external connector operations, recurrence contracts, and device/store configuration remain pending.

# Unverified items

- A1: no end-to-end Flutter outage/reconnect/sync-once run with DB duplicate check.
- A2: no fresh zero-holding user UI run and no per-user stored-insight query; existing DB event count is zero, not proof of correctness.
- A3: no UI registration/onboarding/deep-link manipulation run.
- A4: no real-device restart plus rendered-output grep for all masked amount surfaces.
- A5: no force-close, clock-change, and next-day durability run.
- A6: no three malformed/stale/missing-date valuation POSTs executed at the API boundary, nor missing-FX exclusion query.
- B1: widget coverage exists, but no screenshot/evidence verifies the exact shell and all 1.3× surfaces.
- B2: no golden-fixture repeat/diff run; no complete proof that only eight defined factors can change score. `packages/domain/src/financial-health-score.ts` remains a second score implementation with different inputs/weights and check-in-era action text, requiring ownership/path analysis.
- B3: no missing-factor fixtures.
- B4: no query proving all stored WealthSnapshots carry both changes and all events carry non-empty `plainWhy`.
- B5: recurring money and non-PKT timezone behavior not evidenced.
- B6: repository grep found regulatory/spec/example payment language (for example `packages/shared/src/mock-learn.ts` and `packages/shared/src/mock-today.ts`), but no complete copy review or endpoint initiation test was run.
- B7: no 20-output DB sample and validator result.
- B8: no skip-everything UI completion run.
- C1-C5: no requested fresh-account, screenshot/screen-recorded UI evidence.
- D1: no three-way import replay with DB counts.
- D2: no cross-user token tests.
- D3: no simultaneous goal/Quick Add test.
- D4: no oversized/negative/absurd-date/injection fuzz run with log review.
- D5: no gate-service-unreachable fail-closed run.
- D7: no TLS deployment, request-log correlation, PII/stack-trace client test, or graceful mid-request shutdown test.
- E2 CI green status is unverified; only local commands were run.
- E3 real-device performance, biometrics, notification delivery, accessibility, store configuration, deployed secrets, signing, TLS/origins, object storage scanning, connector/webhook operations, and monitoring/alerting remain human/deployment gates.

# Human handoffs

- Test on a real low-end Android device at 1.3× text scale, including jank, offline recovery, storage inspection, permissions, accessibility, notifications, deep links, and app restart.
- Test iOS behavior without SMS capture; verify biometric/device unlock on supported hardware.
- Supply production bundle IDs, signing certificates/profiles, store identities, privacy/support URLs, and release configuration.
- Verify deployed secrets manager, TLS, database credentials, CORS/origins, encrypted backup retention, restore in an isolated environment, request IDs, sanitized errors, monitoring, and alerting.
- Keep real NAV/FX exposure disabled until 14 qualifying consecutive days and MUFAP cross-validation are evidenced.
- Keep statement object storage, malware scanning, external connectors, and webhooks disabled until their operational controls are proven.
- Define and approve recurring-income/liability occurrence, missed-occurrence, and timezone contracts before enabling them.

# Evidence appendix

| Check | Command / evidence | Result |
| --- | --- | --- |
| A7/E2 | `pnpm test:e2e:local` | FAIL: repeated login attempts were not observed as 429; earlier assertions passed. |
| E2 | `pnpm check` | PASS: all workspace builds and TypeScript typechecks completed. |
| E2 | `pnpm audit --audit-level=moderate` | PASS: No known vulnerabilities found. |
| E2 | `cd apps/mobile && flutter analyze` | PASS: No issues found. |
| E2 | `cd apps/mobile && flutter test` | PASS: 22 tests passed. |
| E2 | `cd apps/mobile && flutter build web --release` | PASS build; emitted third-party Rive WASM dry-run compatibility warnings and a MaterialIcons asset warning. |
| D6 | `artifacts/valuation-burn-in-2026-07-14.json` | FAIL: gatePassed false; 0 NAV dates, 0 FX dates, 0 distinct job dates, 2 failed jobs, 11 duplicate snapshots, no cross-validation. |
| D7 | `pnpm ops:backup` | PASS: created `artifacts/backups/sprout-20260714T204549Z.dump`. |
| D7 | `pnpm ops:restore-smoke -- artifacts/backups/sprout-20260714T204549Z.dump` | PASS: isolated restore smoke test passed. |
| D7 | `curl -si http://127.0.0.1:8787/health` | PASS local headers: HSTS, X-Content-Type-Options, X-Frame-Options, Referrer-Policy, and X-Request-ID present. This is local-only, not deployed TLS evidence. |
| DB | `docker compose exec -T postgres psql -U sprout -d sprout -Atc ...` | `users=22`, `daily_briefings=18`, `wealth_events=0`, `wealth_snapshots=18`, `holdings=14`, `transactions=29`, `job_runs=29`. |
| A7 | `apps/api/src/auth/rate-limit.ts` and `apps/api/src/auth/routes.ts` | Code declares 10 login attempts/15 minutes, but executed required test did not confirm 429. |
| A7 | `apps/mobile/lib/src/data/auth_store.dart` | Evidence of SharedPreferences token read/migration/web/fallback paths; device inspection not performed. |
| B3 | `apps/api/src/services/briefing-pipeline.ts:365-378` | Hard-coded missing-data inputs observed; required partial-score behavior not evidenced. |
| E1 | `spec/screen_acceptance_criteria.md` and `artifacts/acceptance-traceability.md` | Traceability is a high-level table without stable test IDs for each acceptance bullet. All criteria in sections App-Level, Today, Money, Insights, Navigation, Goals, Design System, Quick Add, Settings, Onboarding, Information Gathering, Sprout Explains, AI Briefing, Notifications, and Production Hardening therefore have no independently named per-bullet passing committed test in the artifact. |

## Traceability gaps

The acceptance matrix has no stable test ID column and does not map every bullet in `spec/screen_acceptance_criteria.md` to a named committed test. The unmapped criteria include, at minimum, lines 18–33, 39–85, 89–100, 104–115, 119–124, 128–135, 139–141, 145–153, 157–164, 168–178, 182–189, 193–198, 202–219, 223–228, 232–236, and 240–254. These are listed as gaps, not passes.


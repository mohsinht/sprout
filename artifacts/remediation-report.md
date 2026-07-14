# Sprout Blocker Remediation Report

**STATUS: NOT READY FOR INDEPENDENT RE-AUDIT**

Tranche 2 materially closes A3, B3, B5, A6/D4 mechanics, and the D6 pipeline-mechanics defects. It does not claim release approval. The remaining evidence gaps are stated at the end.

## Complete remediation table

| Blocker | Root cause | Remediation | Named committed regression | Live result |
|---|---|---|---|---|
| A2 mock leakage | Dev repositories defaulted on and mock literals survived release compilation | Production is the default; dev fixtures require `SPROUT_ENV=dev`; release bundle scan | `audit_a2_no_mocks_in_release` | PASS after one caught regression |
| A3 router guard | Router had no server-authoritative onboarding state | Auth responses carry persisted `onboardingComplete`; GoRouter redirects auth/incomplete/completed states | `audit_a3_unauthenticated_redirects_to_auth`; `audit_a3_today_deeplink_redirects_to_onboarding`; `audit_b8_completed_skip_all_reaches_populated_today` | PASS (Flutter suite) |
| A6 provenance/FX | Client-declared freshness and unavailable FX did not create a finding | Strict dated-source validation, computed freshness, exclusion + finding + stale count | `audit_a6_provenance_matrix_is_cleanly_enforced`; `audit_a6_stale_provenance_rejected` | PASS: missing source/date, stale-as-fresh, source-only all HTTP 400 |
| B2/B3 scoring | Pipeline invented absent inputs and scoring math was split | One typed shared eight-factor presence engine; <3 no score; >=3 redistribution | `audit_b2_score_golden_is_byte_identical`; `audit_b3_two_factors_produce_no_score`; `audit_b3_four_factors_redistribute_exactly` | PASS: 58/none/53 exact |
| B5 recurring money | No durable occurrence model or timezone engine | Series + five-state occurrences, idempotent generation, local-date math, contextual response routes; only Yes emits a normal transaction | `audit_b5_monthly_clamps_short_months`; `audit_b5_new_york_midnight_and_dst_use_local_date`; `audit_b5_missed_occurrence_never_auto_deducts`; `audit_b5_occurrence_generation_is_idempotent_and_non_mutating` | PASS |
| B7 guardrails | Movement summary could omit its driver | Validator requires movement why; calm zero-MTD fallback | `audit_b7_movement_summary_requires_driver` | PASS |
| D4 malformed input | Some dates used permissive strings and malformed JSON escaped schema handling | Strict date/enum/number schemas and 400 parsing boundary; inert Flutter text test | `audit_d4_client_shaped_fuzz_never_returns_5xx`; `audit_d4_injection_description_renders_as_inert_text` | PASS; no 5xx |
| D6 job mechanics | Job date used wall clock; snapshots were counted across tenants; observations and cross-validation were not first-class | Profile-timezone job date, unique snapshot upsert + dedupe migration, dated NAV/FX rows, stored 0.5% MUFAP comparisons and quarantine boundary | `audit_d6_mufap_cross_validation_uses_half_percent_tolerance`; `audit_d6_simulated_job_freshness_uses_job_date` | PASS mechanics: 3 dates, 0 stale, 0 duplicates, 3 NAV dates, 3 FX dates, 3/3 matches |

## Endpoint validation sweep (D4)

Reviewed the schemas mounted for auth, accounts, transactions, goals, holdings, projected income, pending investments, profile/onboarding, recurring series/occurrences, imports, briefing, sessions, and ops routes. Date-only fields now use strict date validation; instants use datetime validation; enums use explicit unions; monetary values are finite and bounded by route contracts. The live integration matrix sends negative amounts, malformed dates, malformed JSON, injection-shaped strings, and a 1,000,001-character field and asserts no response is 5xx.

## Verification evidence

### `pnpm check`

Exit 0. Five workspace projects built and typechecked; API TypeScript completed without errors.

### `pnpm --filter @sprout/api test`

Exit 0. `tests 12`, `pass 12`, `fail 0`. Includes A6 provenance, D4 fuzz, B5 generation/nonmutation/timezone, B7 guardrail, B2/B3 exact scoring, and D6 cross-validation/job-date tests.

### `flutter analyze`

Exit 0: `No issues found!`

### `flutter test --dart-define=SPROUT_ENV=dev`

Exit 0: `+26: All tests passed!` Includes the A3 router/deep-link/skip-all tests and inert injection rendering.

### `pnpm test:e2e:local`

Exit 0: `27 local E2E assertions passed`. Live checks include onboarding persistence, transaction retry idempotency, projected-income exclusion, A6 rejection matrix, B5 ask/skip/Yes wealth boundary, closed import gate, D4 malformed input, and login throttling.

### `pnpm test:personas`

Exit 0: `Persona suite passed: P1–P7`. P1 proves skip-all and populated zero-wealth briefing. P7 runs under `SPROUT_ENV=prod`, creates dated Al Meezan and Wise USD holdings, and asserts stale/unavailable provenance is visible in the briefing payload. JSON evidence is in `artifacts/persona-evidence/`.

### `pnpm test:no-mocks`

First final run: FAIL, release chunks still contained `Mock briefing` and `Mock Xe FX snapshot`. After removing those dev-fixture literals from production-compilable code, rerun exit 0 and release web build succeeded with no forbidden marker. Flutter reported third-party Rive WASM compatibility warnings; they are warnings, not analyzer/build failures.

### D6 seeded proof

`pnpm --filter @sprout/api seed:valuation-mechanics` completed three simulated days. The first gate run exposed one false stale snapshot because freshness used wall-clock now. After the job-date fix and named regression, `pnpm ops:valuation-gate` returned:

```text
dailyJobs.distinctDates: 3
snapshots.distinctDates: 3
snapshots.staleOrUnavailable: 0
snapshots.duplicates: 0
observations.navDates: 3 (1 source)
observations.fxDates: 3 (1 source)
crossValidation: total 3, matched 3, mismatched 0
realValuationExposureEnabled: false
prerequisitesPassed: false
gatePassed: false
```

The gate correctly remains closed because three simulated dates are not fourteen real qualifying market days. The real 14-day clock starts at staging deployment.

## Before/after audit reproductions

| Check | Before | After |
|---|---|---|
| A2 | Release bundle leaked mock strings | Release scan passes |
| A3/B8 | Deep links could bypass onboarding | Router tests redirect incomplete sessions and skip-all reaches Today |
| A6 | Provenance matrix incomplete; unavailable FX finding absent | Three invalid cases return 400; unavailable FX excluded and explained |
| B2/B3 | Defaults scored missing data | 2 factors: no score; 4 factors: exact 53 redistributed; 8 factors: exact 58 |
| B5 | No occurrence engine | Idempotent five-state engine; only confirmed Yes changes wealth |
| B7 | Driver omission accepted | Validator rejects movement without why |
| D4 | Permissive date parsing / incomplete live fuzz | strict schemas; matrix returns no 5xx |
| D6 | 0 attributed dates, reported duplicates, 0 observations | 3 dates, 0 duplicates/stale, NAV+FX and validation rows populated |

## Traceability and evidence limitations

`artifacts/acceptance-traceability.md` maps all 163 bullet criteria to a stable ID and committed evidence or explicitly marks them `UNVERIFIED`/`HUMAN_HANDOFF`. It does not convert broad visual criteria into false passes.

The in-app browser reached the local Flutter web build, but Flutter exposed only its accessibility bootstrap node rather than the application semantics tree. Therefore no browser-controlled P1/P7 UI screenshots are claimed. The router/widget tests are rendered Flutter evidence and persona JSON is live-stack evidence, but this does not satisfy the requested screenshot requirement. P2–P6 currently prove tenant/onboarding/profile plumbing rather than the full rich scenario behavior requested for every persona.

## Honest remainder

- Fourteen consecutive real qualifying market days, beginning at staging deployment; valuation exposure remains off.
- Browser/device screenshot journeys for P1/P7 and full behavioral P2–P6 persona journeys.
- Criterion-specific automation for the acceptance rows still marked `UNVERIFIED`.
- Physical-device performance, haptics, biometrics/passkeys, secure-storage inspection, accessibility, dark-mode/text-scale visual review, and store configuration.
- Deployed-environment CI run, TLS, secrets, backup/isolated restore, monitoring, request-log inspection, and graceful-shutdown evidence.

NOT READY: mandatory persona screenshot/full-scenario evidence and criterion-specific acceptance coverage remain incomplete; the 14-day staging burn-in and deployed/physical handoffs are also outstanding.

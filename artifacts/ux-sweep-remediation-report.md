# Sprout UX Sweep Remediation Report

## Part 0 — Reconciliation (recorded before remediation)

The previously ordered remediation did not land as a complete, verifiable change set. The evidence shows a mixture of an internally contradictory implementation, one later regression, and work that was never implemented:

| Item | Reconciliation | Evidence |
| --- | --- | --- |
| Salary strip on Today | **Never removed.** Commit `394ffa54` both declared the Today layout locked and introduced `_SalaryStrip`; no branch or later commit contains the ordered removal. The current 13-part acceptance list forbids this extra element. | `git blame` attributes the strip to `394ffa54`; `git log --all -S'_SalaryStrip'` finds only its introduction. Current screenshot: [before — zero-data Today](ux-sweep/Today/today-zero-data.png). |
| Zero-data mascot and collision | **Regressed/incomplete.** Commit `59d0e846` added the score-unavailable sentence inside the mascot's fixed 92×92 `Stack`, which makes text render over the mascot. The same path maps score-unavailable to `SproutMascotState.happy`; the canonical `sprout-happy.png` asset visibly contains confetti, so the non-celebration state was never guarded from celebratory art. | `git show 59d0e846` and current `_MascotHero`; [before screenshot](ux-sweep/Today/today-zero-data.png). |
| Floating-nav clearance | **Partially implemented, not structurally fixed.** `NavMetrics` centralizes the arithmetic, but each screen still owns and applies its own scroll padding. The existing test asserts the helper's numeric result rather than rendering each tab and proving its final content clears the real floating nav. This allowed visible failures on Today, Money, and Settings. | Current `nav_metrics.dart`, per-screen padding call sites, and [Today](ux-sweep/Today/today-zero-data.png), [Money](ux-sweep/Money/money-populated.png), [Settings](ux-sweep/Settings/root.png). |
| `seed:ux-states` | **Never implemented.** There is no root script, API script, source file, or historical commit containing `seed:ux-states`. | `package.json`, `apps/api/package.json`, and `git log --all -S'seed:ux-states'` have no implementation. |
| Previous remediation report | **Missing.** The requested `artifacts/ux-remediation-report.md` is absent, so earlier claimed evidence cannot be reconciled against files or test output. | Filesystem check on 2026-07-15. |

### Root process failure

The prior effort did not have a single committed acceptance gate tying the locked structure, real rendered nav clearance, state seeding, and screenshot evidence together. Some code was described as remediation even though its test only checked a helper, while other ordered work left no implementation or report. “Implemented,” “covered by CI,” and “running in the real app” therefore diverged.

### Spec conflict

`spec/phase1_execution_plan.md` still asks for a Today salary strip, but the newer `spec/product_spec.md` and `spec/screen_acceptance_criteria.md` lock Today to 13 parts and explicitly allow no extra element. Per the remediation instruction and spec precedence, this work follows the newer locked acceptance contract and removes the strip; salary timing remains in contextual tiles, Money, and Settings.

### Recurrence guards required by this remediation

- A CI widget test will assert the exact 13 Today part keys in order and explicitly fail if `today-salary-strip` appears.
- Golden tests will render the complete zero-data Today in light/dark at 1.0×/1.3×.
- Golden tests will render all four real tab scroll surfaces with the floating nav in light/dark at 1.0×/1.3× and prove the final content is above the nav.
- `pnpm seed:ux-states` will be a real root command backed by the API database, with deterministic credentials and state inventory output.

## Remediation results

Implementation and verification results follow after Part 0 so the reconciliation above remains the pre-fix record.

## Part 1 — Zero-data Today

| Finding | Root cause | Fix | Test / evidence |
| --- | --- | --- | --- |
| Mascot covered the summary | The sentence was positioned inside the mascot's fixed `Stack`. | Mascot, wealth, movement, read, and action are independent stacked layout parts. | `UX-L1-TODAY-ZERO-*` goldens: [light 1.0×](../apps/mobile/test/goldens/UX-L1-TODAY-ZERO-light-1x0.png), [light 1.3×](../apps/mobile/test/goldens/UX-L1-TODAY-ZERO-light-1x3.png), [dark 1.0×](../apps/mobile/test/goldens/UX-L1-TODAY-ZERO-dark-1x0.png), [dark 1.3×](../apps/mobile/test/goldens/UX-L1-TODAY-ZERO-dark-1x3.png). Running app: [after](ux-sweep-remediation/seeded-states/UX-SEED-zero-data.png); [before](ux-sweep/Today/today-zero-data.png). |
| Confetti appeared without completion | Landing selected mascot art from health score; `confident` resolves to celebration art. | Today landing always uses the calm, static wave. Celebration states remain available to onboarding handoff and completed-action surfaces only. | `UX-P0-TODAY-13` asserts `peek`, `animate == false`, and `playOnMount == false`. Down-day [before](ux-sweep-remediation/before/UX-P0-CONFETTI-down-day.png) / [after](ux-sweep-remediation/seeded-states/UX-SEED-down-day.png). |
| Salary strip was a 14th part | The locked-layout commit itself introduced the strip. | Removed it. Salary timing remains in context, Money, and Settings. | `UX-P0-TODAY-13` asserts exactly 13 ordered part keys and fails on `today-salary-strip` or “Salary in”. |
| Zero-data action reviewed nonexistent movement | The normal recommendation path was reused for empty wealth. | “Add your first cash entry” opens Quick Add; its impact is “Start with money you can see”; the 20-second caption is absent. | `UX-P0-TODAY-13`; [running zero-data Today](ux-sweep-remediation/seeded-states/UX-SEED-zero-data.png). |
| Zero values and explanations were mechanical | Formatter kept a decimal and empty movement used punctuation placeholders/redundant clauses. | Whole PKR amounts have no decimal; lakh/crore is used only for magnitude; empty movement says “No movement yet”; Why uses one warm sentence. | `UX-C2-PKR-01`; four zero-data goldens. |
| Greeting repeated “Salaam” | The API greeting parser stripped only English time-of-day greetings. | It now extracts a name from either “Salaam, …” or “Good morning/afternoon/evening, …”. | `UX-C1-TODAY-GREETING`; all seeded screenshots. |
| Offline no-cache looked like saved data | The local store's zero-value Cash shell was treated as meaningful data. | Zero-value shells are zero-data; copy says nothing is saved and the first action is cash entry. | [offline no-cache](ux-sweep-remediation/seeded-states/UX-SEED-offline-no-cache.png). |

## Part 2 — One global nav-clearance contract

All four tab scroll surfaces now go through `SproutTabScrollView`. It reserves `floating nav height + safe area + spacing token`, and owns the end-of-content sentinel used by tests. Today's separate balance-hidden scroll path also uses it. Per-screen bottom-padding ownership was removed from Today and `SproutPage` consumers.

The first golden run correctly failed because Money had independent horizontal overflows at 360px. Account balances, budget rows, budget summary, and goal amounts were made flexible/wrappable; the suite then passed generation and a clean comparison.

Evidence: 16 `UX-L2-NAV-*` goldens cover Today, Money, Insights, and Settings in both themes and both scales. Each test measures the real final-content sentinel against the real floating-nav rectangle before comparing pixels. Examples: [Today light 1.3×](../apps/mobile/test/goldens/UX-L2-NAV-today-light-1x3.png), [Money dark 1.3×](../apps/mobile/test/goldens/UX-L2-NAV-money-dark-1x3.png), [Settings light 1.0×](../apps/mobile/test/goldens/UX-L2-NAV-settings-light-1x0.png). CI already runs every `golden`-tagged test on macOS in `.github/workflows/ci.yml`, so these files are now an active gate rather than dormant evidence.

## Part 3 — Quick Add

Root cause: every category brought its own saturated color and the two alternate tasks shared primary visual weight. Validation inserted a new line into the layout, moving Save.

Fixes:

- All expense chips use one muted mint tint family; icons and labels carry category identity.
- Local categories remain unchanged: Zakat, Sadaqah, Committee.
- “I got paid” and “Import” are quiet secondary rows at the bottom.
- “Import statement” is shortened to “Import”.
- Expense and income paths reserve a fixed validation slot, so Save does not move.

Tests/evidence: `UX-L1-QUICK-VALIDATION` measures Save before and after the error; [before](ux-sweep/QuickAdd/expense-sheet.png), [after](ux-sweep-remediation/after/UX-F4-QUICK-ADD.png).

## Part 4 — Money honesty

Root cause: the populated budget component inferred comfort solely from a zero progress ratio, so no income and no spending looked “comfortable.” It also rendered three nearly identical zero amounts.

Fix: a budget with no income/spending/safe-to-spend/remaining now renders only: “No budget picture yet — log income and spending to build one.” It has no health pill or pace judgment. Populated summaries use one “PKR … left to spend” line. All PKR output uses the shared no-decimal formatter.

A copy guard rejects unsupported reassurance such as “Looking comfortable,” “Nice pace,” “On track,” and “Budget health” for an empty financial state. `UX-S1-MONEY-01` tests the accepted and rejected strings. Evidence: [before](ux-sweep/Money/money-populated.png), [after](ux-sweep-remediation/after/UX-S1-MONEY-ZERO.png).

## Part 5 — Settings

Reconciliation of blocked controls:

| Control | Before remediation | Result |
| --- | --- | --- |
| Reduce motion | Existed lower on the screen but was not captured by the sweep. | Retained and visible under App preferences. |
| Balance visibility | Existed inside the privacy promises panel. | Moved into its own control section; privacy promises remain promises. |
| Delete imported data | Existed lower on the screen. | Retained with consequence copy: manual entries stay. |
| Language | Absent. | Added English/Urdu selector and profile locale sync. |
| Streak freeze/repair | Absent. | Added status plus a real protection-reminder switch; repair eligibility copy is explicit. |
| Export | Absent. | Added authenticated `/v1/profile/export`; export excludes credentials/tokens and copies a readable JSON record locally. |

The privacy surface is now a plain panel with one “You're in control” line and four scannable promises. Salary timing is an offer: “Set your salary date so Sprout can celebrate payday.”

Evidence: [privacy before](ux-sweep/Settings/privacy-preferences.png), [privacy after](ux-sweep-remediation/after/UX-F1-SETTINGS-PRIVACY.png), [preferences and streak](ux-sweep-remediation/after/UX-I2-SETTINGS-CONTROLS.png), [export/delete](ux-sweep-remediation/after/UX-I5-SETTINGS-DATA-CONTROLS.png), [Settings root](ux-sweep-remediation/after/UX-L2-SETTINGS-ROOT.png).

## Part 6 — Coverage unblocker

`pnpm seed:ux-states` now seeds the Docker-local PostgreSQL database through the real API schema with mocks off. The root command is deliberately pinned to the local Sprout database; direct use of the API script refuses a non-local database unless `ALLOW_REMOTE_UX_SEED=true` is explicitly set for an intentional test database.

The command creates 12 deterministic accounts and prints their credentials:

| State | API proof | Screenshot |
| --- | --- | --- |
| zero-data | score `insufficient_data`, movement 0 | [UX-SEED-zero-data](ux-sweep-remediation/seeded-states/UX-SEED-zero-data.png) |
| thin-wealth | score available, cash PKR 1.25 lakh | [UX-SEED-thin-wealth](ux-sweep-remediation/seeded-states/UX-SEED-thin-wealth.png) |
| good-day | movement +45,000 | [UX-SEED-good-day](ux-sweep-remediation/seeded-states/UX-SEED-good-day.png) |
| down-day | movement -38,490 | [UX-SEED-down-day](ux-sweep-remediation/seeded-states/UX-SEED-down-day.png) |
| stale | endpoint freshness `stale` | [UX-SEED-stale](ux-sweep-remediation/seeded-states/UX-SEED-stale.png) |
| insufficient-score | score `insufficient_data` | [UX-SEED-insufficient-score](ux-sweep-remediation/seeded-states/UX-SEED-insufficient-score.png) |
| offline-with-cache | cached briefing + injector | [UX-SEED-offline-with-cache](ux-sweep-remediation/seeded-states/UX-SEED-offline-with-cache.png) |
| offline-no-cache | login-only fixture + all financial requests blocked | [UX-SEED-offline-no-cache](ux-sweep-remediation/seeded-states/UX-SEED-offline-no-cache.png) |
| briefing-failed | freshness `local_fallback`, one failed job | [UX-SEED-briefing-failed](ux-sweep-remediation/seeded-states/UX-SEED-briefing-failed.png) |
| quiet-week | Insights `quiet:0` | [UX-SEED-quiet-week](ux-sweep-remediation/seeded-states/UX-SEED-quiet-week.png) |
| populated-insights | Insights `populated:3` | [UX-SEED-populated-insights](ux-sweep-remediation/seeded-states/UX-SEED-populated-insights.png) |
| uncertain-transactions | one `needsReview` transaction | [UX-SEED-uncertain-transactions](ux-sweep-remediation/seeded-states/UX-SEED-uncertain-transactions.png) |

Every account returned HTTP 200 for login and briefing through the local API. The distinguishing assertions above were checked after the final seed.

Sweep controls, active only with `SPROUT_ENV=sweep`:

- `SPROUT_SWEEP_THEME=light|dark`
- `SPROUT_SWEEP_TEXT_SCALE=1.0|1.3`
- `SPROUT_SWEEP_OFFLINE=true|false`
- web URL `?sweepOffline=true`; the no-cache login fixture additionally uses `sweepOfflineAllowLogin=true`, which permits only `/v1/auth/login` before blocking all financial endpoints.

Onboarding's visible “Continue” and “Just call me friend” controls now expose those exact button labels to accessibility semantics. `UX-A4-ONBOARDING` verifies both.

## Part 7 — Verification and before/after closure

| Sweep finding | Before | After / guard |
| --- | --- | --- |
| 1. Today collision/wrong action | [before](ux-sweep/Today/today-zero-data.png) | [after](ux-sweep-remediation/seeded-states/UX-SEED-zero-data.png); four `UX-L1-TODAY-ZERO` goldens |
| 2. Today nav clearance | [before](ux-sweep/Today/today-zero-data.png) | `UX-L2-NAV-Today` in four matrix cells |
| 3. Settings nav clearance | [before](ux-sweep/Settings/root.png) | [after](ux-sweep-remediation/after/UX-L2-SETTINGS-ROOT.png); `UX-L2-NAV-Settings` in four cells |
| 4. Quick Add hierarchy | [before](ux-sweep/QuickAdd/expense-sheet.png) | [after](ux-sweep-remediation/after/UX-F4-QUICK-ADD.png) |
| 5. Import truncation | [before](ux-sweep/QuickAdd/income-path.png) | [after](ux-sweep-remediation/after/UX-F4-QUICK-ADD.png) |
| 6. Money nav seam | [before](ux-sweep/Money/money-populated.png) | `UX-L2-NAV-Money` in four cells; [running Money](ux-sweep-remediation/after/UX-S1-MONEY-ZERO.png) |
| 7. Money zeros/fabricated pace | [before](ux-sweep/Money/money-populated.png) | [after](ux-sweep-remediation/after/UX-S1-MONEY-ZERO.png); `UX-C2-PKR-01`, `UX-S1-MONEY-01` |
| 8. Quiet/populated Insights ambiguity | [previous quiet state](ux-sweep/Insights/insights-populated.png) | [quiet](ux-sweep-remediation/seeded-states/UX-SEED-quiet-week.png) and [populated](ux-sweep-remediation/seeded-states/UX-SEED-populated-insights.png) are separate fixtures |
| 9. Settings privacy density/missing controls | [before](ux-sweep/Settings/privacy-preferences.png) | [privacy](ux-sweep-remediation/after/UX-F1-SETTINGS-PRIVACY.png), [controls](ux-sweep-remediation/after/UX-I2-SETTINGS-CONTROLS.png) |
| 10. State coverage blocked | [19/352 report](ux-sweep-report.md) | 12 real state accounts, deterministic matrix controls, offline injector, and 12 running screenshots |

Final automated results:

- Flutter analyze: pass, zero issues.
- Flutter non-golden suite: 28/28 pass.
- New remediation widget/unit tests: 6/6 pass.
- Remediation goldens: 20/20 pass while regenerating, then 20/20 pass as a clean comparison.
- API tests: 20/20 pass.
- API and shared TypeScript typechecks: pass.
- Release no-mocks build/check: pass (`audit_a2_no_mocks_in_release`).
- Exact `pnpm seed:ux-states`: pass against local PostgreSQL.
- Final 12-account API contract check: pass.

This report records implementation readiness only. It does not approve the UX; the requested fresh full-matrix re-sweep remains the judge.

READY FOR FULL-MATRIX RE-SWEEP

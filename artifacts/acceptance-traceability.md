# Sprout V1 Acceptance Traceability

Last verified: 15 July 2026 (Asia/Karachi)

This artifact records current local release evidence. It does not waive the
operational and real-device gates in `spec/production_hardening.md`.

| Requirement | Automated evidence | Live/manual evidence | Status |
| --- | --- | --- | --- |
| Registration starts onboarding | Local API E2E checks `onboardingComplete` before/after onboarding; auth route sends new registrations to `/onboarding` | Fresh registration routing inspected in code | Pass |
| Profile and settings persist | `pnpm test:e2e:local` patches and reads income type, salary day, currency, motion, balance privacy, and all notification classes | Settings UI rendered with editable name, income type, salary day, expected-income controls, security, and five reminder controls | Pass |
| Manual account and transaction flow | Local E2E creates an account, income, expense, and duplicate retry; asserts exact final balance | Money and Today show the resulting local account picture | Pass |
| Offline Quick Add retry safety | Pending non-UUID transactions are retried before server state replaces local state; server dedupe returns the existing transaction for a retry | Offline Today and reconnect were exercised with the API stopped and restarted | Pass |
| Offline daily check-in | Flutter tests; Today repository cache and device-data fallback | With API stopped, Today rendered saved values and “You are offline” instead of an error | Pass |
| Balance privacy | Flutter widget coverage plus persistent privacy provider | Live toggle masked accounts, budget, goals/investments, transactions, and the entire Today amount view; state synchronized to profile | Pass |
| Today action completion durability | Completion is keyed by PKT-local day and action identity in local persistence | Navigation/rebuild no longer clears the completed state | Pass |
| Personally relevant Insights | Production repository maps only the user's dated briefing events; no event returns the quiet-week state | Live Insights showed quiet week with no Al Meezan/Wise demo claims | Pass |
| Goals work end to end | Local E2E creates, contributes, and reorders goals | Settings exposes add/edit and explicit up/down reorder controls | Pass |
| Multiple dated expected incomes | Local E2E creates two entries, verifies both are excluded from current wealth, and deletes one | Settings adds entries through one-question-at-a-time amount/date steps and communicates exclusion from wealth | Pass |
| Holding provenance | Local E2E rejects fresh PKR cash and accepts manual PKR cash | — | Pass |
| AI briefing contract | Local E2E validates briefing shape and values | Database evidence: `gpt-5.6-luna`, `ai_cost_cents=1` for the E2E user | Pass |
| Auth abuse baseline | Local E2E verifies repeated login attempts return 429; API responses include security headers | — | Pass |
| Device-bound sessions | Local E2E creates two named device sessions, lists them, revokes one, and verifies ownership-scoped removal | Settings exposes signed-in device review; mobile refresh tokens are bound to a persistent random device ID | Pass |
| Biometric/device unlock | `flutter analyze`; Android/iOS platform integration compiles at Dart level | Settings shows a privacy-safe app lock and leaves it unavailable on unsupported web; real-device authentication is still a named manual gate | Code pass; device gate pending |
| Notification contract | API E2E round-trips all five classes; Flutter tests and release web build pass | Settings displays all five classes; mobile service schedules private daily, salary, weekly, and streak reminders with deep links; bill scheduling fails dormant without a bill model | Code pass; device gate pending |
| Import safety | Local E2E verifies structured imports return `FEATURE_DISABLED`; strict extract schemas reject arbitrary OCR/file payloads | Source documents are not retained by the enabled extract path | Pass for disabled V1 profile |
| Valuation safety | `pnpm ops:valuation-gate` reports `gatePassed=false` against real local evidence | Real NAV/FX exposure stays disabled; cross-validation cannot be claimed | Pass (fail-closed) |
| Backup/restore | `pnpm ops:backup`; isolated `pnpm ops:restore-smoke -- <dump>` | Local restore smoke passed | Pass locally |
| Dependency/static quality | `pnpm check`; `pnpm audit --audit-level=moderate`; `flutter analyze`; `flutter test`; `flutter build web --release` | No known npm vulnerabilities; zero Flutter analysis issues; 22/22 Flutter tests | Pass |
| Local services | `/health`, `/ready`, PostgreSQL health, Flutter web at `127.0.0.1:8080` | API and app restarted after outage testing | Pass |

## Release blockers that require real evidence or expanded scope

- The 14-consecutive-day headless NAV/FX valuation burn-in is not complete.
  Real valuation exposure must remain gated until source success, staleness,
  disagreement, correction, and snapshot-gap evidence exists.
- Android and iOS project shells, biometric/device unlock, notification
  scheduling, and bundled fonts are implemented. Android/iOS builds and
  low-end performance, permission, notification-delivery, deep-link,
  biometric, and accessibility checks still require real devices plus an
  Android SDK and complete Xcode installation on the release machine.
- Production secrets manager, deployed TLS/origins, database credentials,
  encrypted backup retention, and monitoring/alerting must be verified in the
  deployment environment. Production config now rejects weak JWT/cron secrets,
  non-TLS databases, local database credentials, wildcard CORS, and local CORS
  origins. Local backup/restore and the incident/deployment runbooks pass.
- Statement object-storage malware scanning and external connector/webhook
  operations are not release-proven. Do not enable those paths for strangers.
- Recurring income frequencies and automatic liabilities (for example rent)
  do not have a V1 calculation/cadence contract. Multiple dated expected
  incomes are implemented; recurrence and automatic deductions remain outside
  V1 until the product spec defines occurrence generation, editing, skipped
  occurrences, timezone rules, and whether a due liability affects cash,
  projected cash, or confirmed wealth.
- The scoring spec requires contribution history, bill coverage, debt pressure,
  and a monthly-expense basis but does not define missing-data behavior. The
  current briefing pipeline still contains provisional score inputs; do not
  treat the composite score as production-approved until those inputs are
  collected or the spec defines an explicit unavailable/partial-score state.
- Store identities, signing certificates/profiles, privacy/support URLs, and
  release signing remain launch-owner inputs. The generated platform shells
  intentionally retain placeholder bundle identifiers and debug signing until
  those values are supplied.

Current verdict: the manual-first V1 core is locally release-candidate quality,
but the application is not approved for an unrestricted production launch
until the blockers above are closed or the corresponding features remain
disabled.

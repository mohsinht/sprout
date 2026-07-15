# Sprout comprehensive harness report

This is a harness construction report, not a release verdict. Statuses below
describe committed verification coverage and known first-run behavior.

| Suite                      | Stable IDs             | Runner                       | Observed status                                              |
| -------------------------- | ---------------------- | ---------------------------- | ------------------------------------------------------------ |
| Golden financial fixtures  | FIX-01..FIX-09         | `pnpm test:golden`           | PASS_LOCAL (9/9)                                             |
| Ledger and recurring money | LED-01..02, REC-01..07 | `pnpm test:money-invariants` | PASS_LOCAL (7 test blocks covering all IDs)                  |
| Insights and WorldFact     | INS-01..04             | `pnpm test:insights`         | PASS_LOCAL (4/4, repeat-safe)                                |
| AI budget/degradation      | AI-01..05              | `pnpm test:ai-budget`        | PASS_LOCAL (5/5)                                             |
| Persona journeys           | P1..P7                 | `pnpm test:personas`         | CI_DEVICE_RUN_REQUIRED; Android target compiles locally      |
| Adversarial API            | ADV-01..07             | `pnpm test:adversarial`      | PASS_LOCAL (7/7 API plus inert-text Flutter assertion)       |
| Ops/pipeline               | OPS-01..03             | `pnpm test:ops`              | PASS_LOCAL (cron, backup/restore, headers, boot refusal)      |

The production no-mocks release precondition passes locally. Database suites
were run against a disposable PostgreSQL 16 instance, never against the
configured shared/deployed database.

## Spec-vs-code conflicts found and corrected

- Added the deterministic `/v1/insights` matcher, versioned templates,
  provenance, relevance filtering, finite cap, quiet state, persistent storage,
  Flutter API repository, and offline cache.
- Added quiet-day AI suppression, a configured daily budget gate, persistent
  canonical input-hash cache, output validation, deterministic fallback, and
  stored model/cost telemetry. With no configured cap, production stays
  deterministic; the code does not invent a financial operating limit.
- Added tenant ownership enforcement for goal ledgers and row locking for
  concurrent goal contributions.
- Added malformed-JSON and PostgreSQL-integer-range handling so adversarial
  transaction payloads do not become 5xx responses.

No backend spec conflict remains from the prior report. The device suite still
has coverage gaps listed below; those are not silently promoted to passing.

## Remaining committed-harness gaps

- P1 does not yet automate the host network cut/reconnect needed to prove an
  offline Quick Add syncs exactly once through Flutter.
- P5 does not yet corrupt/delete a briefing during the device run and assert
  both cached and no-cache local fallback paths.
- P6 captures all four hidden-balance tabs, but the device runner does not yet
  mechanically grep Flutter's rendered semantics for every unmasked currency.
- P7 seeds multi-currency holdings and a goal, but statement reconciliation,
  both goal-editor entry points, reorder, provenance-on-tap, and changed-action
  assertions are not complete in the real-UI runner.

## Human/device/calendar handoff

- Real burn-in days elapsed and 14 consecutive calendar-day review.
- Biometrics/passkeys and OS secure-storage behavior.
- Low-end Android 60fps, haptics, sound, reduce-motion, and restart behavior.
- Play/App Store permission and signing configuration.
- Deployed TLS, certificate, hosting controls, and external OAuth consent.
- Human copy/design review for emotional calm and the locked 13-part layout.

## Evidence rules

- `artifacts/acceptance-traceability.md` maps every screen acceptance bullet.
- Persona screenshots belong in `artifacts/persona-evidence/P<n>-*.png`.
- Real valuation gate numbers are printed by OPS-01; fixtures never count as
  elapsed production burn-in.
- No status in this report is a release approval.

HARNESS INCOMPLETE: P1 offline/reconnect, P5 briefing-corruption fallback, P6 rendered privacy grep, and the full P7 real-UI assertions remain explicit gaps.

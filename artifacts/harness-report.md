# Sprout comprehensive harness report

This is a harness construction report, not a release verdict. Statuses below
describe committed verification coverage and known first-run behavior.

| Suite                      | Stable IDs             | Runner                       | Harness status                                   |
| -------------------------- | ---------------------- | ---------------------------- | ------------------------------------------------ |
| Golden financial fixtures  | FIX-01..FIX-09         | `pnpm test:golden`           | PASS_LOCAL (9/9)                                 |
| Ledger and recurring money | LED-01..02, REC-01..07 | `pnpm test:money-invariants` | NOT_RUN_LOCAL; isolated API/PostgreSQL required  |
| Insights and WorldFact     | INS-01..04             | `pnpm test:insights`         | FAILING_SPEC_CONFLICT                            |
| AI budget/degradation      | AI-01..05              | `pnpm test:ai-budget`        | FAILING_SPEC_CONFLICT                            |
| Persona journeys           | P1..P7                 | `pnpm test:personas`         | FAILING_DEVICE_EVIDENCE_MISSING                  |
| Adversarial API            | ADV-01..07             | `pnpm test:adversarial`      | NOT_RUN_LOCAL; isolated API/PostgreSQL + Flutter |
| Ops/pipeline               | OPS-01..03             | `pnpm test:ops`              | NOT_RUN_LOCAL; isolated API/PostgreSQL/pg tools  |

## Spec-vs-code conflicts intentionally exposed

- INS-01..04: there is no `/v1/insights` API, deterministic matcher/ranker,
  or versioned template registry yet. The schema and tables alone do not
  satisfy the Insight Engine spec.
- AI-01: the briefing pipeline currently calls AI on quiet days.
- AI-02: no configured hard daily cost-cap gate exists. The spec does not set
  a numeric cap, so the harness refuses to invent one and requires
  `AI_DAILY_COST_CAP_CENTS`.
- AI-03: AI output is not validated independently before being copied into the
  final briefing.
- AI-04: no canonical input-hash cache exists across identical user state.
- P1..P7: the committed persona runner currently proves API/PostgreSQL setup
  only. It deliberately fails unless real Flutter screenshots exist for all
  seven personas; JSON files are not accepted as UI evidence.
- ADV-05 may expose a lost-update race because goal contribution updates do
  not currently lock the goal row or use an atomic increment.

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

HARNESS INCOMPLETE: real Flutter P1-P7 screenshot automation and the missing Insights/AI product layers remain explicit failing gaps.

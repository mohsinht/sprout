# Agent And Test Traceability

## Purpose

Specs remain authoritative only when their pass/fail statements map to tests.
This document defines that mapping discipline for humans and coding agents. It
does not replace `AGENTS.md`, `skills/sprout-spec-guardian/SKILL.md`, or domain
specs; it makes their acceptance requirements executable.

## Session Constitution

Every implementation session reads the repository `AGENTS.md` and Sprout spec
guardian first. The guardian is the compact constitution: product identity,
seven asking laws, fixed navigation, token-only design, permanent invariants,
required states, and domain-spec routing. A second duplicated constitution file
must not drift from it.

## Stable Acceptance IDs

Each pass/fail bullet changed or implemented receives a stable ID in the
release traceability matrix:

```text
AC-<SURFACE>-<NNN>
```

Examples: `AC-TODAY-001`, `AC-QUICKADD-004`, `AC-PIPELINE-003`.
Existing `S1–S30` stories and `I1–I54` invariants keep their permanent IDs.
Renumbering to make a document look tidy is forbidden.

For every release candidate, `artifacts/acceptance-traceability.md` records:

| Requirement | Automated test | Manual/device test | Status | Evidence |
| --- | --- | --- | --- | --- |
| `I44` | shell widget test | — | pass/fail | test path/run |
| `S28` | thin-wealth fixture integration | low-end visual check | pass/fail | screenshot/run |

An unmapped acceptance bullet is a release failure, not implicitly covered.

## Canonical Fixtures

The canonical wealth fixture is
`packages/shared/src/mock-wealth.ts`. Its 7 Jul 2026 prices and Xe values are
test data, never production fallbacks. Typed contracts, validators,
deterministic score/action goldens, backend repositories, Flutter adapters,
and screenshots use this fixture or mechanically derived serialized variants.

Additional standing fixtures:

- Zero connection / skipped onboarding (Ayesha).
- Thin wealth: one manual PKR cash holding + one goal (Bilal).
- Multi-source duplicate transaction (Mahnoor).
- Irregular income and foreign cash (Usman).
- Return after missed days (Fatima).
- Wealth-down / bill pressure (Sara).
- Stale and disputed NAV/FX plus durable history (Mohsin).

## CI Invariant Layer

CI blocks merges when practical invariants fail, including:

- Exactly four tabs plus center Quick Add.
- No `check_in` recommended action.
- Every WealthEvent has `plainWhy`.
- Every valued holding has dated provenance and valid freshness.
- Goal actions are goal-relative.
- Snapshot uniqueness per user/PKT date.
- No raw feature `Color(0x...)`, arbitrary spacing/type sizes, or nested card
  containers outside explicitly allowlisted token/system files.
- No force-unwrap of nullable briefing fields at rendering boundaries; missing
  data must select a specified state.

## Vertical Slice Rule

Prefer one reviewable slice per implementation session: contracts/scoring,
repository/fixture, shell/Today, Quick Add persistence, Money/goals, Settings/
onboarding, valuation/reconciliation, then nightly job/validator. A session may
fix cross-slice regressions, but must not quietly broaden product scope.

## Visual And Performance Evidence

Golden coverage runs at approximately 1.3× text scale in light and dark for
core states. Release evidence also includes the target low-end Android profile
with raster/static mascot baseline, reduced motion, and throttled/offline
journeys. Rive is enabled only where measured frame time and memory satisfy the
current performance budget defined by engineering; this spec does not invent
the numeric device budget.

# Insight Engine Execution Plan

## Delivery Rule

Specs and fixtures land before implementation. Each phase is reviewable and
keeps real sources unavailable until independently verified.

## Phase 1: Deterministic Substrate

1. Add an immutable `goal_contributions` ledger and seed each existing goal
   with one `opening_balance` entry equal to its tracked amount.
2. Implement complete-month expense baselines, partial-capture rejection, and
   the Eid/outlier median rule.
3. Implement cadence-aware contribution consistency.
4. Wire recurring liabilities into bill coverage.
5. Implement deadline pace at completed-month granularity with grace bands.
6. Derive affordable, rounded, payday-aware goal actions and connect real
   attention factors to action selection.
7. Add fixtures: Eid spike, monthly payday saver, unaffordable deadline.

Exit: scores and actions have no fixed contribution hardcode or always-on-track
placeholder and every unavailable input is explicit.

## Phase 2: Shared Facts and Deterministic Join

1. Add WorldFact and PersonalInsight contracts and PostgreSQL tables.
2. Implement unavailable source adapters and idempotent fact repository.
3. Add deterministic matcher/ranker and versioned template registry.
4. Feed stored matches through the existing finite Insights UI.
5. Preserve quiet, offline, stale, error, and populated states.

## Phase 3: Budgeted AI

Add skip-when-quiet, privacy-safe rewrite cache, hard daily cost cap,
deterministic degradation, explicit AI-mode telemetry, and separate monthly
story budget.

## Phase 4: Deterministic Delight

Specify one surface at a time: How Sprout Knows, Sprout Remembers, stored
trend-day explanations, and salary-day ritual. Monthly Wealth Story requires
30 days of trustworthy snapshots. No new Today hero or primary CTA.

## Phase 5: Calendar-Bound Valuation Work

Finish Al Meezan primary and MUFAP validation fetchers, start the 14-day
burn-in, filter nightly work to active users, and wire notifications. This
blocks real NAV/FX facts, not behavior insights.

## Current Implementation Slice

- [x] Phase 1 contracts and migration.
- [x] Phase 1 pure calculators and three Pakistan fixtures.
- [x] Phase 1 briefing integration.
- [x] Initial WorldFact/PersonalInsight contracts and persistence skeleton.
- [ ] Regression and acceptance verification.

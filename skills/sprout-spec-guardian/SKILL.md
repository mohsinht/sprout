---
name: sprout-spec-guardian
description: Use when working on the Sprout Financial repo for any product, UI, backend, data, test, onboarding, navigation, mascot, copy, integration, or spec task. Guides Codex to read the right repo specs before coding, restate scope, avoid generic finance-app drift, implement required states, and preserve Sprout's regression invariants.
---

# Sprout Spec Guardian

## Prime Directive

You are building Sprout: the 30-second daily money check-in for Pakistani earners. It is a calm mascot-led check-in with one glance, one sentence, and one small action. It is not a generic finance dashboard, bank app, budgeting spreadsheet, or chart wall.

Restraint is the product. Build exactly what the relevant spec says and no more. Unrequested features, screens, UI elements, tabs, charts, filters, feeds, or settings are bugs, not bonuses.

## Required Pre-Code Ritual

Before editing code for any Sprout task:

1. Restate the task in one short paragraph.
2. State what you are deliberately not including.
3. Name any place the specs are silent. If a value, formula, source shape, threshold, tax rate, parser format, bank SMS format, or API contract is undefined, stop and ask. Never fabricate.
4. List the states you will implement: populated, empty/zero-connection, offline, stale, error, and success. If a state does not apply, say why.
5. Name the spec docs you read or will read from the map below.

Do not skip this ritual for "small" UI changes. Small drift is how Sprout becomes generic.

## Spec Map

All paths are relative to the repo root.

- Product and screens: `spec/product_spec.md`, `spec/application_screen_guidance.md`
- Feel and UX laws: `spec/ux_philosophy.md`
- Asking users for information: `spec/information_gathering_trust.md`
- Permanent regression tests: `spec/user_stories_regression_invariants.md`
- Data shapes: `spec/data_model_contract.md`
- Scoring and findings: `spec/scoring_model.md`
- Nightly AI job: `spec/ai_briefing_backend_spec.md`
- Navigation: `spec/navigation_ia.md`
- Voice and copy: `spec/copy_tone_guide.md`
- Visual system: `spec/design_system_reference.md`
- Mascot: `spec/mascot_asset_set.md`
- Acceptance bars: `spec/screen_acceptance_criteria.md`
- Regulatory boundary: `spec/regulatory_constraints.md`
- Capture reliability: `spec/capture_reliability.md`
- External data sources: `spec/data_sources_registry.md`
- Production hardening: `spec/production_hardening.md`

Read only the specs relevant to the task, plus `ux_philosophy.md`, `user_stories_regression_invariants.md`, and this skill for every product/UI task.

## Forbidden Drift

Never do these unless a spec explicitly changes:

- Add unrequested features, tabs, cards, search bars, notification centers, activity feeds, or "while I was here" UI.
- Default to a numbers-first finance dashboard.
- Add dense card grids or chart walls.
- Invent formulas, tax logic, thresholds, market data shapes, parser formats, API contracts, or fake integrations.
- Treat stubbed data as a real integration. Stub data must be labeled and kept behind repository interfaces.
- Skip empty, zero-connection, offline, stale, error, or success states.
- Add arbitrary colors, spacing, radii, type scales, or nested cards.
- Add a second primary Today action.
- Shame, guilt, alarm, or panic the user.
- Gate core value behind a connection, permission, real name, salary date, or complete profile.
- Request or store bank passwords.
- Screen-scrape.
- Move money, hold stored value, initiate payments, or enable merchant acceptance.

## Non-Negotiables

- Today has one hero, one sentence, one primary action. Mascot is the largest element.
- App is alive with zero connections.
- Manual entry is first-class.
- Glance first, depth on tap. No black-box score or insight.
- Trust is visible: source, freshness, confidence, parser health, disconnect, and delete where relevant.
- Playful on progress, calm on problems, never cruel.
- Streak survives bad money days; checking in honestly counts.
- Privacy is stricter than the legal minimum.
- Reduce-motion is respected.
- Low-end Android performance is a shipping gate.
- User info is gathered as a conversation: one question per moment, tap over type, warm skip, editable later.
- Sprout states uncertainty and never predicts income or outcomes it cannot know.

## Navigation Is Fixed

Three tabs: Today, Money, Settings.

Center `+` opens Quick Add as a sheet. Quick Add is not a tab. There is no Learn tab; learning folds into Sprout Explains. Do not add tabs.

## Build Order

Prefer small, reviewable diffs and one surface at a time:

1. Shared contracts.
2. Today.
3. Quick Add.
4. Onboarding.
5. Money and Settings.
6. Sprout Explains.

Each change must preserve all existing user stories and invariants in `spec/user_stories_regression_invariants.md`.

## Definition Of Done

For every change:

- Relevant specs were read.
- Task was restated and non-scope was named before coding.
- Spec gaps were surfaced instead of filled with guesses.
- Populated, empty/zero-connection, offline, stale, error, and success states are handled where relevant.
- Screen acceptance criteria pass.
- Regression stories/invariants still pass.
- No arbitrary design tokens or unrequested UI were added.
- Reduce-motion and performance floor are respected.
- Any stub/mock integration is explicitly identified as stub/mock.

When unsure, ask. A blocked task with a precise question is better than a plausible wrong implementation in someone's money product.

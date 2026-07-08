# Sprout Spec Package

This folder is the working spec package for Sprout. It translates the high-level product direction into documents that can guide design, implementation, review, and future iteration.

## Documents

- [UX Philosophy](ux_philosophy.md): the feel constitution that governs how every screen should feel.
- [Information Gathering and Trust](information_gathering_trust.md): the law for how Sprout asks for any information without becoming a form.
- [Product Spec](product_spec.md): app-level principles, navigation, daily loop, screen requirements, phasing, and definition of done.
- [Application Screen Guidance](application_screen_guidance.md): reusable guidance for writing or reviewing any screen spec.
- [Design System Reference](design_system_reference.md): current colors, typography, spacing, radius, card/pill/tile styles, iconography, and component rules.
- [Mascot Asset Set](mascot_asset_set.md): required Sprout mascot moods, animation states, current asset inventory, and future asset requirements.
- [Data Model Contract](data_model_contract.md): typed daily briefing contract plus transaction, goal, account, finding, and support models.
- [Scoring Model](scoring_model.md): deterministic v0 garden-health score, finding detection, thresholds, and recommended-action selection.
- [AI Briefing Backend Spec](ai_briefing_backend_spec.md): nightly job inputs, cadence, severity model, output contract, fallback behavior, and guardrails.
- [Market Personalization Spec](market_personalization_spec.md): when market context appears, how it is sourced, and how it becomes personally relevant.
- [Navigation IA](navigation_ia.md): target 3-tab shell plus center quick-add action.
- [Copy Tone Guide](copy_tone_guide.md): Sprout voice rules and example strings.
- [Notifications Spec](notifications_spec.md): daily habit trigger timing, copy, privacy defaults, and deep-link behavior.
- [Screen Acceptance Criteria](screen_acceptance_criteria.md): per-screen done bars for product and QA review.
- [User Stories and Regression Invariants](user_stories_regression_invariants.md): permanent persona journeys and invariants for e2e/integration tests.
- [Regulatory Constraints](regulatory_constraints.md): fund-movement boundary, privacy posture, hosting assumptions, and PECA/screen-scraping limits.
- [Data Sources Registry](data_sources_registry.md): official, semi-official, commercial, and user-permissioned sources with cost/cadence notes.
- [Capture Reliability](capture_reliability.md): parser drift, dedupe, confidence, and per-platform capture reality.
- [Production Hardening](production_hardening.md): backend stack, auth baseline, idempotency, storage, webhooks, and observability.

## Package Rule

When a screen changes, update its product requirement, data contract impact, copy examples, and acceptance criteria together. A screen is not ready for implementation if its empty, offline, error, and zero-connection states are unspecified.

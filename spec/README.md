# Sprout Spec Package

> **Realignment note (2026-07-09):** Sprout is now defined as a **personal
> wealth-health tracker.** The docs below have been updated foundations-first
> to reflect this: wealth is the hero, "check-in" is removed as a health
> mechanic, every movement has a "why," provenance is first-class, and a
> production mock is built from the canonical wealth automation example. See
> the realignment note at the top of each doc for what changed.

This folder is the working spec package for Sprout. It translates the high-level product direction into documents that can guide design, implementation, review, and future iteration.

## Documents

- [UX Philosophy](ux_philosophy.md): the feel constitution that governs how every screen should feel.
- [Information Gathering and Trust](information_gathering_trust.md): the law for how Sprout asks for any information without becoming a form.
- [Product Spec](product_spec.md): app-level principles, navigation, daily loop (three wealth questions + assembling load sequence), locked Today layout, screen requirements, phasing, and definition of done.
- [Application Screen Guidance](application_screen_guidance.md): reusable guidance for writing or reviewing any screen spec, including the locked 13-part Today layout, load sequence, mascot-alive, micro-interactions, and wealth states.
- [Design System Reference](design_system_reference.md): current colors, typography, spacing, radius, card/pill/tile styles, iconography, and component rules.
- [Design Language & Elements Spec](design_language_spec.md): the playful visual language, motion system (Today load sequence, haptics standard, approved interaction toolkit), wealth hero figure rules, and consistency rules that govern how Sprout looks and moves across screens.
- [Mascot Asset Set](mascot_asset_set.md): required Sprout mascot moods, animation states (animated mascot required for Today), current asset inventory, and asset requirements.
- [Data Model Contract](data_model_contract.md): typed daily briefing contract plus Holding, PriceQuote/FxRate, WealthSnapshot, WealthEvent, LearnThread, transaction, goal, account, finding, and support models.
- [Scoring Model](scoring_model.md): deterministic v0 wealth-health score (goal pace, buffer, diversification, contribution consistency, trend stability), finding detection, thresholds, and recommended-action selection. Check-in is removed.
- [AI Briefing Backend Spec](ai_briefing_backend_spec.md): nightly wealth job inputs, cadence, severity model, WealthSnapshot + events + provenance validation, output contract, fallback behavior, and guardrails.
- [Market Personalization Spec](market_personalization_spec.md): when market context appears (only to explain the user's own movement or goal), how it is sourced, and how it becomes personally relevant.
- [Navigation IA](navigation_ia.md): regression-protected 4-tab shell plus center quick-add action: Today · Money · [＋] · Insights · Settings. Money is the holdings + trend + provenance depth surface.
- [Copy Tone Guide](copy_tone_guide.md): Sprout voice rules, wealth movement phrasing, goal-relative step phrasing, provenance phrasing, and example strings.
- [Notifications Spec](notifications_spec.md): daily habit trigger timing, copy, privacy defaults, and deep-link behavior.
- [Screen Acceptance Criteria](screen_acceptance_criteria.md): per-screen done bars for product and QA review, including locked Today layout, motion/mascot/craft pass-fail checks, and wealth-health criteria.
- [User Stories and Regression Invariants](user_stories_regression_invariants.md): permanent persona journeys (including P7 Multi-Currency Investor) and invariants for e2e/integration tests.
- [Regulatory Constraints](regulatory_constraints.md): fund-movement boundary, privacy posture, hosting assumptions, and PECA/screen-scraping limits.
- [Data Sources Registry](data_sources_registry.md): official, semi-official, commercial, and user-permissioned sources (Al Meezan prices, Xe FX, Wise balances, MUFAP) with cost/cadence/provenance notes.
- [Agent and Test Traceability](agent_test_traceability.md): the executable-spec
  contract for stable acceptance IDs, invariant CI checks, canonical fixtures,
  vertical slices, taste lints, and low-end visual/performance runs.
- [Capture Reliability](capture_reliability.md): parser drift, dedupe, confidence, and per-platform capture reality.
- [Production Hardening](production_hardening.md): backend stack, auth baseline, idempotency, storage, webhooks, and observability.
- [Post-v1 Product Opportunities](post_v1_roadmap.md): sequenced roadmap
  candidates for memory, ritual, visible proof, goal depth, and privacy after
  v1, with product-constitution guardrails and explicit rejected directions.

## Package Rule

When a screen changes, update its product requirement, data contract impact, copy examples, and acceptance criteria together. A screen is not ready for implementation if its empty, offline, error, zero-connection, stale-price, and wealth-down states are unspecified.

**Navigation tabs, Insights relevance, and goal CRUD are regression-protected** — see invariants I44–I50 in `user_stories_regression_invariants.md`. A build missing a primary tab, showing generic Insights feed items, obscuring content behind nav, or lacking full goal management fails.

Post-v1 ideas are not current acceptance requirements. A roadmap candidate
must receive its own focused specification, contracts, required states,
acceptance IDs, and persona/invariant test mapping before implementation.

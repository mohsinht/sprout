# Sprout Application Screen Guidance

> **Realignment note (2026-07-09):** The Today section is updated to the
> three-questions structure (wealth + movement + why + one goal-relative
> step) and the glance/depth contract. Required states are expanded to
> include wealth-down day (calm, not alarm), flat day, thin-data/first-run,
> and stale-price/stale-FX day. The rule "no movement shown without a why"
> is added. The Money section is updated to include holdings breakdown and
> trend depth. Manual expense logging remains first-class via Quick Add.

## Purpose

This document defines the minimum requirements every Sprout application screen must meet before deeper iteration begins. It is intentionally screen-focused: each screen should have a clear job, a minimum content set, required states, and acceptance criteria.

Use this as the baseline before writing detailed feature specs, design tickets, or implementation prompts.

For the shared visual language, motion rules, and component usage contract, also refer to [design_language_spec.md](design_language_spec.md).

## Product Anchor

Sprout is the 20-second daily wealth-health check-in for Pakistani earners. It should make a user feel calmer, informed, and gently nudged toward one goal-relative next step.

The application must remain useful with no connected accounts. Manual entry, cached data, and realistic mock states are first-class parts of the product, not fallbacks.

## App-Level Minimum Requirements

Every screen must support these product rules:

- The daily check-in is the central behavior. No screen should compete with Today for emotional weight.
- Sprout, the mascot, carries emotional context at meaningful moments: loading, action, success, uncertainty, and setbacks.
- The interface is glance-first. Essential meaning should be understood in seconds; detail belongs behind taps.
- Problems are calm and specific. The app must never shame, guilt, or panic the user.
- Trust is visible. Data source, freshness, confidence, parser health, privacy, and user control must be clear where relevant.
- Manual use works. A user with zero connections must be able to onboard, check in, log money, and understand their state.
- Pakistan is the default context: PKR, local categories, irregular income, salary timing, committees/BC, Zakat, Sadaqah, Eidi, mobile load, utility bills, ride-hailing, and school fees.
- Performance is a shipping gate. Animations must remain smooth on a low-end Android device; any animation that causes jank should be simplified or removed.

## Navigation Model

Minimum navigation:

- `Today`: default landing screen and primary daily loop.
- `Money`: calm detail room for balances, budgets, goals, and transactions.
- `Settings`: trust, privacy, profile, goals, notifications, and data controls.
- Center `+`: quick-add sheet, not a tab.

Educational content should appear contextually through Sprout explanations and recommended actions. Do not add a standalone learning surface unless the product direction changes.

## Screen Spec Template

Each screen spec should answer:

- Purpose: what job this screen does for the user.
- Primary user moment: what the user should be able to do in under 30 seconds.
- Required content: the minimum visible elements.
- Required states: loading, populated, empty, offline, error, success, and any domain-specific states.
- Primary actions: the few actions the screen must support.
- Trust requirements: freshness, source, confidence, privacy, or control details.
- Motion and feedback: what animates, what celebrates, what stays calm.
- Must not include: explicit anti-requirements.
- Acceptance criteria: objective checks that define done.

## Screen Minimums

### Today

Purpose: deliver the daily wealth-health check-in as a fast emotional arc that answers three questions and ends with closure.

**The three questions, in order:**

1. What is my total wealth, and how did it move? (today, and month-to-date)
2. Why did it move? (plain-language interpretation of the drivers)
3. What's my one next step toward my goals? (an AI suggestion, not empty ritual)

Minimum content:

- Prominent streak and XP.
- Greeting by name.
- Large reactive Sprout mascot with a visible mood — the largest visual element, never competed for by other UI.
- **Total wealth figure** (large, Inter font) with an up/down movement chip showing today's change and MTD change — the hero number the user opens the app for.
- One clear sentence in Sprout's voice, leading with the movement + reason + reassurance (e.g. "Down PKR 38k today — Al Meezan took a tea break after yesterday's jump, not a crash").
- **"What happened" event set** — dated events with yesterday-continuity, each with a plain-language "why." Mix good and not-good honestly.
- **One goal-relative AI next-step** as the main call to action — visible but recessed, so the reading order is: face → wealth figure → sentence → events → score → action.
- Garden-health score in trustworthy Inter font (mono/tabular), with count-up and ring animation.
- Tap-through explanation for the score and its factors.
- Tappable glance tiles with recognizable icons: holdings, goal, trend, and the most relevant context tile (review items, salary countdown, bills, or data quality). Market appears only when personally relevant.
- **Provenance on tap:** every valuation exposes its dated price/FX source.
- **The trend sparkline/chart is a depth element, not a Today-hero element.** It lives one tap down.

**Required states:**

- Normal (wealth up): calm celebration, not exuberance.
- **Wealth-down day:** calm, not alarm. Mascot is watchful (never angry/red-faced). The sentence ends on calm. No shame.
- **Flat day:** "steady" framing. No false excitement, no worry.
- **Thin-data / first-run:** few or no holdings. Today still works with manual entry and a starter next-step.
- **Stale-price / stale-FX day:** holdings with stale valuations are labelled with the as-of date. The wealth figure notes "some prices are from [date]."
- Not completed.
- Completed with celebration.
- Offline cached state.
- Briefing unavailable state.

**Rule: no movement shown without a "why."** Every change (today's change, MTD change, per-event magnitude) must be accompanied by its driver — "main reason: NAV movement," "EUR/PKR moved," "you added to savings." This is the interpretation layer that makes it a health tracker *with an analyst*, not a number.

Acceptance criteria:

- Today is the default landing screen.
- The mascot is the largest visual element and the emotional hero of the screen.
- Reading order is clear: greeting → mascot/mood signal → wealth figure + movement → summary sentence → events → score number → action card → glance tiles.
- The wealth figure uses Inter font for trustworthiness.
- The action card does not visually compete with the mascot for prominence; it sits below the score, not above it.
- The score number uses Inter font for trustworthiness; count-up animation respects tabular figures.
- All money values in tiles (e.g., PKR amounts) use Inter, never playful display fonts.
- **Every movement has a "why"** — no change shown without its driver.
- **"What happened" events reference prior days** to form a story, not a snapshot.
- **One goal-relative next-step** is shown, not an empty ritual.
- **Breakdown, trend, and provenance are reachable on tap** (depth, not forced).
- **A wealth-down day stays calm** — no alarm, no shame, no red-faced mascot.
- **Stale price/FX is labelled** with the as-of date, never silently trusted.
- **Opening the app never changes health** — the score reflects wealth reality, not attendance.
- The user can complete the recommended action and receive closure through celebration, streak/XP feedback, and a sign-off.
- Every score, tile, event, or finding opens a plain-language explanation.
- Market appears only when personally relevant.
- The screen is useful with no connected accounts.
- The full check-in can be completed in under 20 seconds.

### Money

Purpose: provide a calm, trustworthy place to inspect wealth and money details without turning it into a game.

Minimum content:

- **Holdings breakdown** with per-holding value, source, freshness, and provenance (dated NAV/FX on tap).
- **6-day wealth trend** chart (depth element showing per-holding columns).
- Account balances with source and freshness.
- Safe-to-spend or monthly budget summary.
- Goals with progress, remaining-to-target, and next step.
- Recent transactions with category, source, and confidence.
- One-tap confirmation for uncertain transactions.
- A short Sprout line that summarizes the wealth state calmly.

Required states:

- Populated holdings and transactions.
- No connected accounts (manual-only).
- Offline cached data.
- Transactions needing review.
- Balance unavailable or stale.
- **Stale price/FX on a holding** (labelled with as-of date).

Acceptance criteria:

- The user can see what is current, stale, uncertain, and confirmed.
- **Holdings show per-holding value with dated price/FX provenance on tap.**
- **The 6-day trend chart is available as a depth element.**
- Safe-to-spend is understandable at a glance.
- Uncertain transactions can be confirmed in one tap.
- The screen does not duplicate the Today hero treatment.
- Offline cached data remains readable and useful.

### Quick Add

Purpose: let the user log cash, income, or unseen activity in about three seconds.

Minimum content:

- Slide-up sheet from the center `+`.
- One-tap expense category chips using Pakistani categories.
- Income path for salary, freelance, gift, and other.
- Optional amount entry when needed.
- Short copy that frames manual entry as helping Sprout see what auto-capture cannot.
- Non-punitive validation when amount, category, or income source is missing.

Required states:

- Expense logging.
- Income logging.
- Custom category or other.
- Offline local save.
- Success feedback.
- Validation error for incomplete entries.

Acceptance criteria:

- A common cash expense can be logged without typing.
- Income can be logged quickly.
- The sheet opens and closes without leaving the current screen.
- Entries persist locally while offline.
- Taps provide immediate haptic or visual feedback.

### Settings

Purpose: make trust, privacy, and control easy to inspect and change.

Minimum content:

- Profile: name, salary date, income type.
- Goals editor for the goals that drive briefing recommendations.
- Data sources: manual, email, statement import, optional Android SMS, and future partnerships, each with status.
- Connect, disconnect, and delete controls where applicable.
- Plain-language privacy block.
- Notification preferences for daily check-in, bills, salary, and weekly summary.
- Reduce-motion and balance-visibility preferences.

Required states:

- No sources connected.
- One or more sources connected.
- Source needs attention.
- Data deletion confirmation.
- Goal editing.
- Notification disabled.

Acceptance criteria:

- Every data source can be connected or disconnected from this surface.
- Privacy guarantees are visible in normal language.
- Goals are editable and clearly tied to future briefings.
- Settings is calm and sober; it should not feel gamified.

### Onboarding

Purpose: create a first win before asking for data connections or profile detail. Onboarding is a short conversation with Sprout, not a form.

Minimum content:

- Warm intro that explains the daily check-in.
- Name or nickname capture, with a playful random nickname option and "just call me friend."
- One goal selected through chips, with "+ something else" and "help me decide later."
- Offline-safe local first briefing.
- Celebration handoff to a living Today screen.

Must not contain:

- Salary date.
- Income type.
- Multiple-goal form.
- Source connection request before core value is visible.

Required states:

- New user.
- Nickname chosen.
- Nickname skipped/default used.
- Goal chosen.
- Goal skipped/starter help-me-choose action used.
- Offline local completion.
- First-briefing generation error with retry.

Acceptance criteria:

- Onboarding can be completed without connecting anything.
- Onboarding can complete while offline and produce a local first Today screen.
- First-briefing failure shows a retry path without blocking entry.
- The only asks are name/nickname and one goal.
- Every ask follows the Information Gathering and Trust spec.
- Salary date, income type, extra goals, and source connections are captured later in context.
- The user lands on a populated Today screen.
- No permission is required before the core value is visible.

### Sprout Explains

Purpose: provide the depth layer behind glanceable UI.

Minimum content:

- Focused explanation for the tapped score, tile, finding, transaction, market move, or goal.
- Plain-language reason why it matters.
- Connection back to the user's goals where relevant.
- Optional next action.
- Follow-up affordance for asking more.

Required states:

- Score explanation.
- Tile explanation.
- Transaction or confidence explanation.
- Market context explanation.
- AI unavailable or local fallback explanation.

Acceptance criteria:

- Every tappable insight on Today and Money has a relevant explanation.
- Explanations are calm, specific, and not black-box.
- The user can leave the explanation and return to the previous screen without losing context.

## Data and AI Guidance

All screens should read from shared domain models rather than one-off local shapes. At minimum, the application should define stable contracts for:

- Daily briefing (carrying WealthSnapshot, WealthEvents, and goal-relative recommended action).
- Holding (with PriceQuote/FxRate provenance).
- WealthSnapshot.
- WealthEvent.
- Finding.
- Account.
- Transaction.
- Goal (with remainingToTarget and paceNote).
- Optional market snapshot, only when personally relevant.
- User profile.
- Data source.

AI output must be treated as structured product data, not free-form UI copy. The nightly briefing should provide severity, explanation, action, and confidence signals so screens can render deterministic states.

When data is thin, stale, or unavailable, the app should say so and continue with local/manual value. **Stale prices/FX are labelled, never silently trusted.**

## Motion and Feedback Guidance

Use motion to communicate progress, completion, and warmth:

- Count up numbers only when they clarify change.
- Sweep rings and fill bars on first reveal.
- Celebrate completed daily actions with confetti, mascot reaction, XP, and streak feedback.
- Use gentle motion for setbacks or warnings.
- Respect reduce-motion settings.
- Prefer simpler static states over any animation that drops frames.

## Copy Guidance

Sprout copy should be:

- Short.
- Specific.
- Kind.
- Actionable.
- Honest about uncertainty.

Avoid:

- Shame or guilt.
- Overconfidence about income or future outcomes.
- Investment pressure or FOMO.
- Technical finance language without explanation.
- Empty encouragement that hides the real state.

## Minimum Acceptance Checklist

Before a screen is considered ready for iteration, verify:

- It has a clear purpose and one primary user moment.
- It works with no connected accounts.
- It handles loading, empty, offline, error, and success states.
- It shows source, freshness, or confidence where money data appears.
- It has no black-box scores or unexplained insights.
- It offers a plain-language explanation for important glance elements.
- It respects Pakistan-specific categories, currency, and income patterns.
- It respects reduce motion and remains smooth on low-end Android.
- It avoids shame, dark patterns, and connection-gated core value.
- It has objective acceptance criteria that can be tested.

## Iteration Order

Recommended order for building detailed specs:

1. Lock shared contracts: daily briefing, finding, transaction, goal, account, user profile, and data source.
2. Specify Today in the most detail, because it defines the product behavior.
3. Specify Quick Add, because it keeps the app alive with zero connections.
4. Specify Onboarding, because it feeds the first briefing.
5. Specify Money and Settings, because they provide depth and trust.
6. Specify Sprout Explains across all tappable insight surfaces.

Each detailed screen spec should be small enough to implement and verify independently, but consistent with this guidance.

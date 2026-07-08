# Sprout Application Screen Guidance

## Purpose

This document defines the minimum requirements every Sprout application screen must meet before deeper iteration begins. It is intentionally screen-focused: each screen should have a clear job, a minimum content set, required states, and acceptance criteria.

Use this as the baseline before writing detailed feature specs, design tickets, or implementation prompts.

## Product Anchor

Sprout is the 30-second daily money check-in for Pakistani earners. It should make a user feel calmer, informed, and gently nudged toward one small useful action.

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

Purpose: deliver the daily check-in as a fast emotional arc that ends with closure.

Minimum content:

- Prominent streak and XP.
- Greeting by name.
- Large reactive Sprout mascot with a visible mood.
- One clear sentence in Sprout's voice.
- Garden-health score with count-up and ring animation.
- Tap-through explanation for the score and its factors.
- One recommended action as the main call to action.
- Tappable glance tiles for wallet, goal, last night's scan, and the most relevant context tile. Market appears only when personally relevant; otherwise use bill, salary, cash runway, or data-quality context.

Required states:

- Not completed.
- Completed with celebration.
- Bad-news or needs-attention state.
- Empty or first-run state with no connected accounts.
- Offline cached state.
- Briefing unavailable state.

Acceptance criteria:

- Today is the default landing screen.
- The mascot is the largest visual element.
- The user can complete the recommended action and receive closure through celebration, streak/XP feedback, and a sign-off.
- Every score, tile, or finding opens a plain-language explanation.
- Market appears only when personally relevant.
- The screen is useful with no connected accounts.
- The full check-in can be completed in under 30 seconds.

### Money

Purpose: provide a calm, trustworthy place to inspect money details without turning it into a game.

Minimum content:

- Account balances with source and freshness.
- Safe-to-spend or monthly budget summary.
- Goals with progress and next step.
- Recent transactions with category, source, and confidence.
- One-tap confirmation for uncertain transactions.
- A short Sprout line that summarizes the money state calmly.

Required states:

- Populated accounts and transactions.
- No connected accounts.
- Offline cached data.
- Transactions needing review.
- Balance unavailable or stale.

Acceptance criteria:

- The user can see what is current, stale, uncertain, and confirmed.
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

- Daily briefing.
- Finding.
- Account.
- Transaction.
- Goal.
- Optional market snapshot, only when personally relevant.
- User profile.
- Data source.

AI output must be treated as structured product data, not free-form UI copy. The nightly briefing should provide severity, explanation, action, and confidence signals so screens can render deterministic states.

When data is thin, stale, or unavailable, the app should say so and continue with local/manual value.

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

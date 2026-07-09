# Sprout Application Screen Guidance

> **Realignment note (2026-07-09):** The Today section is updated to the
> three-questions structure (wealth + movement + why + one goal-relative
> step) and the glance/depth contract. Required states are expanded to
> include wealth-down day (calm, not alarm), flat day, thin-data/first-run,
> and stale-price/stale-FX day. The rule "no movement shown without a why"
> is added. The Money section is updated to include holdings breakdown and
> trend depth. Manual expense logging remains first-class via Quick Add.
>
> **Layout-lock note (2026-07-09):** The Today screen layout is now **locked**
> as a canonical 13-part structure (see below). No new content or elements
> may be added to Today; further quality is *temporal* — it lives in the load
> sequence, micro-interactions, and the mascot coming alive, not in more
> elements. Reordering or adding requires a deliberate spec revision.

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

#### Locked layout (canonical structure — do not add or reorder)

The Today screen has reached its final layout. This exact top-to-bottom order is the fixed structure. Nothing added, nothing reordered without a deliberate spec change.

1. Greeting + streak (compact, top).
2. Mascot (reactive, mood-driven).
3. **Total wealth** — the hero figure, largest on screen.
4. Movement chips — today + month-to-date.
5. Sprout's one-line read (calm/honest, mood-matched).
6. Your one step — single chunky action button.
7. **What's happening** — 4–5 tiles (good/bad news + fund/goal highlights).
8. Your holdings — visual rows.
9. Depth door — 6-day trend / breakdown (tap-through).
10. Why it moved today — the interpretation paragraph.
11. Your goals — progress bars.
12. Learn later — tap-through.
13. Provenance footer — prices/FX/dates/sources.

**Above the fold = 1–6** (the 20-second glance). **Below = the rest** (depth for the curious). The layout is DONE. The remaining quality is temporal — it lives in the load sequence and micro-interactions, not in more elements.

#### Load sequence (the screen assembles, it does not just appear)

On Today open, the screen assembles in this ordered entrance. This is a first-class requirement, not an optional nicety.

1. **Wealth figure counts up** to its value over ~800ms, ease-out (fast then settling). This is the hero moment of the load.
2. **Movement chips fade in** just after the number lands.
3. **Mascot does a small settle-bounce** on entrance.
4. **"What's happening" tiles stagger in**, rising/fading, ~50ms apart.
5. **Goal progress bars/rings fill** left-to-right on first reveal.
6. **"Why it moved" paragraph fades in** last.

Content is readable instantly — non-essential motion finishes behind reading. Never block reading on animation.

#### Micro-interactions (every interactive element)

- **Light haptic** on every tile tap, chip tap, and nav tap.
- **Tiles and buttons press down** on touch (the chunky-edge press).
- **Action completion** → haptic + chime + confetti, then the calm "done" state.

#### Mascot-alive requirement

- On Today, the mascot must **animate** — at minimum a subtle idle (breathing/bob + occasional blink), and a **mood-matched expression** driven by product state (thriving / content / watchful / concerned), plus a reaction on load and on action completion.
- Static PNG is a **fallback only** (reduce-motion, missing asset), never the default experience on Today.
- The mascot is the primary emotional signal; its motion is what turns the screen from "calm dashboard" into "calm companion."

#### Motion rules

- Everything routes through `sprout_motion` / `flutter_animate`; no ad-hoc controllers with literal durations.
- **Reduce-motion** fully respected: count-up, stagger, bounce, confetti all replaced by calm static reveals; no information hidden, no layout broken.
- **60fps on the target low-end Android device** is the gate; simplify or cut any entrance effect that janks.

#### Required states

- Normal (wealth up): calm celebration, not exuberance.
- **Wealth-down day:** calm, not alarm. Mascot is watchful (never angry/red-faced). The sentence ends on calm. No shame.
- **Flat day:** "steady" framing. No false excitement, no worry.
- **Thin-data / first-run:** few or no holdings. Today still works with manual entry and a starter next-step.
- **Stale-price / stale-FX day:** holdings with stale valuations are labelled with the as-of date. The wealth figure notes "some prices are from [date]."
- Not completed.
- Completed with celebration.
- Offline cached state.
- Briefing unavailable state.

#### Craft quality bar

- **Tile heights:** tiles are equal-height AND content fills them — no large dead gap between icon row and title. Reduce height or top-align content so there's no empty middle.
- **No truncation, ever:** tile copy is shortened at the source (1–3 word title, ≤5 word description). "Al Meezan, NAV correcti…" style clipping fails acceptance.
- **Readability floor:** no readable body text below ~14px; the interpretation paragraph at comfortable body size; all survives 1.3× text scale without clipping.
- **Depth retained:** tiles and buttons keep the solid chunky bottom edge; committed tints, not washed-out pastels.

**Rule: no movement shown without a "why."** Every change (today's change, MTD change, per-event magnitude) must be accompanied by its driver — "main reason: NAV movement," "EUR/PKR moved," "you added to savings." This is the interpretation layer that makes it a health tracker *with an analyst*, not a number.

Acceptance criteria:

- Today is the default landing screen.
- **The 13-part locked layout is present in the exact order specified.** No extra elements, no reordering.
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
- **Wealth figure animates count-up on first reveal** (unless reduce-motion).
- **Tiles stagger in** on load (~50ms apart).
- **Goal bars fill on reveal.**
- **Mascot animates and is mood-matched** (not a static PNG by default).
- **Haptic feedback on every tile/chip/nav tap.**
- **Action completion celebrates** (haptic + chime + confetti → calm "done").
- **Entrance motion holds 60fps** on the target low-end Android device.
- **Reduce-motion replaces all entrance motion** with static reveals, losing no information.
- **Tiles are equal-height and content-filled** — no dead gaps, no truncation.
- **No body text below ~14px; 1.3× text scale intact.**
- **Chunky depth present** on tiles and buttons; committed tints, not washed-out pastels.
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

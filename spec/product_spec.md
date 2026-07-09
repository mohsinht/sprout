# Sprout Product Spec

> **Realignment note (2026-07-09):** Sprout is redefined as a **personal
> wealth-health tracker.** The hero of Today is now total net wealth across
> holdings (mutual funds + multi-currency cash + PKR cash) with today's and
> month-to-date movement, a plain-language "why," and one goal-relative AI
> next-step. "Check-in" as a health-changing mechanic is removed. Manual
> expense logging is retained as first-class for the cash use case (Bilal,
> the cash guy) but is demoted from the Today hero. The three questions Today
> must answer (§1 of the realignment doc) replace the old daily loop. The
> calm, playful, no-shame feel and all UX philosophy laws are preserved.
>
> **Layout-lock note (2026-07-09):** The Today screen layout is **locked** as
> a canonical 13-part structure. No new content or elements may be added to
> Today; further quality is temporal (load sequence, micro-interactions,
> mascot coming alive). Reordering or adding requires a deliberate spec
> revision. The daily loop now includes the assembling load sequence and
> completion celebration as part of the defined loop.

## One-Line Product

Sprout is the 20-second daily wealth-health check-in: a calm, trustworthy mascot that turns an overnight analysis of your total wealth, its movement, and your goals into one glance, one sentence, and one goal-relative next step.

## Non-Negotiable Principles

- One daily behavior: every feature supports the daily wealth check-in.
- Character carries emotion: Sprout is present and reactive at meaningful beats.
- Glance first, depth on tap: essential state is understood quickly; details live behind explanations.
- Playful on progress, calm on problems: no guilt, shame, panic, or red-faced mascot.
- Alive with zero connections: manual entry and cached/mock data are first-class.
- Trust is the product: data source, freshness, confidence, and controls must be visible. **Provenance is first-class** — every valuation shows its dated price/FX source.
- Performance is a gate: ship only what stays smooth on low-end Android.
- Native to Pakistan: PKR, local categories, irregular income, Urdu readiness, and offline tolerance.
- **Wealth is the hero:** total net worth across funds and multi-currency cash, with today's and month-to-date movement, is the number the user opens the app for.
- **Every movement has a "why":** no change is shown without its driver.
- **Opening the app never changes health:** the score reflects wealth reality, not attendance.

## Application Requirements

### Navigation

Target navigation is three tabs plus a center action:

- Today
- Money
- Settings
- Center `+` quick-add sheet

Today is the default landing screen. Quick Add is not a tab. Educational content appears through Sprout explanations and contextual recommendations.

### Daily Loop

Open app -> **the screen assembles** (wealth figure counts up, movement chips fade in, mascot settles, tiles stagger in, goal bars fill, interpretation fades in last) -> Sprout greets by name and reacts to the current state -> user sees **total wealth, how it moved, and why** -> user reads the one goal-relative next step -> user completes one small action (if any) -> **haptic + chime + confetti + mascot cheer**, streak tick, and XP -> user closes the app feeling calmer.

The Today screen must answer three questions, in order:

1. **What is my total wealth, and how did it move?** (today, and month-to-date)
2. **Why did it move?** (plain-language interpretation of the drivers)
3. **What's my one next step toward my goals?** (an AI suggestion, not empty ritual)

Completion must feel like closure: the user is done for today.

**The Today layout is locked** (13-part canonical structure — see `application_screen_guidance.md`). No new content or elements may be added; further quality is temporal (load sequence, micro-interactions, mascot). Reordering or adding requires a deliberate spec revision.

### Streak System

Streaks are maintained by showing up (honest check-ins), not by spending or saving a target amount. Financial hardship must never break a streak by itself. The product should support humane recovery such as freeze or repair.

**Health/score is decoupled from streak:** the score changes only when something *real* happens — wealth moves, a goal advances, an action is taken, a bill is handled. Opening the app keeps the streak but never changes the score. No "+3 health for checking in."

### Data Capture

The source-agnostic data pipeline is:

1. Manual entry.
2. Email parsing through OAuth.
3. Statement import.
4. Optional Android financial SMS fallback.
5. Selective bank/wallet partnerships later.

Manual entry is the always-on floor. Auto-captured transactions include a confidence signal, parser version, and dedupe fingerprint. Uncertain items route to one-tap confirmation. Connections use OAuth where available; Sprout must never store bank passwords or screen-scrape.

### Core Domain: Holdings and Goals

The core domain is **holdings** (mutual funds, cash in multiple currencies, their prices/NAVs and FX) and **goals** (car, emergency, etc. with a "how far to go" figure). Day-to-day expense logging still exists and stays first-class for the manual/cash use case — but the *hero* of Today is wealth movement and goal progress, not a budget bar.

**Multi-currency and price/FX provenance are first-class.** Holdings span PKR, USD, EUR. Every valuation shows its basis: which NAV/redemption price, which FX rate, as of which date, from which source. Provenance is the trust — it appears on tap, never hidden.

### AI Briefing

The nightly briefing is core. It fetches holdings, pulls NAVs/redemption prices and FX with dates+sources, reconciles units, computes a WealthSnapshot (total + today/MTD movement + main reason + interpretation), detects WealthEvents with yesterday-continuity, and selects one goal-relative next-step. If the briefing is missing, thin, or stale, the app falls back to local data and still works.

Sprout reports facts and uncertainty. It must not confidently predict income, investment outcomes, or user behavior it cannot know. No guaranteed-return language, no FOMO, honest good/bad, state uncertainty.

## Screen Requirements

### Today

Purpose: deliver the 20-second daily wealth-health check-in.

The Today screen answers three questions, in order:

1. **What is my total wealth, and how did it move?** (today, and month-to-date)
2. **Why did it move?** (plain-language interpretation of the drivers)
3. **What's my one next step toward my goals?** (an AI suggestion, not empty ritual)

Minimum:

- Streak and XP.
- Greeting by name.
- Large reactive Sprout mascot.
- **Total wealth figure** (large, Inter font) with today's change and MTD change — the hero number.
- One Sprout summary sentence in the automation's voice (movement + reason + reassurance).
- **"What happened" event set** with yesterday-continuity (e.g. "Al Meezan pulled back after yesterday's jump").
- **One goal-relative AI next-step** (e.g. "PKR 2 lakh to your car goal" or "MIF is lagging — consider directing your next contribution there").
- Garden-health score with animated count-up and ring.
- Glance tiles for holdings, goal, trend, and the most relevant context tile.
- Market appears only when personally relevant (explains the user's own movement or goal); otherwise use bill, salary, cash runway, or data-quality context.
- Explanation surface for every score, tile, finding, and wealth event.
- **Provenance on tap:** every valuation exposes its dated price/FX source.

Removed from Today hero:

- Wallet balance as the hero number (replaced by total wealth).
- Check-in as a health-changing action (opening the app never changes health).
- Budget bar as the hero (demoted to Money; expense logging stays first-class for cash use case via Quick Add).

### Money

Purpose: calm detail room for wealth and money inspection.

Minimum:

- **Holdings breakdown** with per-holding value, source, freshness, and provenance (dated NAV/FX).
- **6-day wealth trend** chart (depth element, not a Today hero).
- Accounts with balances, source, and freshness.
- Safe-to-spend or budget summary.
- Goals with progress, remaining-to-target, and next step.
- Recent transactions with source and confidence.
- One-tap confirmation for uncertain transactions.
- A short calm Sprout line.

### Quick Add

Purpose: log cash, income, or unseen activity in about three seconds.

Minimum:

- Slide-up sheet from center `+`.
- Pakistani category chips.
- Salary, freelance, gift, and other income paths.
- Offline local persistence.
- Success feedback.
- Non-punitive validation for missing amount, category, or income source.

### Settings

Purpose: trust, privacy, profile, goals, data controls, and preferences.

Minimum:

- Profile details.
- Goals editor.
- Data source statuses and controls.
- Privacy promises in plain language.
- Notification, reduce-motion, language, and balance-visibility settings.
- Streak freeze/repair status and controls.

### Onboarding

Purpose: create value before asking for data connections.

Minimum:

- Welcome promise: daily check-in, about 20 seconds, no bank needed.
- Name or nickname, with skip to a friendly default.
- One goal, selected through chips, with "help me decide later."
- Offline-safe local first briefing.
- First Today screen populated after completion.

Do not ask salary date, income type, multiple goals, or source connections during onboarding. Sprout captures those later in context, one tap at a time.

### Sprout Explains

Purpose: depth layer behind glance elements.

Minimum:

- Focused explanation.
- Why it matters.
- Tie-back to goals when relevant.
- Optional next action.
- Follow-up affordance.

## Phasing

### Phase 1

3-tab shell plus center `+`, onboarding, manual-first capture, Today, Money, Settings, Sprout Explains, local persistence, mock/rules briefing, mascot states, and celebration.

### Phase 2

Real nightly AI briefing behind the same contract, severity-ranked findings, model-powered explanations, notification timing, and personalized market context where relevant.

### Phase 3

Auto-capture sources, confidence pipeline, Urdu expansion, streak recovery, and richer income outlook that asks and remembers instead of predicting.

## App-Level Definition of Done

A first-time user with nothing connected finishes onboarding, lands on a living Today screen, **sees their total wealth and how it moved**, understands why in one glance, sees one goal-relative next step, completes one small action, and closes in under 20 seconds feeling calmer.

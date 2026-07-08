# Sprout Product Spec

## One-Line Product

Sprout is the 30-second daily money check-in a Pakistani earner looks forward to: a calm, trustworthy mascot that turns an overnight analysis of money into one glance, one sentence, and one small winnable action.

## Non-Negotiable Principles

- One daily behavior: every feature supports the daily check-in.
- Character carries emotion: Sprout is present and reactive at meaningful beats.
- Glance first, depth on tap: essential state is understood quickly; details live behind explanations.
- Playful on progress, calm on problems: no guilt, shame, panic, or red-faced mascot.
- Alive with zero connections: manual entry and cached/mock data are first-class.
- Trust is the product: data source, freshness, confidence, and controls must be visible.
- Performance is a gate: ship only what stays smooth on low-end Android.
- Native to Pakistan: PKR, local categories, irregular income, Urdu readiness, and offline tolerance.

## Application Requirements

### Navigation

Target navigation is three tabs plus a center action:

- Today
- Money
- Settings
- Center `+` quick-add sheet

Today is the default landing screen. Quick Add is not a tab. Educational content appears through Sprout explanations and contextual recommendations.

### Daily Loop

Open app -> Sprout greets by name and reacts to the current state -> score counts up and ring sweeps -> user sees they are okay or what needs attention -> user completes one small action -> confetti, mascot cheer, streak tick, and XP -> user closes the app feeling calmer.

Completion must feel like closure: the user is done for today.

### Streak System

Streaks are maintained by honest check-ins, not by spending or saving a target amount. Financial hardship must never break a streak by itself. The product should support humane recovery such as freeze or repair.

### Data Capture

The source-agnostic data pipeline is:

1. Manual entry.
2. Email parsing through OAuth.
3. Statement import.
4. Optional Android financial SMS fallback.
5. Selective bank/wallet partnerships later.

Manual entry is the always-on floor. Auto-captured transactions include a confidence signal, parser version, and dedupe fingerprint. Uncertain items route to one-tap confirmation. Connections use OAuth where available; Sprout must never store bank passwords or screen-scrape.

### AI Briefing

The nightly briefing is core. It analyzes transactions, savings, goals, income timing, market context when personally relevant, and data quality, then returns a structured daily briefing with severity-ranked findings. If the briefing is missing, thin, or stale, the app falls back to local data and still works.

Sprout reports facts and uncertainty. It must not confidently predict income, investment outcomes, or user behavior it cannot know.

## Screen Requirements

### Today

Purpose: deliver the 30-second daily check-in.

Minimum:

- Streak and XP.
- Greeting by name.
- Large reactive Sprout mascot.
- One Sprout summary sentence.
- Garden-health score with animated count-up and ring.
- One recommended action.
- Glance tiles for wallet, goal, last night's scan, and the most relevant context tile.
- Market appears only in Phase 2 when personally relevant; otherwise use bill, salary, cash runway, or data-quality context.
- Explanation surface for every score, tile, and finding.

### Money

Purpose: calm detail room for money inspection.

Minimum:

- Accounts with balances, source, and freshness.
- Safe-to-spend or budget summary.
- Goals with progress and next step.
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

A first-time user with nothing connected finishes onboarding, lands on a living Today screen, understands their money state in one glance, completes one small action, and closes in under 30 seconds feeling calmer.

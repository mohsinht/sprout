# Scoring and Finding Model

> **Realignment note (2026-07-09):** The garden-health score is redefined to
> reflect **wealth health**, not attendance. The "Check-in consistency" factor
> is removed — opening the app / checking in no longer changes the score. New
> factors measure goal pace, buffer months, diversification/concentration,
> contribution consistency, and volatility-adjusted trend. The score now
> answers "is my wealth healthy and on track for my goals?" not "did I show
> up?" Streak is preserved as a separate habit mechanic (showing up keeps the
> streak) but is decoupled from the health score.

## Purpose

The garden-health score must be explainable, deterministic, and actionable. This v0 model defines how the score, findings, and recommended action are chosen before any AI language is generated.

The AI may summarize and phrase explanations, but it must not invent score math, factors, thresholds, or action priority.

## Score Output

The score is an integer from `0` to `100`.

Bands:

- `strong`: 85-100
- `healthy`: 70-84
- `watch`: 50-69
- `urgent`: 0-49

Mascot mood:

- `strong` -> `thriving`
- `healthy` -> `content`
- `watch` -> `watchful`
- `urgent` -> `concerned`

## V0 Factor Weights

The score is the rounded sum of these weighted factors. The model reflects
**wealth health**: is the user's net wealth on track for their goals, with
adequate buffer, reasonable diversification, and consistent contributions?

| Factor | Weight | What It Measures |
| --- | ---: | --- |
| Goal pace | 25 | Progress against active goals (remaining-to-target trajectory). |
| Cash buffer | 20 | Emergency buffer or available-cash runway in months. |
| Contribution consistency | 15 | Regular contributions to goals/holdings over recent weeks. |
| Diversification / concentration | 10 | Spread across asset types and currencies; penalty for single-holding dominance. |
| Volatility-adjusted trend | 10 | Wealth trend stability over recent days (reward steady, penalize sharp swings). |
| Bill coverage | 10 | Upcoming bills covered by available cash. |
| Debt or fixed commitments | 5 | Debt/required payment pressure, if present. |
| Data confidence | 5 | How many important items need confirmation / stale prices. |

Total: 100.

> **Removed:** "Spending pace" (20) and "Salary/income timing" (5) and
> "Investment/long-term bucket freshness" (5) and "Check-in consistency" (5)
> are removed as standalone factors. Spending pace and bill coverage are
> still relevant for the cash use case but are no longer the hero — they
> fold into "Bill coverage" and "Cash buffer." Income timing remains a
> *finding* (not a score factor) when a confirmed income date is missing.
> **Opening the app / checking in does not change the score.**

## Factor Calculations

### Goal Pace, 25 points

Input: `goalPaceRatio` — the weighted average of `currentAmount / targetAmount`
across active goals, adjusted for deadline proximity. For goals without a
deadline, use raw progress ratio.

Formula:

```text
goalPacePoints = clamp(goalPaceRatio, 0, 1) * 25
```

Finding thresholds:

- `>= 0.75`: all good.
- `>= 0.50`: heads up.
- `>= 0.25`: worth doing.
- `< 0.25`: needs attention.

Explanation examples:

- Positive: "Your car goal is 48% funded — PKR 2 lakh to go."
- Attention: "Your emergency fund is below 25% of target."

### Cash Buffer, 20 points

Input: `emergencyBufferMonths`.

Formula:

```text
cashBufferPoints = clamp(emergencyBufferMonths / 3, 0, 1) * 20
```

Explanation examples:

- Positive: "Emergency buffer covers 3.2 months."
- Attention: "Emergency fund is below one month of expenses."

### Contribution Consistency, 15 points

Input: `contributionConsistencyRatio` — fraction of the last N weeks (v0: 4
weeks) in which the user made at least one contribution to a goal or
holding. This measures the *habit of adding to wealth*, not the amount.

Formula:

```text
contributionPoints = clamp(contributionConsistencyRatio, 0, 1) * 15
```

Finding thresholds:

- `>= 0.75`: all good.
- `>= 0.50`: heads up.
- `>= 0.25`: worth doing.
- `< 0.25`: needs attention.

### Diversification / Concentration, 10 points

Input: `diversificationRatio` — 1 minus the share of total wealth in the
single largest holding. `1.0` means perfectly spread; `0.0` means one
holding is 100% of wealth.

Formula:

```text
diversificationPoints = clamp(diversificationRatio, 0, 1) * 10
```

Finding thresholds:

- `>= 0.60`: all good.
- `>= 0.40`: heads up.
- `>= 0.25`: worth doing.
- `< 0.25`: needs attention.

Explanation example: "MIF is lagging your other funds — consider directing
your next contribution there." (This is informational, never investment
advice — see guardrails.)

### Volatility-Adjusted Trend, 10 points

Input: `trendStabilityRatio` — a 0..1 measure of how steady the wealth trend
is over the last N days (v0: 6 days). Computed as
`1 - (absStdDevOfDailyChanges / absTotalChange)`, clamped to 0..1. A steady
climb scores high; a single sharp swing scores lower.

Formula:

```text
trendPoints = clamp(trendStabilityRatio, 0, 1) * 10
```

This factor is informational. It must never produce alarm — a volatile day
is context, not a crisis. The mascot stays calm (watchful at most).

### Bill Coverage, 10 points

Input: `upcomingBillsCoverageRatio`.

Formula:

```text
billPoints = clamp(upcomingBillsCoverageRatio, 0, 1) * 10
```

Finding thresholds:

- `>= 1.00`: all good.
- `>= 0.80`: heads up.
- `>= 0.60`: worth doing.
- `< 0.60`: needs attention.

### Debt or Fixed Commitments, 5 points

Input: `debtPaymentRatio`.

This is required debt or fixed repayment as a share of monthly income. If the user has no tracked debt, use `0`.

Formula:

```text
debtPoints = clamp(1 - debtPaymentRatio / 0.35, 0, 1) * 5
```

### Data Confidence, 5 points

Input: `unconfirmedImportantTransactions` plus `stalePriceCount` (holdings
with stale NAV/FX).

Formula:

```text
dataConfidencePoints = clamp(1 - (unconfirmedImportantTransactions + stalePriceCount) / 8, 0, 1) * 5
```

Finding thresholds:

- `0`: all good.
- `1-2`: heads up.
- `3-5`: worth doing.
- `6+`: needs attention.

> **What does NOT change the score:** Opening the app, checking in, viewing
> a screen, or tapping a tile. The score reflects **wealth reality** — goal
> progress, buffer, diversification, contribution habit, trend stability,
> bill coverage, debt pressure, and data confidence — not attendance.
> Streak is a separate habit mechanic and is unaffected by the score.

## Finding Detection Rules

Every factor can emit zero or one finding. A finding is created when:

- A factor crosses a threshold above.
- A source is stale or low confidence.
- A user goal has no next step.
- A bill is due within 7 days and not covered.
- A confirmed income date is missing for a salaried user.
- The market relevance rules produce a personalized market finding.

Each finding must include:

- `severity`
- `category`
- `confidence`
- `sourceIds`
- `why`
- Optional `action`

## Recommended Action Selection

Choose exactly one action. Actions are now **goal-relative and concrete**
(per realignment §2.6): framed against the user's goals and holdings.

Priority order:

1. `needs_attention` bill coverage or cash runway.
2. `needs_attention` data quality that blocks the score (stale prices/FX or unconfirmed transactions).
3. `worth_doing` goal contribution ("PKR 2 lakh to your car goal").
4. `worth_doing` rebalance suggestion ("MIF is lagging your other funds — consider directing your next contribution there").
5. `heads_up` confirmation or manual cash logging.
6. `all_good` review today's wealth movement.

Tie breakers:

- Prefer actions completable inside the app or in one step outside.
- Prefer actions under 30 seconds.
- Prefer actions that improve data confidence before actions that move money.
- Never select an action that pressures investment, implies guaranteed returns, or uses FOMO.
- Never select a "check-in" action — opening the app is not an action.

## Action XP

- `all_good`: 5-10 XP
- `heads_up`: 10-15 XP
- `worth_doing`: 15-25 XP
- `needs_attention`: 20-30 XP

XP rewards completing a **real action** (confirming a transaction, logging
cash, contributing to a goal, reviewing a holding), not attendance. Opening
the app awards no XP.

## Score Explanation Requirements

Every score display must expose:

- Final score and band.
- Delta from previous briefing.
- Top two positive factors.
- Top two attention factors.
- How the recommended action would help.

No UI may show a score without a path to these factors.

## V0 Acceptance

- Same inputs always produce the same score and action.
- Every point contribution maps to a named factor.
- Every finding is traceable to a rule.
- The AI cannot change scores, thresholds, or action ranking.
- Opening the app / checking in does not change the score or award XP.
- A wealth-down day never produces alarm, shame, or a red-faced mascot.
- Bad financial state does not break the streak by itself.

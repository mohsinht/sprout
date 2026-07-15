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

| Factor                          | Weight | What It Measures                                                                |
| ------------------------------- | -----: | ------------------------------------------------------------------------------- |
| Goal pace                       |     25 | Progress against active goals (remaining-to-target trajectory).                 |
| Cash buffer                     |     20 | Emergency buffer or available-cash runway in months.                            |
| Contribution consistency        |     15 | Regular contributions to goals/holdings over recent weeks.                      |
| Diversification / concentration |     10 | Spread across asset types and currencies; penalty for single-holding dominance. |
| Volatility-adjusted trend       |     10 | Wealth trend stability over recent days (reward steady, penalize sharp swings). |
| Bill coverage                   |     10 | Upcoming bills covered by available cash.                                       |
| Debt or fixed commitments       |      5 | Debt/required payment pressure, if present.                                     |
| Data confidence                 |      5 | How many important items need confirmation / stale prices.                      |

Total: 100.

> **Removed:** "Spending pace" (20) and "Salary/income timing" (5) and
> "Investment/long-term bucket freshness" (5) and "Check-in consistency" (5)
> are removed as standalone factors. Spending pace and bill coverage are
> still relevant for the cash use case but are no longer the hero — they
> fold into "Bill coverage" and "Cash buffer." Income timing remains a
> _finding_ (not a score factor) when a confirmed income date is missing.
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

#### Expense model and capture guard

`monthlyExpenses` is the mean of up to the three most recent **complete
calendar months** of confirmed outflows. It is unavailable until one complete
month exists. Outflows exclude goal contributions, holding/investment
purchases, and transfers between the user's own accounts.

If one observed month differs from the median of the observed set by more than
50%, use the median rather than the mean and attach the explanation note `one
unusual month set aside`. This is a deterministic seasonal/outlier guard,
including for Ramadan and Eid spending; it is not an assertion that the spend
was incorrect.

If confirmed logged outflows are below 25% of confirmed monthly income, mark
expense capture `partial`. In that state, `emergencyBufferMonths` is
unavailable, the cash-buffer factor is omitted from the score, data confidence
drops, and copy says `based on the expenses you've logged`. The product must
not display a numeric buffer estimate from implausibly incomplete capture.

Formula:

```text
cashBufferPoints = clamp(emergencyBufferMonths / 3, 0, 1) * 20
```

Explanation examples:

- Positive: "Emergency buffer covers 3.2 months."
- Attention: "Emergency fund is below one month of expenses."

### Contribution Consistency, 15 points

Input: `contributionConsistencyRatio`. This measures the _habit of adding to
wealth_, not the amount, and must be cadence-aware:

- For confirmed monthly income, use the fraction of the last three completed
  salary cycles with at least one contribution. Calendar months are the v1
  fallback when salary-cycle boundaries cannot be established.
- For freelance or unknown cadence, use the fraction of the last three
  complete calendar months with at least one contribution.
- Synthetic `opening_balance` ledger entries never count as contributions.

Do not use a four-week weekly ratio: it incorrectly grades a disciplined
monthly payday saver as inconsistent.

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

### Goal pace and contribution amount

For a goal with a deadline, compare funded percentage with linear elapsed-time
percentage from creation to deadline, evaluated at the **last completed month
boundary**. Mid-cycle days do not change the label. Recompute from the new line
after an edited deadline; retain no penalty memory.

- `on_track`: actual pace is at least 85% of expected pace.
- `slightly_behind`: actual pace is at least 60% but below 85%.
- `needs_review`: actual pace is below 60%.

For a deadline-less goal, show raw funded percentage and never invent a dated
pace. Its action copy is non-numeric, such as `Add to your car goal`.

For a dated goal, the raw suggestion is
`min(remainingTarget, remainingTarget / max(1, remainingMonths))`. Round down
to denominations a person can actually move:

- below PKR 25,000: nearest PKR 1,000;
- PKR 25,000–99,999: nearest PKR 5,000;
- PKR 100,000–249,999: nearest PKR 10,000;
- PKR 250,000 and above: nearest PKR 25,000.

Use natural lakh wording where appropriate. A numeric suggestion is allowed
only when affordability can be checked. If it exceeds 40% of confirmed monthly
income or exceeds known safe-to-spend, replace it with `This goal's deadline
may need a review` linking to the goal editor. If neither affordability input
is known, use a non-numeric action. Prioritize the contribution action around
the confirmed salary date; prefer smaller non-money actions mid-cycle.

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
- Partial expense capture never produces a numeric cash-buffer claim.
- Monthly payday contributions are evaluated by completed cycles, not weeks.
- The Eid-spike, monthly-payday-saver, and unaffordable-deadline golden fixtures pass.

### Pakistan golden fixtures

1. **Eid spike:** complete-month expenses PKR 50k, 52k, and 90k yield the
   median PKR 52k (90k is more than 50% above the set median), with `one unusual
month set aside`; the spike alone must not lower the user's score.
2. **Monthly payday saver:** contributions in each of the last three completed
   monthly salary cycles yield consistency `1.0`, even though only three weeks
   in the wider period contain a contribution. `opening_balance` is ignored.
3. **Unaffordable deadline:** a computed PKR 50k monthly contribution for
   confirmed PKR 100k income produces no amount CTA because it exceeds 40%; the
   action is `This goal's deadline may need a review` and opens the goal editor.

- Opening the app / checking in does not change the score or award XP.
- A wealth-down day never produces alarm, shame, or a red-faced mascot.
- Bad financial state does not break the streak by itself.

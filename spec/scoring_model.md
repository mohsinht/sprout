# Scoring and Finding Model

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

The score is the rounded sum of these weighted factors:

| Factor | Weight | What It Measures |
| --- | ---: | --- |
| Cash buffer | 25 | Emergency buffer or available-cash runway. |
| Spending pace | 20 | Month-to-date spend against expected pace. |
| Savings and goal pace | 15 | Progress against active goals. |
| Debt or fixed commitments | 10 | Debt/required payment pressure, if present. |
| Bill coverage | 10 | Upcoming bills covered by available cash. |
| Salary/income timing | 5 | Near-term income timing without prediction. |
| Investment/long-term bucket freshness | 5 | Whether long-term buckets are tracked and fresh. |
| Data confidence | 5 | How many important items need confirmation. |
| Check-in consistency | 5 | Honest daily check-in and goal review rhythm. |

Total: 100.

## Factor Calculations

### Cash Buffer, 25 points

Input: `emergencyBufferMonths`.

Formula:

```text
cashBufferPoints = clamp(emergencyBufferMonths / 3, 0, 1) * 25
```

Explanation examples:

- Positive: "Emergency buffer covers 3.2 months."
- Attention: "Emergency fund is below one month of expenses."

### Spending Pace, 20 points

Input: `spendingPaceRatio`.

`1.0` means spending is exactly on expected month-to-date pace.

Formula:

```text
spendingPoints = clamp((1.30 - spendingPaceRatio) / 0.35, 0, 1) * 20
```

Finding thresholds:

- `<= 1.00`: all good.
- `> 1.00` and `<= 1.15`: heads up.
- `> 1.15` and `<= 1.30`: worth doing.
- `> 1.30`: needs attention.

### Savings and Goal Pace, 15 points

Input: `savingsProgressRatio`.

Formula:

```text
savingsPoints = clamp(savingsProgressRatio, 0, 1) * 15
```

Finding thresholds:

- `>= 0.90`: all good.
- `>= 0.70`: heads up.
- `>= 0.45`: worth doing.
- `< 0.45`: needs attention.

### Debt or Fixed Commitments, 10 points

Input: `debtPaymentRatio`.

This is required debt or fixed repayment as a share of monthly income. If the user has no tracked debt, use `0`.

Formula:

```text
debtPoints = clamp(1 - debtPaymentRatio / 0.35, 0, 1) * 10
```

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

### Salary / Income Timing, 5 points

Input: `daysUntilExpectedIncome`.

For salaried users, use configured salary date. For irregular income users, use confirmed expected inflows only. Do not predict unconfirmed income.

Formula:

```text
incomeTimingPoints = clamp((7 - daysUntilExpectedIncome) / 7, 0, 1) * 5
```

If no confirmed inflow exists, score this factor as `0` and create an `income_outlook` finding that asks for confirmation only when useful.

### Investment / Long-Term Bucket Freshness, 5 points

Input: `freshLongTermBuckets`.

Formula:

```text
investmentFreshnessPoints = clamp(freshLongTermBuckets / 3, 0, 1) * 5
```

This factor is informational. It must never produce investment pressure.

### Data Confidence, 5 points

Input: `unconfirmedImportantTransactions`.

Formula:

```text
dataConfidencePoints = clamp(1 - unconfirmedImportantTransactions / 8, 0, 1) * 5
```

Finding thresholds:

- `0`: all good.
- `1-2`: heads up.
- `3-5`: worth doing.
- `6+`: needs attention.

### Check-In Consistency, 5 points

Input: `goalConsistencyRatio`.

This measures honest check-ins and goal reviews, not financial performance.

Formula:

```text
consistencyPoints = clamp(goalConsistencyRatio, 0, 1) * 5
```

Hardship must not reduce this factor when the user checks in honestly.

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

Choose exactly one action.

Priority order:

1. `needs_attention` bill coverage or cash runway.
2. `needs_attention` data quality that blocks the score.
3. `worth_doing` confirmation or manual cash logging.
4. `worth_doing` small goal/savings action.
5. `heads_up` spending pace review.
6. `all_good` check-in completion.

Tie breakers:

- Prefer actions completable inside the app.
- Prefer actions under 30 seconds.
- Prefer actions that improve data confidence before actions that move money.
- Never select an action that pressures investment or spending.

## Action XP

- `all_good`: 5-10 XP
- `heads_up`: 10-15 XP
- `worth_doing`: 15-25 XP
- `needs_attention`: 20-30 XP

XP rewards completion of the check-in behavior, not financial wealth.

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
- Bad financial state does not break check-in consistency or streak by itself.

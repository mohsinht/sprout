# AI Briefing Backend Spec

## Purpose

The AI briefing backend produces the structured daily briefing that powers Today and Sprout Explains. It should turn money data into one calm summary, one score, one action, and a ranked set of explainable findings.

## Cadence

- Runs nightly for every active user.
- Target completion: before the user's configured daily check-in notification.
- Also supports manual refresh after meaningful data changes, with rate limits.
- Today must still render if the job has not run.

## Inputs

Minimum inputs:

- User profile: name, income type, salary date or income timing, goals, locale.
- Accounts: balances, source, freshness, manual/connected status.
- Transactions: recent activity, categories, amounts, source, confidence, needs-review.
- Goals: targets, progress, pace, deadlines, next steps.
- Budget/safe-to-spend: month progress, category pace, upcoming bills.
- Income timing: days until expected salary or known irregular inflow.
- Market context: Pakistan market snapshot only when personally relevant under the market personalization rules.
- Data source state: connected sources, sync failures, stale data, low-confidence items.
- Parser health: parser versions, drift state, dedupe merge rate, and recent parse failures.
- Historical daily briefings: prior score, prior action, streak/check-in status.

## Architecture Baseline

Follow [Production Hardening](production_hardening.md) for the runtime layer:

- Flutter app.
- Small TypeScript or Go backend.
- PostgreSQL.
- Object storage for uploaded statements.
- Redis for cache and idempotency.
- Queue/worker layer for parsers, retries, and official data fetchers.
- Notification service.

Every parser/import/briefing job must be idempotent. Retry must not duplicate transactions, findings, or notifications.

## Output

The job writes a `DailyBriefing` contract. Score, finding detection, and action selection must follow [Scoring and Finding Model](scoring_model.md):

- `mascotMood`
- `greeting`
- `summary`
- `health`
- `recommendedAction`
- `glanceTiles`
- `findings`
- `sourceSummary`
- `freshness`

The model may draft language, but the backend must validate and normalize the output before the UI consumes it.

## Severity Model

Severity controls visual tone, mascot mood, ordering, and action priority.

### `all_good`

Meaning: no action required; reinforces calm.

Examples:

- Salary is close and bills are covered.
- Goal pace is on track.
- Market move is neutral for the user's current goals.

Mascot mood: thriving or content.

### `heads_up`

Meaning: worth noticing but not urgent.

Examples:

- Spending pace is slightly above usual.
- One account is stale.
- Market move is meaningful but not actionable.

Mascot mood: watchful.

### `worth_doing`

Meaning: a small action would improve the user's state.

Examples:

- Confirm three uncertain transactions.
- Add cash spending from yesterday.
- Set aside a small amount for a goal.

Mascot mood: content or watchful.

### `needs_attention`

Meaning: the user should review soon, calmly.

Examples:

- Bill due soon may not be covered.
- Low-confidence transaction affects budget.
- Account sync failed for several days.

Mascot mood: concerned.

## Ranking

Findings are ranked by:

1. User safety and trust.
2. Bills and near-term cash.
3. Data quality blocking confidence.
4. Goals and savings progress.
5. Market context.
6. Ideas and education.

The top ranked actionable finding usually becomes the recommended action, unless it would create pressure or shame.

## Guardrails

Sprout must:

- State uncertainty clearly.
- Ask about uncertain income rather than predict it.
- Avoid investment advice and FOMO.
- Avoid shame, guilt, or moral judgment.
- Never imply connected users are better users.
- Never hide stale or low-confidence data.
- Never create a black-box score.

## Failure and Fallback Behavior

### Job Missing

Use the latest local/cache data. Show freshness as `local_fallback`. Greeting remains useful.

### Job Failed

Show a calm message: "I could not refresh last night's scan, so I am using what I already know." Keep Quick Add and Money usable.

### Thin Data

Generate a manual-first briefing. Lead with what the user can do without connections.

### Stale Sources

Include stale source information in `sourceSummary` and Settings. Do not silently trust stale balances.

### Low Confidence

Route uncertain transactions to one-tap confirmation. Findings should say what is uncertain and why.

## Validation

Before saving a briefing:

- Validate against schema.
- Ensure one and only one primary recommended action.
- Ensure every score factor has an explanation.
- Ensure every finding has severity and confidence.
- Ensure copy passes tone checks.
- Ensure no unsupported prediction is present.
- Ensure all referenced source IDs exist.
- Ensure parser versions and dedupe fingerprints exist for captured transactions.

## Backend Acceptance

- Nightly job can produce a valid briefing from mock/manual-only data.
- UI can render a useful Today screen when the job fails.
- Severity changes mascot mood and visual priority.
- Every finding has "why" detail for Sprout Explains.
- Recommended action is small, concrete, and completable.

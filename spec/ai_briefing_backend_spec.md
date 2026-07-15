# AI Briefing Backend Spec

> **Realignment note (2026-07-09):** The nightly job is reframed around the
> wealth-health tracker automation. It now fetches holdings, pulls
> NAVs/redemption prices and FX with dates+sources, reconciles units,
> computes a `WealthSnapshot` (today + MTD + main reason), generates the
> interpretation, detects `WealthEvents` with yesterday-continuity, and
> selects one goal-relative next-step. Provenance validation is added: no
> valuation without a dated price/FX source. Stale-price/stale-FX handling
> is required (label it, don't silently trust). "Check-in" is removed from
> the job's action selection. All guardrails are preserved.

## Purpose

The AI briefing backend produces the structured daily briefing that powers Today and Sprout Explains. It turns overnight wealth analysis into one calm summary, one score, one goal-relative action, a wealth snapshot with movement and "why," and a ranked set of explainable findings.

## Cadence

- Runs nightly for every active user.
- Target completion: before the user's configured daily check-in notification.
- Also supports manual refresh after meaningful data changes, with rate limits.
- Today must still render if the job has not run.

## Inputs

Minimum inputs:

- User profile: name, income type, salary date or income timing, goals, locale.
- **Holdings:** mutual funds (fund code, units, NAV, price date, source), multi-currency cash (currency, balance, FX rate, FX date, source), PKR cash, equities if present.
- **Price quotes:** dated NAVs/redemption prices per fund, with source label and URL.
- **FX rates:** dated USD/PKR, EUR/PKR (and others as needed), with source label.
- **Unit reconciliation:** user-uploaded Al Meezan statement for unit reconciliation (optional but recommended for accuracy).
- Accounts: balances, source, freshness, manual/connected status.
- Transactions: recent activity, categories, amounts, source, confidence, needs-review.
- Goals: targets, progress, pace, deadlines, next steps, remaining-to-target.
- Budget/safe-to-spend: month progress, category pace, upcoming bills.
- Income timing: days until expected salary or known irregular inflow.
- Market context: Pakistan market snapshot only when personally relevant under the market personalization rules.
- Data source state: connected sources, sync failures, stale data, low-confidence items, stale prices/FX.
- Parser health: parser versions, drift state, dedupe merge rate, and recent parse failures.
- Historical daily briefings: prior score, prior action, prior WealthSnapshot, streak/check-in status.

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
- `wealthSnapshot` — total wealth, per-holding breakdown, change vs yesterday, change MTD, main reason, interpretation lines, 6-day trend, provenance summary
- `wealthEvents` — dated events with yesterday-continuity, each with `plainWhy` and optional `learnMoreId`
- `recommendedAction` — one goal-relative next-step (never a check-in)
- `glanceTiles`
- `findings`
- `sourceSummary`
- `freshness`

The model may draft language, but the backend must validate and normalize the output before the UI consumes it.

## Wealth Job Pipeline

The nightly job follows this sequence (mirroring the canonical automation example):

1. **Fetch holdings:** pull current fund units (from reconciled statement or connected source), Wise multi-currency balances, and PKR cash.
2. **Pull and validate prices/FX:** versioned fetchers read dated NAVs/redemption prices per fund and dated FX rates. Al Meezan observations are cross-checked with MUFAP for matching fund/date. Every accepted observation carries `asOf`, source, fetcher version, and validation status. Failed or disputed observations are quarantined; the last trusted value may only continue as explicitly stale.
3. **Reconcile units:** cross-check fund units against the user-uploaded Al Meezan statement. Flag discrepancies for review; never silently override.
4. **Persist WealthSnapshot:** calculate `valuePkr` per holding, sum to `totalPkr`, compute `changeVsYesterday` and `changeMtd` from durable prior snapshots, determine `mainReason`, and generate interpretation. Upsert one canonical snapshot per user and `Asia/Karachi` date. Never compute history only on read.
5. **Detect WealthEvents:** identify per-holding NAV moves, FX moves, contributions, withdrawals, bills, and goal milestones. Each event references prior-day context where available ("Al Meezan pulled back after yesterday's jump"). Mix good and not-good honestly.
6. **Select recommended action:** choose one goal-relative, concrete next-step per the scoring model's priority order. Never a check-in. Never investment advice with implied certainty.
7. **Attach learn-later threads:** for events worth learning (e.g. "why do fund NAVs move?"), attach a `learnMoreId` linking to a `LearnThread`.

## Insights Generation

Insights follow the shared-fact → deterministic personal join → optional
budgeted rewrite architecture in [Insight Engine Spec](insight_engine_spec.md).
AI is a presentation layer, never the source of facts, math, relevance, or
action priority.

Pipeline:

1. Gather candidate facts with provenance: policy-rate moves, inflation, FX,
   car/goal price context, and market moves only when they can affect the
   user's holdings, goals, cash, or currencies.
2. Join candidates against the user's actual holdings, goals, and balances.
3. Versioned deterministic templates write the world→user framing: what
   happened, what it means for this user, optional action, and calm explanation.
4. Only notable events, milestones, `needs_attention` items, and the monthly
   recap may receive an AI rewrite. Rewrites are cached by canonical input hash
   and skipped when the daily cost cap is reached.
5. The validator drops any item without personal relevance, provenance, date,
   safe tone, or deterministic fallback text.
6. The UI receives a finite list, usually 3–6 items, plus a quiet-week state
   when nothing meaningful applies.

Validation:

- Every Insight must complete: "[something happened] → here's what it means
  for your [holding/goal/cash]."
- No generic headlines.
- No FOMO, "buy now," guaranteed-return language, or unsupported prediction.
- Provenance and as-of date are required.
- Quiet weeks are allowed and should not be padded.

## Provenance Validation

Before saving a briefing:

- **No valuation without a dated price/FX source.** Every `Holding.valuePkr` must trace to a `PriceQuote` (for funds) or `FxRate` (for non-PKR cash) with an `asOf` date and `source` label. If missing, the holding is marked `freshness: "unavailable"` and excluded from the total, with a finding.
- **Stale price/FX handling:** if a NAV is older than the expected cadence (e.g. 2+ market days stale) or FX is older than 1 business day, mark the holding `freshness: "stale"`, label it in the UI, and include a finding. Never silently trust a stale price.
- **Provenance summary:** `wealthSnapshot.provenanceSummary` must state the dated sources used (e.g. "Al Meezan prices valid 7 Jul 2026; FX from Xe: USD/PKR 277.992, EUR/PKR 317.536").
- **Cross-validation:** a disputed Al Meezan/MUFAP observation is not published
  as fresh. AI never chooses between numeric sources.
- **Calendar continuity:** market-day freshness uses versioned Pakistan market
  calendar data. A failed fetch still produces the canonical PKT-date snapshot
  from last-trusted stale/unavailable observations.

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

Include stale source information in `sourceSummary` and Settings. Do not silently trust stale balances. **Stale prices/FX are labelled on the holding and in the WealthSnapshot** — the user sees "NAV updated 3 days ago" or "FX rate from 2 days ago," never a silently stale valuation.

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
- **Ensure every holding valuation has a dated price/FX source** (provenance validation).
- **Ensure every `WealthEvent` has a `plainWhy`** — no event without its driver.
- **Ensure `wealthSnapshot.changeVsYesterday` and `changeMtd` are both present** — always shown together.
- **Ensure the recommended action is goal-relative** (has `goalRelativeNote` or targets a goal/holding).
- **Ensure no "check-in" action is selected** — opening the app is not an action.
- **Ensure every Insight is personally relevant and provenance-backed** — no
  generic feed item is saved.

## Backend Acceptance

- Nightly job can produce a valid briefing from mock/manual-only data.
- UI can render a useful Today screen when the job fails.
- Severity changes mascot mood and visual priority.
- Every finding has "why" detail for Sprout Explains.
- Recommended action is small, concrete, goal-relative, and completable.
- **WealthSnapshot includes total, change vs yesterday, change MTD, main reason, and interpretation.**
- **Every WealthEvent has a plain-language "why."**
- **Every holding valuation exposes dated price/FX provenance.**
- **Stale prices/FX are labelled, never silently trusted.**
- **No "check-in" action is ever selected.**
- **Snapshot persistence is idempotent per user/PKT date and history-backed.**
- **Price/FX fetchers are versioned, golden-tested, and drift-observed.**
- **Disputed observations are quarantined, never silently fresh.**

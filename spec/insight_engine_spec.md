# Insight Engine Spec

## Purpose

Sprout turns shared, sourced world facts and the user's own confirmed money
events into a small set of personally relevant insights. Deterministic code is
the analyst, approved templates are the writer, and AI is an optional editor.
AI never performs financial arithmetic, decides relevance, selects an action,
or resolves disputed source data.

This engine does not create a chat surface, generic market feed, speculative
return comparison, or daily commentary quota. A quiet week is valid.

## Architecture

### Shared World Fact Store

One source job gathers facts shared by every user. Candidate sources include
SBP policy data, PBS CPI, accepted FX rates, and accepted NAV changes. Source
adapters remain unavailable until formats, terms, parser versions, freshness
rules, and golden samples are verified.

One optional AI call may normalize already sourced text into the WorldFact
schema. The deterministic fallback is required. The model cannot invent a
fact, magnitude, date, source, affected asset class, or currency.

### Deterministic Personal Join

Code joins each WorldFact against actual holdings, currencies, and goals. A
fact that matches nothing produces no insight. Results are ranked by safety,
direct relevance, magnitude, freshness, and goal relevance, then capped at
3–6. The engine never pads the list.

Copy comes from a reviewed, versioned template keyed by fact kind, matched
user object, and direction. Every insight retains the fact/event id, source,
date, template id/version, and matched object ids.

### Budgeted AI Editing

AI may rewrite approved text fields only. It is skipped for quiet/all-good
states and invoked only for a notable movement, milestone, needs-attention
finding, or monthly story. Notable thresholds require configuration backed by
source research and tests; prompts and UI never invent them.

Rewrites are cached by a privacy-safe input hash. A hard daily cost cap
degrades to templates. No user loses a briefing because AI is unavailable or
over budget.

## WorldFact Contract

```ts
type WorldFact = {
  id: string;
  kind: "policy_rate" | "cpi" | "fx_move" | "nav_move" | "goal_cost_context";
  observedOn: string;
  validFrom?: string;
  magnitude?: number;
  unit?: "percent" | "percentage_point" | "pkr" | "index";
  direction: "up" | "down" | "flat" | "changed";
  sourceId: string;
  sourceLabel: string;
  sourceUrl?: string;
  sourcePublishedAt?: string;
  freshness: "fresh" | "recent" | "stale" | "unavailable";
  plainSummary: string;
  affectsAssetClasses: string[];
  affectsCurrencies: string[];
  affectsGoalTypes: string[];
  normalizer: "deterministic" | "ai";
  normalizerVersion: string;
  createdAt: string;
};
```

Stable uniqueness is source + kind + observed date + affected instrument or
currency. Retry updates/confirms the same fact rather than duplicating it.

## PersonalInsight Contract

```ts
type PersonalInsight = {
  id: string;
  stableKey: string;
  userId: string;
  worldFactId?: string;
  wealthEventId?: string;
  matchedHoldingId?: string;
  matchedGoalId?: string;
  matchedCurrency?: string;
  headline: string;
  personalMeaning: string;
  detail: string;
  deterministicHeadline: string;
  deterministicPersonalMeaning: string;
  deterministicDetail: string;
  severity: "all_good" | "heads_up" | "worth_doing" | "needs_attention";
  sourceLabel: string;
  sourceUrl?: string;
  asOf: string;
  freshness: "fresh" | "recent" | "stale";
  templateId: string;
  templateVersion: string;
  presentationMode: "deterministic" | "ai_rewrite";
  rewriteInputHash?: string;
  generatedAt: string;
};
```

An insight references exactly one WorldFact or one WealthEvent. Its stable key
is user + origin + template version, and its deterministic fields always remain
available even after an AI rewrite. It completes:
"something happened -> this is what it means for this user's money."

## Required States

- Populated: 3–6 ranked personally matched insights at most.
- Empty/zero connection: quiet state; never a connection gate or generic feed.
- Offline: last validated insights with cached date and offline label.
- Stale: visible source and as-of date; no fresh presentation.
- Error: last validated insights or quiet state plus recorded source/job error.
- Success: persisted facts and insights are idempotent, explainable, and dated.

## Cost and Privacy Controls

- Shared normalization is at most one optional AI call per source batch.
- Per-user AI is skipped unless an approved trigger is present.
- Cache keys omit raw descriptions, names, account references, and balances.
- Log cost, model, mode, cache hit, and budget-degradation reason.
- Runtime logs state deterministic or AI mode without printing credentials.

## Rejected Directions

- Chat with Sprout.
- Infinite or generic market/news feeds.
- "What if you invested in X" comparisons.
- AI-computed money, relevance, source truth, or action ranking.
- Padding quiet periods to meet an engagement quota.

## Acceptance

- Every insight traces to a fact/event id with date and source.
- A user with no matching money objects gets zero facts-based insights.
- Template output passes copy guardrails in tests.
- AI is schema locked; deterministic fallback remains valid.
- Daily AI spend is capped and cap exhaustion is tested.
- Quiet weeks remain quiet.
- Stale/error/offline states never present a fact as fresh.

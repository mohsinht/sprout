# Market Personalization Spec

> **Realignment note (2026-07-09):** Market/news context is sharpened: it
> appears **only** to explain the user's own holding movement or goal impact.
> No feed. No generic headlines. Every market appearance must tie to a
> `WealthEvent` or goal. If it doesn't move *your* wealth or *your* goal, it
> doesn't appear on Today.

## Purpose

Market context should answer "does this affect me?" It must not become decorative KSE filler, investment pressure, or a news feed.

## Product Decision

Market is a Phase 2 personalized insight, not a mandatory Phase 1 Today tile. **It appears only to explain the user's own holding movement or goal impact — never as a feed.**

Today may show a market tile only when at least one of these is true:

- The user has a tracked investment, mutual fund, or long-term bucket affected by market movement **and** that movement explains a visible change in the user's tracked holding value (a `WealthEvent` of kind `nav_move` or `news_context`).
- The user has selected a goal where inflation or market context changes the explanation.
- The market move is large enough to explain a visible change in the user's tracked investment value.

If none of these are true, replace the market tile with a more relevant tile such as bill, salary, cash runway, or scan summary. **No generic headlines. If it doesn't move *your* wealth or *your* goal, it doesn't appear on Today.**

## Data Source

Phase 2 needs a licensed or allowed source before production use. Candidate source class:

- Pakistan equity index feed such as KSE-100 / PSX market data.
- MUFAP-style NAV snapshots for mutual funds.
- Inflation or policy-rate context from a reliable public source when relevant.

Named baseline sources:

- MUFAP for daily mutual-fund NAVs and fund metadata.
- SBP EasyData for official macro indicators where relevant.
- PBS CPI for inflation context.
- Sarmaaya only as optional commercial enrichment.

The spec does not approve scraping or unlicensed redistribution. Until a source is approved in [Data Sources Registry](data_sources_registry.md), market data remains mock or disabled.

## MarketSnapshot Contract

Market data should include:

- Index or fund label.
- Date/time.
- Move value and percentage.
- Source label.
- Source freshness.
- Relevance reason.
- Personalized meaning.
- Severity.

## Personalization Rules

### User Has No Investments

Default: do not show a market tile.

Allowed exception: inflation or policy-rate context is directly relevant to a goal, such as "car fund target may need review this quarter."

### User Has Money Market / Cash Fund

Explain stability and freshness. Avoid daily index drama.

Example:

"Your Al Meezan Cash Fund NAV updated yesterday. This is mainly a freshness check, not a reason to move money."

### User Has Equity Fund

Explain movement calmly in relation to long-term goal timing.

Example:

"The KSE-100 moved down 1.2%. Your car goal is still 18 months away, so today's move is context, not an action."

### User Has Near-Term Goal

Market movement should rarely affect the action. Cash safety and bill coverage take priority.

### Large Market Move

If the market moves sharply and the user has relevant holdings, severity can become `heads_up`. It should not become `needs_attention` unless the user's own near-term plan is affected.

## Severity Rules

- `all_good`: data fresh, small movement, no action.
- `heads_up`: notable movement or stale market/NAV data.
- `worth_doing`: review allocation only if a user goal or stale holding requires review.
- `needs_attention`: reserved for data integrity or near-term cash risk, not normal market movement.

## Fallback States

### No Market Data

Do not show an error tile unless the user has market-linked holdings. If holdings exist, show:

"Market data did not refresh. Your saved balances are still here."

### No Investments

Use a more relevant Today tile. Do not teach markets just to fill space.

### Mock Data

Label internal/demo environments clearly. Production UI must not present mock market data as real.

## Acceptance

- Market tile is hidden when it is not personally relevant.
- **Every market explanation names why it matters to this user.**
- **Every market appearance ties to a WealthEvent or goal** — no generic headlines.
- Market insight never recommends "buy", "sell", or "invest now".
- Data source and freshness are visible in Sprout Explains.
- Missing market data does not block the daily check-in.
- **Market context never appears as a feed.**

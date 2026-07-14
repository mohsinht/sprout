# Data Sources Registry

> **Realignment note (2026-07-09):** The real, named sources from the
> canonical wealth automation example are added: **Al Meezan** fund
> redemption prices (fund codes AMMF/MIF/MSF/MDIP/MFPF-AAP), **Xe** for
> USD/PKR & EUR/PKR FX, **Wise** for multi-currency cash balances, and
> user-uploaded Al Meezan statement for unit reconciliation. MUFAP is noted
> as an alternative/validation NAV source. Cadence, cost, and reliability
> are specified for each.

## Purpose

This registry lists external data sources Sprout can use, what each source feeds, cost posture, cadence, and product constraints.

Use official or semi-official free sources as the foundation. Treat commercial sources as enrichment, not product-critical dependencies.

## Registry

| Source | Type | Feeds | Access / Cost | Refresh Cadence | Product Notes |
| --- | --- | --- | --- | --- | --- |
| Manual entry | User-entered | Transactions, goals, cash, income notes | Free, first-party | Instant/local | Foundation for MVP and offline use. |
| Gmail API | User-permissioned email | Salary, bills, receipts, alerts | OAuth, Google policy/scopes | Push/webhook or periodic sync | Best non-bank MVP capture path. Use finance senders and least privilege. |
| Microsoft Graph | User-permissioned email | Salary, bills, receipts, alerts | OAuth, Microsoft scopes | Change notifications or periodic sync | Needed for Outlook/Hotmail users. |
| Statement import | User upload | Transaction history, balances | Free; parser work required | User-triggered | CSV/XLSX/PDF/MT940/CAMT/QIF where available. Discard source file by default. |
| Android SMS | Device permission | Bank/wallet alerts | Store-policy constrained | Near real-time on Android only | Optional fallback. Not available on iOS. Play Store approval is a risk. |
| MUFAP | Public/semi-official market data | Mutual-fund NAVs, returns, AUM, categories | Free public access; no guaranteed API | Daily market days | Good foundation for mutual-fund snapshots. Respect source terms. Alternative/validation NAV source for Al Meezan funds. |
| Al Meezan redemption prices | Official fund provider | Fund NAVs/redemption prices per fund (AMMF, MIF, MSF, MDIP, MFPF-AAP) | Free public access (Al Meezan website/official PDF) | Daily (market days) | **Primary NAV source for Al Meezan holdings.** Each price carries an as-of validity date. Used in the canonical wealth automation example. |
| Xe FX rates | Commercial FX data provider | USD/PKR, EUR/PKR (and other pairs as needed) | Free public access; paid API for higher cadence | Intraday (free: daily; paid: intraday) | **Primary FX source for multi-currency cash holdings.** Each rate carries an as-of date. Used in the canonical example (USD/PKR 277.992, EUR/PKR 317.536). |
| Wise API / exports | Partner/API and user export | Foreign balances (USD, EUR, etc.), statements, conversions | Partnership/API terms or user exports | Webhooks/exports | **Primary source for multi-currency cash balances.** Partnership track; exports are safer for MVP. Provides the Wise USD/EUR cash holdings. |
| Al Meezan statement (user upload) | User-uploaded document | Fund unit reconciliation, folio details | Free; parser work required | User-triggered | **Unit reconciliation source.** Cross-checks fund units against the official statement. Discard file after parsing by default. |
| SBP EasyData | Official public data | Macro context, policy, selected indicators | Free public access | Source-dependent | Use for Pakistan context and learning/explanations. |
| PBS CPI | Official public data | Inflation context | Free public access | Monthly | Use for inflation explanations and goal target reviews. |
| FBR tax cards / budget notes | Official public data | Salary tax lessons, tax estimates | Free public access | Annual/budget-cycle | Use for Learn/Sprout Explains. Keep dated and versioned. |
| SBP regulated institutions list | Official public data | Institution verification | Free public access | As published | Use to verify referenced banks/EMIs/PSPs. |
| Sarmaaya | Commercial platform | Market analytics, mutual funds, watchlists | Paid/commercial | Vendor-dependent | Enrichment only. Not a free foundation. |
| 1LINK APIs | Institutional/payment rails | Payment products, merchant/institution flows | Sandbox/certification/commercial | Partner-dependent | Not a retail PFM feed. Do not treat as account aggregation. |
| Bank partnerships | Commercial partnership | Account data, statements, referrals | Negotiated | Partner-dependent | Phase 3+. Not MVP foundation. |

## Non-Foundation Sources

The research did not identify a reliable Plaid-style retail bank aggregator for Pakistan. Product language should not imply universal "connect your bank" support.

Use:

- "Connect email."
- "Import statement."
- "Add manually."
- "Optional Android SMS."
- "Bank partnerships later."

Avoid:

- "Connect any Pakistani bank."
- "Automatic bank sync for everyone."

## Source Freshness Labels

Every external data source should expose:

- Source name.
- Last refresh time or label.
- Freshness: `fresh`, `recent`, `stale`, `unavailable`, or `mock`.
- Confidence.
- Delete/disconnect control where applicable.

## Valuation Pipeline Reliability

NAV/redemption-price and FX fetchers are financial parsers, even when their
inputs come from an official website or PDF. They receive the same rigor as
transaction parsers:

- Every fetcher has a name, version, supported source shape, golden samples,
  last-success timestamp, and drift/error metrics.
- Al Meezan is the primary source for its redemption prices. MUFAP is an
  independent checksum for matching fund/date observations, not merely a
  manual fallback.
- A disagreement between primary and validation sources is never resolved by
  silently choosing one. The quote is held from fresh publication, the last
  trusted dated quote remains available as labelled stale data, and the
  discrepancy is observable for review. The numeric tolerance is an
  implementation-owned configuration backed by source research and tests; it
  is not invented in UI or AI code.
- A failed or drifted fetch never skips the user's day and never fabricates a
  replacement value. The daily snapshot is still produced from the last
  trusted quote with explicit stale/unavailable provenance.
- Source HTML/PDF samples and parser versions are retained for reproducible
  incident analysis without retaining user financial documents.

Before real valuations are exposed to users, this pipeline runs headlessly on
its production cadence for at least 14 consecutive days. Launch review must
inspect fetch success, stale rate, cross-source disagreement, and correction
incidents. A calendar duration alone is not proof of reliability.

## Acceptance

- Market, tax, and macro features name their source and freshness.
- Commercial sources are optional enrichment.
- Mock source data is never presented as live production data.
- Bank aggregation is not assumed without partnership.
- Source registry is reviewed before adding any new external dependency.
- **Every holding valuation names its dated price/FX source** (Al Meezan prices with validity date; Xe FX with as-of date).
- **Stale prices/FX are labelled** with the as-of date and freshness status, never silently trusted.
- **Al Meezan fund codes** (AMMF/MIF/MSF/MDIP/MFPF-AAP) are used to identify specific funds in holdings and price fetches.
- Price and FX fetchers are versioned and covered by golden samples.
- MUFAP cross-validation failures prevent a disputed Al Meezan observation
  from being silently published as fresh.
- Fetch failure produces a labelled-stale or unavailable snapshot, never a
  skipped day or invented value.

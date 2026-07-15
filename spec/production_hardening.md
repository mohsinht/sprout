# Production Hardening

## Purpose

This document defines the minimum production layer beneath the UX specs before Sprout handles real financial data from strangers.

## Recommended Stack

MVP architecture:

- Flutter mobile app.
- Small TypeScript or Go backend.
- PostgreSQL for structured data.
- Object storage for uploaded statements.
- Redis for cache, idempotency, and short-lived job coordination.
- Queue and worker layer for parsers, imports, market/tax fetchers, and retries.
- Notification service.
- Analytics and feature flags.

The stack should optimize reliability, auditability, and simple operations over novelty.

## Auth Baseline

Minimum:

- App account.
- Device binding.
- Passkey or biometric unlock where available.
- Refresh tokens encrypted at rest.
- Secrets never stored in client apps.
- Server-side secrets manager.
- Session revocation.
- Suspicious device/session review.

## Connector Baseline

- Gmail and Outlook delegated OAuth first.
- Finance sender allowlist.
- Narrowest practical scopes.
- Webhooks/change notifications where available.
- Bank connectors only through explicit partnerships.
- No stored bank passwords.
- No screen scraping.

## Queue and Idempotency

Every parse/import job must be idempotent.

Use stable job keys for:

- Email message ID.
- Statement file ID.
- SMS message source ID where available.
- Data source fetch date/window.
- Market/tax source version.

Workers must safely retry without duplicating transactions or notifications.

Daily WealthSnapshot writes use a stable user + `Asia/Karachi` date key.
Retries update/confirm the same canonical snapshot rather than appending a
second history point.

Shared WorldFact writes use a stable source + kind + observed date + affected
instrument/currency key. PersonalInsight writes use a stable user + fact/event

- template-version key. Goal contributions accept a client idempotency key;
  the progress update and immutable ledger insert commit in one transaction.

## AI Cost and Degradation Gate

- All score, relevance, pace, affordability, and action decisions run without AI.
- Optional rewrites are cached by a privacy-safe canonical input hash.
- Enforce a hard daily spend/call cap before dispatch, with a separate monthly-recap budget.
- Budget exhaustion, provider error, timeout, or schema rejection serves the
  reviewed deterministic template and never fails the briefing.
- Record model, prompt/template version, estimated cost, cache hit, and
  degradation reason without logging financial descriptions or credentials.

## Valuation Pipeline Gate

Treat NAV/redemption-price and FX fetchers as production parsers:

- Version fetchers and keep sanitized golden source samples.
- Cross-check Al Meezan fund/date observations with MUFAP.
- Quarantine unresolved discrepancies; AI never arbitrates numeric truth.
- Persist the daily snapshot even when an input is stale or unavailable.
- Use a versioned Pakistan market calendar for market-day expectations.
- Run the production cadence headlessly for at least 14 consecutive days
  before exposing real valuations. Review success, stale, disagreement, and
  correction evidence before enabling users.

## Object Storage

Uploaded statement files:

- Virus/malware scan where practical.
- Access limited to parser workers.
- Discard after parsing by default.
- Retain only if the user explicitly chooses retention.
- Store extracted transactions separately with source references.

## Webhooks

Prefer:

- Gmail push notifications.
- Microsoft Graph change notifications.
- Wise webhooks where partnership/API use exists.

Polling is acceptable as a fallback, not the primary design for email capture.

## Offline and Local Security

Mobile app must cache:

- Today view.
- Recent transactions.
- Categories.
- Pending Quick Add entries.
- Prompts/check-in state.

Local cache must be encrypted where sensitive. The app should remain useful with weak networks or no network.

## Observability

Track:

- Parser success/drift.
- Dedupe merges.
- Queue retries and dead letters.
- Notification delivery and opens.
- Briefing job success/failure.
- Source freshness.
- User corrections on low-confidence items.
- NAV/FX fetch success by source and fetcher version.
- Stale/unavailable valuation rate by holding and user snapshot.
- Primary-vs-validation disagreement and quarantine rate.
- Snapshot gaps, duplicate PKT dates, and market-calendar version.
- WorldFact duplicate rate, join/template version, insight quiet-state rate.
- AI rewrite calls, cache hits, estimated cost, cap exhaustion, and fallback reason.
- Open-to-close duration, D7/D30 return without notification prompting, and
  user correction rate as beta trust/habit indicators.

## Acceptance

- Refresh tokens are encrypted at rest.
- Parser jobs are idempotent and retry-safe.
- Statement files are discarded by default after parsing.
- Webhooks are preferred for email capture.
- Offline cache preserves the daily check-in.
- No production path requires universal bank aggregation.
- Daily snapshots are durable and idempotent per user/PKT date.
- Real valuation sources pass the headless burn-in and review gate.
- Disputed or failed valuations degrade visibly; no job silently publishes a
  questionable value as fresh.
- AI cap exhaustion and provider failure pass with deterministic copy.
- Shared facts, personal insights, and goal contributions are retry-safe.

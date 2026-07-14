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

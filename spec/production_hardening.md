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

## Acceptance

- Refresh tokens are encrypted at rest.
- Parser jobs are idempotent and retry-safe.
- Statement files are discarded by default after parsing.
- Webhooks are preferred for email capture.
- Offline cache preserves the daily check-in.
- No production path requires universal bank aggregation.

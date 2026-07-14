# Sprout Incident Response

## Severity

- **SEV-1:** unauthorized financial-data access, token/secret exposure,
  corrupted balances, or mock/disputed valuations shown as fresh.
- **SEV-2:** widespread login, sync, briefing, or deletion failure.
- **SEV-3:** isolated parser drift, stale source, notification, or UI failure
  with a safe fallback.

## First response

1. Stop the unsafe path with its feature flag; preserve manual/offline access.
2. Rotate affected secrets and revoke sessions when credentials may be exposed.
3. Preserve sanitized logs, parser/fetcher versions, source dates, job IDs, and
   deployment identifiers. Do not copy raw financial documents into tickets.
4. Quarantine disputed observations and keep the last trusted dated value
   labelled stale or unavailable.
5. Confirm delete/export requests and audit events continue to work.

## Recovery and communication

- Restore from a verified backup only into an isolated database first.
- Reconcile affected users and dates before re-enabling automated valuation.
- User communication states what happened, what data was affected, what was
  disabled, and what the user should do. Avoid minimizing uncertainty.
- Complete a blameless review with corrective tests, monitoring, and an owner
  before closing the incident.

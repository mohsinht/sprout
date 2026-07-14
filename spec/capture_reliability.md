# Capture Reliability

## Purpose

Sprout's trust depends on not double-counting, silently missing, or misclassifying money events. Parser reliability is a product requirement, not an implementation detail.

## Capture Priority

MVP capture priority:

1. Manual Quick Add.
2. Email parsing through Gmail or Microsoft Graph OAuth.
3. Statement import.
4. Optional Android financial SMS fallback.
5. Selective direct partnerships later.

Reasoning:

- Manual works for everyone and offline.
- Email works across platforms and can use OAuth/webhooks.
- Statement import is accurate and user-controlled.
- Android SMS is useful but store-policy constrained and Android-only.
- iOS has no general SMS inbox read path for this use case.

## Parser Drift

Parser drift is when a bank, wallet, or email format changes and an existing parser silently breaks.

Every parser must have:

- Parser name.
- Parser version.
- Source provider.
- Supported message/file patterns.
- Golden sample tests.
- Last successful parse timestamp.
- Drift/error metrics.
- Fallback to needs-review rather than silent confidence.

Parser failures must not corrupt the user's money state. If confidence drops, route to confirmation.

### Price And FX Fetcher Drift

The parser rules also apply to public valuation inputs: Al Meezan web/PDF
redemption prices, MUFAP validation observations, and Xe FX observations.
Each fetcher has golden source samples, a parser/fetcher version, source-shape
metadata, and last-success/drift metrics.

For a valuation source failure:

- Do not reuse the old observation while labelling it fresh.
- Do not omit the daily WealthSnapshot.
- Carry forward only the last trusted dated observation, label the affected
  holding and snapshot stale, and expose its as-of date.
- If primary and validation sources disagree outside the configured tested
  tolerance, quarantine the new observation and alert; do not let AI choose.

## Dedupe Rule

The same transaction may arrive through SMS, email, and statement import. Dedupe is mandatory.

Primary dedupe fingerprint:

```text
hash(normalizedAmount + normalizedTimestampWindow + normalizedMerchant + maskedAccountRef)
```

Fields:

- Amount.
- Timestamp or posting-time window.
- Merchant/counterparty.
- Masked account or card reference.

If two captured items share a fingerprint, merge sources into one transaction and keep the highest-confidence normalized fields. Preserve source references for audit/debug.

## Confidence Rules

High confidence:

- Amount, type, timestamp, and account are clear.
- Merchant/category is either clear or safely inferred.
- Dedupe fingerprint is stable.

Medium confidence:

- Amount and type are clear, but merchant/category/account is partial.

Low confidence:

- Missing account, ambiguous type, unclear amount, parser version degraded, or possible duplicate.

Low and medium confidence items should be visible in review and confirmable in one tap.

## Platform Reality

### Android

Financial SMS parsing can be useful but requires sensitive SMS permissions. Google Play policy may reject or restrict this path. Build it as optional fallback, not MVP foundation.

### iOS

iOS does not provide a general SMS inbox read path for budgeting apps. iOS auto-capture should use email, import, and user entry.

### Email

Use OAuth, narrow scopes, and finance sender allowlists. Prefer Gmail push and Microsoft Graph change notifications over polling.

### Statement Import

Support common formats where practical: CSV, XLSX, PDF, MT940, CAMT, QIF. Scan files, parse asynchronously, and discard originals by default.

## Parser Health Monitoring

Track:

- Parse success rate by provider and parser version.
- Needs-review rate by provider.
- Duplicate merge rate.
- Sudden drop in parsed emails/SMS per provider.
- Top unparsed sender IDs or subjects.
- User correction rate after confirmation.
- NAV/FX fetch success by source and fetcher version.
- Cross-source NAV disagreement rate and quarantined observations.
- Percentage of user snapshots containing stale or unavailable valuations.

Alert when:

- Success rate drops materially.
- Needs-review spikes.
- Duplicate rate changes sharply.
- A high-volume provider has no successful parses in the expected window.

## Acceptance

- Every captured transaction has a dedupe fingerprint.
- Every parser has a version.
- Parser failures route to review, not silent wrong data.
- Android SMS is optional and Android-only.
- iOS capture works without SMS.
- Duplicate SMS/email/import transactions merge into one transaction.
- NAV/FX drift degrades to dated stale/unavailable data without skipping the
  snapshot or publishing an unverified fresh value.

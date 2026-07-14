# Sprout Production Runbook

## Supported launch profile

The current production-safe profile is manual-first V1. Real NAV/FX values,
external connectors, and structured imports remain disabled until their
individual evidence gates pass. Disabled features must return an explicit
`FEATURE_DISABLED` response and must not silently use mock data.

## Deployment checks

1. Inject `DATABASE_URL`, `DATABASE_SSL=true`, `JWT_SECRET`, `CRON_SECRET`, `CORS_ORIGINS`, and
   `OPENAI_API_KEY` through the hosting provider's secrets manager.
2. Keep `ENABLE_REAL_VALUATIONS=false`, `ENABLE_EXTERNAL_CONNECTORS=false`,
   and `ENABLE_STRUCTURED_IMPORTS=false` for the manual-first release.
3. Terminate TLS at the managed load balancer or reverse proxy. Redirect HTTP
   to HTTPS there; the API already emits strict transport/security headers.
4. Run database migrations as a one-off release command before starting the
   new API image.
5. Verify `/health`, `/ready`, registration, login, onboarding, Quick Add,
   briefing fetch, and logout from the deployed mobile build.
6. Run `pnpm check`, `pnpm test:e2e:local` against the deployment's isolated
   staging database, and `pnpm ops:valuation-gate` when valuation burn-in is in
   progress.

Production startup intentionally fails for weak secrets, local database
credentials, wildcard/local CORS origins, mock valuation sources, or valuation
exposure without an approval timestamp and validated sources.

## Monitoring and alerts

Collect JSON application logs and alert on:

- `/ready` failures or elevated 5xx rate;
- failed daily jobs, missing PKT snapshot dates, and duplicate snapshot dates;
- stale/unavailable holdings and valuation-source failures;
- authentication throttling spikes;
- structured audit events for imported-data deletion and reconciliation;
- OpenAI fallback rate and unexpected cost growth.

Never place access tokens, refresh tokens, source credentials, statement
contents, transaction notes, or monetary values in logs.

## Backup and recovery

- Run `pnpm ops:backup` daily using encrypted storage with retention controlled
  by the hosting environment.
- Run `pnpm ops:restore-smoke -- <dump>` at least monthly and before a major
  database migration.
- Record backup timestamp, size, restore result, operator, and recovery time.
- A backup is not release evidence until a restore has succeeded.

## Valuation enablement

`pnpm ops:valuation-gate` writes a private report under `artifacts/`. The gate
requires 14 genuine daily observations, durable snapshots without duplicates,
two independent NAV sources, FX observations, and implemented cross-source
validation. A human reviews stale, disagreement, and correction incidents
before setting `VALUATION_BURN_IN_APPROVED_AT`. Never backfill fake dates to
make the report pass.

## Rollback

1. Disable risky feature flags first.
2. Roll back the API image to the last migration-compatible release.
3. If a migration is not backward compatible, restore into a separate database
   and verify before changing production routing.
4. Keep manual entries and the last trusted briefing available; never replace
   a failed source with mock or AI-generated numbers.

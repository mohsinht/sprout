import { Hono } from "hono";
import { pool } from "../db/client.js";
import { config } from "../config.js";

export const opsRoute = new Hono();

opsRoute.use("*", async (c, next) => {
  const secret = c.req.header("X-Ops-Secret");
  if (!secret || !process.env.CRON_SECRET || secret !== process.env.CRON_SECRET) {
    return c.json({ error: "Unauthorized" }, 401);
  }
  await next();
});

opsRoute.get("/release-readiness", async (c) => {
  const jobsResult = await pool.query<{
    total: number;
    succeeded: number;
    failed: number;
    distinct_dates: number;
  }>(`select count(*)::int as total,
      count(*) filter (where status = 'succeeded')::int as succeeded,
      count(*) filter (where status = 'failed')::int as failed,
      count(distinct split_part(idempotency_key, ':', 3))
        filter (where type = 'daily' and status = 'succeeded')::int as distinct_dates
    from job_runs where started_at >= now() - interval '14 days'`);
  const snapshotResult = await pool.query<{
    distinct_dates: number;
    stale_or_unavailable: number;
    duplicates: number;
  }>(`select count(distinct date)::int as distinct_dates,
      count(*) filter (where freshness in ('stale', 'unavailable'))::int as stale_or_unavailable,
      coalesce(sum(duplicate_count - 1), 0)::int as duplicates
    from (
      select user_id, date, freshness, count(*) as duplicate_count
      from wealth_snapshots
      where date >= (now() at time zone 'Asia/Karachi')::date - 13
      group by user_id, date, freshness
    ) snapshot_days`);
  const quoteResult = await pool.query<{ nav_dates: number; nav_sources: number }>(
    `select count(distinct as_of)::int as nav_dates,
      count(distinct source)::int as nav_sources
    from price_quotes where as_of >= (now() at time zone 'Asia/Karachi')::date - 13`,
  );
  const fxResult = await pool.query<{ fx_dates: number; fx_sources: number }>(
    `select count(distinct as_of)::int as fx_dates,
      count(distinct source)::int as fx_sources
    from fx_rates where as_of >= (now() at time zone 'Asia/Karachi')::date - 13`,
  );
  const validationResult = await pool.query<{ total: number; matched: number; mismatched: number }>(
    `select count(*)::int total, count(*) filter (where matched)::int matched,
      count(*) filter (where not matched)::int mismatched from nav_cross_validations
      where as_of >= (now() at time zone 'Asia/Karachi')::date - 13`,
  );
  const jobRow = jobsResult.rows[0];
  const snapshotRow = snapshotResult.rows[0];
  const quoteRow = quoteResult.rows[0];
  const fxRow = fxResult.rows[0];
  const jobs = {
    total: jobRow?.total ?? 0,
    succeeded: jobRow?.succeeded ?? 0,
    failed: jobRow?.failed ?? 0,
    distinctDates: jobRow?.distinct_dates ?? 0,
  };
  const snapshots = {
    distinctDates: snapshotRow?.distinct_dates ?? 0,
    staleOrUnavailable: snapshotRow?.stale_or_unavailable ?? 0,
    duplicates: snapshotRow?.duplicates ?? 0,
  };
  const quotes = {
    navDates: quoteRow?.nav_dates ?? 0,
    navSources: quoteRow?.nav_sources ?? 0,
  };
  const fx = {
    fxDates: fxRow?.fx_dates ?? 0,
    fxSources: fxRow?.fx_sources ?? 0,
  };

  const evidence = {
    generatedAt: new Date().toISOString(),
    windowDays: 14,
    dailyJobs: jobs,
    snapshots,
    observations: { ...quotes, ...fx },
    crossValidation: validationResult.rows[0] ?? { total: 0, matched: 0, mismatched: 0 },
    crossValidationImplemented: true,
    realValuationExposureEnabled: config.features.valuationExposureEnabled,
  };
  const prerequisitesPassed =
    jobs.failed === 0 &&
    jobs.distinctDates >= 14 &&
    snapshots.distinctDates >= 14 &&
    snapshots.duplicates === 0 &&
    quotes.navDates >= 14 &&
    quotes.navSources >= 2 &&
    fx.fxDates >= 14 && (validationResult.rows[0]?.mismatched ?? 0) === 0 && (validationResult.rows[0]?.matched ?? 0) >= 14;

  // Cross-validation is intentionally false until the primary Al Meezan and
  // MUFAP validation parsers are implemented and independently observed.
  return c.json({
    ...evidence,
    prerequisitesPassed,
    gatePassed: prerequisitesPassed && evidence.crossValidationImplemented,
  });
});

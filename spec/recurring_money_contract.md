# Recurring Money Contract

## Scope

Sprout v1 supports exactly two recurring-money frequencies:

- `monthly`: an occurrence is due on a configured day of month. Days 29, 30,
  and 31 clamp to the last calendar day of a shorter month.
- `on_salary_day`: an occurrence becomes due only when a confirmed salary
  transaction lands.

Weekly and custom recurrence are not supported in v1.

## Wealth Boundary

Recurring liabilities and expected income never mutate confirmed wealth.
They exist in exactly two product roles:

1. Input to the bill-coverage scoring factor.
2. An upcoming context tile or finding.

Confirmed wealth changes only through confirmed transactions. Creating,
editing, reaching, skipping, or stopping a recurring occurrence does not
change wealth.

## Missed Occurrences

When an occurrence date passes without a matching confirmed transaction,
Sprout creates one contextual ask:

> Rent usually leaves around now. Did it this month?

The ask offers exactly these outcomes:

- **Yes** logs the confirmed transaction.
- **No** stores the occurrence with status `skipped`.
- **Stopped** ends the recurring series without changing wealth.

Sprout never auto-deducts a liability. It asks at most once per occurrence.
Skipped occurrences are stored with status `skipped`; they are never silently
dropped.

The ask follows `information_gathering_trust.md`: one question, a one-line
reason, tap-first answers, a warm skip, and visible reversibility.

## Calendar And Timezone

Occurrence math is computed server-side in the user's stored IANA timezone.
The default timezone is `Asia/Karachi`.

An occurrence belongs to the calendar date in the user's timezone, regardless
of the server timezone. Midnight-boundary behavior must be tested for a
non-PKT user, and daylight-saving transitions must be tested with an IANA zone
that observes DST.

## Required States

- `upcoming`: due date has not passed; may inform bill coverage and context.
- `ask_pending`: due date passed without a matching confirmed transaction;
  one contextual ask is available.
- `confirmed`: matched to or created as a confirmed transaction.
- `skipped`: user answered No for this occurrence.
- `stopped`: series ended by the user; no future occurrences are generated.

## Invariants

- Occurrence generation is idempotent per series and user-local date.
- At most one ask is emitted per occurrence.
- No occurrence changes account balances or WealthSnapshot totals by itself.
- Only the Yes path creates a confirmed transaction.
- All persisted occurrence dates are the user's local calendar dates.

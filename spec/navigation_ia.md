# Navigation and Information Architecture

> **Realignment note (2026-07-09):** Money tab is confirmed as the holdings
> + trend + provenance depth surface — where the 6-day chart, per-fund
> detail, and dated price/FX provenance live. Today links into it. The
> Four tabs + center "+" is the required shell.
>
> **Insights note (2026-07-10):** The shell is updated to four required tabs
> plus the center quick-add action: Today · Money · [＋] · Insights ·
> Settings. Insights is a finite, personally-relevant world→user surface,
> not a news feed.

## Target Shell

Sprout uses a four-tab shell plus a center quick-add action:

- Today
- Money
- Insights
- Settings
- Center `+`

Today is the default route on every app open.

> **All four tabs are required and must not be dropped.** A build
> missing Today, Money, Insights, or Settings fails. The nav renders all four tabs + center
> action — this is a regression invariant (see
> `user_stories_regression_invariants.md`).

## Current Code Note

The Flutter shell renders the target four tabs. Quick Add is a center action
sheet, not a tab, and Learn remains an internal destination reached from
contextual explanations.

Relevant current files:

- `apps/mobile/lib/src/presentation/shell/app_shell.dart`
- `apps/mobile/lib/src/app/sprout_app.dart`

## Routes

Target routes:

- `/today`
- `/money`
- `/insights`
- `/settings`
- `/onboarding`
- Modal/sheet: `quick-add`
- Modal/sheet: `sprout-explains`

Optional internal/dev route:

- `/mascot-lab`

## Today

Primary job:

- Deliver daily briefing.
- Complete one recommended action.
- Provide explanations behind glance tiles.

Entry points:

- App launch.
- Check-in notification.
- Post-onboarding handoff.

Exit points:

- Quick Add.
- Money detail.
- Settings source/profile controls.
- Sprout Explains.

## Money

Primary job:

- **Inspect holdings, wealth trend, and provenance depth.**
- Inspect accounts, safe-to-spend, goals, and transactions.
- Confirm uncertain transactions.

Entry points:

- Bottom tab.
- Today tile tap (holdings, trend, or goal tile).
- Sprout Explains related action.

Exit points:

- Quick Add.
- Transaction confirm flow.
- Settings data source control.
- Sprout Explains (provenance detail, learn-later thread).

## Insights

Primary job:

- Translate personally-relevant world and market context into what it means
  for the user's holdings, goals, and cash.
- Stay finite and calm: 3–6 items when populated, quiet-week state when
  little matters, no infinite feed.

Entry points:

- Bottom tab.
- Sprout Explains related action.
- Future briefing notification when an item materially affects the user.

Exit points:

- Money holding/account detail.
- Goal editor for goal-target insights.
- Sprout Explains / Learn for context.

## Settings

Primary job:

- Profile, goals, data sources, privacy, notifications, language, motion, and balance visibility.

Entry points:

- Bottom tab.
- Data-source warning from Today or Money.

Exit points:

- Source connect/disconnect.
- Delete imported data.
- Goal edit.
- Notification preferences.

## Center Quick Add

Primary job:

- Log cash/income in about three seconds.

Behavior:

- Opens as a sheet above the current screen.
- Does not change tab selection.
- Saves locally while offline.
- Returns the user to the prior screen after success.

## Sprout Explains

Primary job:

- Explain any score, tile, finding, transaction confidence, market move, or goal pace.

Behavior:

- Opens from Today or Money.
- Keeps context of the originating element.
- Offers a next action only when useful.
- Returns to the prior screen without losing scroll/context.

## IA Acceptance

- App launch lands on Today.
- **Nav renders all four tabs (Today, Money, Insights, Settings) + center "+" action.** A build missing a primary tab fails.
- Quick Add is reachable from every primary tab.
- Quick Add is not represented as a destination tab.
- Content on Today, Money, Insights, and Settings clears the floating nav at
  1.3x text scale and is never hidden behind it.
- **Money is the holdings + trend + provenance depth surface** (6-day chart, per-fund detail, dated price/FX).
- Insights is curated, personally relevant, finite, and provenance-backed.
- Money is quieter than Today and never competes with the daily loop.
- Settings is the trust surface.
- Every insight path has a return path.

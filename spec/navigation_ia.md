# Navigation and Information Architecture

## Target Shell

Sprout uses a three-tab shell plus a center quick-add action:

- Today
- Money
- Settings
- Center `+`

Today is the default route on every app open.

## Current Code Note

The current Flutter shell includes `Today`, `Add`, `Money`, `Learn`, and `Settings` as bottom tabs. The target product IA moves Add into a center action sheet and removes Learn as a primary tab. Learning content should appear inside Sprout Explains and contextual recommendations unless the product direction changes.

Relevant current files:

- `apps/mobile/lib/src/presentation/shell/app_shell.dart`
- `apps/mobile/lib/src/app/sprout_app.dart`

## Routes

Target routes:

- `/today`
- `/money`
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

- Inspect accounts, safe-to-spend, goals, and transactions.
- Confirm uncertain transactions.

Entry points:

- Bottom tab.
- Today tile tap.
- Sprout Explains related action.

Exit points:

- Quick Add.
- Transaction confirm flow.
- Settings data source control.

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
- Quick Add is reachable from every primary tab.
- Quick Add is not represented as a destination tab.
- Money is quieter than Today and never competes with the daily loop.
- Settings is the trust surface.
- Every insight path has a return path.

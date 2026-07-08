# Notifications Spec

## Purpose

Notifications trigger the daily check-in loop. They must be useful, respectful, and never shame the user for money state or missed days.

## Notification Types

- Daily check-in.
- Bill reminder.
- Salary/income reminder.
- Weekly summary.
- Streak protection or repair.

Settings must allow each notification class to be enabled or disabled.

## Timing Logic

### Daily Check-In

Default window: 8:00 AM to 10:00 AM local time.

After enough usage, infer a preferred window from completed check-ins:

- Use the median check-in time from the last 14 completed check-ins.
- Send within 30 minutes before that time.
- Never send before 7:00 AM or after 9:00 PM.
- If the user has no history, use the default window.

### Bill Reminder

Send only for bills due within 3 days when not marked paid and cash coverage is uncertain.

### Salary / Income Reminder

For salaried users, send near configured salary date. For irregular users, only send for user-confirmed expected inflows.

### Weekly Summary

Send once weekly at a user-friendly time, default Sunday evening.

### Streak Protection

If the user has not checked in by their usual window and notifications are enabled, send one gentle reminder. Do not send repeated nagging.

## Copy Rules

- Mention one clear reason.
- Avoid shame and urgency inflation.
- Never reveal sensitive balances on lock screen by default.
- Do not mention exact transaction amounts unless the user has allowed balance/detail notifications.

## Example Copy

Daily check-in:

- "Sprout has today's money check-in ready."
- "One quick check-in can keep your streak safe today."
- "Your daily money picture is ready when you are."

Bill:

- "One bill may need a quick look before it is due."
- "School transport is coming up. Want to check it now?"

Salary/income:

- "Salary day is close. Sprout can help plan the first move."
- "You mentioned an expected payment. Want to mark whether it arrived?"

Weekly:

- "Your weekly money garden summary is ready."

Streak protection:

- "A quick honest check-in keeps the streak alive."
- "No money move required today. Just check in."

Error/fallback:

- "Sprout could not refresh everything, but today's check-in still works."

## Badge and Deep Link Behavior

- Daily check-in opens Today.
- Bill reminder opens the relevant Sprout Explains or Money bill detail.
- Salary/income reminder opens Today or income confirmation.
- Weekly summary opens Money summary.
- Streak protection opens Today.

## Privacy Defaults

- Hide balances and amounts in notification text by default.
- Use generic labels on lock screen.
- Respect system notification permissions.
- If permissions are denied, Settings should show notifications as disabled without blocking app value.

## Acceptance

- User can disable each notification class.
- Daily reminder timing adapts after enough check-ins.
- No notification shames missed days or financial hardship.
- Notification tap opens the relevant destination.
- Notifications are not required for streak preservation when the user checks in manually.

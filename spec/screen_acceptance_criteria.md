# Screen Acceptance Criteria

## App-Level

- A new user can complete onboarding without connecting any external account.
- Today is populated after onboarding.
- The daily action can be completed in under 30 seconds.
- Manual entry works offline.
- Money data shows source, freshness, or confidence.
- Every important insight has an explanation.
- Settings exposes privacy and data controls.
- Notifications have timing, copy, privacy defaults, and deep-link behavior.
- Streak repair/freeze is modeled and visible when relevant.
- No v0 feature moves funds, stores value, initiates payments, or enables merchant acceptance.
- Real captured transactions include parser version and dedupe fingerprint.
- The app remains smooth on low-end Android.

## Today

- Opens as the default landing screen.
- Shows streak, XP, greeting, mascot, summary, health score, recommended action, and glance tiles.
- Mascot is the largest visual element.
- Score animates on first reveal unless reduce-motion is enabled.
- Completing the action triggers celebration, XP, streak feedback, and sign-off.
- Bad-news state is calm and still protects the check-in streak.
- Empty/first-run state works with zero connections.
- Market tile appears only when personally relevant; otherwise a more relevant context tile appears.
- Every tile, score factor, and finding opens Sprout Explains.

## Money

- Shows accounts with balances and freshness.
- Shows safe-to-spend or budget summary.
- Shows goals with progress and next step.
- Shows transactions with source and confidence/review state.
- Uncertain transactions are confirmable in one tap.
- Offline cached data is visible.
- Stale balances are labeled.
- The screen remains quiet and un-gamified.

## Quick Add

- Opens from center `+` without changing tabs.
- Common expense can be logged without typing.
- Income can be logged through salary, freelance, gift, or other.
- Pakistani categories are present.
- Offline save works.
- Success feedback is immediate.
- Validation errors are clear and non-punitive.
- Missing amount/category/income source states use approved copy from the tone guide.
- Sheet closes back to the originating screen.

## Settings

- Shows profile, income timing, and income type.
- Goals can be edited.
- Data sources show status, confidence, freshness, and controls.
- Connect, disconnect, and delete data controls are reachable.
- Privacy copy includes no stored bank passwords, user-controlled sources, statement deletion, and confirmation for uncertain transactions.
- Notification settings are editable.
- Reduce-motion and balance visibility settings are present.
- The screen is sober and not gamified.

## Onboarding

- Introduces Sprout's daily check-in promise.
- Captures name or nickname, with skip/default.
- Offers a playful nickname generator beside the plain text option.
- Captures one goal through chips, or lets Sprout help decide later.
- Allows completion with no connections.
- Allows completion while offline using a local first briefing.
- Shows a retry path if first-briefing generation fails.
- Does not ask salary date, income type, multiple goals, or source connections before first value.
- Optional connections are framed as upgrades after core value is visible, not gates.
- Ends on a populated Today screen.
- Does not request permissions before showing core value.

## Information Gathering

- No screen or sheet asks more than one question.
- Free text appears only when choices cannot express the answer.
- Every non-required ask has a warm skip.
- Every ask states the user benefit in one line.
- Deferred fields are captured in context, one tap, and remembered.
- No surface nags users to complete a profile.
- Privacy and reversibility are visible at the point of asking.
- Source connections are never requested before core value is visible.

## Sprout Explains

- Opens from Today and Money insight surfaces.
- Explanation matches the tapped element.
- Explains what happened and why it matters.
- States uncertainty when applicable.
- Offers a next step when sensible.
- Returns to the previous screen without losing context.

## AI Briefing

- Valid briefing is generated from manual-only mock data.
- Job failure falls back to local data.
- Severity determines ordering, mascot mood, and visual treatment.
- Every finding has severity, confidence, category, and why detail.
- Recommended action is singular, small, and completable.
- Score and action follow the deterministic scoring model.
- Parser drift and low-confidence capture affect findings transparently.

## Design System

- Uses existing tokens and components.
- No new arbitrary colors, spacing, radius, or type scales.
- Text fits at mobile sizes and 1.3x text scale.
- Reduce-motion is respected.
- No nested cards.
- Icons support recognition and have labels/tooltips where required.

## Notifications

- Daily check-in notification follows the configured or inferred user window.
- Notification copy hides balances and exact amounts by default.
- Each notification deep-links to the relevant screen.
- User can disable daily, bill, salary/income, weekly, and streak-protection notifications separately.
- Notifications never shame missed days or financial hardship.

## Production Hardening

- Refresh tokens are encrypted at rest.
- Device binding and biometric/passkey unlock are supported where available.
- Parser/import jobs are idempotent and retry-safe.
- Statement files are discarded by default after parsing.
- Email capture uses OAuth and narrow scopes.
- Android SMS capture is optional, Android-only, and policy-gated.
- iOS works without SMS capture.
- No screen scraping or stored bank passwords.

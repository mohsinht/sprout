# Screen Acceptance Criteria

> **Realignment note (2026-07-09):** Today criteria are replaced with
> wealth-health criteria: total wealth + today/MTD change, every movement
> has a "why," "what happened" events reference prior days, one goal-relative
> next-step, breakdown/trend/provenance reachable on tap, wealth-down day
> stays calm, stale price/FX is labelled, opening the app never changes
> health. Money criteria are updated to include holdings breakdown and
> trend depth. AI Briefing criteria are updated for WealthSnapshot and
> provenance.
>
> **Layout-lock note (2026-07-09):** Today layout is locked as a canonical
> 13-part structure. Motion, mascot-alive, haptics, and craft fixes are now
> pass/fail acceptance checks, not optional polish.

## App-Level

- A new user can complete onboarding without connecting any external account.
- Today is populated after onboarding.
- The daily action can be completed in under 20 seconds.
- Manual entry works offline.
- Money data shows source, freshness, or confidence.
- Every important insight has an explanation.
- Settings exposes privacy and data controls.
- Notifications have timing, copy, privacy defaults, and deep-link behavior.
- Streak repair/freeze is modeled and visible when relevant.
- No v0 feature moves funds, stores value, initiates payments, or enables merchant acceptance.
- Real captured transactions include parser version and dedupe fingerprint.
- The app remains smooth on low-end Android.
- **Total wealth is always the Today hero.**
- **Opening the app never changes the health score.**

## Today

### Layout (locked)

- Opens as the default landing screen.
- **The 13-part locked layout is present in the exact order specified** (greeting+streak → mascot → wealth → movement chips → one-line read → action button → what's happening tiles → holdings rows → depth door → why it moved → goals → learn later → provenance footer). No extra elements, no reordering.
- **Above the fold (1–6) delivers the 20-second glance; below the fold is depth.**
- Total wealth is the Today hero and largest numeric element; mascot is the living emotional narrator, prominent and mood-driven without overpowering the wealth number.
- **Shows total wealth with today's change and MTD change** as the hero number.
- **Every movement has a "why"** — no change shown without its driver.
- **"What happened" events reference prior days** to form a story, not a snapshot.
- **One goal-relative next-step** is shown (not an empty ritual).
- **Breakdown, trend, and provenance are reachable on tap** (depth, not forced).

### Motion (pass/fail)

- **Wealth figure animates count-up on first reveal** (unless reduce-motion is enabled).
- **"What's happening" tiles stagger in** on load (~50ms apart, rising/fading).
- **Goal progress bars/rings fill** left-to-right on first reveal.
- **Mascot animates on load** (settle-bounce) and is mood-matched (not a static PNG by default).
- **Haptic feedback on every tile tap, chip tap, and nav tap.**
- **Action completion celebrates:** haptic + chime + confetti → calm "done" state.
- **Entrance motion holds 60fps** on the target low-end Android device; any effect that janks is simplified or cut.
- **Reduce-motion replaces all entrance motion** with calm static reveals — no information hidden, no layout broken.

### States (pass/fail)

- **Wealth-down day stays calm** — no alarm, no shame, no red-faced mascot.
- **Stale price/FX is labelled** with the as-of date, never silently trusted.
- **Opening the app never changes health.**
- Empty/first-run state works with zero connections.
- Market tile appears only when personally relevant; otherwise a more relevant context tile appears.
- Completing the action triggers celebration, XP, streak feedback, and sign-off.
- Every tile, score factor, event, and finding opens Sprout Explains.

### Craft (pass/fail)

- **Tiles are equal-height AND content-filled** — no large dead gap between icon row and title. Reduce height or top-align content.
- **Zero truncation:** tile copy is shortened at the source (1–3 word title, ≤5 word description). "Al Meezan, NAV correcti…" style clipping fails.
- **No readable body text below ~14px;** the interpretation paragraph at comfortable body size.
- **1.3× text scale survives** without clipping or broken layout.
- **Chunky depth present** on tiles and buttons — solid bottom edge, committed tints, not washed-out pastels.

## Money

- Shows holdings with per-holding value, source, freshness, and provenance.
- **6-day wealth trend chart is available as a depth element.**
- Shows accounts with balances and freshness.
- Shows safe-to-spend or budget summary.
- Shows goals with progress, remaining-to-target, and next step.
- Shows transactions with source and confidence/review state.
- Uncertain transactions are confirmable in one tap.
- Offline cached data is visible.
- Stale balances and **stale prices/FX are labelled.**
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
- Recommended action is singular, small, concrete, **goal-relative**, and completable.
- Score and action follow the deterministic scoring model.
- Parser drift and low-confidence capture affect findings transparently.
- **WealthSnapshot includes total, change vs yesterday, change MTD, main reason, and interpretation.**
- **Every WealthEvent has a plain-language "why."**
- **Every holding valuation exposes dated price/FX provenance.**
- **Stale prices/FX are labelled, never silently trusted.**
- **No "check-in" action is ever selected.**

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

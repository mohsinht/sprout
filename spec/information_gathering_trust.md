# Sprout Information Gathering and Trust Spec

## Purpose

This is the general law for how Sprout asks a user for information anywhere in the app. Onboarding is one example, not a special case.

Applies to:

- Onboarding.
- Settings edits.
- Sprout contextual asks.
- Transaction confirmation.
- Source connection.
- Goal setup.
- Income/payday confirmation.

If each surface invents its own asking pattern, trust erodes. Sprout uses one pattern everywhere.

## Core Principle

Sprout asks; the user taps. One thing at a time. Everything is skippable. If the user skips the data that would personalize the first briefing, Sprout supplies a starter path and asks again later in context.

Information gathering is a conversation with Sprout, not a form the user owes the app. The emotional target is that the user feels known, not processed.

## The Seven Laws Of Asking

### 1. One Question Per Moment

Never show two questions or two fields on one screen or sheet.

One question with a large tappable answer feels like a conversation. Two fields feel like paperwork.

### 2. Tap Beats Type

Default to:

- Chips.
- Toggles.
- Sliders.
- Single-select cards.
- One-tap confirmation.

Use free text only when choices cannot express the answer. The name/nickname field is the main exception.

### 3. Ask Only What Is Needed Now

Every field has a capture moment: the point where the answer becomes genuinely useful.

Ask at that moment, not up front. No screen should exist just to complete a profile.

### 4. Skip Is A Gift

Every ask has a visible, warm skip.

Examples:

- "Just call me friend."
- "Help me decide later."
- "I'll tell you another time."

Skipping must never feel penalized or nagged. A user who skips everything possible still reaches a working app.

### 5. Say Why Before Asking

Every question states its user benefit in one line.

Good:

- "So I can celebrate your payday."
- "So I can protect this bill before it surprises you."

Bad:

- "To enable salary features."
- "Complete your profile."

If Sprout cannot explain why an answer helps the user, Sprout should not ask.

### 6. Privacy Is Offered

Lead with what the user does not have to provide.

Examples:

- "No bank connection needed."
- "A nickname is fine."
- "You can delete this anytime."
- "Sprout does not move money."

In Pakistan's incomplete private-sector data protection environment, visibly asking for less than expected is a trust signal.

### 7. Playful Is Offered, Never Imposed

Fun affordances sit beside the plain option.

Examples:

- Random nickname next to a normal name field.
- Mascot reaction after a tap, not before consent.
- Playful goal chips plus "something else."

The delight is a gift. The plain path is a right.

## Capture-Moment Model

Every user data item belongs to one of three classes.

### Needed For Personalization Now

Minimum that makes the first Today screen feel personal:

- Name or nickname.
- One goal.

Both are skippable. Name can fall back to a friendly default. If goal is skipped, Sprout must still land on a living Today screen and use a starter "help me choose" action.

### Captured In Context

Sprout asks once, at the moment the answer matters.

| Info | Capture Moment | Ask Pattern |
| --- | --- | --- |
| Salary date | First time income appears | "Money came in. Is this your usual payday?" |
| Income type | Inferred from inflow pattern | Confirm only if it changes an action. |
| Additional goals | After a few successful check-ins | "You're doing well. Want to add another goal?" |
| Bill timing | Recurring charge detected | "Looks like this repeats monthly. Track it?" |
| Category correction | Low-confidence transaction | One-tap confirm or relabel. |
| Source connection | User asks for less manual work | Explain what Sprout reads and discards. |

Rules:

- Ask one contextual question at a time.
- Ask at most once unless new data contradicts the answer.
- Remember the answer.
- Never batch contextual asks into a form.

### User-Initiated

Available in Settings, never pushed:

- Full profile.
- All goals.
- Income details.
- Data source connections.
- Preferences.
- Notification settings.
- Data deletion/export.

Settings is for control, not nagging.

## Onboarding Pattern

Onboarding uses the needed-for-personalization-now class only.

### Flow

1. Welcome: Sprout introduces itself and promises a 20-second daily money check-in with no bank needed.
2. Name or nickname: one text field, a "surprise me" nickname option, and "just call me friend."
3. One goal: single-select chips, "+ something else", and "help me decide later."
4. Celebration handoff: Sprout uses the chosen name/nickname/default, plants the garden, and sends the user to a living Today screen.

### Rules

- No salary date in onboarding.
- No income type in onboarding.
- No multi-goal form in onboarding.
- No source connection before core value is visible.
- Optional connections may appear after the first Today value moment as upgrades.
- Progress should feel nearly done from the start.
- The final onboarding moment is a celebration, not a summary.

## Trust Rules For Every Ask

- Lead with less.
- Real name is never required.
- Every field has a one-line why.
- Anything given can be changed or deleted.
- Confidence is visible when Sprout is unsure.
- No fake-required fields.
- No guilt for skipping.
- No "connect to continue."
- No pre-ticked consent.
- Consent is explicit and scoped.
- Source connection states what Sprout reads, ignores, and discards.
- Flows complete offline and never hard-block on recoverable errors.

## Acceptance

- No screen or sheet asks more than one question.
- Free text appears only when chips/cards cannot express the answer.
- Every non-required ask has a warm skip.
- Every ask states the user benefit.
- The app is usable after skipping everything beyond the minimum.
- The app is usable after skipping every onboarding ask.
- Deferred fields are captured in context, one tap, and remembered.
- No surface nags users to complete a profile.
- Privacy and reversibility are visible at the point of asking.
- Onboarding reaches a working Today screen in about 20 seconds.
- Source connections are never requested before core value is visible.

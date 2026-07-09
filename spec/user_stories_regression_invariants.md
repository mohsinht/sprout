# Sprout User Stories, Personas, and Regression Invariants

> **Realignment note (2026-07-09):** A new primary persona is added: **P7 —
> Mohsin, the Multi-Currency Investor** (Al Meezan funds + Wise USD/EUR + PKR
> cash). New invariants are added: total wealth is always the Today hero;
> no movement is ever shown without a reason; opening the app never changes
> the score; every valuation exposes dated price/FX provenance on tap; a
> wealth-down day never uses alarm/shame; goals always show remaining-to-
> target. A "learn later" thread invariant is added: an event flagged for
> learning is retrievable later, not lost. Manual expense logging (Bilal,
> the cash guy) is preserved as first-class — killing it would breach
> existing invariants.

## Purpose

This is the permanent behavioral contract for Sprout. Every story below is an invariant: it must hold in every release. New features may not regress any of them.

Coding agents should turn:

- Each `S` story into one or more e2e/integration tests.
- Each persona journey into a scenario suite.
- Each `I` invariant into a standing assertion that runs on every build where practical.

Rule: if a change makes a "Must always" clause false, the change is wrong. Preserve the invariant or deliberately revise this document first with product rationale.

## Personas

### P1 — Ayesha, The Skipper

Privacy-first, low trust.

Salaried teacher, 29, Lahore. Downloads the app, refuses to connect anything, skips every optional question, and will not give her real name.

Stresses:

- Zero-data states.
- Skip paths.
- Nickname/default identity.
- Alive with nothing.
- Settings recovery after skipped onboarding.

### P2 — Bilal, The Cash Guy

Unbanked-in-practice.

Rickshaw-fleet owner, 41, mostly cash, one bank account he rarely checks. No Gmail habit. Android budget phone.

Stresses:

- Manual-only lifecycle.
- Offline persistence.
- Low-end performance.
- Cash categories: chai, committee/BC, fuel, mobile load.
- Quick Add speed.

### P3 — Mahnoor, The Connected Optimiser

Power user.

Software engineer, 26, Karachi, iPhone. Connects Gmail, imports statements, sets goals, and checks daily.

Stresses:

- Auto-capture.
- Dedupe.
- Confidence/review.
- Multi-goal management.
- iOS with no SMS capture.

### P4 — Usman, The Freelancer

Irregular income.

Designer, 33, income arrives unpredictably in PKR and through Wise. No fixed salary date.

Stresses:

- Irregular inflow handling.
- Salary countdown fallback.
- Ask-and-remember income context.
- Foreign balance handling.

### P5 — Fatima, The Returner

Lapsed and re-engaging.

Student, 22, used the app for 12 days, missed several days, then comes back.

Stresses:

- Streak humaneness.
- Bad-day/return states.
- Re-onboarding not required.
- Data persistence across absence.

### P6 — Sara, The Stressed User

Hard financial moment.

Nurse, 37, tight month, bill may not be covered, overspending flagged.

Stresses:

- Bad-news tone.
- No-shame guarantees.
- Streak protection under hardship.
- Dignity.

### P7 — Mohsin, The Multi-Currency Investor

Wealth-health primary persona.

Tech professional, holds Al Meezan mutual funds (AMMF/MIF/MSF/MDIP/MFPF-AAP), Wise USD cash, Wise EUR cash, and PKR cash. Total wealth ~PKR 13.67M. Checks wealth every morning. Cares about movement, why, and goal progress (car goal).

Stresses:

- Total wealth as the Today hero (not a wallet balance).
- Multi-currency holdings (PKR, USD, EUR) with dated NAV/FX provenance.
- Movement + plain-language "why" (NAV movement, FX moves).
- Yesterday-continuity in events ("pulled back after yesterday's jump").
- Goal-relative next-steps ("PKR 2 lakh to your car goal").
- Wealth-down day stays calm (not alarm).
- Stale price/FX labelling.
- Learn-later thread retrievability.
- 6-day trend as a depth element.

## Onboarding And Identity Stories

### S1 — Complete Onboarding With Nothing Connected

As Ayesha, I finish onboarding without connecting any account, so that I can try the app with zero commitment.

Given a fresh install, when she completes onboarding without connecting a source, then she lands on a populated, usable Today screen.

Must always:

- No external connection is required to complete onboarding or reach Today.
- No permission prompt appears before core value is visible.

### S2 — Skip Every Onboarding Ask And Still Arrive Working

As Ayesha, I skip name, goal, and every optional prompt, so that I am not forced to disclose anything.

Given onboarding, when she taps skip on every step, then onboarding still completes and Today is functional using a default identity and a starter "help me choose" action.

Must always:

- Skipping all onboarding asks never blocks completion.
- The app never dead-ends on skip.
- Today never greets with a blank name or error.

### S3 — Skipped Onboarding Is Recoverable And Editable Later

As Ayesha, who skipped name and goal during onboarding, I can set or change them later from Settings or Sprout's contextual prompts, so that an early skip is never permanent.

Given a user who skipped name and/or goal, when she opens Settings, then name/nickname, goals, income type, salary date, and preferences are viewable and editable there.

Must always:

- Every field collected in onboarding is viewable and editable in Settings.
- Skipped fields can be set later with the same effect as setting them during onboarding.
- No field is write-once.

### S4 — Nickname Or Anonymous Identity

As Ayesha, I use a nickname or no name, so that I keep my privacy.

Given the name step, when she picks a random nickname, types her own, or skips, then all three produce a valid identity and a working greeting.

Must always:

- A real name is never required.
- Skipped name resolves to a friendly default.
- Nickname can be changed later.

### S5 — Onboarding Completes Offline

As Bilal, I onboard on weak or no connection, so that network is not a barrier.

Given no network, when he completes onboarding, then it succeeds and persists locally, syncing later if a backend exists.

Must always:

- Onboarding never hard-blocks on network or backend availability.
- Local first Today appears even if remote briefing generation fails.

### S6 — Onboarding Never Becomes A Form

As any user, I answer at most one thing per screen, so that onboarding feels like a conversation with Sprout.

Must always:

- Onboarding never presents more than one question per screen.
- Onboarding never asks for salary date, income type, multiple goals, or source connections before first value.
- Source connections are offered only after core value is visible.

## Core Daily Loop Stories

### S7 — Today Is The Default Landing

As any returning user, I open the app, so that I see today's check-in first.

Must always:

- App launch lands on Today after onboarding.
- No interstitial blocks the daily loop.

### S8 — The 30-Second Check-In Completes

As Mahnoor, I open, read Sprout, do the one action, and close, so that I feel done.

Given a briefing with a recommended action, when she completes it, then she gets celebration, XP, streak feedback, and a sign-off.

Must always:

- Today has exactly one primary recommended action.
- Completing it produces closure feedback.
- The loop is completable in under 30 seconds.

### S9 — Today Is Alive With Zero Data

As Ayesha, connected nothing and skipped goal, I still see a living Today, so that the app shows value immediately.

Must always:

- Today never renders blank, empty, or "connect something to begin."
- Zero-data Today still shows Sprout, greeting/default identity, check-in action, and sensible first step.

### S10 — Mascot Reflects Real State

As any user, I see Sprout reacting to my actual state, so that I understand the emotional context at a glance.

Must always:

- On Today, total wealth is the hero; mascot is prominent, alive, mood-driven, and does not overpower the wealth figure.
- Mascot mood is driven by product state, not random decoration.

### S11 — Every Insight Is Explainable

As any user, I tap the score, tile, or finding, so that I understand why.

Must always:

- Every score, score factor, glance tile, and finding opens a plain-language explanation.
- No number or status is a black box.

### S12 — Motion Respects Reduce Motion

As Mahnoor, I see score count-up and ring sweep when motion is allowed. As Bilal with reduce-motion, I see the same information calmly without motion.

Must always:

- First-reveal animation plays when motion is allowed.
- Motion is fully suppressed when reduce-motion/disable-animations is on.
- Reduce-motion never breaks layout or hides information.

## Persona Journey Stories

### S13 — Bilal Manual Offline Lifecycle On Low-End Phone

Given a budget Android device, no connections, and weak network, when Bilal onboards, logs cash expenses via Quick Add, logs income, and checks in daily for a week, then every entry persists, Today updates, and the app stays smooth.

Must always:

- Manual entry works offline end to end.
- Logged data survives app restart.
- Low-end performance floor is measured, not assumed.

### S14 — Mahnoor Connected Path With Dedupe And Confidence

Given Gmail connected and a statement imported, when the same transaction arrives from two sources, then it appears once and low-confidence items route to one-tap confirm.

Must always:

- Duplicate transactions never double-count.
- Every auto-captured item has source, parser version, dedupe fingerprint, and confidence/review state.
- Uncertain items are confirmable in one tap.
- iOS path does not depend on SMS.

### S15 — Usman Irregular Income

Given no fixed salary date and sporadic PKR plus Wise inflows, when income arrives, then Sprout handles it without assuming a monthly salary, asks and remembers rather than predicting, and salary countdown degrades gracefully.

Must always:

- Product never assumes regular salary.
- Salary countdown has a defined non-broken state for irregular earners.
- Sprout asks about uncertain income instead of predicting it.

### S16 — Fatima Returner

Given a 12-day streak, several missed days, and then a return, when Fatima reopens, then her data, goals, and identity are intact; she is not forced to re-onboard; streak is handled humanely.

Must always:

- Lapse never wipes data.
- Lapse never forces re-onboarding.
- Missed day never produces shame.
- Streak logic protects check-in habit, not spending/saving targets.

### S17 — Sara Hard Month

Given overspending flagged and a bill possibly uncovered, when Sara checks in, then Sprout shows the bad-news state calmly, protects her streak, offers one doable step, and never uses shame.

Must always:

- Bad financial state never produces guilt, shame, panic, red-faced mascot, or broken streak.
- Checking in on a bad day still counts.

### S18 — Settings As Recovery Surface

As any user, I can fix or change anything I skipped earlier, so that the app remains trustworthy after imperfect onboarding.

Given any skipped or deferred onboarding/contextual field, when the user opens Settings, then the field is visible, editable, and explains why it matters.

Must always:

- Settings can edit display name/nickname, goals, salary date, income type, preferences, notification settings, and data source controls.
- Editing later has the same product effect as setting earlier.

### S19 — Source Connection Is Optional And Reversible

As Mahnoor, I connect Gmail after seeing core value, so that Sprout can reduce manual work without taking control.

Given a source connection prompt, when she opens it, then it states what Sprout reads, what it ignores/discards, and how to disconnect/delete.

Must always:

- No source connection is required for core value.
- Consent is explicit and scoped.
- Disconnect and delete are reachable from Settings.

### S20 — Total Wealth Is The Today Hero

As Mohsin, I open the app, so that I see my total net wealth and how it moved — not a wallet balance or a budget bar.

Given a populated Today screen, when it renders, then the hero number is total wealth across all holdings (funds + multi-currency cash + PKR cash) with today's change and MTD change.

Must always:

- Total wealth is always the largest numeric figure on Today.
- Today's change and MTD change are shown together.
- The hero is never a single account balance or a budget bar.

### S21 — Every Movement Has A Why

As Mohsin, I see a wealth change, so that I understand what drove it.

Given any wealth movement shown on Today (today's change, MTD change, or a WealthEvent), when it renders, then it is accompanied by a plain-language driver ("NAV movement," "EUR/PKR moved," "you added to savings").

Must always:

- No change is ever shown without a reason.
- The "why" is plain language, not jargon.

### S22 — Opening The App Never Changes Health

As any user, I open the app, so that my health score reflects my wealth reality, not my attendance.

Given a health score, when the user opens the app or checks in, then the score does not change. The score changes only when wealth moves, a goal advances, an action is taken, or a bill is handled.

Must always:

- Opening the app / checking in never changes the score or awards XP.
- The score reflects wealth reality, not attendance.
- Streak is preserved as a separate habit mechanic.

### S23 — Provenance Is Visible On Tap

As Mohsin, I tap a holding valuation, so that I see where the number came from.

Given any holding valuation on Today or Money, when the user taps it, then the dated price/FX source is shown (NAV value, as-of date, source label; FX rate, as-of date, source label).

Must always:

- Every valuation exposes dated price/FX provenance on tap.
- Stale prices/FX are labelled with the as-of date, never silently trusted.

### S24 — Wealth-Down Day Stays Calm

As Mohsin, my wealth drops PKR 38k in a day, so that I see the dip calmly without alarm.

Given a wealth-down day, when Today renders, then the mascot is watchful (never angry/red-faced), the sentence ends on calm, and there is no shame or panic.

Must always:

- A wealth-down day never uses alarm, shame, or a red-faced mascot.
- The sentence ends on calm ("cooled after yesterday's jump, not a crash").

### S25 — Goals Always Show Remaining-To-Target

As Mohsin, I check my car goal, so that I see how far I have to go.

Given any goal displayed on Today or Money, when it renders, then it shows remaining-to-target ("PKR 2 lakh to go") and a pace note.

Must always:

- Goals always show remaining-to-target.
- The pace note is plain language.

### S26 — Learn-Later Thread Is Retrievable

As Mohsin, I see a WealthEvent flagged for learning ("why do fund NAVs move?"), so that I can learn about it later without losing it.

Given a WealthEvent with a `learnMoreId`, when the user taps "learn more" or returns to Money later, then the LearnThread is retrievable — it is not lost.

Must always:

- An event flagged for learning is retrievable later, not lost.
- The LearnThread is accessible from the event and from the depth surface.

### S27 — Manual Expense Logging Stays First-Class

As Bilal, the cash guy, I log a cash expense via Quick Add, so that my cash use case is not broken by the wealth realignment.

Given the wealth realignment, when Bilal opens Quick Add, then manual expense logging works exactly as before — first-class, offline, fast.

Must always:

- Manual expense logging is not deleted or broken.
- Quick Add works for the cash use case.
- The cash persona (Bilal) is not regressed.

## Cross-Cutting Invariants

### Trust And Privacy

- `I1`: Real name and external connections are never required for core features.
- `I2`: Bank passwords are never requested or stored.
- `I3`: Every data source is disconnectable and imported data deletable from Settings.
- `I4`: Connecting a source states what is read and discarded before consent.
- `I5`: No pre-ticked consent, fake-required field, or "connect to continue" gate.
- `I6`: Sprout does not move funds, hold stored value, initiate payments, or enable merchant acceptance in v0.

### Information Gathering

- `I7`: No screen or sheet asks more than one question.
- `I8`: Every ask has a warm skip.
- `I9`: Every ask says why in one user-benefit line.
- `I10`: Deferred fields are captured in context, one tap, and remembered.
- `I11`: No "complete your profile" nagging.

### Data Integrity

- `I12`: Every field collected in onboarding is editable in Settings.
- `I13`: User data persists across app restart and periods of non-use.
- `I14`: Manual entries save offline and are never lost due to lack of network/backend.
- `I15`: Duplicate transactions from multiple sources never double-count.
- `I16`: Money values display consistently as whole PKR rupees.
- `I17`: Captured transactions include parser version and dedupe fingerprint.

### Availability And Resilience

- `I18`: Today renders usefully when briefing job is missing, failed, thin, or stale.
- `I19`: No screen has an empty/blank dead-end.
- `I20`: Stale or low-confidence data is labelled, never silently trusted.
- `I21`: Every insight path has a return path preserving prior context.
- `I22`: iOS works without SMS capture; Android SMS remains optional.

### Tone And Dignity

- `I23`: No screen shames, guilts, or panics the user about money.
- `I24`: Mascot is never angry or red-faced.
- `I25`: Financial hardship alone never breaks a streak.
- `I26`: Sprout states uncertainty and never confidently predicts income or outcomes it cannot know.

### Accessibility And Performance

- `I27`: Reduce-motion is respected everywhere and never hides information.
- `I28`: Text remains readable and non-clipped at about 1.3x text scale.
- `I29`: App meets the low-end Android performance floor every release.
- `I30`: Icons carry accessible labels; nothing critical is conveyed by color or icon alone.

### Structure And Design

- `I31`: App launch lands on Today.
- `I32`: Quick Add is reachable from every primary tab and is never a destination tab.
- `I33`: Today has exactly one primary recommended action.
- `I34`: Design uses existing tokens only; no arbitrary color, spacing, radius, or type scale.

### Wealth Health

- `I35`: Total wealth is always the Today hero — the largest numeric figure, with today's change and MTD change shown together.
- `I36`: No movement is ever shown without a plain-language reason.
- `I37`: Opening the app / checking in never changes the health score or awards XP.
- `I38`: Every valuation exposes dated price/FX provenance on tap.
- `I39`: A wealth-down day never uses alarm, shame, or a red-faced mascot.
- `I40`: Goals always show remaining-to-target and a pace note.
- `I41`: An event flagged for learning (learnMoreId) is retrievable later, not lost.
- `I42`: Manual expense logging remains first-class for the cash use case (not deleted or broken by the wealth realignment).
- `I43`: Stale prices/FX are labelled with the as-of date, never silently trusted.

## Regression Discipline

- Every `S` story maps to at least one e2e or integration test.
- Every `I` invariant maps to a standing assertion where practical.
- A pull request that fails an `S` or `I` test is blocked.
- A new feature must add its own stories and keep the full existing suite green.
- If product strategy genuinely requires changing an invariant, revise this doc first with rationale, then update tests.
- Personas P1-P6 are the standing manual QA cast for every release.

## Coverage Matrix

| Persona | Trust | Info Gathering | Data | Resilience | Dignity | A11y/Perf | Wealth |
| --- | --- | --- | --- | --- | --- | --- | --- |
| P1 Ayesha | I1-I5 | I7-I12 | I12 | I18-I19 | | | I35-I37 |
| P2 Bilal | | I7-I10 | I13-I14, I42 | I18-I19 | | I27-I29 | I42 |
| P3 Mahnoor | I3-I5 | I7-I10 | I15-I17 | I20-I22 | | | I35-I36 |
| P4 Usman | | I10 | I13 | I18 | I26 | | I38 |
| P5 Fatima | | I12 | I13 | | I25 | | |
| P6 Sara | | | | I20 | I23-I26 | | I39 |
| P7 Mohsin | | | I38, I43 | | I39 | | I35-I41 |

Any invariant with no persona exercising it needs a synthetic test case.

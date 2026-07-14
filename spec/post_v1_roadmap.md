# Post-v1 Product Opportunities

## Status And Purpose

This document records promising opportunities for releases after v1. It is a
roadmap input, not an implementation specification, release commitment, or
permission to weaken existing acceptance criteria.

The opportunity is not to add more information to Today. Sprout can become
more distinctive through:

- **Memory:** make useful history feel continuous and personal.
- **Ritual:** make meaningful money moments feel calm and intentional.
- **Proof:** make provenance and calculations visible and understandable.
- **Character:** let Sprout carry warmth without adding dashboard density.

All ideas remain subordinate to the UX philosophy and permanent regression
invariants. In particular:

- The four-tab shell plus center Quick Add remains fixed.
- Today's canonical 13-part layout remains locked. A post-v1 experience may
  temporarily transform an existing moment or open behind a tap, but it may
  not add another Today card, hero, or primary action.
- Total wealth remains the Today hero and every movement retains a plain-
  language reason and dated provenance.
- Manual-only, zero-connection, offline, low-end Android, reduce-motion, stale,
  and unavailable paths remain first-class.
- Sprout never predicts investment returns or uncertain income, moves money,
  pressures investment action, or presents regulated advice.
- Amount-sharing is opt-in. Shareable output defaults to amount-hidden or
  percentage-only presentation and must prevent accidental disclosure.

Before any candidate enters delivery, create a focused feature spec covering
its domain contract, source and freshness rules, populated and empty states,
zero-connection behavior, offline and stale behavior, errors, success,
reduce-motion, privacy, low-end performance, copy, analytics, acceptance IDs,
and persona/invariant test mapping.

## Recommended Sequence

### v1.1 — Continuity And Trust

#### Sprout Remembers

Occasionally surface a truthful milestone, anniversary, or callback derived
from durable snapshot and contribution history, such as a longest contribution
run or year-over-year wealth change.

Why it matters: continuity turns stored history into a relationship without
adding a feed or asking the user to study more data.

Guardrails:

- Every statement is deterministic, reproducible, and linked to the underlying
  dated observations.
- No callback is fabricated when history is too thin, stale, disputed, or
  unavailable.
- Hard periods are described calmly and never framed as failure.
- At most one memory competes for attention in a briefing, and it cannot create
  a second Today action.

#### How Sprout Knows

From an existing wealth or holding detail, let the user inspect how the total
is assembled: units multiplied by dated NAV/redemption price, converted with a
dated FX rate, and reconciled into total wealth.

Why it matters: provenance becomes a visible proof interaction instead of a
footnote.

Guardrails:

- This is a depth interaction behind a tap, not new Today content.
- It uses the same canonical valuation contract as the briefing; it never
  recomputes with a separate client-only formula.
- Missing, stale, disputed, estimated, and unavailable inputs remain explicit.
- Reduce-motion shows the same proof as a static ordered breakdown.
- Animation ships only when measured low-end Android performance passes.

#### Salary-day Ritual

When a user-confirmed or reliably detected income event arrives, adapt the
existing daily moment with a calm once-per-income-event acknowledgement and one
relevant suggestion based on the user's own prior behavior or chosen goal.

Why it matters: income arrival is a natural moment for an intentional next
step.

Guardrails:

- It must support multiple income streams, irregular frequencies, foreign
  currency, and users with no salary date.
- Sprout asks when income identity or recurrence is uncertain; it never assumes
  that an inflow is salary or predicts the next one.
- The suggestion is not an automatic transfer and never implies money moved.
- It reuses Today's one primary action rather than adding another action.
- The ritual does not fire twice for a duplicate or corrected transaction.

### First Marquee Post-launch Release — Memory Made Visible

#### Monthly Wealth Story

After a user has enough trusted history, offer a concise monthly recap using a
garden narrative: total movement, the strongest supported contributor, one
calmly stated miss or pressure point when appropriate, and one focus for the
next month.

Why it matters: it converts durable history into a memorable story and can
become an organic sharing moment.

Guardrails:

- It appears only after a complete-enough month; otherwise Sprout offers a
  shorter honest recap or waits.
- It is a temporary monthly ritual or depth destination, not a permanent Today
  card and not a replacement for the normal daily briefing beyond that one
  deliberate moment.
- Contributions, market movement, FX movement, fees, income, and expenses are
  attributed separately; causal claims must be supported by stored events.
- Sharing is optional, previews exactly what will leave the app, and defaults
  to percentages or amount-hidden output.
- Offline users can reopen a cached generated story with its source dates.
- Reduce-motion provides an equally complete static story.

#### Milestone Artifacts

When a goal completes or a supported wealth milestone is crossed, optionally
generate a small garden-themed artifact that can be kept or shared without
exposing balances.

Guardrails:

- Crossing logic is deterministic and idempotent; app reopen never creates a
  duplicate milestone.
- Goal completion never implies that funds moved.
- Amounts are hidden by default and the share preview is explicit.
- The artifact remains useful without sharing and never becomes social
  comparison.

### Goal Experience Maturity

#### Goal Time-travel

In goal detail, let the user vary a contribution amount and see the
contribution-only completion date change, expressed through the garden rather
than a dense finance chart.

Why it matters: it makes a goal tradeoff understandable without pretending to
forecast returns.

Guardrails:

- The calculation uses current remaining-to-target and user-entered
  contribution cadence only. Investment returns, inflation, income, and
  behavior are not predicted.
- The result says "at this contribution pace," not "you will reach."
- No default contribution, cadence rule, rounding rule, or date convention may
  be invented; those require an approved data contract and tests.
- Irregular and paused contributions have explicit non-broken states.
- It lives in goal detail and does not add a Today chart or second action.

#### Water The Garden Contribution Gesture

Offer a tactile, optional gesture for recording a goal contribution, with a
small plant-growth response and haptic completion.

Guardrails:

- It invokes the same contribution command and idempotency behavior as the
  standard accessible control; the animation is never the data model.
- A conventional labelled control remains available for accessibility,
  keyboard use, reduce-motion, and low-performance devices.
- Celebration occurs only after persistence succeeds. Offline success is
  labelled as saved locally and pending sync where relevant.

### Trust And History Depth

#### Ask Sprout Why On A Historical Day

From Money's historical trend, let the user open the stored interpretation for
a selected date and inspect what moved, why, and which observations supported
it.

Guardrails:

- Retrieval uses the immutable historical snapshot and interpretation for that
  date; it does not rewrite history with today's prices or a new model answer.
- Missing history, stale observations, and unavailable interpretations have
  honest states.
- The interaction opens as depth and returns to the same Money context.

#### Privacy Blur With Press-to-peek

Extend balance-hidden mode so the default view communicates garden health
without visible amounts, with an intentional temporary reveal gesture.

Guardrails:

- Hidden amounts must not leak through semantics, notifications, screenshots,
  recent-app previews, charts, labels, or transition frames.
- Press-and-hold is not the only accessible reveal mechanism.
- The preference persists consistently and never obscures source, freshness,
  uncertainty, or non-numeric meaning.

## Explicitly Rejected Directions

These remain outside the product unless the product constitution is
deliberately revised with rationale:

- Open-ended AI chat with Sprout.
- Social feeds, leaderboards, friend comparisons, or competitive wealth
  mechanics.
- Reward escalation that punishes missed days or ties dignity to financial
  performance.
- Home-screen widgets that expose balances. A future widget may show only a
  privacy-safe mascot state after a separate platform/privacy spec.
- "What if you had invested in X" counterfactuals, guaranteed outcomes, FOMO,
  buy/sell pressure, or speculative return projections.
- Any feature that adds another Today card, another primary action, an infinite
  feed, or a fifth tab.

## Prioritization Gate

Rank a candidate for delivery only when all of the following are true:

1. v1 launch gates and regression suites are green.
2. The required trusted history or provenance exists; demo fixtures are not
   presented as user truth.
3. The feature makes the daily ritual, memory, or trust materially stronger
   without increasing glance-time or anxiety.
4. A zero-connection/manual user receives a complete experience or an honest
   not-yet-enough-history state.
5. Privacy, accessibility, reduce-motion, offline, stale, error, and low-end
   performance acceptance criteria are written before implementation.
6. The feature has stable acceptance IDs and persona/invariant mappings in the
   release traceability artifact.


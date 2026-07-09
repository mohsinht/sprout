# Sprout Mascot Asset Set

> **Layout-lock note (2026-07-09):** The animated mascot is elevated from
> "future" to **required for Today.** On Today, the mascot must animate —
> at minimum a subtle idle (breathing/bob + occasional blink), a
> mood-matched expression driven by product state, plus a reaction on load
> and on action completion. Static PNG is a fallback only (reduce-motion,
> missing asset), never the default experience on Today. The existing
> expression assets (videos / Rive states) must be wired to the four
> product moods, not left unused.

## Purpose

Sprout is the emotional center of the product. The mascot should make money feel calm, understandable, and winnable without hiding the truth.

## Current Implementation

Primary widget:

- `apps/mobile/lib/src/widgets/sprout_mascot.dart`

State enum:

- `apps/mobile/lib/src/widgets/sprout_mascot_state.dart`

Current asset folder:

- `apps/mobile/assets/mascot/`

Current stills:

- `stills/sprout-happy.png`
- `stills/sprout-wave.png`
- `stills/sprout-concerned.png`
- `stills/sprout-thinking.png`
- `stills/sprout-idea.png`
- `stills/sprout-confident.png`
- `stills/sprout-thumbs-up.png`
- `stills/sprout-happy-hearts.png`
- `stills/sprout-grateful.png`

Current videos:

- `videos/sprout-happy.mp4`
- `videos/sprout-wave.mp4`
- `videos/sprout-concerned.mp4`
- `videos/sprout-thinking.mp4`
- `videos/sprout-idea.mp4`
- `videos/sprout-confident.mp4`
- `videos/sprout-thumbs-up.mp4`
- `videos/sprout-happy-hearts.mp4`
- `videos/sprout-grateful.mp4`
- `videos/sprout-sequence-9s.mp4`
- `videos/sprout-more-poses-10s.mp4`

Rive target:

- `assets/mascot/sprout_coin.riv`
- State machine: `sprout_mascot`
- Inputs: `state`, `blink`, `celebrate`, `wave`

Fallback:

- `CoinSproutMascot` custom painter.

## Required Product Mood Set

The product-level mood set is:

- `thriving`: user is strongly on track; use for high score, completed milestones, strong buffer.
- `content`: normal healthy state; use for the default daily check-in.
- `watchful`: something is worth noticing; use for mild budget pace, uncertain transactions, upcoming bills.
- `concerned`: something needs attention; use for low score, stale data, source failures, urgent review.

## Mapping to Current States

The product mood to asset map is deterministic:

| Product Mood | Canonical State | Canonical Still | Canonical Video |
| --- | --- | --- | --- |
| `thriving` | `SproutMascotState.confident` | `stills/sprout-confident.png` | `videos/sprout-confident.mp4` |
| `content` | `SproutMascotState.happy` | `stills/sprout-happy.png` | `videos/sprout-happy.mp4` |
| `watchful` | `SproutMascotState.thinking` | `stills/sprout-thinking.png` | `videos/sprout-thinking.mp4` |
| `concerned` | `SproutMascotState.worried` | `stills/sprout-concerned.png` | `videos/sprout-concerned.mp4` |

Other states are internal variants for specific moments:

- `celebrate`, `happyHearts`, `thumbsUp`: completion or milestone.
- `wave`: greeting or onboarding.
- `idea`, `pointing`, `reading`: explanation or educational surfaces.
- `grateful`: thank-you and completion tone.

Use helper factories where possible:

- `SproutMascotState.fromHealthScore`
- `SproutMascotState.fromPaydayDays`
- `SproutMascotState.fromConnectionError`
- `SproutMascotState.fromContext`

## Required Animation States

### Idle (required for Today)

The mascot must **animate** on Today — at minimum a subtle idle (breathing/bob + occasional blink). It should feel alive but quiet. Blink and bob are acceptable when reduce-motion is off. **Static PNG is a fallback only** (reduce-motion, missing asset), never the default experience on Today.

### Mood-Matched Expressions (required for Today)

The mascot's expression must be **driven by product state** (thriving / content / watchful / concerned) and react on load (settle-bounce) and on action completion (celebrate bounce). The existing expression videos / Rive states must be wired to the four product moods, not left unused.

### Bounce / Celebrate (required for action completion)

Use only after meaningful completion:

- Daily action completed.
- Goal milestone reached.
- Lesson/action XP awarded.
- Streak repaired or protected.

### Gentle

Use for bad news, uncertainty, stale data, and review prompts. The mascot should show care, not alarm.

## Static PNG Requirements

Static PNGs are the first required asset layer. Each product mood needs:

- Transparent background.
- Square canvas.
- 1x, 2x, and 3x export targets when production asset delivery begins.
- Consistent mascot scale and baseline.
- No embedded text.
- Usable on light and dark surfaces.

Minimum canonical PNG set:

- `sprout-thriving.png`
- `sprout-content.png`
- `sprout-watchful.png`
- `sprout-concerned.png`

Existing stills satisfy this through the deterministic mapping above. Future asset naming should use the product mood names for clarity.

## Lottie / Rive Requirements (required for Today)

Rive or Lottie is **required for Today** — the mascot must animate (idle + mood expressions + load reaction + completion reaction). Static PNGs remain the fallback layer. The existing expression assets (videos / Rive states) must be mapped to the four product moods and wired to the mascot state.

Required animation clips:

- `idle` — subtle breathing/bob + occasional blink (the default Today presence).
- `celebrate` — bounce on action completion.
- `gentle` — care, not alarm, for bad news / uncertainty / stale data.
- `wave` — greeting or onboarding.
- `blink` — occasional blink during idle.

Performance requirements:

- No blocking load on Today.
- Static fallback always visible.
- Respect reduce-motion.
- No looping celebration.
- Idle loop must be subtle.

## Usage Rules

- **Today: mascot is the largest visual element and must animate** — idle + mood-matched expression + load reaction + completion reaction. Static PNG is fallback only.
- Money: mascot is a small calm signal only.
- Settings: mascot appears sparingly; trust copy matters more.
- Quick Add: mascot can confirm completion but should not slow entry.
- Bad news: use watchful or concerned, never angry or panicked.

## Asset Acceptance

- Every required mood has a static PNG fallback.
- Every animated state has a static fallback.
- The four product moods map 1:1 to canonical states and assets.
- **The existing expression assets (videos / Rive states) are wired to the four product moods** — not left unused.
- **On Today, the mascot animates by default** (idle + mood-matched + load reaction + completion reaction). Static PNG is fallback only (reduce-motion, missing asset).
- Missing Rive/video assets never produce a blank box.
- Reduce-motion displays still art.
- Mascot mood is driven by product state, not decorative choice.

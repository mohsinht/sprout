# Sprout Mascot Asset Set

> **Performance realignment (2026-07-14):** Mood and presence remain required
> on Today, but raster/static art is the shipping baseline. Animation is a
> measured upgrade for device profiles that pass the low-end performance gate.
> Reduce-motion, low-end, missing, or failed assets retain the same canonical
> expression and information.

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

### Idle (conditional upgrade for Today)

On profiles that pass the performance gate, the mascot may animate with a
subtle idle (breathing/bob + occasional blink). It should feel alive but quiet.
Raster/static is the baseline and is required on reduce-motion and low-end
profiles; it is not a degraded error state.

### Mood-Matched Expressions (required for Today)

The mascot's expression must be **driven by product state** (thriving / content / watchful / concerned). Passing animated profiles react on load and completion; static profiles switch to the corresponding canonical still.

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

## Lottie / Rive Requirements (performance-gated upgrade)

Rive or Lottie is optional for launch and enabled only after measured frame-time
and memory acceptance on the target device profile. Static PNGs are the first
shipping layer. Existing expression assets remain mapped to the four moods so
animation can be enabled without changing product state semantics.

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

- **Today: mascot is the living emotional narrator and must be mood-matched.**
  Passing profiles add idle/load/completion motion; static profiles use the
  same expression and stay prominent without overpowering wealth.
- Money: mascot is a small calm signal only.
- Settings: mascot appears sparingly; trust copy matters more.
- Quick Add: mascot can confirm completion but should not slow entry.
- Bad news: use watchful or concerned, never angry or panicked.

## Asset Acceptance

- Every required mood has a static PNG fallback.
- Every animated state has a static fallback.
- The four product moods map 1:1 to canonical states and assets.
- **The existing expression assets (videos / Rive states) are wired to the four product moods** — not left unused.
- **On Today, raster/static is the safe baseline.** Animation is enabled only
  for profiles that pass the performance gate.
- Missing Rive/video assets never produce a blank box.
- Reduce-motion displays still art.
- Mascot mood is driven by product state, not decorative choice.

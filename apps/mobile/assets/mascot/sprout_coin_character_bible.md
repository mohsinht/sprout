# Sprout Coin Mascot — Character Bible

This is the single source of truth for the Sprout coin mascot. Every screen,
every animation, and every illustration must conform to this document. If a
mascot asset does not match the rules below, it is wrong — fix the asset, not
the bible.

The Flutter integration lives in
`apps/mobile/lib/src/widgets/sprout_mascot.dart` and reads from a single Rive
file at `apps/mobile/assets/mascot/sprout_coin.riv`.

---

## 1. Core structure

The Sprout mascot is a round golden coin character with a sprout growing from
the top. It is friendly and premium, never childish or cartoonish.

| Part      | Description                                                  |
| --------- | ------------------------------------------------------------ |
| Body      | Round gold coin, slightly glossy, soft radial highlight.     |
| Top       | Two green sprout leaves on a short stem.                     |
| Face      | Large expressive eyes, small mouth. No nose.                 |
| Arms      | Short rounded arms at the sides.                             |
| Legs      | Tiny rounded feet under the body.                            |
| Style     | Soft vector, slightly glossy, friendly, premium.             |

---

## 2. Design rules (consistency contract)

These rules are non-negotiable. They are what stop the mascot from mutating
between screens.

- Body proportions are fixed: coin radius is `0.32 * canvasSize`, centered at
  `(0.5, 0.56)` of the canvas.
- Leaf size and placement are fixed: leaves sit at `y = 0.16 * canvasSize`,
  x-offset `±0.12 * canvasSize` from center, angle `±0.6 rad`.
- Eye spacing is fixed: eyes sit at `y = center.y - 0.12 * r`, x-offset
  `±0.32 * r`, radius `0.13 * r`.
- Smile curvature style: a single quadratic bezier, stroke width
  `0.022 * canvasSize`, round caps. Never a sharp corner.
- Shadow style: soft drop shadow, `ink @ 12%`, blur `24`, offset `(0, 12)`.
- Highlight style: radial white `@ 55%` at top-left of the coin body.
- Stroke style: outlines use `coinOutline` (`#B97818`), width
  `0.022 * canvasSize`. Inner rim uses `coinRim` (`#C8881A`) at `35%` alpha.
- Color palette is fixed — see `sprout_coin_color_tokens.json`. No off-palette
  colors are permitted in any mascot asset.

---

## 3. Turnarounds

The mascot is primarily shown front-on. For 3D-feeling screens a 3/4 view is
allowed; side and back views are reserved for future marketing.

| View     | Use case                                  |
| -------- | ----------------------------------------- |
| Front    | Default. All in-app states.               |
| 3/4      | Optional hero illustrations, marketing.   |
| Side     | Reserved. Not used in-app today.          |
| Back     | Reserved. Not used in-app today.          |

---

## 4. Expression sheet

Each expression maps to a `SproutMascotState` in Flutter.

| State        | Eyes                  | Mouth        | Leaves        | Notes                          |
| ------------ | --------------------- | ------------ | ------------- | ------------------------------ |
| `idle`       | Open, gentle blink    | Soft smile   | Still         | Default breathing loop.        |
| `happy`      | Open, bright          | Smile        | Still         | Light bounce.                  |
| `excited`    | Open, wide            | Smile        | Pop           | Faster bounce, one-hand wave.  |
| `celebrate`  | Closed (happy arcs)   | Big open grin| Pop           | Jump, both arms up.            |
| `thinking`   | Up-looking            | Smirk        | Still         | Slight head tilt.              |
| `worried`    | Brows down, soft      | Frown        | Slight droop  | Supportive, not sad.           |
| `reading`    | Down-looking          | Small smile  | Still         | Tiny focus bob.                |
| `pointing`   | Open, forward         | Smile        | Still         | One arm out, guiding pose.     |
| `peek`       | One closed, one open  | Small smile  | Still         | Peeking from a card.           |
| `thumbsUp`   | Open, bright          | Smile        | Still         | One hand shows a thumb.        |

---

## 5. Pose sheet

| Pose            | State used in        |
| --------------- | -------------------- |
| Wave            | `excited`, empty     |
| Point           | `pointing`           |
| Thumbs up       | `thumbsUp`           |
| Jump            | `celebrate`          |
| Hold coin       | (future)             |
| Hold book       | `reading`            |
| Peek from card  | `peek`               |
| Celebrate quest | `celebrate`          |

---

## 6. Motion personality

The mascot is not a static icon. It has movement rules.

- **Soft bounce**: idle and happy states breathe with a small vertical move
  (`-5px`, `mascotReaction` duration, reverse loop).
- **Leaf wiggle**: leaves wiggle subtly on `excited` and `celebrate`.
- **Slow blink**: `idle` blinks every few seconds.
- **Cheerful hops**: `celebrate` uses quick hops, not a single jump.
- **Worried lean**: `worried` leans slightly down; never shakes or panics.
- **Reading bob**: `reading` keeps a tiny focus bob, eyes down.
- **Reduced motion**: all looping motion is disabled when the OS requests
  reduced motion. The static art still renders.

---

## 7. Single source of truth

- Rive file: `apps/mobile/assets/mascot/sprout_coin.riv`
- Flutter widget: `apps/mobile/lib/src/widgets/sprout_mascot.dart`
- State enum + mapper: `apps/mobile/lib/src/widgets/sprout_mascot_state.dart`
- Color tokens: `apps/mobile/assets/mascot/sprout_coin_color_tokens.json`
- Motion guidelines: `apps/mobile/assets/mascot/sprout_coin_motion_guidelines.md`

All screens must use `SproutMascot(state: ..., size: ...)`. No screen may
import a private mascot painter or ship its own `.riv` file.
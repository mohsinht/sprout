# Sprout Coin Mascot — Motion Guidelines

This document defines how the Sprout mascot moves inside the Flutter app. It is
the contract between the motion designer (working in Rive) and the Flutter
developer (integrating the runtime).

The Rive file is `apps/mobile/assets/mascot/sprout_coin.riv`. It must expose a
single state machine named `sprout_mascot` with the inputs and states listed
below. The Flutter widget
(`apps/mobile/lib/src/widgets/sprout_mascot.dart`) drives this state machine
and falls back to the `CustomPaint` mascot when the `.riv` file is absent.

---

## 1. State machine contract

**State machine name:** `sprout_mascot`

### Inputs

| Input name   | Type    | Purpose                                              |
| ------------ | ------- | ---------------------------------------------------- |
| `state`      | number  | The active `SproutMascotState` index (see enum).     |
| `blink`      | trigger | Fire a one-shot blink from any state.                |
| `celebrate`  | trigger | Fire a one-shot celebration burst.                   |
| `wave`       | trigger | Fire a one-shot wave.                                |

The Flutter widget sets `state` whenever `SproutMascotState` changes and fires
`blink` on a timer. `celebrate` and `wave` are fired on demand.

### States (Rive animation names)

Each state is a looping animation unless marked one-shot.

| State        | Animation name   | Loop  |
| ------------ | ---------------- | ----- |
| `idle`       | `idle`           | loop  |
| `happy`      | `happy`          | loop  |
| `excited`    | `excited`        | loop  |
| `celebrate`  | `celebrate`      | loop  |
| `thinking`   | `thinking`       | loop  |
| `worried`    | `worried`        | loop  |
| `reading`    | `reading`        | loop  |
| `pointing`   | `pointing`       | loop  |
| `peek`       | `peek`           | loop  |
| `thumbsUp`   | `thumbs_up`      | loop  |

### Transitions

- Any state → any other state via the `state` number input (blend, ~250ms).
- `idle` → `blink` one-shot, then back to `idle`.
- `celebrate` trigger → `celebrate` loop for 2.5s, then back to previous state.
- `wave` trigger → wave one-shot, then back to previous state.

---

## 2. Timing tokens

These mirror `packages/sprout_motion/lib/src/sprout_durations.dart`.

| Token              | Duration | Used by                          |
| ------------------ | -------- | -------------------------------- |
| `mascotReaction`   | 480ms    | Idle breathing, state blends.    |
| `cardEntrance`     | 320ms    | Mascot pop-in on screen entry.   |
| `xpReward`         | 600ms    | Celebrate burst.                 |

Curves live in `packages/sprout_motion/lib/src/sprout_curves.dart`
(`standard`, `playful`). Use them inside Rive where possible.

---

## 3. Motion personality rules

- **Soft bounce**: idle/happy breathe `-5px` vertically, reverse loop.
- **Leaf wiggle**: leaves wiggle `±4°` on `excited` and `celebrate`.
- **Slow blink**: idle blinks every ~3.5s, duration ~120ms.
- **Cheerful hops**: `celebrate` uses two quick hops, not one big jump.
- **Worried lean**: `worried` leans `+3px` down, leaves droop `+6°`. No shake.
- **Reading bob**: `reading` bobs `±2px`, eyes look down.
- **Reduced motion**: when `MediaQuery.disableAnimations` is true, the Flutter
  widget renders the static `CustomPaint` mascot and does not drive Rive loops.

---

## 4. Flutter integration

```dart
SproutMascot(
  state: SproutMascotState.happy,
  size: 72,
)
```

- `state` maps to the `state` number input.
- `size` is the rendered edge length in dp.
- The widget loads `assets/mascot/sprout_coin.riv` once and caches it.
- If the file is missing or fails to load, it renders the `CustomPaint`
  fallback (`CoinSproutMascot`) with the matching mood — never a blank box.

---

## 5. Financial-state mapping

Use `SproutMascotState.fromHealthScore(score)` and
`SproutMascotState.fromContext(...)` helpers in
`sprout_mascot_state.dart` so screens never hard-code mascot state.

| Product signal              | Mascot state   |
| --------------------------- | -------------- |
| Health score ≥ 75           | `happy`        |
| Health score 50–74          | `thinking`     |
| Health score < 50           | `worried`      |
| Payday ≤ 3 days             | `excited`      |
| Quest completed             | `celebrate`    |
| Learn screen                | `reading`      |
| Empty state                 | `excited` (wave) |
| Error / disconnected source | `worried`      |
| Budget on track             | `thumbsUp`     |
| Peek / card reveal          | `peek`         |
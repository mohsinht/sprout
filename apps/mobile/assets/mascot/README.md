# Sprout Coin Mascot — Assets

This folder is the **single source of truth** for the Sprout coin mascot.

## Files

| File                                  | Purpose                                  |
| ------------------------------------- | ---------------------------------------- |
| `sprout_coin.riv`                     | Rive file with the `sprout_mascot` state machine. **Drop the exported `.riv` here.** |
| `sprout_coin_color_tokens.json`       | Canonical mascot color palette.          |
| `sprout_coin_character_bible.md`      | Design rules, expression sheet, poses.   |
| `sprout_coin_motion_guidelines.md`    | State machine contract + motion rules.   |
| `sprout_coin_master.svg`              | (Optional) master vector for designers.  |
| `sprout_coin_expressions.png`         | (Optional) expression sheet export.      |
| `sprout_coin_pose_sheet.png`          | (Optional) pose sheet export.            |

## Adding the Rive file

1. Export from Rive with the state machine named **`sprout_mascot`**.
2. Artboard name: **`sprout_coin`**.
3. Required inputs (see `sprout_coin_motion_guidelines.md`):
   - `state` (number) — active `SproutMascotState` index.
   - `blink` (trigger) — one-shot blink.
   - `celebrate` (trigger) — one-shot celebration burst.
   - `wave` (trigger) — one-shot wave.
4. Drop the file at `apps/mobile/assets/mascot/sprout_coin.riv`.
5. The Flutter widget `SproutMascot` picks it up automatically. Until the file
   exists, the widget renders the `CustomPaint` fallback mascot so the app
   never shows a blank box.

## Flutter integration

```dart
import 'package:sprout_mobile/src/widgets/sprout_mascot.dart';
import 'package:sprout_mobile/src/widgets/sprout_mascot_state.dart';

SproutMascot(state: SproutMascotState.happy, size: 72)
```

Use the helpers on `SproutMascotState` to map product signals:

```dart
SproutMascotState.fromHealthScore(score)
SproutMascotState.fromPaydayDays(daysUntilSalary)
SproutMascotState.fromContext(healthScore: ..., daysUntilSalary: ...)
```

## Do not

- Do not add a second `.riv` file for the mascot.
- Do not import `CoinSproutMascot` directly from screens — use `SproutMascot`.
- Do not introduce off-palette colors — see `sprout_coin_color_tokens.json`.
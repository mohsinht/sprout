# Design System Reference

This reference documents the current Sprout system. Keep the system; do not invent a new visual language for new screens.

## Source Files

- Flutter tokens: `apps/mobile/lib/src/theme/sprout_tokens.dart`
- Flutter theme: `apps/mobile/lib/src/theme/sprout_theme.dart`
- TypeScript tokens: `packages/design_tokens/src/index.ts`
- Shared components: `apps/mobile/lib/src/widgets/`

## Colors

Core light tokens:

- `seed`: `#2FB46E`
- `leaf`: `#167A4A`
- `mint`: `#E9F8EF`
- `sky`: `#2E7BEF`
- `lilac`: `#7B61FF`
- `gold`: `#F3B43F`
- `tomato`: `#E05252`
- `ink`: `#17201B`
- `muted`: `#647067`
- `line`: `#DCE8E1`
- `surface`: `#FFFFFF`
- `background`: `#F6FAF7`

Hero gradients:

- Green: `heroGreenStart` -> `heroGreenEnd`
- Sky: `heroSkyStart` -> `heroSkyEnd`
- Lilac: `heroLilacStart` -> `heroLilacEnd`
- Gold: `heroGoldStart` -> `heroGoldEnd`
- Teal: `heroTealStart` -> `heroTealEnd`

Tint surfaces:

- `tintGold`: warm money/reward surfaces.
- `tintSky`: information and account surfaces.
- `tintMint`: healthy progress and selected nav surfaces.
- `tintLilac`: goals and learning surfaces.
- `tintWarm`: bills, chai, and gentle attention surfaces.

Status accents:

- `healthy`: positive status.
- `attention`: warning without panic.
- `locked`: disabled or locked.
- `goldInk`: readable text on gold tints.

Dark mode tokens exist in `SproutColors.dark*` and must be accessed through `SproutColorScheme.of(context)` for adaptive surface, background, ink, muted, line, and mint.

## Typography

Current type families:

- Fredoka: display, playful headings, quest labels, and expressive numbers.
- Nunito Sans: body, explanations, settings, and calm UI text.
- Inter: money values, score values, and compact metrics.

Type scale:

- `s11`
- `s14`
- `s18`
- `s23`
- `s29`
- `s37`
- `s47`
- `s60`

Rules:

- Letter spacing should be `0` unless already defined in the theme.
- Use theme styles or `SproutType` helpers.
- Do not scale font size with viewport width.
- Avoid oversized display type inside cards, rows, sheets, or settings surfaces.

## Spacing

Canonical spacing tokens:

- `xs`: 4
- `sm`: 6
- `md`: 10
- `lg`: 16
- `xl`: 26
- `xxl`: 42
- `pageHorizontal`: 20
- `pageTop`: 10
- `pageBottom`: 26

These values are the source of truth for Flutter and TypeScript. If either token package differs, treat that as a bug to fix before adding UI.

## Radius

- `card`: 24
- `hero`: 28
- `tile`: 20
- `pill`: 999

Cards should feel friendly but not become nested decorative containers. Do not put UI cards inside other cards.

## Elevation

- `SproutElevation.card`: standard card shadow.
- `SproutElevation.raised`: bottom sheets and raised panels.
- `SproutElevation.hero`: hero gradient surfaces.

Use shadows sparingly. Settings and trust surfaces should stay sober.

## Component Styles

### Cards

Use `SproutCard` for individual content units. Cards should hold a complete item: account, goal, transaction group, explanation, or repeated row. Avoid using cards as page sections.

### Pills

Use pills for compact status, confidence, source, streak, XP, and recommended actions. Pills should be short and scannable.

### Tiles

Use tiles for Today glance items and small action chips. Tiles should be tappable when they reveal an explanation or action.

### Panels

Use `SproutPanel` for bottom sheets such as Quick Add, explanations, source controls, and confirmations.

### States

Use `SproutStates` for loading, empty, and error states. Empty states must still be useful with zero connections.

## Iconography

Use Material rounded icons in Flutter for now. Prefer familiar symbols:

- Wallet/accounts: `account_balance_wallet_rounded`
- Cash/savings: `savings_rounded`
- Add: `add_circle_rounded`
- Settings: `settings_rounded`
- Transactions: `receipt_rounded`
- Goals: `flag_rounded` or `track_changes_rounded`
- Trust/privacy: `verified_user_rounded`, `lock_rounded`
- Warnings: `error_outline_rounded`, used calmly

Icons should support recognition, not decoration. Do not use text-only controls where a familiar icon plus accessible label is clearer.

## Mascot Usage

Use `SproutMascot` with `SproutMascotState`, not `CoinSproutMascot` directly. The widget handles Rive, raster, video, and fallback rendering.

The mascot is largest on Today. Elsewhere it should appear as a small emotional signal, not a second hero.

## Motion

Use `sprout_motion` primitives for press, transitions, number counters, progress rings, mascot idle, and confetti. Honor `MediaQuery.disableAnimations`.

Motion hierarchy:

- Celebration: completed daily action, milestone, XP.
- Gentle attention: setback, warning, review needed.
- Ambient: mascot idle only when it does not distract.

Any animation that janks on low-end Android should be simplified or removed.

# Sprout — Design Language & Elements Spec

**What this is:** the playful visual language layered on top of the existing token system (`sprout_tokens.dart`, `sprout_motion`, `sprout_theme.dart`). It defines how Sprout looks and moves so every screen feels like one app — animated and joyful like Duolingo, but calm enough for money. It does not replace the tokens; it governs how they're used.

> **Realignment note (2026-07-09):** The new Today hero is a large wealth
> figure (Inter, trustworthy) with an up/down movement chip — treat it with
> the same care as the mascot in the weight ladder. The trend sparkline/chart
> is a depth element, not a Today-hero element. The mascot remains the
> living emotional narrator; the wealth figure is the Today hero and largest
> *numeric* element. Do not enlarge the mascot to overpower the wealth figure.
>
> **Layout-lock + motion note (2026-07-09):** The Today layout is locked
> (13-part canonical structure). A "Today load sequence" subsection is added
> specifying the ordered entrance, the count-up-as-hero-moment rule, and
> stagger timing. Haptics-on-every-tap is now a standard. An approved
> interaction toolkit is recorded to protect the 60fps gate. Depth is
> reinforced as the chunky solid kind — tiles never flat/washed.

**Prime rule:** the tokens are the vocabulary; this doc is the grammar. A raw hex, a magic `EdgeInsets`, a literal `Duration`, or a one-off color in feature code is a bug. If a value isn't in a token, it doesn't ship.

---

## 1. The feeling we're designing for

Duolingo-playful, money-calm. Big friendly shapes, generous rounding, confident color, and motion that rewards — but never loud enough to feel anxious about finances. The energy lives in the mascot, the color, and the motion; the layout underneath stays clean and predictable. Playfulness on top of order. If a screen feels busy or hyper, pull energy out of the layout and put it back into Sprout.

---

## 2. Color language (built on existing tokens)

Use only `SproutColors` / `SproutColorScheme.of(context)`. Never a raw hex in feature code.

### Roles (what each color means — keep meaning consistent everywhere)

- **Seed / leaf (green):** health, success, primary action, "you're okay." The default positive.
- **Sky (blue):** information, accounts, neutral facts.
- **Lilac (purple):** goals, aspiration, learning moments.
- **Gold (warm):** money, rewards, XP, streak, celebration accents.
- **Tomato (red):** reserved. Errors and destructive confirms only — never for a bad money state. A tight month is watchful gold/amber, not red.

### Playful-but-calm color rules

- **One dominant color per screen.** Today is green-led; Money is calm/neutral-led; Grow/goals lean lilac. A screen with five competing bright fills reads as chaos — pick a lead and let others support.
- **Tinted surfaces, not flat white everywhere.** Use the tint surfaces (`tintMint`, `tintSky`, `tintLilac`, `tintGold`, `tintWarm`) to give cards gentle personality — but a tint carries meaning (mint = healthy, gold = money/reward, warm = gentle attention). Don't tint for decoration.
- **Color must never be the only signal.** Pair every colored state with an icon or label (accessibility + colorblind users). A red border alone is not an error message.
- **Dark mode is first-class.** Every color comes from the adaptive scheme; test every screen in both. No hardcoded light-mode assumption.

---

## 3. Typography (playful headings, trustworthy numbers)

Three families, each with a fixed job. This split is deliberate — playful where it delights, precise where it's money.

- **Fredoka (display):** greetings, quest labels, celebration text, big expressive moments, playful UI labels. This is the "fun" voice. Rounded, warm, Duolingo-adjacent. Never used for numbers the user must trust.
- **Nunito Sans (body):** explanations, settings, transaction descriptions, all calm reading text. Friendly but neutral.
- **Inter (numbers/money):** money values, score numbers, balances, percentages, any numeric figure the user must trust. Tabular, precise, unambiguous. This is the non-negotiable rule: the score value uses Inter, never Fredoka. Playful numerals undermine trust in financial figures. Same applies to PKR amounts in tiles and any money display. Count-up animations for these values use Inter throughout, never swap fonts mid-animation.

### Type rules

- Use only the fixed scale (`s11`–`s60`); never an arbitrary font size.
- Letter-spacing stays `0` unless the theme already sets it.
- **Never scale type to viewport width.** Sizes are fixed; layout flexes, not the font.
- No oversized display type inside cards, rows, sheets, or settings — big Fredoka belongs to hero moments, not dense surfaces.
- **Score number rule (non-negotiable):** The garden-health score (e.g., "78") and any financial metric must always use Inter font. The label "Garden Health" or similar may use Fredoka for warmth, but the number itself is always Inter.
- **Wealth hero rule (non-negotiable):** The total wealth figure on Today (e.g., "PKR 13,673,019") is the largest numeric element on the screen and always uses Inter font. The movement chip (up/down PKR amount) also uses Inter. Playful numerals never appear on the wealth figure. Treat the wealth figure with the same care as the mascot in the weight ladder — it is the number the user opens the app for.
- **Money in tiles rule (non-negotiable):** PKR amounts, balances, and financial values in today's glance tiles use Inter, never Fredoka, to maintain trust and readability.
- Support **1.3× text scale** without clipping or broken layout (test it; it's a regression invariant).
- Numbers that animate (count-up) use Inter throughout the animation, never a swap mid-count.

---

## 4. Spacing, layout & the consistency contract

This is the section that makes twenty screens look like one app. Enforce it hard.

### Spacing

- Use only `SproutSpacing` tokens (`xs 4 / sm 6 / md 10 / lg 16 / xl 26 / xxl 42`). No literal `EdgeInsets` numbers in feature code.
- **Page padding is fixed and identical on every screen:** `pageHorizontal 20`, `pageTop 10`, `pageBottom 26`. Every screen breathes the same. No screen invents its own margins.
- **Vertical rhythm between sections is one token** (pick `lg` or `xl` and use it consistently). Sections are not spaced by eyeball.

### Content width & stretch (edge-to-edge consistency)

- Content is a single column that stretches to the page padding — full-width cards, not floating narrow ones, and not inconsistent insets per screen.
- Cards and primary buttons stretch to the same content width on every screen. A button that's full-width on Today is full-width on Money.
- **No nested cards.** A card holds one complete item; it never contains another card. (Already a spec rule — enforce in review.)
- Grids (quick-action tiles) use a fixed gutter (`sm` or `md`) and equal-width cells; never ragged.

### Radius (the friendly shape language)

- Use only `SproutRadius`: `card 24`, `hero 28`, `tile 20`, `pill 999`.
- Generous rounding is core to the playful feel — but consistent: all cards are `card`, all chips/buttons are `pill`, all small tiles are `tile`. Never mix radii within a role.

### Elevation

- Use only `SproutElevation` (`card / raised / hero`). Shadows are sparing. Trust surfaces (Settings) stay flat and sober; hero surfaces may lift. No custom shadows.

---

## 5. Core components (the shared kit — reuse, don't reinvent)

Every screen is assembled from these existing primitives. A new bespoke component is a last resort and must justify itself.

- **`SproutCard`** — one content unit (account, goal, transaction group, explanation). Token-driven. The default container.
- **Pills** — status, confidence, source, streak, XP, recommended action. Short, scannable, `pill` radius.
- **Tiles** — Today glance items and quick-action chips. Tappable when they reveal an explanation/action; the tap affordance must be visible. **Tiles keep the solid chunky bottom edge** — committed tints, not washed-out pastels. Depth is the chunky solid kind, never flat/washed.
- **`SproutPanel`** — all bottom sheets (Quick Add, Sprout Explains, confirmations). One sheet style app-wide: same handle, same radius, same entrance.
- **`SproutStates`** — loading, empty, error. Empty states are useful with zero connections (never a dead blank).
- **Buttons** — one primary style (filled, `pill`, full content width), one secondary (quieter), one text/skip (warm, underlined). Exactly one primary action emphasized per screen.

### Iconography

- Material rounded icons only, from the agreed set. Icons aid recognition, not decoration. Every icon that carries meaning has an accessible label. Never a text-only control where a familiar icon + label is clearer.

---

## 6. Forms & inputs (playful, not paperwork)

Inputs follow the info-gathering laws (one question per moment, tap over type). Visually:

- **Chips are the default input.** Big, rounded (`pill`), tappable, with a clear selected state (filled tint + check). Selecting a chip should feel satisfying — subtle scale/haptic on tap.
- **Text fields are rare and friendly.** Rounded (`card` or a dedicated field radius), generous height (min 48dp tap target), clear focus state using the lead color, a plain example as placeholder (not "e.g."), and a visible label. Only used where a choice genuinely can't express the answer.
- **Sliders/steppers over numeric keypads** where a range works (e.g. goal amount) — more playful, less typing.
- **One field visible at a time in flows.** No stacked form of ten inputs. Ever.
- **Validation is gentle and inline.** Non-punitive copy, calm color (never red-alarm for a normal mistake), and it never blocks the user from continuing where a value is optional.
- **Every input has an obvious skip/optional affordance** unless it's the defined required minimum.

---

## 7. Motion (the Duolingo magic — via `sprout_motion` only)

All motion comes from the `sprout_motion` primitives (`SproutButtonPress`, `ConfettiBurst`, `SproutNumberCounter`, `SproutProgressRing`, `SproutTransitions`, `SproutCurves`, `SproutDurations`, mascot idle). No ad-hoc `AnimationController` with literal durations in feature code.

### Motion hierarchy (what's allowed to move, and when)

- **Celebration (loud, rare):** completed daily action, milestone, streak protected/repaired. Confetti + mascot bounce + XP burst + count-up. Capped particles. This is the peak — reserve it for real wins.
- **Reveal (medium):** score counts up, ring sweeps, goal bars fill — on first appearance only, to communicate change. Staggered card entrance (the existing ~45ms/index) gives the screen life without chaos.
- **Feedback (small, everywhere):** button press-scale, chip select, tap ripples, **haptics on every tap** (tile, chip, nav, action — via built-in `HapticFeedback`), a chime on completion.
- **Ambient (subtle):** mascot idle blink/bob only — never enough to distract from reading. **The mascot must animate on Today** — idle breathing/bob + occasional blink is the minimum; static PNG is fallback only (reduce-motion, missing asset).
- **Gentle (for bad news):** soft, slow, caring motion. Never alarm, never shake, never red flash.

### Motion rules (non-negotiable)

- **Every animation means something.** If it doesn't communicate change, completion, or feedback, cut it. No motion for busyness.
- **Reduce-motion is respected at every animated surface** (`MediaQuery.disableAnimations`). Disabling motion shows a calm static state and never hides information or breaks layout.
- **Performance is the gate.** Wrap animated subtrees in `RepaintBoundary`, use `const`, cap particles, static-fallback when Rive is unavailable. Any animation that drops frames on the target low-end Android device is simplified or removed. A still screen at 60fps beats a beautiful one that stutters.
- **Celebration never blocks.** Show it instantly and let background work finish behind it; it auto-dismisses (the existing ~1.8s pattern). The user is never trapped in an animation.

---

## 8. The mascot as a design element

Sprout is the primary expressive element, not an illustration in a corner.

- **Today: mascot is the living emotional narrator**, mood driven by real state (via `SproutMascotState`), animated (idle/celebrate/gentle), and visually present without overpowering the wealth figure.
- **Money / Settings / Quick Add: mascot is a small, calm signal only** — never a second hero competing with the content.
- **Rive first, CustomPaint fallback always available.** A missing/failed Rive asset never produces a blank box — the painted `CoinSproutMascot` renders instead. Reduce-motion shows still art.
- **Four product moods, one canonical expression each** (thriving / content / watchful / concerned). Bad news uses watchful or concerned — never angry, never red-faced.

---

## 9. Cross-platform (Android + iOS, one Flutter codebase)

Sprout looks like itself on both platforms — not Material on Android and Cupertino on iOS — but respects each platform's physics and safe areas.

- **One visual language both platforms** (the token system). Don't fork the look per OS.
- **Respect safe areas / notches / home indicators** on both; page padding sits inside safe insets. Test the sheet and bottom nav against the iPhone home indicator and Android gesture bar.
- **Platform-native feel where it matters:** scroll physics (bouncing on iOS, glow/clamp on Android), back-gesture behavior, and haptics use the platform's native APIs. A sheet dismisses the way each OS expects.
- **Capture reality differs by platform** and the UI must reflect it honestly: SMS auto-capture is Android-only; on iOS that option is absent or clearly "not available on iPhone," never a dead toggle.
- **Fonts render on both** — bundle the three families; don't rely on system fallbacks that differ across OSes and break the numeric alignment of Inter.
- **Tap targets ≥ 48dp** on both. Test one-handed reach: primary actions sit in the comfortable lower zone.

---

## 10. Design acceptance criteria (per screen)

A screen is visually done only when:

- It uses only tokens — no raw hex, magic spacing, literal duration, or off-scale type.
- Page padding and content width match every other screen.
- It has one dominant color and one emphasized primary action.
- Numbers use Inter; playful text uses Fredoka; reading text uses Nunito Sans.
- Radii, elevation, and component styles come from the shared kit; no nested cards.
- All motion routes through `sprout_motion`, means something, and has a reduce-motion static state.
- It holds the performance floor on the target low-end Android device.
- It renders correctly in light and dark, at 1.3× text scale, and within safe areas on both Android and iOS.
- The mascot's prominence matches the screen's role (emotional narrator on Today, quiet elsewhere).
- Color is never the sole carrier of meaning.

---

## 11. What kills the design (guard these)

- **Token drift** — a new blue here, a 22px padding there. After twenty screens, nothing matches. Enforce tokens by lint, not goodwill.
- **Motion for its own sake** — animating to look busy instead of to communicate. It reads as chaos and it costs frames.
- **Red for money moods** — the instinct to make a bad month "clearer" with red alarm. Red is errors only; money stays watchful-gold. This is the line between a coach and an anxiety machine.
- **A second hero** — a big bright element added to "balance" the wealth figure. Today already has its hero: total wealth. Sprout supplies emotion; the UI should not create another competing focal point.
- **Per-screen personality** — each screen inventing its own margins, radii, or rhythm. Consistency is the design; deviation is the bug.

---

## 12. Today Screen Motion Implementation (sprout_motion wiring)

The Today screen's emotional journey relies on motion tied to state change, not decoration. The layout is locked (13-part canonical structure); the remaining quality is temporal. These are wired via `sprout_motion` and `flutter_animate` primitives.

### Today Load Sequence (the screen assembles, it does not just appear)

On Today open, the screen assembles in this ordered entrance. This is a first-class requirement.

1. **Wealth figure counts up** to its value over ~800ms, ease-out (fast then settling). This is the **hero moment** of the load — the number the user opened the app for arrives with weight. Use `SproutNumberCounter` with `SproutCurves` ease-out. Inter font throughout, never swap mid-count.
2. **Movement chips fade in** just after the number lands (~100ms delay).
3. **Mascot does a small settle-bounce** on entrance — `Transform.scale` with `SproutCurves.playful`, gentle not exuberant unless thriving mood.
4. **"What's happening" tiles stagger in**, rising/fading, ~50ms apart via `flutter_animate` stagger.
5. **Goal progress bars/rings fill** left-to-right on first reveal — `SproutProgressRing` / animated `LinearProgressIndicator`.
6. **"Why it moved" paragraph fades in** last.

**Total on-screen time:** ~1.2s before the user perceives the screen as fully loaded. Content is readable instantly — non-essential motion finishes behind reading. Never block reading on animation.

### On Action Completion
- **Confetti burst:** Use `ConfettiBurst` (capped particles, respects `reduce-motion`). Auto-dismisses after ~1.8s; never blocks the user.
- **Haptic + chime:** `HapticFeedback.mediumImpact` + completion chime on action completion.
- **Streak and XP animation:** Use `XpRewardAnimation` for the "+XP" burst, streak pill pulses.
- **Mascot state:** Transition to `celebrate` with bounce (use `Transform.scale` and `SproutCurves.playful`).
- **Completion feedback:** Brief "Done today." message stays calm; no alarm or triumph.

### Haptics Standard

- **Light haptic on every tap:** tile taps, chip taps, nav taps, button presses — via built-in `HapticFeedback.lightImpact`. No dependency needed.
- **Medium haptic on action completion:** `HapticFeedback.mediumImpact` paired with the chime + confetti.
- Haptics are suppressed when reduce-motion is enabled (consistent with the motion-suppression contract).

### Respect Reduce-Motion
- When `MediaQuery.of(context).disableAnimations` is true, show all elements instantly in their final state.
- Count-up → static final number. Stagger → all tiles visible immediately. Bounce → no bounce. Confetti → no confetti. Goal fill → bars at final state.
- The screen must be complete and understandable with zero animation.
- Use `if (reducedMotion)` guards as already implemented in `_QuestHeroState`.

### Performance Constraints
- Wrap animated subtrees in `RepaintBoundary` to prevent redraw cascades.
- Cap `ConfettiBurst` particle count (default is safe; do not increase).
- Test on target low-end Android: if any motion causes frame drops, simplify or remove.
- A still screen at 60fps is better than beautiful motion at 40fps.

### Approved Interaction Toolkit

No heavy additions. Every dependency risks the 60fps low-end gate.

- **`flutter_animate`** — load cascade, staggered tiles, fades/slides.
- **`sprout_motion`** (`SproutNumberCounter`, `SproutProgressRing`, `ConfettiBurst`, press) — count-up, ring/bar fill, confetti, press.
- **Built-in `HapticFeedback`** — taps everywhere (no dependency needed).
- **`fl_chart`** — the 6-day trend tap-through only.
- **Do NOT add** heavy animation/physics libraries (e.g. lottie physics engines, custom particle systems, physics-based spring packages beyond what `sprout_motion` provides). Every dependency risks the 60fps low-end gate.

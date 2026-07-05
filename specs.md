# Sprout — Sub-Agent Prompt Pack (v2, matched to the real monorepo)

Production-ready instructions for parallel coding agents extending **Sprout**, a Duolingo-style financial health companion for Pakistan.

> **What changed from v1:** Phase 0 (theme, tokens, shell, shared widgets, mascot, data contracts) and the entire **Today** feature are already built. The parallelizable work now is the four placeholder tabs — **Budget, Grow, Learn, Profile** — each built as a full-stack contract that mirrors the existing Today feature across TypeScript and Dart.

---

## How to use this pack

1. **Paste the Shared Preamble into every agent**, then append that agent's prompt.
2. **Run the four tab agents in parallel.** Each owns its own presentation folder plus its own per-feature files across the stack. The only shared-file edits are single append-only lines, spelled out per agent — so parallel merges are trivial.
3. **Phase 2 (onboarding, localization/Urdu, real API wiring) comes last** and is sequential. Do not parallelize it.

---

## SHARED PREAMBLE (paste into EVERY agent)

You are a senior full-stack engineer extending **Sprout**, a financial health companion for Pakistan. You are adding ONE feature that spans a TypeScript backend contract and a Flutter client, mirroring the existing **Today** feature exactly.

### Product one-liner
Sprout is the 30-second daily money check-in a Pakistani earner actually looks forward to — calm, trustworthy, turns financial anxiety into small winnable moments, and stays fully useful even when connected to nothing.

### The repo (pnpm monorepo — study Today before writing anything)
```
apps/
  api/        TypeScript Hono API (Zod-validated). Dev: pnpm dev:api → http://localhost:8787
  mobile/     Flutter app (primary client). Dev: pnpm dev:web (Chrome :8080) or cd apps/mobile && flutter run
packages/
  shared/         Zod schemas + mock payloads (the API contract). @sprout/shared
  design_tokens/  Cross-platform tokens (TS), mirrored in Flutter. @sprout/design_tokens
  domain/         Pure calculation engines (e.g. financial health score). @sprout/domain
  parsers/        Mock email/SMS/CSV parsing adapters. @sprout/parsers
  sprout_motion/  Local Flutter package: animation primitives.
```
Build/verify: `pnpm install`, `pnpm check` (typecheck all TS packages), then `cd apps/mobile && flutter analyze && flutter test`.

### THE PATTERN TO COPY — how the Today feature is wired end to end
Replicate this exact chain for your feature; do not invent a different shape:
1. `packages/shared/src/<feature>.ts` — Zod schemas + `z.infer` types for your payload.
2. `packages/shared/src/mock-<feature>.ts` — a realistic Pakistani mock dataset (PKR, Meezan/Wise/Al Meezan, chai/committee/Zakat/Eidi categories).
3. *(only if you need computation)* `packages/domain/src/<feature>-*.ts` — a pure, tested engine. Mirror the transparency of `financial-health-score.ts`.
4. `apps/api/src/routes/<feature>.ts` — a Hono sub-router exposing `GET /v1/<feature>`, returning mock data (run through your domain engine if any) and validated with `<Feature>ResponseSchema.parse()` before returning.
5. `apps/mobile/lib/src/domain/<feature>_models.dart` — immutable Dart models mirroring the Zod types 1:1.
6. `apps/mobile/lib/src/data/mock_<feature>_repository.dart` — an `abstract interface class <Feature>Repository`, a `Mock<Feature>Repository` (simulate ~220ms latency like `MockTodayRepository`), and a `<feature>RepositoryProvider` (`Provider<<Feature>Repository>`) — the future swap point for a real HTTP client.
7. `apps/mobile/lib/src/presentation/<feature>/` — `<feature>_controller.dart` (`FutureProvider<<Feature>Data>` reading the repo provider), `<feature>_screen.dart` (replace the placeholder; handle async via `.when(data/loading/error)` using `SproutStates` for loading/error), and `<feature>_widgets.dart` (all sub-widgets).

### The ONLY shared files you may touch (append-only, one line each)
- `packages/shared/src/index.ts` — add one `export * from './<feature>.js'` line.
- `packages/domain/src/index.ts` — add one export line **only if** you created a domain engine.
- `apps/api/src/index.ts` — add one `app.route('/v1/<feature>', <feature>Route)` registration line.

Everything else lives in files you create or in your own presentation folder. **Do not edit another feature's folder, the theme, the shell, the router config, `sprout_motion`, or the Today feature.** The five tab routes already exist in the `ShellRoute`; you are replacing a placeholder screen, so you do **not** add or edit routes.

### Consume the existing foundation — DO NOT rebuild any of this
Already built and off-limits to re-implement:
- **Theme/tokens:** `SproutColors`, `SproutSpacing`, `SproutRadius`, `SproutElevation`, `SproutGradients`; `SproutColorScheme.of(context)` (a `ThemeExtension`, light/dark aware); `buildSproutTheme()`. Material 3.
- **Type:** Fredoka (display/numbers) + Nunito Sans (body) via `google_fonts`. Use theme text styles; never instantiate fonts yourself.
- **Motion (`sprout_motion`):** `SproutButtonPress`, `ConfettiBurst`, `SproutCurves`, `SproutDurations`, `SproutNumberCounter`, `SproutProgressRing`, `SproutTransitions`, mascot idle helpers. Reach for these before writing raw animation code.
- **Shared widgets:** `SproutCard`, `SproutPage`, `SproutPanel` (bottom sheets), `SproutStates` (loading/error), `SproutMascot` (+ `CoinSproutMascot` fallback, `sprout_mascot_state`).
- **Mascot, Financial Health Score, Daily Quest, Streak, Money Status, Money Radar, Payday, Quick Actions** — all exist inside the Today feature. Reuse their widgets/models where sensible; do not duplicate them.

### Pinned stack (do not substitute)
Flutter stable, Dart 3.5+, null-safe · Riverpod `flutter_riverpod ^2.6.1` · `go_router ^14.6.2` · `google_fonts ^6.3.0` · `flutter_animate ^4.5.2` · `rive ^0.13.20` · `lottie ^3.3.1` · `intl ^0.20.1` · local `sprout_motion`. Backend: Hono `^4.6.16`, Zod `^3.24.1`, `@hono/node-server`, `tsx`. Keep TS `strict`.

### Non-negotiable tone & safety rules (already enforced in code — keep enforcing)
- Playful/celebratory on **progress**; calm and supportive on **problems**. The `worried`/`concerned` register is never guilt-inducing.
- Any health/status number is **never a black box** — always paired with the factors behind it and one concrete recommended action (with XP + impact, like the score engine).
- The app is **fully alive with zero connections** — manual paths are first-class, not fallbacks. Your empty states must be useful and encouraging.
- **No dark patterns.** Loss-aversion is fine for streaks; forbidden when aimed at real spending or upsells. No investment FOMO or pressure in Grow.

### Design, localization, performance (hard rules)
- **No hardcoded design values.** A raw hex, magic `EdgeInsets`, or literal `Duration`/`Curve` in feature code is a bug — pull from tokens / `sprout_motion`.
- **Strings:** route user-facing copy through the existing string layer (`sprout_strings.dart` / `intl`). Assume Urdu/RTL is coming (Phase 2): don't bake in LTR-only layouts or fixed widths that break under RTL or 1.3× text scale.
- **Performance gate (hard):** 60fps on a ~2GB-RAM budget Android device, tested in profile mode. Use `const`, `RepaintBoundary` around animated subtrees, scoped providers / `ref.watch(select:)`, capped confetti particles, and honor reduce-motion via `MediaQuery.disableAnimations` at every animated surface. A cut animation beats jank.

### Definition of Done
- Full-stack feature works against mock data: `GET /v1/<feature>` returns schema-valid JSON; the Flutter screen renders it via its repository/controller.
- TypeScript: `pnpm check` clean. Flutter: zero `flutter analyze` warnings, `dart format` applied.
- Tests: domain engine unit tests (if any); Flutter widget tests for each state + at least one golden for the primary visual state.
- A standalone preview under your presentation folder (`<feature>_preview.dart`) rendering every visual state in isolation.
- Public API (Zod schemas, Dart models, providers, widgets) documented (`///` / JSDoc).
- TS types and Dart models are in exact 1:1 sync (no codegen bridge exists — keep them aligned by hand and note it in the PR).
- All tone, token, localization, and performance rules above respected.

---

## PHASE 1 — The Four Tabs (run in parallel)

Each prompt assumes the Shared Preamble is prepended. `<feature>` names are given per agent.

### Agent A — Budget tab  ·  `<feature> = budget`

**Mission:** Turn logged/captured spending into a calm, glanceable budget health view — category health lights, spend breakdown, and upcoming-bill risk — that never scolds and always offers a next step.

**Owns:** `apps/mobile/lib/src/presentation/budget/`, plus its own per-feature files across the stack (schema, mock, route, model, repository) per the Pattern.

**Contract (`packages/shared/src/budget.ts`):** `BudgetResponse` = monthly period info; a list of `CategoryBudget` (category, budgeted, spent, band: `healthy`/`watch`/`over`, typical-for-you baseline); `UpcomingBill` list (name, amount, dueDate, dueRisk); month-to-date totals; and a `recommendedAction`. Mock in `mock-budget.ts` with Pakistani categories (chai, groceries, fuel, ride-hailing, mobile load, utilities, school fee, committee/BC, Zakat, rent).

**Build:**
- Category budget list: each row a `SproutCard` with an animated fill (`SproutProgressRing` or a linear variant) and a health-light color from tokens (`healthy`/`watch`/`over`).
- Spend-by-category summary for the month with a compact, low-cost visual (avoid heavy charting libs on low-end devices — a token-styled bar layout is fine).
- Upcoming bills list ordered by due risk, with a calm "at risk" treatment (no alarm-red panic).
- **Alive-when-empty:** with no data, show a friendly "start logging to see your budget bloom" state, still branded and useful.
- Ties conceptually to the score's spending-pace and bills-coverage factors — surface the same recommended action shape.

**Acceptance:** over-budget category renders calmly + carries a doable next step; bills sort by risk; fills animate on load and respect reduce-motion; golden tests for healthy / watch / over / empty.

---

### Agent B — Grow tab  ·  `<feature> = grow`

**Mission:** The "money garden" — savings goals, an emergency-fund tracker, and simple investment snapshots — where progress is visibly, joyfully *grown*. This is where the plant/mascot metaphor pays off ("Your money garden is calm today", the "Plant PKR 10K" quest).

**Owns:** `apps/mobile/lib/src/presentation/grow/` + per-feature files.

**Contract (`packages/shared/src/grow.ts`):** `GrowResponse` = a list of `SavingsGoal` (name, target, saved, pct, e.g. the Car fund at 35%); an `EmergencyFund` summary; an `Investments` snapshot — `MutualFund` holdings using MUFAP-style NAV mock data (fund name, NAV, category, return) and cash-goal summaries; plus milestone metadata. Mock in `mock-grow.ts` (Al Meezan / MUFAP-style funds, PKR).

**Build:**
- Goals list with animated progress and a **garden-growth visual** that advances with pct (a plant/sprout that visibly grows by milestone). Keep it cheap to render; static-frame fallback under reduce-motion / Rive-absence, mirroring the mascot's fallback discipline.
- Milestone celebration: crossing a threshold (e.g. 25/50/75/100%) triggers a brief `ConfettiBurst` + a mascot celebrate beat (reuse mascot widgets; do not rebuild them).
- Emergency-fund tracker with an encouraging target framing.
- Investment snapshot: read-only NAV/return cards from mock MUFAP data. **No FOMO, no pressure, no "buy now"** — informational and calm.
- **Alive-when-empty:** a "plant your first goal" empty state that creates a goal via a `SproutPanel` sheet.

**Acceptance:** goal progress + garden visual animate to pct; milestone celebration fires once per threshold crossing; investment cards render from mock NAVs; tone review passes (no investment pressure); goldens for empty / mid / milestone / funded.

---

### Agent C — Learn tab  ·  `<feature> = learn`

**Mission:** The most Duolingo-like surface — a path of 30–60s micro-lessons that earn XP and feed the existing streak/XP economy. Bite-size, playful, Urdu-friendly.

**Owns:** `apps/mobile/lib/src/presentation/learn/` + per-feature files.

**Contract (`packages/shared/src/learn.ts`):** `LearnResponse` = an ordered `LessonPath` of `LessonNode`s (id, title, status: `locked`/`available`/`done`, xp); each `Lesson` has 1–3 short `LessonCard`s (title, body) and one `CheckQuestion` (prompt, options, correctIndex, explanation). Seed content: "What is IBFT", "Raast vs card", "Salary tax basics", "Inflation ate your savings". Mock in `mock-learn.ts`.

**Build:**
- A **lesson-path UI** (Duolingo-style nodes: locked → available → done) driving progression.
- Lesson player: swipeable cards → one check question → result. Correct answer → success haptic + chime + XP award + node marked done + next node unlocks.
- XP awards must use the **existing XP/quest economy** (reuse Today's reward animation/models — do not fork a second XP system). Emit the same completion signal the Daily Quest uses so the mascot can celebrate.
- Progress persists via the repository (mock persists in memory).
- Urdu-readiness: content model supports an Urdu string per field even if English ships first.

**Acceptance:** completing a lesson awards XP, marks the node done, unlocks the next, and celebrates; wrong answers are gently corrective (no shaming); reduce-motion honored; goldens for locked / available / in-lesson / result / path-complete.

---

### Agent D — Profile tab  ·  `<feature> = profile`

**Mission:** Identity, progress, and — critically — the **trust surface**: transparent data controls plus settings. Trust is the product.

**Owns:** `apps/mobile/lib/src/presentation/profile/` + per-feature files.

**Contract (`packages/shared/src/profile.ts`):** `ProfileResponse` = user (name, level derived from XP, total XP); streak stats (current, longest, history for a calendar); `Achievement`/badge list; connected `DataSource`s (Gmail, Meezan, Wise, Al Meezan — each with status + confidence + "needs review" count); and settings state (theme, language, hide-balances default, notifications, reduce-motion). Mock in `mock-profile.ts`.

**Build:**
- Profile header: name, level, XP-to-next, and a streak summary with a longest-streak **calendar/history** (reuse streak widgets/models from Today where possible).
- Achievements/badges grid with earned vs locked states.
- **Data-control surface (the trust core):** list connected sources with confidence badges and a "needs review" count; each source is one tap from *view what it reads / disconnect / delete data*. Copy must state: OAuth-only, no stored bank passwords, statements discarded after parsing by default. Route low-confidence items to a one-tap confirm list. Never silently trust uncertain data.
- Settings: theme via the existing `themeModeProvider` (do not create a new one); language English/Urdu toggle (wired to the Phase 2 l10n layer — expose the control now); hide-balances default; notifications; reduce-motion note.
- **Alive-when-empty:** with nothing connected, reassure that the app is fully useful and framing connection as an optional upgrade.

**Acceptance:** disconnect/delete reachable in one tap; confidence + review list work from mock; theme toggle uses the existing provider and persists; trust copy present and accurate; goldens for connected / needs-review / empty.

---

## PHASE 2 — Integration (sequential, after Phase 1)

Run each as a focused task with the Shared Preamble:

- **Localization & Urdu/RTL hardening** — add `flutter_localizations` + ARB (en/ur), Noto Nastaliq Urdu to the pubspec/theme, RTL audit across all tabs, and wire the Profile language toggle. (Not currently in the pubspec — this is net-new.)
- **Onboarding & permission flows** — plainspoken consent (Gmail, optional Android SMS, statement import) using the trust copy; depends on Profile's data surface + l10n.
- **Real API wiring** — implement HTTP repositories against `http://localhost:8787` (and prod base URL) behind each existing `*Repository` interface, then flip the `*RepositoryProvider`s from Mock to HTTP. Because every feature codes against the interface, no feature/UI code changes.
- **Full-app performance pass** — profile every tab on a low-end device; enforce the 60fps gate; tune or gate animations as needed.

---

## Reviewer checklist (apply to every merged agent)

- Follows the Today end-to-end pattern; per-feature files only; shared-file edits are the three named append-only lines and nothing more.
- Consumes existing theme/tokens/`sprout_motion`/shared widgets — zero hardcoded design values, no rebuilt foundation or duplicated Today components.
- Codes against a `*Repository` interface + mock; no direct network/platform calls; no router/shell/theme edits.
- TS `pnpm check` clean; Flutter `analyze` clean + formatted; Dart models 1:1 with Zod types.
- Tone rules honored (no guilt, explainable numbers, alive-when-empty, no dark patterns / no investment pressure).
- RTL- and 1.3×-text-safe; reduce-motion respected; 60fps on low-end profile.
- Tests + golden(s) + `<feature>_preview.dart` + doc comments present.
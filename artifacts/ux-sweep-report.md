VERDICT: STRUCTURAL ISSUES — the real zero-data path is reachable, but the screen seams, state fixtures, and matrix coverage are not production-auditable yet; Today and Settings visibly collide with their own content/navigation.

## Run conditions and evidence

Real stack, mocks OFF, local Docker Postgres, authenticated account, Flutter web at 360×800. The requested `pnpm seed:ux-states` command is not present in this checkout, so state-account coverage is blocked rather than inferred. Screenshots are under [artifacts/ux-sweep](/Users/mohsinhayat/Documents/Sprout%20Financial/artifacts/ux-sweep/).

Observed evidence includes:

- [Today real zero-data](ux-sweep/Today/today-zero-data.png)
- [Money](ux-sweep/Money/money-populated.png)
- [Insights quiet week](ux-sweep/Insights/insights-populated.png)
- [Settings root](ux-sweep/Settings/root.png)
- [Settings data sources](ux-sweep/Settings/lower-controls.png)
- [Settings privacy](ux-sweep/Settings/privacy-preferences.png)
- [Settings notifications](ux-sweep/Settings/preferences-lower.png)
- [Quick Add expense sheet](ux-sweep/QuickAdd/expense-sheet.png)
- [Quick Add income](ux-sweep/QuickAdd/income-path.png)
- [Quick Add validation](ux-sweep/QuickAdd/validation-error.png)

## Screen scorecard

Legend: PASS = screenshot-backed; FAIL = screenshot-backed issue; BLOCKED = not reachable or required fixture absent; N/A = not applicable to the observed state.

| Screen/state | P | L | C | I | S | F | Evidence / blocker |
|---|---|---|---|---|---|---|---|
| Onboarding welcome | PASS | PASS | PASS | PASS | PASS | PASS | [P1 welcome](ux-sweep/Onboarding/P1-welcome.png) |
| Onboarding name + skip | PASS | PASS | FAIL | BLOCKED | PASS | PASS | [P1 name](ux-sweep/Onboarding/P1-name.png); semantics exposed generic controls |
| Onboarding goal + skip | PASS | PASS | PASS | BLOCKED | PASS | PASS | [P1 goal](ux-sweep/Onboarding/P1-goal.png); full tap path not re-run in this sweep |
| Celebration handoff | PASS | PASS | PASS | PASS | PASS | PASS | [P1 celebration](ux-sweep/Onboarding/P1-celebration.png); real handoff now works after backend fix |
| Auth registration/login/error/logged-out return | BLOCKED | BLOCKED | BLOCKED | BLOCKED | BLOCKED | BLOCKED | Auth route was reached in prior run, but no fresh sweep screenshot set; fixture accounts do not cover all error variants |
| Today zero-data | FAIL | FAIL | FAIL | FAIL | PASS | FAIL | [Today zero-data](ux-sweep/Today/today-zero-data.png) |
| Today thin/good/down/stale/insufficient/offline/error/post-action | BLOCKED | BLOCKED | BLOCKED | BLOCKED | BLOCKED | BLOCKED | No `seed:ux-states`; no safe runtime trigger for these states |
| Money populated/manual cash | PASS | FAIL | PASS | BLOCKED | PASS | FAIL | [Money](ux-sweep/Money/money-populated.png); lower content/nav seam and mascot absent/presence not fully verified |
| Money empty/offline/holdings/detail/trend/accounts/safe-to-spend/goals/transactions/uncertain review | BLOCKED | BLOCKED | BLOCKED | BLOCKED | BLOCKED | BLOCKED | No state seed; subroutes require data/taps not reached |
| Goal editor create/edit/contribute/complete/delete/reorder/empty/unaffordable | BLOCKED | BLOCKED | BLOCKED | BLOCKED | BLOCKED | BLOCKED | Both entry points blocked by missing seeded goals and no sweep fixture command |
| Insights quiet week | PASS | PASS | PASS | N/A | PASS | PASS | [Insights](ux-sweep/Insights/insights-populated.png); observed state is quiet, not populated 3–6 |
| Insights populated/offline/detail | BLOCKED | BLOCKED | BLOCKED | BLOCKED | BLOCKED | BLOCKED | No seeded insight payload available |
| Quick Add expense | FAIL | FAIL | PASS | PASS | PASS | FAIL | [Expense sheet](ux-sweep/QuickAdd/expense-sheet.png) |
| Quick Add salary/freelance/gift/other | PASS | PASS | FAIL | PASS | PASS | PASS | [Income path](ux-sweep/QuickAdd/income-path.png); “Import statem…” clips at this viewport |
| Quick Add validation | PASS | PASS | PASS | PASS | PASS | PASS | [Validation](ux-sweep/QuickAdd/validation-error.png) |
| Quick Add offline/save/success/from all four tabs | BLOCKED | BLOCKED | BLOCKED | BLOCKED | BLOCKED | BLOCKED | No offline injector or state seed; origin screenshots captured but full save/force-kill seam not run |
| Settings root/profile/income/goals | FAIL | FAIL | PASS | BLOCKED | PASS | FAIL | [Settings root](ux-sweep/Settings/root.png) |
| Settings sources/privacy | PASS | FAIL | PASS | BLOCKED | PASS | PASS | [Sources](ux-sweep/Settings/lower-controls.png), [privacy](ux-sweep/Settings/privacy-preferences.png) |
| Settings notifications | PASS | PASS | PASS | BLOCKED | PASS | PASS | [Notifications](ux-sweep/Settings/preferences-lower.png) |
| Settings reduce-motion/balance/language/streak/delete/export | BLOCKED | BLOCKED | BLOCKED | BLOCKED | BLOCKED | BLOCKED | Controls not all reachable in captured scroll; language/streak/delete/export not exposed in this run |
| Sprout Explains from score/tile/event/provenance/insight | BLOCKED | BLOCKED | BLOCKED | BLOCKED | BLOCKED | BLOCKED | Origins not reachable with zero-data account and no seeded wealth/insights |
| System asks/notifications/dialogs/toasts | BLOCKED | BLOCKED | BLOCKED | BLOCKED | BLOCKED | BLOCKED | No seeded contextual events or notification deep links |

## Top 10 findings

1. **Today zero-data — U3/L1/F5 — [screenshot](ux-sweep/Today/today-zero-data.png).** The mascot visibly sits over “Sprout is still getting to know your money,” so the emotional narrator obscures the sentence. The primary action is “Review today’s wealth movement” even though the real user has no movement. Fix the zero-data composition and make the primary action manual-first, e.g. add a cash entry.

2. **Today zero-data — L2/A1 — [screenshot](ux-sweep/Today/today-zero-data.png).** The lower “Why it moved today” content is hidden behind the floating nav at 360×800. Fix reserved bottom inset/scroll padding and assert last-content visibility.

3. **Settings root — L2 — [screenshot](ux-sweep/Settings/root.png).** The “Add a goal” CTA is clipped by the floating nav. Fix the page’s bottom safe-area budget before adding more Settings content.

4. **Quick Add expense — P3/F1 — [screenshot](ux-sweep/QuickAdd/expense-sheet.png).** The sheet presents many co-equal category chips plus two income/import actions; the sheet’s hero is difficult to name in three words. Group expense categories and make the income/import escape hatches secondary.

5. **Quick Add income — C3/L1 — [screenshot](ux-sweep/QuickAdd/income-path.png).** “Import statem…” is visibly clipped on the companion action. Shorten the label at source or allow it to wrap without truncation.

6. **Money — L2 — [screenshot](ux-sweep/Money/money-populated.png).** The “Add a goal” card ends at the floating nav edge, leaving the user unsure whether the action is fully available. Reserve nav space consistently across all scroll surfaces.

7. **Money — C2 — [screenshot](ux-sweep/Money/money-populated.png).** “PKR 0.0 of PKR 0.0” and “Left to spend: PKR 0.0” are not Pakistan-natural formatting and repeat near-identical zeros. Use a single clear zero-state sentence and local grouping/lakh rules when values exist.

8. **Insights — P1/F5 — [screenshot](ux-sweep/Insights/insights-populated.png).** The observed screen is a quiet-week state while the surface is labeled as the populated case. That mismatch makes the tab feel empty during a first inspection. Give quiet-week its own explicit state label and test populated 3–6 items separately.

9. **Settings privacy — F1/L3 — [screenshot](ux-sweep/Settings/privacy-preferences.png).** The privacy card is a large tinted panel with multiple rows and a toggle, visually more like a dashboard card than the spec’s sober trust surface. Flatten the surface and keep one trust statement plus scannable controls.

10. **Global state coverage — all state checks — [Today evidence](ux-sweep/Today/today-zero-data.png).** Without `pnpm seed:ux-states`, down-day, stale, offline, uncertain, failed, and post-action states cannot be exercised. Add a deterministic state seeder before calling the UI beta-ready.

## Per-screen punch-list

### Onboarding

- A4/C3 — [name](ux-sweep/Onboarding/P1-name.png): expose “Continue” and “Just call me friend” as semantic labels instead of generic Submit. (<30 min)
- I3 — [celebration](ux-sweep/Onboarding/P1-celebration.png): add a back/dismiss route assertion for handoff. (<30 min)

### Today

- L1/F2 — [zero-data](ux-sweep/Today/today-zero-data.png): separate mascot from summary copy. (<30 min)
- P3/S1 — [zero-data](ux-sweep/Today/today-zero-data.png): replace movement review with a useful manual action. (<30 min)
- L2 — [zero-data](ux-sweep/Today/today-zero-data.png): reserve bottom-nav height. (<30 min)
- C2 — [zero-data](ux-sweep/Today/today-zero-data.png): avoid “PKR 0.0” and em-dash movement pills when there is no movement. (<30 min)

### Money

- L2 — [Money](ux-sweep/Money/money-populated.png): clear nav on the goals card. (<30 min)
- C2 — [Money](ux-sweep/Money/money-populated.png): remove duplicated zero amount phrasing. (<30 min)

### Quick Add

- P3 — [expense sheet](ux-sweep/QuickAdd/expense-sheet.png): establish one expense hero and demote income/import. (<30 min)
- C3 — [income](ux-sweep/QuickAdd/income-path.png): prevent “Import statem…” clipping. (<30 min)
- L1 — [validation](ux-sweep/QuickAdd/validation-error.png): keep error copy and amount field from shifting the primary save target. (<30 min)

### Settings

- L2 — [root](ux-sweep/Settings/root.png): clear nav at the end of goals card. (<30 min)
- L3/F1 — [privacy](ux-sweep/Settings/privacy-preferences.png): use a flatter trust treatment. (<30 min)
- S5 — [privacy](ux-sweep/Settings/privacy-preferences.png): complete the balance-hiding walk across all screens. BLOCKED until a deterministic privacy test account exists.

### Insights

- P1 — [quiet week](ux-sweep/Insights/insights-populated.png): label the state as quiet-week and supply populated fixture coverage. BLOCKED by missing seed.

## Consistency report

| Seam | Result | Evidence |
|---|---|---|
| X1 data agreement | BLOCKED | Real account has only PKR 0; no populated Today/Money pair or goal progress pair |
| X2 pattern consistency | FAIL | [Today](ux-sweep/Today/today-zero-data.png), [Money](ux-sweep/Money/money-populated.png), and [Settings](ux-sweep/Settings/root.png) all use different empty/card densities; the nav-clearance bug repeats |
| X3 deep round-trips | BLOCKED | Explains, holding detail, goal editor, and insight detail origins unavailable |
| X4 Quick Add seam | BLOCKED | Origin screenshots exist for [Money](ux-sweep/QuickAdd/money-origin.png), [Insights](ux-sweep/QuickAdd/insights-origin.png), and [Settings](ux-sweep/QuickAdd/settings-origin.png), but interruption/force-kill persistence was not executed |

## Coverage statement

The inventory expands to 88 logical screen/state combinations before the four matrix cells, or 352 required screen×state×theme/text-scale cells. This run produced 19 screenshot-backed observations, all at light/1.0×; 333 cells remain unverified. The 19 include 4 onboarding states, 1 real Today state, 1 Money state, 1 Insights quiet-week state, 3 Quick Add states, 3 Settings states, 3 Quick Add origin captures, and 3 supporting duplicate/previous evidence captures.

BLOCKED items: all seeded Today variants except zero-data; Money empty/offline and all deep Money sub-surfaces; all Goal Editor states; populated/offline Insights and detail; Quick Add offline/success/force-kill and full four-origin completion; Settings language, streak freeze/repair, delete/export, reduce-motion and full balance-visibility walk; all Sprout Explains origins; contextual asks; notification deep links; dark mode and 1.3× text scale across every screen. The immediate unblocker is implementing the requested `seed:ux-states` setup and exposing deterministic theme/text-scale controls for the sweep harness.

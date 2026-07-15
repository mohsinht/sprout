VERDICT: FIXABLE-BEFORE-BETA — the real API-backed zero-data path now reaches Today, but the first real screen still has a visually colliding mascot/briefing layer and an empty “movement” action that does not help a zero-data user.

## Audit conditions

I ran the Flutter web stack at 360×800 with the production flag, a local API, and a local Postgres database. The first attempt exposed a setup mismatch: migrations had been applied to the database named in `apps/api/.env`, while the API was pointed at Docker Postgres; the local database therefore lacked `goal_contributions`. The API also allowed `localhost:8080` but not `127.0.0.1:8080` for CORS. After applying migrations explicitly to Docker Postgres and rerunning on the matching localhost origin, register → onboarding → authenticated briefing returned 200. I also ran the repository’s explicit `SPROUT_ENV=dev` fixture to inspect the populated Today composition; those screenshots are labeled fixture evidence and are not proof of real-data behavior. I did not modify code.

The production-flag first-run screenshots are [U2-onboarding-welcome](ux-audit/U2-onboarding-welcome.png), [U2-onboarding-name](ux-audit/U2-onboarding-name.png), [U2-onboarding-goal](ux-audit/U2-onboarding-goal.png), and [U2-onboarding-today](ux-audit/U2-onboarding-today.png). The populated Today fixture is [U3-U4-today-fixture](ux-audit/U3-U4-today-fixture.png). The attempted zero-data handoff is [U3-U4-today-zero-data](ux-audit/U3-U4-today-zero-data.png).
The production-flag first-run screenshots are [U2-onboarding-welcome](ux-audit/U2-onboarding-welcome.png), [U2-onboarding-name](ux-audit/U2-onboarding-name.png), [U2-onboarding-goal](ux-audit/U2-onboarding-goal.png), and [U2-onboarding-today](ux-audit/U2-onboarding-today.png). The corrected real API-backed Today is [U3-real-api-zero-data](ux-audit/U3-real-api-zero-data.png). The populated Today fixture is [U3-U4-today-fixture](ux-audit/U3-U4-today-fixture.png).

### Rerun correction

The earlier apparent onboarding/Today dead end was not a product navigation failure. It was caused by the backend returning 503 during the first run, plus a CORS origin mismatch. With the local schema fixed and the origin matched, a fresh account completed onboarding and Today loaded from the real API. The remaining findings below are UI/UX findings; the database/API setup issue is reported separately in the handoff note.

## 10 findings that matter most

| Rank | Check | Screenshot | What the universal user experiences | Violation | Fix direction |
|---|---|---|---|---|---|
| 1 | U3/L1 | [U3-real-api-zero-data](ux-audit/U3-real-api-zero-data.png) | On the real zero-data Today, the mascot appears over the “Sprout is still getting to know your money” copy, and the only action says “Review today’s wealth movement” when there is no movement to review. The first-time user sees a visual collision and an empty ritual. | Law 1/L6/L7; S9 | Give zero-data Today its own honest action such as “Add a cash expense”; reserve movement review for users with movement data; fix mascot/text layering before accepting the state.
| 2 | U3/U4 | [U3-U4-today-fixture](ux-audit/U3-U4-today-fixture.png) | On the populated fixture, the eye meets greeting, streak, mascot, total wealth, two movement pills, salary strip, why sentence, one-step button, tiles, and nav. A first-time user cannot confidently tell which single thing to do first. | Law 1; Today acceptance | Reduce above-fold competition: keep wealth + one sentence + one action, move salary/tiles behind depth or make their hierarchy visibly subordinate.
| 3 | U3/C2 | [U3-U4-today-fixture](ux-audit/U3-U4-today-fixture.png) | “PKR 13.7M” is glanceable, but “PKR 38.5K today” and “PKR 14.8K this month” are close pills with unfamiliar triangle cues. A modest-English user must parse color, arrow, and period together. | Law 6; movement rule | Use explicit “Down today” / “Up this month” labels and a plain-language why that states both periods without relying on color or glyphs.
| 4 | L2/L5 | [U3-U4-today-fixture](ux-audit/U3-U4-today-fixture.png) | The saturated green hero action, green movement pill, mint why panel, yellow salary strip, yellow down pill, green up pill, and mascot all compete for emotion. The interface is louder than the constitution’s quiet UI. | Law 2 and Law 5 | Reserve the strongest accent for the action/mascot moment; neutralize supporting strips and movement chips, especially on a down day.
| 5 | C1/C3 | [U3-U4-today-fixture](ux-audit/U3-U4-today-fixture.png) | “Al Meezan cooled after yesterday’s jump” is warm, but “Wise EUR helped” assumes the user knows EUR is a holding and what “helped” means. The exact driver and amount are not stated in the sentence. | Copy tone; every movement has a why | Pair the plain meaning on first contact: “Your EUR cash rose in rupees by PKR X”; keep fund/source detail one tap away.
| 6 | T1 | [U3-U4-today-fixture](ux-audit/U3-U4-today-fixture.png) | The hero number has no visible as-of date or source. The user has to know that tapping the number or holding detail should reveal provenance; this was not reachable in the fixture run. | Trust/provenance acceptance | Put a compact “Updated [date] · sources” affordance next to the hero and verify each holding exposes source, freshness, and FX/NAV date.
| 7 | U2/C4 | [U2-onboarding-name](ux-audit/U2-onboarding-name.png) | The name step is visually simple, but the tested semantic surface exposed a textbox as “A nickname is fine” and a generic “Submit” rather than a clear next action. The warm skip is visible visually but not exposed meaningfully to the accessibility tree. | Asking law 2/4; A4 | Give controls meaningful accessible names (“Continue”, “Just call me friend”) and test Flutter web semantics rather than relying on the canvas overlay.
| 8 | N3 | [U3-U4-today-fixture](ux-audit/U3-U4-today-fixture.png) | The center “+” is prominent and reachable, but the screenshot does not prove it is a sheet, returns to origin, or stays off-tab. The core 3-second cash expense path was not verifiable with production data. | Navigation IA | Add a scripted four-origin Quick Add test: open sheet, log a cash expense, background/return, save, and assert the origin tab and scroll position.
| 9 | A1 | [U3-U4-today-fixture](ux-audit/U3-U4-today-fixture.png) | At 360×800, the floating nav visibly covers the lower “What’s happening” tiles. At 1.3×, the same fixed geometry is high risk for hidden content and tap targets. | 1.3× acceptance; nav IA | Treat the bottom nav as an overlay with reserved safe-area content padding and verify at 1.3× in both themes.
| 10 | C4/T3 | [U3-real-api-zero-data](ux-audit/U3-real-api-zero-data.png) | “No salary timing set · no bills due soon” is a status statement, not a useful answer or next step for a user who skipped setup. The page still asks them to review movement rather than offering the obvious manual path. | Asking/trust rules; Law 7 | Pair the zero-data ask with one-line benefit and a warm skip, then make the primary action manual-first and reversible.

## Per-section pass/fail

| Section | Result | Evidence |
|---|---|---|
| U1–U4 cold first-run | FAIL | [U2 onboarding set](ux-audit/U2-onboarding-welcome.png); [real Today](ux-audit/U3-real-api-zero-data.png) |
| L1–L7 seven laws | FAIL | [Today fixture](ux-audit/U3-U4-today-fixture.png); L3/L4 and triggered bad-day states not reached |
| N1–N5 navigation | FAIL / incomplete | [Today fixture](ux-audit/U3-U4-today-fixture.png); Quick Add and depth not verified |
| C1–C5 copy | FAIL | [Today fixture](ux-audit/U3-U4-today-fixture.png); jargon and movement ambiguity observed |
| T1–T4 trust | INCOMPLETE | No authenticated real holding detail or Settings trust walk was reachable |
| Section 6 states | INCOMPLETE | Real zero-data is verified; offline/stale/error/down/failed-sync variants were not triggered |
| A1–A5 accessibility/device | FAIL / incomplete | [Today fixture](ux-audit/U3-U4-today-fixture.png); 1.3×, contrast pairs, touch geometry, and screen reader pass not completed |
| G1–G4 gut/coherence | INCOMPLETE | One fixture landing and onboarding path observed; five-state matrix not reachable |

## Spec-vs-usability conflicts

- The “celebration handoff” is visually pleasant, but it adds a separate screen after the skip path and creates a hard dependency on one button before first value. The spec calls for celebration, yet the usable product needs a guaranteed route transition even if the button or web semantics fail.
- Today follows the required wealth-health content model, but the salary strip, movement pills, why panel, one-step CTA, tiles, streak, and nav all appear in one glance. Spec completeness is producing a dashboard-like scan burden that conflicts with Law 1 and Law 6.
- The fixture uses abbreviated amounts such as “PKR 13.7M” and “PKR 38.5K”. This is compact, but it conflicts with Pakistan-local number comprehension and the copy rule that movement must be plain and self-explanatory.

## Craft punch-list

| Screen | Small fix | Check |
|---|---|---|
| Onboarding | Replace generic semantic “Submit” with the visible action label; expose warm skip labels. | A4/C4 |
| Onboarding | Add a route test for “See my Today” after skip-all and force-kill return. | U2/N2/N4 |
| Today | Reserve bottom-nav height in scroll content; verify tile bottom edge is never covered. | A1 |
| Today | Make today/MTD movement labels explicit and visually distinct without color alone. | C2/L6 |
| Today | Add source/date affordance beside total wealth. | T1 |
| Today | Check down-state accent count; neutralize the yellow warning strip if it is not the one action. | L2/L5 |
| Shell | Confirm the center plus has a 44px semantic target and a meaningful label on web/Android. | N3/A3/A4 |
| Theme | Render the same screens in dark mode and verify every tint has a dark variant. | A2/G3 |

## HUMAN HANDOFF

This audit could not honestly verify authenticated real-stack holdings, bad-day, failed-sync, stale-price, offline-cache/no-cache, briefing-failed, insufficient-score, Quick Add persistence, goal editor, Sprout Explains, Settings controls, dark mode, 1.3× text scale, contrast pairs, touch-target measurement, or screen-reader semantics end-to-end. The local API has no external NAV/FX sources, so real non-PKR holdings remain outside this run. The initial 503 was a local migration-target mismatch, not an application endpoint defect after correction.

### Moderated test script for 5 users

1. Give the participant a fresh 360×800 phone and say: “This is your first finance app. Think aloud. You may skip anything.” Observe first-run comprehension, skip comfort, and time-to-first-action.
2. After Today settles, hide the screen for five seconds. Ask: “What is this screen for? What is the most important thing? What would you tap first?”
3. Ask the three questions without allowing taps: “What is your total wealth? How did it move? Why did it move? What is your one next step?” Mark exact-string recall and inference errors.
4. Seed a wealth-down day. Say only: “This is today’s update.” Observe the first emotional word, facial reaction, whether they expect danger, and whether they can name one calm next step.
5. Run a Quick Add race: “Log a PKR 500 cash expense for chai.” Start the timer on the first tap. Interrupt with a phone background at 1.5 seconds, return after 30 seconds, then force-kill and reopen. Record taps, time, state preservation, origin-tab return, and duplicate entries.
6. Ask: “After opening this, do you feel calmer or more anxious? What made you feel that way?” Do not prompt toward either answer.

### Measure

- Task success and recovery after interruption.
- Time-to-first-action and full daily-loop time.
- Tap count for Quick Add.
- Comprehension errors on wealth, movement, why, source, freshness, and next step.
- Emotional words used: calm, okay, safe, confused, worried, behind, pressured, curious.
- Skip rate, abandonment point, and whether users voluntarily open depth.

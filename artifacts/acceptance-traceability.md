# Acceptance traceability

Generated from every bullet criterion in `spec/screen_acceptance_criteria.md`. Status is evidence state, not a release verdict. `AUTOMATED` means a committed assertion exists; it does not claim an independent run passed. Known missing product/device capabilities are explicitly failing or handed off.

| Spec line | Criterion | Stable test ID | Committed test/evidence | Status |
|---:|---|---|---|---|
| 18 | A new user can complete onboarding without connecting any external account. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 19 | Today is populated after onboarding. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 20 | The daily action can be completed in under 20 seconds. | HUMAN-SAC-20 | Independent physical/deployed verification | HUMAN_HANDOFF |
| 21 | Manual entry works offline. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 22 | Money data shows source, freshness, or confidence. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 23 | Every important insight has an explanation. | INS-01..04 | apps/api/src/harness/insights.integration.test.ts | FAILING_SPEC_CONFLICT |
| 24 | Settings exposes privacy and data controls. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 25 | Notifications have timing, copy, privacy defaults, and deep-link behavior. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 26 | Streak repair/freeze is modeled and visible when relevant. | P1..P7-SAC-26 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 27 | No v0 feature moves funds, stores value, initiates payments, or enables merchant acceptance. | ADV-06..07 / OPS-03 | apps/api/src/harness/adversarial.integration.test.ts; apps/api/src/harness/ops.integration.test.ts | AUTOMATED_PARTIAL |
| 28 | Real captured transactions include parser version and dedupe fingerprint. | ADV-01..04 / OPS-01 | apps/api/src/harness/adversarial.integration.test.ts; apps/api/src/harness/ops.integration.test.ts | AUTOMATED |
| 29 | The app remains smooth on low-end Android. | HUMAN-SAC-29 | Independent physical/deployed verification | HUMAN_HANDOFF |
| 30 | **Total wealth is always the Today hero.** | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 31 | **Opening the app never changes the health score.** | FIX-01..09 | apps/api/src/harness/golden.test.ts | AUTOMATED |
| 32 | **Nav renders Today · Money · [＋] · Insights · Settings**, and no screen | INS-01..04 | apps/api/src/harness/insights.integration.test.ts | FAILING_SPEC_CONFLICT |
| 39 | Opens as the default landing screen. | P1..P7-SAC-39 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 40 | **The 13-part locked layout is present in the exact order specified** (greeting+streak → mascot → wealth → movement chips → one-line read → action button → what's happening tiles → holdings rows → depth door → why it moved → goals → learn later → provenance footer). No extra elements, no reordering. | FIX-01..09 | apps/api/src/harness/golden.test.ts | AUTOMATED |
| 41 | **Above the fold (1–6) delivers the 20-second glance; below the fold is depth.** | P1..P7-SAC-41 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 42 | Total wealth is the Today hero and largest numeric element; mascot is the living emotional narrator, prominent and mood-driven without overpowering the wealth number. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 43 | **Shows total wealth with today's change and MTD change** as the hero number. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 44 | **Every movement has a "why"** — no change shown without its driver. | FIX-01..09 | apps/api/src/harness/golden.test.ts | AUTOMATED |
| 45 | **"What happened" events reference prior days** to form a story, not a snapshot. | ADV-01..04 / OPS-01 | apps/api/src/harness/adversarial.integration.test.ts; apps/api/src/harness/ops.integration.test.ts | AUTOMATED |
| 46 | **One goal-relative next-step** is shown (not an empty ritual). | LED-01..02 / P7 | apps/api/src/harness/money-invariants.integration.test.ts; scripts/persona-local.mjs | AUTOMATED_PARTIAL |
| 47 | **Breakdown, trend, and provenance are reachable on tap** (depth, not forced). | ADV-01..04 / OPS-01 | apps/api/src/harness/adversarial.integration.test.ts; apps/api/src/harness/ops.integration.test.ts | AUTOMATED |
| 51 | **Wealth figure animates count-up on first reveal** (unless reduce-motion is enabled). | P1..P7-SAC-51 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 52 | **"What's happening" tiles stagger in** on load (~50ms apart, rising/fading). | P1..P7-SAC-52 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 53 | **Goal progress bars/rings fill** left-to-right on first reveal. | LED-01..02 / P7 | apps/api/src/harness/money-invariants.integration.test.ts; scripts/persona-local.mjs | AUTOMATED_PARTIAL |
| 54 | **Mascot is mood-matched on load.** On device profiles that pass the motion | P1..P7-SAC-54 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 57 | **Haptic feedback on every tile tap, chip tap, and nav tap.** | HUMAN-SAC-57 | Independent physical/deployed verification | HUMAN_HANDOFF |
| 58 | **Action completion celebrates:** haptic + chime + confetti → calm "done" state. | HUMAN-SAC-58 | Independent physical/deployed verification | HUMAN_HANDOFF |
| 59 | **Entrance motion holds 60fps** on the target low-end Android device; any effect that janks is simplified or cut. | HUMAN-SAC-59 | Independent physical/deployed verification | HUMAN_HANDOFF |
| 60 | **Reduce-motion replaces all entrance motion** with calm static reveals — no information hidden, no layout broken. | P1..P7-SAC-60 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 64 | **Wealth-down day stays calm** — no alarm, no shame, no red-faced mascot. | FIX-01..09 | apps/api/src/harness/golden.test.ts | AUTOMATED |
| 65 | **Stale price/FX is labelled** with the as-of date, never silently trusted. | ADV-01..04 / OPS-01 | apps/api/src/harness/adversarial.integration.test.ts; apps/api/src/harness/ops.integration.test.ts | AUTOMATED |
| 66 | **Opening the app never changes health.** | P1..P7-SAC-66 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 67 | Empty/first-run state works with zero connections. | P1..P7-SAC-67 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 68 | Market tile appears only when personally relevant; otherwise a more relevant context tile appears. | P1..P7-SAC-68 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 69 | Completing the action triggers celebration, XP, streak feedback, and sign-off. | P1..P7-SAC-69 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 70 | Every tile, score factor, event, and finding opens Sprout Explains. | FIX-01..09 | apps/api/src/harness/golden.test.ts | AUTOMATED |
| 71 | **Thin-wealth Today passes:** with one manual PKR cash holding and a goal, | LED-01..02 / P7 | apps/api/src/harness/money-invariants.integration.test.ts; scripts/persona-local.mjs | AUTOMATED_PARTIAL |
| 75 | **Valuation fetch failure passes:** Today still renders a persisted daily | ADV-01..04 / OPS-01 | apps/api/src/harness/adversarial.integration.test.ts; apps/api/src/harness/ops.integration.test.ts | AUTOMATED |
| 81 | **Tiles are equal-height AND content-filled** — no large dead gap between icon row and title. Reduce height or top-align content. | P1..P7-SAC-81 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 82 | **Zero truncation:** tile copy is shortened at the source (1–3 word title, ≤5 word description). "Al Meezan, NAV correcti…" style clipping fails. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 83 | **No readable body text below ~14px;** the interpretation paragraph at comfortable body size. | P1..P7-SAC-83 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 84 | **1.3× text scale survives** without clipping or broken layout. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 85 | **Chunky depth present** on tiles and buttons — solid bottom edge, committed tints, not washed-out pastels. | P1..P7-SAC-85 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 89 | **Money tab is present and rendering** — a build missing the Money tab fails. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 90 | Shows holdings with per-holding value, source, freshness, and provenance. | ADV-01..04 / OPS-01 | apps/api/src/harness/adversarial.integration.test.ts; apps/api/src/harness/ops.integration.test.ts | AUTOMATED |
| 91 | **6-day wealth trend chart is available as a depth element.** | P1..P7-SAC-91 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 92 | Shows accounts with balances and freshness. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 93 | Shows safe-to-spend or budget summary. | P1..P7-SAC-93 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 94 | Shows goals with progress, remaining-to-target, and next step. | LED-01..02 / P7 | apps/api/src/harness/money-invariants.integration.test.ts; scripts/persona-local.mjs | AUTOMATED_PARTIAL |
| 95 | **Tapping a goal opens its editor** (add/contribute/complete/delete reachable). | LED-01..02 / P7 | apps/api/src/harness/money-invariants.integration.test.ts; scripts/persona-local.mjs | AUTOMATED_PARTIAL |
| 96 | Shows transactions with source and confidence/review state. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 97 | Uncertain transactions are confirmable in one tap. | P1..P7-SAC-97 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 98 | Offline cached data is visible. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 99 | Stale balances and **stale prices/FX are labelled.** | ADV-01..04 / OPS-01 | apps/api/src/harness/adversarial.integration.test.ts; apps/api/src/harness/ops.integration.test.ts | AUTOMATED |
| 100 | The screen remains quiet and un-gamified. | P1..P7-SAC-100 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 104 | Insights tab is present and rendering. | INS-01..04 | apps/api/src/harness/insights.integration.test.ts | FAILING_SPEC_CONFLICT |
| 105 | The screen is finite: no infinite feed, no generic headline padding. | INS-01..04 | apps/api/src/harness/insights.integration.test.ts | FAILING_SPEC_CONFLICT |
| 106 | Every item ties a world/market fact to the user's holdings, goals, cash, or | INS-01..04 | apps/api/src/harness/insights.integration.test.ts | FAILING_SPEC_CONFLICT |
| 108 | Every item carries date/freshness and provenance. | ADV-01..04 / OPS-01 | apps/api/src/harness/adversarial.integration.test.ts; apps/api/src/harness/ops.integration.test.ts | AUTOMATED |
| 109 | Every card taps to a detail drawer with personal meaning, plain-language | P1..P7-SAC-109 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 111 | Quiet-week state is calm and does not fill with generic market noise. | INS-01..04 | apps/api/src/harness/insights.integration.test.ts | FAILING_SPEC_CONFLICT |
| 112 | Each item can expose its fact/event id, deterministic template version, | P1..P7-SAC-112 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 114 | Thin-data state shows only relevant items. | P1..P7-SAC-114 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 115 | Offline cached state is labelled. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 116 | Copy avoids FOMO, guaranteed returns, investment pressure, shame, and panic. | P1..P7-SAC-116 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 117 | Light and dark mode remain legible at 1.3x text scale. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 118 | AI budget/provider failure is visually identical to a successful | AI-01..05 | apps/api/src/harness/ai-budget.integration.test.ts | FAILING_SPEC_CONFLICT |
| 123 | Nav renders exactly: Today · Money · [＋] · Insights · Settings. | INS-01..04 | apps/api/src/harness/insights.integration.test.ts | FAILING_SPEC_CONFLICT |
| 124 | Center `+` opens Quick Add and is not a destination tab. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 125 | Two tabs sit left of `+`, two tabs sit right of `+`. | P1..P7-SAC-125 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 126 | Active tab is visually distinct; inactive tabs are muted but readable. | P1..P7-SAC-126 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 127 | Content on Today, Money, Insights, and Settings clears the floating nav and | INS-01..04 | apps/api/src/harness/insights.integration.test.ts | FAILING_SPEC_CONFLICT |
| 132 | A user can **add, edit, contribute to, complete, delete, and reorder** goals from Settings and from tapping a goal. | LED-01..02 / P7 | apps/api/src/harness/money-invariants.integration.test.ts; scripts/persona-local.mjs | AUTOMATED_PARTIAL |
| 133 | **One shared goal-editor** is reached from both entry points (Settings and goal tap). | LED-01..02 / P7 | apps/api/src/harness/money-invariants.integration.test.ts; scripts/persona-local.mjs | AUTOMATED_PARTIAL |
| 134 | **Goal changes affect the next briefing's recommendation** — the connection is real, not cosmetic. | LED-01..02 / P7 | apps/api/src/harness/money-invariants.integration.test.ts; scripts/persona-local.mjs | AUTOMATED_PARTIAL |
| 135 | **Delete/complete copy clarifies money is unaffected** — goals are tracking, not accounts. | LED-01..02 / P7 | apps/api/src/harness/money-invariants.integration.test.ts; scripts/persona-local.mjs | AUTOMATED_PARTIAL |
| 136 | **Empty state prompts warmly** to add a goal (a goal makes Today's "one step" meaningful). | LED-01..02 / P7 | apps/api/src/harness/money-invariants.integration.test.ts; scripts/persona-local.mjs | AUTOMATED_PARTIAL |
| 137 | **A primary/closest goal flag** determines which goal Today references. | LED-01..02 / P7 | apps/api/src/harness/money-invariants.integration.test.ts; scripts/persona-local.mjs | AUTOMATED_PARTIAL |
| 138 | All goal flows work offline; changes persist locally. | LED-01..02 / P7 | apps/api/src/harness/money-invariants.integration.test.ts; scripts/persona-local.mjs | AUTOMATED_PARTIAL |
| 139 | **Goals are never write-once** — everything is editable after creation. | LED-01..02 / P7 | apps/api/src/harness/money-invariants.integration.test.ts; scripts/persona-local.mjs | AUTOMATED_PARTIAL |
| 143 | **Dark-mode tiles are legible** — tints have dark variants, not light tints dropped onto black. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 144 | **Decorative/watermark layers never reduce text contrast** — opacity is capped so text stays fully legible in both themes. | P1..P7-SAC-144 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 145 | **Verified at 1.3× text scale** in both light and dark. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 149 | Opens from center `+` without changing tabs. | P1..P7-SAC-149 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 150 | Common expense can be logged without typing. | P1..P7-SAC-150 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 151 | Income can be logged through salary, freelance, gift, or other. | P1..P7-SAC-151 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 152 | Pakistani categories are present. | P1..P7-SAC-152 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 153 | Offline save works. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 154 | Success feedback is immediate. | P1..P7-SAC-154 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 155 | Validation errors are clear and non-punitive. | P1..P7-SAC-155 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 156 | Missing amount/category/income source states use approved copy from the tone guide. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 157 | Sheet closes back to the originating screen. | P1..P7-SAC-157 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 161 | Shows profile, income timing, and income type. | P1..P7-SAC-161 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 162 | **Goals editor includes full CRUD** (add/edit/contribute/complete/delete/reorder), not just viewing. | LED-01..02 / P7 | apps/api/src/harness/money-invariants.integration.test.ts; scripts/persona-local.mjs | AUTOMATED_PARTIAL |
| 163 | Data sources show status, confidence, freshness, and controls. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 164 | Connect, disconnect, and delete data controls are reachable. | P1..P7-SAC-164 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 165 | Privacy copy includes no stored bank passwords, user-controlled sources, statement deletion, and confirmation for uncertain transactions. | ADV-06..07 / OPS-03 | apps/api/src/harness/adversarial.integration.test.ts; apps/api/src/harness/ops.integration.test.ts | AUTOMATED_PARTIAL |
| 166 | Notification settings are editable. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 167 | Reduce-motion and balance visibility settings are present. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 168 | The screen is sober and not gamified. | P1..P7-SAC-168 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 172 | Introduces Sprout's daily check-in promise. | P1..P7-SAC-172 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 173 | Captures name or nickname, with skip/default. | P1..P7-SAC-173 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 174 | Offers a playful nickname generator beside the plain text option. | P1..P7-SAC-174 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 175 | Captures one goal through chips, or lets Sprout help decide later. | LED-01..02 / P7 | apps/api/src/harness/money-invariants.integration.test.ts; scripts/persona-local.mjs | AUTOMATED_PARTIAL |
| 176 | Allows completion with no connections. | P1..P7-SAC-176 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 177 | Allows completion while offline using a local first briefing. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 178 | Shows a retry path if first-briefing generation fails. | P1..P7-SAC-178 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 179 | Does not ask salary date, income type, multiple goals, or source connections before first value. | LED-01..02 / P7 | apps/api/src/harness/money-invariants.integration.test.ts; scripts/persona-local.mjs | AUTOMATED_PARTIAL |
| 180 | Optional connections are framed as upgrades after core value is visible, not gates. | P1..P7-SAC-180 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 181 | Ends on a populated Today screen. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 182 | Does not request permissions before showing core value. | P1..P7-SAC-182 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 186 | No screen or sheet asks more than one question. | P1..P7-SAC-186 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 187 | Free text appears only when choices cannot express the answer. | P1..P7-SAC-187 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 188 | Every non-required ask has a warm skip. | P1..P7-SAC-188 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 189 | Every ask states the user benefit in one line. | P1..P7-SAC-189 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 190 | Deferred fields are captured in context, one tap, and remembered. | P1..P7-SAC-190 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 191 | No surface nags users to complete a profile. | P1..P7-SAC-191 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 192 | Privacy and reversibility are visible at the point of asking. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 193 | Source connections are never requested before core value is visible. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 197 | Opens from Today and Money insight surfaces. | INS-01..04 | apps/api/src/harness/insights.integration.test.ts | FAILING_SPEC_CONFLICT |
| 198 | Explanation matches the tapped element. | P1..P7-SAC-198 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 199 | Explains what happened and why it matters. | P1..P7-SAC-199 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 200 | States uncertainty when applicable. | P1..P7-SAC-200 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 201 | Offers a next step when sensible. | P1..P7-SAC-201 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 202 | Returns to the previous screen without losing context. | P1..P7-SAC-202 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 206 | Valid briefing is generated from manual-only mock data. | P1..P7-SAC-206 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 207 | Job failure falls back to local data. | P1..P7-SAC-207 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 208 | Severity determines ordering, mascot mood, and visual treatment. | P1..P7-SAC-208 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 209 | Every finding has severity, confidence, category, and why detail. | P1..P7-SAC-209 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 210 | Recommended action is singular, small, concrete, **goal-relative**, and completable. | FIX-01..09 | apps/api/src/harness/golden.test.ts | AUTOMATED |
| 211 | Score and action follow the deterministic scoring model. | FIX-01..09 | apps/api/src/harness/golden.test.ts | AUTOMATED |
| 212 | Parser drift and low-confidence capture affect findings transparently. | ADV-01..04 / OPS-01 | apps/api/src/harness/adversarial.integration.test.ts; apps/api/src/harness/ops.integration.test.ts | AUTOMATED |
| 213 | **WealthSnapshot includes total, change vs yesterday, change MTD, main reason, and interpretation.** | ADV-01..04 / OPS-01 | apps/api/src/harness/adversarial.integration.test.ts; apps/api/src/harness/ops.integration.test.ts | AUTOMATED |
| 214 | **Every WealthEvent has a plain-language "why."** | P1..P7-SAC-214 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 215 | **Every holding valuation exposes dated price/FX provenance.** | ADV-01..04 / OPS-01 | apps/api/src/harness/adversarial.integration.test.ts; apps/api/src/harness/ops.integration.test.ts | AUTOMATED |
| 216 | **Stale prices/FX are labelled, never silently trusted.** | ADV-01..04 / OPS-01 | apps/api/src/harness/adversarial.integration.test.ts; apps/api/src/harness/ops.integration.test.ts | AUTOMATED |
| 217 | **No "check-in" action is ever selected.** | P1..P7-SAC-217 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 218 | **Daily WealthSnapshot is durable and idempotent per user/PKT date**, not | ADV-01..04 / OPS-01 | apps/api/src/harness/adversarial.integration.test.ts; apps/api/src/harness/ops.integration.test.ts | AUTOMATED |
| 220 | **Market-day logic uses versioned Pakistan calendar data** so weekends and | P1..P7-SAC-220 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 222 | **Al Meezan observations are cross-validated with MUFAP**; unresolved | ADV-01..04 / OPS-01 | apps/api/src/harness/adversarial.integration.test.ts; apps/api/src/harness/ops.integration.test.ts | AUTOMATED |
| 227 | Uses existing tokens and components. | P1..P7-SAC-227 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 228 | No new arbitrary colors, spacing, radius, or type scales. | P1..P7-SAC-228 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 229 | Text fits at mobile sizes and 1.3x text scale. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 230 | Reduce-motion is respected. | P1..P7-SAC-230 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 231 | No nested cards. | P1..P7-SAC-231 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 232 | Icons support recognition and have labels/tooltips where required. | P1..P7-SAC-232 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 236 | Daily check-in notification follows the configured or inferred user window. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 237 | Notification copy hides balances and exact amounts by default. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 238 | Each notification deep-links to the relevant screen. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 239 | User can disable daily, bill, salary/income, weekly, and streak-protection notifications separately. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 240 | Notifications never shame missed days or financial hardship. | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 244 | Refresh tokens are encrypted at rest. | HUMAN-SAC-244 | Independent physical/deployed verification | HUMAN_HANDOFF |
| 245 | Device binding and biometric/passkey unlock are supported where available. | HUMAN-SAC-245 | Independent physical/deployed verification | HUMAN_HANDOFF |
| 246 | Parser/import jobs are idempotent and retry-safe. | ADV-01..04 / OPS-01 | apps/api/src/harness/adversarial.integration.test.ts; apps/api/src/harness/ops.integration.test.ts | AUTOMATED |
| 247 | Statement files are discarded by default after parsing. | P1..P7-SAC-247 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 248 | Email capture uses OAuth and narrow scopes. | ADV-06..07 / OPS-03 | apps/api/src/harness/adversarial.integration.test.ts; apps/api/src/harness/ops.integration.test.ts | AUTOMATED_PARTIAL |
| 249 | Android SMS capture is optional, Android-only, and policy-gated. | P1..P7-SAC-249 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 250 | iOS works without SMS capture. | P1..P7-SAC-250 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |
| 251 | No screen scraping or stored bank passwords. | ADV-06..07 / OPS-03 | apps/api/src/harness/adversarial.integration.test.ts; apps/api/src/harness/ops.integration.test.ts | AUTOMATED_PARTIAL |
| 252 | NAV/FX fetchers have versions, golden source samples, drift monitoring, and | P1..P7 | scripts/persona-local.mjs; artifacts/persona-evidence/ | FAILING_DEVICE_EVIDENCE_MISSING |
| 254 | The valuation pipeline completes at least 14 consecutive headless daily runs | ADV-01..04 / OPS-01 | apps/api/src/harness/adversarial.integration.test.ts; apps/api/src/harness/ops.integration.test.ts | AUTOMATED |
| 257 | Every acceptance bullet has a stable test ID in the release traceability | P1..P7-SAC-257 | scripts/persona-local.mjs | FAILING_DEVICE_EVIDENCE_MISSING |

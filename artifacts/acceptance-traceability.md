# Acceptance traceability

Generated from `spec/screen_acceptance_criteria.md`. PASS means the named committed test was run locally in the tranche-2 verification. Broad visual/copy criteria without criterion-specific evidence remain UNVERIFIED; they are not silently promoted to passes.

| Spec line | Criterion | Stable test ID | Committed test/evidence | Last run |
|---:|---|---|---|---|
| 18 | A new user can complete onboarding without connecting any external account. | AUDIT-A3-B8 | apps/mobile/test/audit_a3_router_guard_test.dart | PASS |
| 19 | Today is populated after onboarding. | AUDIT-A3-B8 | apps/mobile/test/audit_a3_router_guard_test.dart | PASS |
| 20 | The daily action can be completed in under 20 seconds. | UNVERIFIED-SAC-20 | No committed criterion-specific test located | UNVERIFIED |
| 21 | Manual entry works offline. | AUDIT-C1-OFFLINE | apps/mobile/test/offline_pending_sync_test.dart | PASS |
| 22 | Money data shows source, freshness, or confidence. | UNVERIFIED-SAC-22 | No committed criterion-specific test located | UNVERIFIED |
| 23 | Every important insight has an explanation. | UNVERIFIED-SAC-23 | No committed criterion-specific test located | UNVERIFIED |
| 24 | Settings exposes privacy and data controls. | UNVERIFIED-SAC-24 | No committed criterion-specific test located | UNVERIFIED |
| 25 | Notifications have timing, copy, privacy defaults, and deep-link behavior. | UNVERIFIED-SAC-25 | No committed criterion-specific test located | UNVERIFIED |
| 26 | Streak repair/freeze is modeled and visible when relevant. | UNVERIFIED-SAC-26 | No committed criterion-specific test located | UNVERIFIED |
| 27 | No v0 feature moves funds, stores value, initiates payments, or enables merchant acceptance. | AUDIT-B6 | scripts/e2e-local.mjs | PASS |
| 28 | Real captured transactions include parser version and dedupe fingerprint. | UNVERIFIED-SAC-28 | No committed criterion-specific test located | UNVERIFIED |
| 29 | The app remains smooth on low-end Android. | MANUAL-SAC-29 | Physical/deployed-device handoff | HUMAN_HANDOFF |
| 30 | **Total wealth is always the Today hero.** | UNVERIFIED-SAC-30 | No committed criterion-specific test located | UNVERIFIED |
| 31 | **Opening the app never changes the health score.** | AUDIT-B2 | apps/api/src/lib/scoring.test.ts | PASS |
| 32 | **Nav renders Today · Money · [＋] · Insights · Settings**, and no screen | UNVERIFIED-SAC-32 | No committed criterion-specific test located | UNVERIFIED |
| 39 | Opens as the default landing screen. | UNVERIFIED-SAC-39 | No committed criterion-specific test located | UNVERIFIED |
| 40 | **The 13-part locked layout is present in the exact order specified** (greeting+streak → mascot → wealth → movement chips → one-line read → action button → what's happening tiles → holdings rows → depth door → why it moved → goals → learn later → provenance footer). No extra elements, no reordering. | UNVERIFIED-SAC-40 | No committed criterion-specific test located | UNVERIFIED |
| 41 | **Above the fold (1–6) delivers the 20-second glance; below the fold is depth.** | UNVERIFIED-SAC-41 | No committed criterion-specific test located | UNVERIFIED |
| 42 | Total wealth is the Today hero and largest numeric element; mascot is the living emotional narrator, prominent and mood-driven without overpowering the wealth number. | UNVERIFIED-SAC-42 | No committed criterion-specific test located | UNVERIFIED |
| 43 | **Shows total wealth with today's change and MTD change** as the hero number. | AUDIT-B4 | scripts/e2e-local.mjs | PASS |
| 44 | **Every movement has a "why"** — no change shown without its driver. | AUDIT-B4 | apps/api/src/audit.integration.test.ts | PASS |
| 45 | **"What happened" events reference prior days** to form a story, not a snapshot. | UNVERIFIED-SAC-45 | No committed criterion-specific test located | UNVERIFIED |
| 46 | **One goal-relative next-step** is shown (not an empty ritual). | UNVERIFIED-SAC-46 | No committed criterion-specific test located | UNVERIFIED |
| 47 | **Breakdown, trend, and provenance are reachable on tap** (depth, not forced). | UNVERIFIED-SAC-47 | No committed criterion-specific test located | UNVERIFIED |
| 51 | **Wealth figure animates count-up on first reveal** (unless reduce-motion is enabled). | UNVERIFIED-SAC-51 | No committed criterion-specific test located | UNVERIFIED |
| 52 | **"What's happening" tiles stagger in** on load (~50ms apart, rising/fading). | UNVERIFIED-SAC-52 | No committed criterion-specific test located | UNVERIFIED |
| 53 | **Goal progress bars/rings fill** left-to-right on first reveal. | UNVERIFIED-SAC-53 | No committed criterion-specific test located | UNVERIFIED |
| 54 | **Mascot is mood-matched on load.** On device profiles that pass the motion | MANUAL-SAC-54 | Physical/deployed-device handoff | HUMAN_HANDOFF |
| 57 | **Haptic feedback on every tile tap, chip tap, and nav tap.** | MANUAL-SAC-57 | Physical/deployed-device handoff | HUMAN_HANDOFF |
| 58 | **Action completion celebrates:** haptic + chime + confetti → calm "done" state. | MANUAL-SAC-58 | Physical/deployed-device handoff | HUMAN_HANDOFF |
| 59 | **Entrance motion holds 60fps** on the target low-end Android device; any effect that janks is simplified or cut. | MANUAL-SAC-59 | Physical/deployed-device handoff | HUMAN_HANDOFF |
| 60 | **Reduce-motion replaces all entrance motion** with calm static reveals — no information hidden, no layout broken. | UNVERIFIED-SAC-60 | No committed criterion-specific test located | UNVERIFIED |
| 64 | **Wealth-down day stays calm** — no alarm, no shame, no red-faced mascot. | AUDIT-B7 | apps/api/src/lib/briefing-validation.test.ts | PASS |
| 65 | **Stale price/FX is labelled** with the as-of date, never silently trusted. | AUDIT-A6 | apps/api/src/audit.integration.test.ts | PASS |
| 66 | **Opening the app never changes health.** | AUDIT-B2 | apps/api/src/lib/scoring.test.ts | PASS |
| 67 | Empty/first-run state works with zero connections. | AUDIT-A3-B8 | apps/mobile/test/audit_a3_router_guard_test.dart | PASS |
| 68 | Market tile appears only when personally relevant; otherwise a more relevant context tile appears. | UNVERIFIED-SAC-68 | No committed criterion-specific test located | UNVERIFIED |
| 69 | Completing the action triggers celebration, XP, streak feedback, and sign-off. | UNVERIFIED-SAC-69 | No committed criterion-specific test located | UNVERIFIED |
| 70 | Every tile, score factor, event, and finding opens Sprout Explains. | UNVERIFIED-SAC-70 | No committed criterion-specific test located | UNVERIFIED |
| 71 | **Thin-wealth Today passes:** with one manual PKR cash holding and a goal, | UNVERIFIED-SAC-71 | No committed criterion-specific test located | UNVERIFIED |
| 75 | **Valuation fetch failure passes:** Today still renders a persisted daily | UNVERIFIED-SAC-75 | No committed criterion-specific test located | UNVERIFIED |
| 81 | **Tiles are equal-height AND content-filled** — no large dead gap between icon row and title. Reduce height or top-align content. | UNVERIFIED-SAC-81 | No committed criterion-specific test located | UNVERIFIED |
| 82 | **Zero truncation:** tile copy is shortened at the source (1–3 word title, ≤5 word description). "Al Meezan, NAV correcti…" style clipping fails. | UNVERIFIED-SAC-82 | No committed criterion-specific test located | UNVERIFIED |
| 83 | **No readable body text below ~14px;** the interpretation paragraph at comfortable body size. | UNVERIFIED-SAC-83 | No committed criterion-specific test located | UNVERIFIED |
| 84 | **1.3× text scale survives** without clipping or broken layout. | MANUAL-SAC-84 | Physical/deployed-device handoff | HUMAN_HANDOFF |
| 85 | **Chunky depth present** on tiles and buttons — solid bottom edge, committed tints, not washed-out pastels. | UNVERIFIED-SAC-85 | No committed criterion-specific test located | UNVERIFIED |
| 89 | **Money tab is present and rendering** — a build missing the Money tab fails. | UNVERIFIED-SAC-89 | No committed criterion-specific test located | UNVERIFIED |
| 90 | Shows holdings with per-holding value, source, freshness, and provenance. | UNVERIFIED-SAC-90 | No committed criterion-specific test located | UNVERIFIED |
| 91 | **6-day wealth trend chart is available as a depth element.** | UNVERIFIED-SAC-91 | No committed criterion-specific test located | UNVERIFIED |
| 92 | Shows accounts with balances and freshness. | UNVERIFIED-SAC-92 | No committed criterion-specific test located | UNVERIFIED |
| 93 | Shows safe-to-spend or budget summary. | UNVERIFIED-SAC-93 | No committed criterion-specific test located | UNVERIFIED |
| 94 | Shows goals with progress, remaining-to-target, and next step. | UNVERIFIED-SAC-94 | No committed criterion-specific test located | UNVERIFIED |
| 95 | **Tapping a goal opens its editor** (add/contribute/complete/delete reachable). | UNVERIFIED-SAC-95 | No committed criterion-specific test located | UNVERIFIED |
| 96 | Shows transactions with source and confidence/review state. | UNVERIFIED-SAC-96 | No committed criterion-specific test located | UNVERIFIED |
| 97 | Uncertain transactions are confirmable in one tap. | UNVERIFIED-SAC-97 | No committed criterion-specific test located | UNVERIFIED |
| 98 | Offline cached data is visible. | UNVERIFIED-SAC-98 | No committed criterion-specific test located | UNVERIFIED |
| 99 | Stale balances and **stale prices/FX are labelled.** | UNVERIFIED-SAC-99 | No committed criterion-specific test located | UNVERIFIED |
| 100 | The screen remains quiet and un-gamified. | UNVERIFIED-SAC-100 | No committed criterion-specific test located | UNVERIFIED |
| 104 | Insights tab is present and rendering. | UNVERIFIED-SAC-104 | No committed criterion-specific test located | UNVERIFIED |
| 105 | The screen is finite: no infinite feed, no generic headline padding. | UNVERIFIED-SAC-105 | No committed criterion-specific test located | UNVERIFIED |
| 106 | Every item ties a world/market fact to the user's holdings, goals, cash, or | UNVERIFIED-SAC-106 | No committed criterion-specific test located | UNVERIFIED |
| 108 | Every item carries date/freshness and provenance. | UNVERIFIED-SAC-108 | No committed criterion-specific test located | UNVERIFIED |
| 109 | Every card taps to a detail drawer with personal meaning, plain-language | UNVERIFIED-SAC-109 | No committed criterion-specific test located | UNVERIFIED |
| 111 | Quiet-week state is calm and does not fill with generic market noise. | UNVERIFIED-SAC-111 | No committed criterion-specific test located | UNVERIFIED |
| 112 | Thin-data state shows only relevant items. | UNVERIFIED-SAC-112 | No committed criterion-specific test located | UNVERIFIED |
| 113 | Offline cached state is labelled. | UNVERIFIED-SAC-113 | No committed criterion-specific test located | UNVERIFIED |
| 114 | Copy avoids FOMO, guaranteed returns, investment pressure, shame, and panic. | UNVERIFIED-SAC-114 | No committed criterion-specific test located | UNVERIFIED |
| 115 | Light and dark mode remain legible at 1.3x text scale. | MANUAL-SAC-115 | Physical/deployed-device handoff | HUMAN_HANDOFF |
| 119 | Nav renders exactly: Today · Money · [＋] · Insights · Settings. | AUDIT-B1 | apps/mobile/test/navigation_test.dart | PASS |
| 120 | Center `+` opens Quick Add and is not a destination tab. | AUDIT-B1 | apps/mobile/test/navigation_test.dart | PASS |
| 121 | Two tabs sit left of `+`, two tabs sit right of `+`. | UNVERIFIED-SAC-121 | No committed criterion-specific test located | UNVERIFIED |
| 122 | Active tab is visually distinct; inactive tabs are muted but readable. | UNVERIFIED-SAC-122 | No committed criterion-specific test located | UNVERIFIED |
| 123 | Content on Today, Money, Insights, and Settings clears the floating nav and | UNVERIFIED-SAC-123 | No committed criterion-specific test located | UNVERIFIED |
| 128 | A user can **add, edit, contribute to, complete, delete, and reorder** goals from Settings and from tapping a goal. | UNVERIFIED-SAC-128 | No committed criterion-specific test located | UNVERIFIED |
| 129 | **One shared goal-editor** is reached from both entry points (Settings and goal tap). | UNVERIFIED-SAC-129 | No committed criterion-specific test located | UNVERIFIED |
| 130 | **Goal changes affect the next briefing's recommendation** — the connection is real, not cosmetic. | UNVERIFIED-SAC-130 | No committed criterion-specific test located | UNVERIFIED |
| 131 | **Delete/complete copy clarifies money is unaffected** — goals are tracking, not accounts. | UNVERIFIED-SAC-131 | No committed criterion-specific test located | UNVERIFIED |
| 132 | **Empty state prompts warmly** to add a goal (a goal makes Today's "one step" meaningful). | UNVERIFIED-SAC-132 | No committed criterion-specific test located | UNVERIFIED |
| 133 | **A primary/closest goal flag** determines which goal Today references. | UNVERIFIED-SAC-133 | No committed criterion-specific test located | UNVERIFIED |
| 134 | All goal flows work offline; changes persist locally. | UNVERIFIED-SAC-134 | No committed criterion-specific test located | UNVERIFIED |
| 135 | **Goals are never write-once** — everything is editable after creation. | UNVERIFIED-SAC-135 | No committed criterion-specific test located | UNVERIFIED |
| 139 | **Dark-mode tiles are legible** — tints have dark variants, not light tints dropped onto black. | UNVERIFIED-SAC-139 | No committed criterion-specific test located | UNVERIFIED |
| 140 | **Decorative/watermark layers never reduce text contrast** — opacity is capped so text stays fully legible in both themes. | UNVERIFIED-SAC-140 | No committed criterion-specific test located | UNVERIFIED |
| 141 | **Verified at 1.3× text scale** in both light and dark. | MANUAL-SAC-141 | Physical/deployed-device handoff | HUMAN_HANDOFF |
| 145 | Opens from center `+` without changing tabs. | AUDIT-B1 | apps/mobile/test/navigation_test.dart | PASS |
| 146 | Common expense can be logged without typing. | UNVERIFIED-SAC-146 | No committed criterion-specific test located | UNVERIFIED |
| 147 | Income can be logged through salary, freelance, gift, or other. | UNVERIFIED-SAC-147 | No committed criterion-specific test located | UNVERIFIED |
| 148 | Pakistani categories are present. | UNVERIFIED-SAC-148 | No committed criterion-specific test located | UNVERIFIED |
| 149 | Offline save works. | AUDIT-C1-OFFLINE | apps/mobile/test/offline_pending_sync_test.dart | PASS |
| 150 | Success feedback is immediate. | UNVERIFIED-SAC-150 | No committed criterion-specific test located | UNVERIFIED |
| 151 | Validation errors are clear and non-punitive. | UNVERIFIED-SAC-151 | No committed criterion-specific test located | UNVERIFIED |
| 152 | Missing amount/category/income source states use approved copy from the tone guide. | UNVERIFIED-SAC-152 | No committed criterion-specific test located | UNVERIFIED |
| 153 | Sheet closes back to the originating screen. | UNVERIFIED-SAC-153 | No committed criterion-specific test located | UNVERIFIED |
| 157 | Shows profile, income timing, and income type. | UNVERIFIED-SAC-157 | No committed criterion-specific test located | UNVERIFIED |
| 158 | **Goals editor includes full CRUD** (add/edit/contribute/complete/delete/reorder), not just viewing. | UNVERIFIED-SAC-158 | No committed criterion-specific test located | UNVERIFIED |
| 159 | Data sources show status, confidence, freshness, and controls. | UNVERIFIED-SAC-159 | No committed criterion-specific test located | UNVERIFIED |
| 160 | Connect, disconnect, and delete data controls are reachable. | UNVERIFIED-SAC-160 | No committed criterion-specific test located | UNVERIFIED |
| 161 | Privacy copy includes no stored bank passwords, user-controlled sources, statement deletion, and confirmation for uncertain transactions. | UNVERIFIED-SAC-161 | No committed criterion-specific test located | UNVERIFIED |
| 162 | Notification settings are editable. | UNVERIFIED-SAC-162 | No committed criterion-specific test located | UNVERIFIED |
| 163 | Reduce-motion and balance visibility settings are present. | UNVERIFIED-SAC-163 | No committed criterion-specific test located | UNVERIFIED |
| 164 | The screen is sober and not gamified. | UNVERIFIED-SAC-164 | No committed criterion-specific test located | UNVERIFIED |
| 168 | Introduces Sprout's daily check-in promise. | UNVERIFIED-SAC-168 | No committed criterion-specific test located | UNVERIFIED |
| 169 | Captures name or nickname, with skip/default. | UNVERIFIED-SAC-169 | No committed criterion-specific test located | UNVERIFIED |
| 170 | Offers a playful nickname generator beside the plain text option. | UNVERIFIED-SAC-170 | No committed criterion-specific test located | UNVERIFIED |
| 171 | Captures one goal through chips, or lets Sprout help decide later. | UNVERIFIED-SAC-171 | No committed criterion-specific test located | UNVERIFIED |
| 172 | Allows completion with no connections. | AUDIT-A3-B8 | apps/mobile/test/audit_a3_router_guard_test.dart | PASS |
| 173 | Allows completion while offline using a local first briefing. | UNVERIFIED-SAC-173 | No committed criterion-specific test located | UNVERIFIED |
| 174 | Shows a retry path if first-briefing generation fails. | UNVERIFIED-SAC-174 | No committed criterion-specific test located | UNVERIFIED |
| 175 | Does not ask salary date, income type, multiple goals, or source connections before first value. | UNVERIFIED-SAC-175 | No committed criterion-specific test located | UNVERIFIED |
| 176 | Optional connections are framed as upgrades after core value is visible, not gates. | UNVERIFIED-SAC-176 | No committed criterion-specific test located | UNVERIFIED |
| 177 | Ends on a populated Today screen. | AUDIT-A3-B8 | apps/mobile/test/audit_a3_router_guard_test.dart | PASS |
| 178 | Does not request permissions before showing core value. | UNVERIFIED-SAC-178 | No committed criterion-specific test located | UNVERIFIED |
| 182 | No screen or sheet asks more than one question. | UNVERIFIED-SAC-182 | No committed criterion-specific test located | UNVERIFIED |
| 183 | Free text appears only when choices cannot express the answer. | UNVERIFIED-SAC-183 | No committed criterion-specific test located | UNVERIFIED |
| 184 | Every non-required ask has a warm skip. | UNVERIFIED-SAC-184 | No committed criterion-specific test located | UNVERIFIED |
| 185 | Every ask states the user benefit in one line. | UNVERIFIED-SAC-185 | No committed criterion-specific test located | UNVERIFIED |
| 186 | Deferred fields are captured in context, one tap, and remembered. | UNVERIFIED-SAC-186 | No committed criterion-specific test located | UNVERIFIED |
| 187 | No surface nags users to complete a profile. | UNVERIFIED-SAC-187 | No committed criterion-specific test located | UNVERIFIED |
| 188 | Privacy and reversibility are visible at the point of asking. | UNVERIFIED-SAC-188 | No committed criterion-specific test located | UNVERIFIED |
| 189 | Source connections are never requested before core value is visible. | UNVERIFIED-SAC-189 | No committed criterion-specific test located | UNVERIFIED |
| 193 | Opens from Today and Money insight surfaces. | UNVERIFIED-SAC-193 | No committed criterion-specific test located | UNVERIFIED |
| 194 | Explanation matches the tapped element. | UNVERIFIED-SAC-194 | No committed criterion-specific test located | UNVERIFIED |
| 195 | Explains what happened and why it matters. | UNVERIFIED-SAC-195 | No committed criterion-specific test located | UNVERIFIED |
| 196 | States uncertainty when applicable. | UNVERIFIED-SAC-196 | No committed criterion-specific test located | UNVERIFIED |
| 197 | Offers a next step when sensible. | UNVERIFIED-SAC-197 | No committed criterion-specific test located | UNVERIFIED |
| 198 | Returns to the previous screen without losing context. | UNVERIFIED-SAC-198 | No committed criterion-specific test located | UNVERIFIED |
| 202 | Valid briefing is generated from manual-only mock data. | AUDIT-B7 | apps/api/src/lib/briefing-validation.test.ts | PASS |
| 203 | Job failure falls back to local data. | AUDIT-C4 | scripts/e2e-local.mjs | PASS |
| 204 | Severity determines ordering, mascot mood, and visual treatment. | UNVERIFIED-SAC-204 | No committed criterion-specific test located | UNVERIFIED |
| 205 | Every finding has severity, confidence, category, and why detail. | AUDIT-B7 | apps/api/src/lib/briefing-validation.test.ts | PASS |
| 206 | Recommended action is singular, small, concrete, **goal-relative**, and completable. | UNVERIFIED-SAC-206 | No committed criterion-specific test located | UNVERIFIED |
| 207 | Score and action follow the deterministic scoring model. | AUDIT-B2-B3 | apps/api/src/lib/scoring.test.ts | PASS |
| 208 | Parser drift and low-confidence capture affect findings transparently. | UNVERIFIED-SAC-208 | No committed criterion-specific test located | UNVERIFIED |
| 209 | **WealthSnapshot includes total, change vs yesterday, change MTD, main reason, and interpretation.** | AUDIT-B4 | apps/api/src/audit.integration.test.ts | PASS |
| 210 | **Every WealthEvent has a plain-language "why."** | AUDIT-B4 | apps/api/src/audit.integration.test.ts | PASS |
| 211 | **Every holding valuation exposes dated price/FX provenance.** | AUDIT-A6 | apps/api/src/audit.integration.test.ts | PASS |
| 212 | **Stale prices/FX are labelled, never silently trusted.** | AUDIT-A6 | apps/api/src/audit.integration.test.ts | PASS |
| 213 | **No "check-in" action is ever selected.** | AUDIT-B2 | apps/api/src/lib/scoring.test.ts | PASS |
| 214 | **Daily WealthSnapshot is durable and idempotent per user/PKT date**, not | AUDIT-D6 | apps/api/src/audit.integration.test.ts | PASS |
| 216 | **Market-day logic uses versioned Pakistan calendar data** so weekends and | UNVERIFIED-SAC-216 | No committed criterion-specific test located | UNVERIFIED |
| 218 | **Al Meezan observations are cross-validated with MUFAP**; unresolved | AUDIT-D6 | apps/api/src/lib/nav-validation.test.ts | PASS |
| 223 | Uses existing tokens and components. | UNVERIFIED-SAC-223 | No committed criterion-specific test located | UNVERIFIED |
| 224 | No new arbitrary colors, spacing, radius, or type scales. | UNVERIFIED-SAC-224 | No committed criterion-specific test located | UNVERIFIED |
| 225 | Text fits at mobile sizes and 1.3x text scale. | MANUAL-SAC-225 | Physical/deployed-device handoff | HUMAN_HANDOFF |
| 226 | Reduce-motion is respected. | MANUAL-SAC-226 | Physical/deployed-device handoff | HUMAN_HANDOFF |
| 227 | No nested cards. | UNVERIFIED-SAC-227 | No committed criterion-specific test located | UNVERIFIED |
| 228 | Icons support recognition and have labels/tooltips where required. | UNVERIFIED-SAC-228 | No committed criterion-specific test located | UNVERIFIED |
| 232 | Daily check-in notification follows the configured or inferred user window. | UNVERIFIED-SAC-232 | No committed criterion-specific test located | UNVERIFIED |
| 233 | Notification copy hides balances and exact amounts by default. | UNVERIFIED-SAC-233 | No committed criterion-specific test located | UNVERIFIED |
| 234 | Each notification deep-links to the relevant screen. | UNVERIFIED-SAC-234 | No committed criterion-specific test located | UNVERIFIED |
| 235 | User can disable daily, bill, salary/income, weekly, and streak-protection notifications separately. | UNVERIFIED-SAC-235 | No committed criterion-specific test located | UNVERIFIED |
| 236 | Notifications never shame missed days or financial hardship. | UNVERIFIED-SAC-236 | No committed criterion-specific test located | UNVERIFIED |
| 240 | Refresh tokens are encrypted at rest. | AUDIT-A7 | apps/api/src/audit.integration.test.ts | PASS |
| 241 | Device binding and biometric/passkey unlock are supported where available. | MANUAL-SAC-241 | Physical/deployed-device handoff | HUMAN_HANDOFF |
| 242 | Parser/import jobs are idempotent and retry-safe. | AUDIT-D1 | apps/api/src/audit.integration.test.ts | PASS |
| 243 | Statement files are discarded by default after parsing. | AUDIT-D1 | scripts/e2e-local.mjs | PASS |
| 244 | Email capture uses OAuth and narrow scopes. | MANUAL-SAC-244 | Physical/deployed-device handoff | HUMAN_HANDOFF |
| 245 | Android SMS capture is optional, Android-only, and policy-gated. | MANUAL-SAC-245 | Physical/deployed-device handoff | HUMAN_HANDOFF |
| 246 | iOS works without SMS capture. | MANUAL-SAC-246 | Physical/deployed-device handoff | HUMAN_HANDOFF |
| 247 | No screen scraping or stored bank passwords. | AUDIT-B6 | scripts/e2e-local.mjs | PASS |
| 248 | NAV/FX fetchers have versions, golden source samples, drift monitoring, and | AUDIT-D6 | apps/api/src/lib/nav-validation.test.ts | PASS |
| 250 | The valuation pipeline completes at least 14 consecutive headless daily runs | MANUAL-SAC-250 | Physical/deployed-device handoff | HUMAN_HANDOFF |
| 253 | Every acceptance bullet has a stable test ID in the release traceability | UNVERIFIED-SAC-253 | No committed criterion-specific test located | UNVERIFIED |

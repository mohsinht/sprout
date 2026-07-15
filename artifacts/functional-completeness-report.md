# Sprout functional-completeness audit

VERDICT: FUNCTIONALLY READY FOR ANOTHER UX SWEEP — every launched, visibly actionable control inspected in the four-tab product shell now has a real local or API path; unlaunched capabilities are disabled and labelled instead of simulating success. The remaining verification gap is current P1–P7 real-UI screenshot evidence, not an API failure.

## Scope and constraints

This pass followed `ux_philosophy.md`, `copy_tone_guide.md`, `information_gathering_trust.md`, `screen_acceptance_criteria.md`, `navigation_ia.md`, `product_spec.md`, `data_model_contract.md`, and `user_stories_regression_invariants.md`.

Preserved:

- the four primary tabs;
- the locked 13-part Today sequence;
- manual-first and zero-connection use;
- whole-PKR formatting and calm bad-news treatment;
- no new banking, payment, score, wealth, or recommendation behavior.

The production product does not expose development fixtures as shipped features. Gmail/SMS connections, Urdu, USD/EUR display, the lesson-path prototype, and bill tracking remain unavailable and are now visibly disabled or development-only.

## Why the local endpoint appeared broken

There were two independent configuration problems:

1. Both repository `.env` files point `DATABASE_URL` to hosted Neon, while the harness defaults `API_BASE_URL` to `http://127.0.0.1:8787`. API requests therefore went to the local server while direct invariant queries went to a different database. This produced false ledger and recurring-state failures.
2. development CORS allowed a fixed list of origins. A Flutter web harness on `127.0.0.1:8090` reached `/ready` successfully with curl but the browser was denied, making a healthy backend look offline.

Fixes:

- development CORS now accepts any `localhost` or `127.0.0.1` port while production remains allowlist-only;
- `pnpm dev:api:local` explicitly starts the API against local PostgreSQL with SSL off;
- local integration verification was run with the same explicit database as the API;
- the valuation fixture now clears only its audit-owned rows before recreating its exact three-day dataset;
- the Insights harness asserts its own seeded fact rather than assuming no other valid product facts exist.

Proof: `/ready` returns 200 with `database: ready`, origin `http://127.0.0.1:8090` receives the matching `access-control-allow-origin`, and the real API-to-PostgreSQL E2E suite passes 31 assertions.

## Visible feature audit

| Surface / promise | Functional path | Persistence / backend | Result |
|---|---|---|---|
| Register, login, logout, device sessions | Real auth forms and session recovery | Auth API, refresh-token rotation, secure storage | PASS |
| Continue without account | Real local-only guest session | SharedPreferences; survives restart | PASS |
| Onboarding skips and completion | One-question screens, safe skips | API profile/goal or local guest state | PASS |
| Today briefing | Real controller; no silent production mock fallback | Briefing API/cache/local empty state | PASS |
| Today recommended action | Routes to the actual Quick Add, Money, or goal editor flow | Corresponding real store/API | PASS |
| Today action celebration | Fires only after user-confirmed completion | Goal/transaction completion callback | PASS |
| Manual expense and all income paths | Quick Add creates transactions and updates the chosen account | Local-first store plus transaction/account APIs | PASS |
| Statement import | Native CSV picker, parse, preview, explicit import | Local-first transactions; source marked `statement`; source file not stored | PASS |
| Account balance edit | Real edit sheet | Account PATCH translates visible balance to opening balance without double counting | PASS |
| Holdings and provenance | Real briefing holdings on Money; no production fixture list | Holdings/briefing API | PASS |
| Goals create/edit/contribute/complete/delete/reorder | Real editor from both entry paths | Local store plus goal CRUD/contribution/reorder APIs | PASS online / local guest |
| Transactions needing review | One calm question with confirm, defer, reject | Transaction confirm/delete APIs | PASS |
| Uncertain balance handling | Not counted before confirmation; counted exactly once afterward | Account query filters `needsReview`; confirmation refreshes account and briefing | PASS |
| Insights and details | Real API insights, quiet state, cached-offline state | Insights API and local cache | PASS |
| Sprout Explains | Origin-specific Today/detail explanations | Briefing and insight payloads | PASS |
| Profile, income type/date, expected income | Real editors | Profile and projected-income APIs; guest settings cache | PASS |
| Data-source disconnect | Calm confirmation; manual entries preserved | Source DELETE API | PASS |
| Statement source | Opens the real import path | Quick Add importer | PASS |
| Gmail/SMS source | Disabled, explicitly unavailable | No fake connection state | HONESTLY UNAVAILABLE |
| Hide balances | Global discoverable toggle | Local preference plus profile API | PASS |
| App lock | Platform capability-gated | Device biometric/local auth plugin | PASS on supported device |
| Reduce motion | Changes runtime animation policy | Local preference plus profile API | PASS |
| Dark mode | Changes live app theme | Runtime theme controller | PASS |
| Daily/weekly/salary/streak reminders | Real permission request, scheduling, cancellation and deep links | Platform notification service plus profile preference | PASS on supported device |
| Bill reminders | Disabled with “Nothing is scheduled yet” | Bill tracking is not a launched model/UI | HONESTLY UNAVAILABLE |
| Data export | Copies plain user-owned JSON | Authenticated export API | PASS |
| Delete imported data | Calm consequence confirmation | API deletes imported material, preserves manual entries | PASS |
| Learn lesson path | Development-only route | In-memory development fixture | NOT EXPOSED IN PRODUCTION |
| Urdu and USD/EUR display | Disabled and labelled for later | No fake locale/conversion | HONESTLY UNAVAILABLE |

## User-story coverage

| Stories | Result | Evidence |
|---|---|---|
| S1–S6 onboarding and identity | PASS | router/onboarding/guest tests; real profile E2E |
| S7–S12 daily loop, zero data, explainability, motion | PASS | Today ritual, locked-layout, zero-data and reduce-motion widget/golden tests |
| S13 manual offline lifecycle | PASS for manual entries and guest use | local-first stores and Quick Add tests |
| S14 connected dedupe/confidence | PASS for implemented statement/manual sources | E2E idempotency; uncertainty test and account ledger assertions |
| S15 irregular income | PASS | all Quick Add income paths and projected-income API |
| S16 returner | PASS | durable auth/local state; invalid sessions return cleanly to auth |
| S17 hard month | PASS | wealth-down fixture and golden behavior |
| S18 Settings recovery | PASS for launched controls | profile/privacy/security/export/delete functionality |
| S19 optional/reversible sources | PASS for launched sources | manual-first state and disconnect API |
| S20–S25 wealth hero, why, score integrity, provenance, calm-down, goals | PASS | Today goldens, score/invariant suites, provenance tests |
| S26 learn-later retrieval | PASS through Sprout Explains | production lesson-path demo removed from routing |
| S27–S28 manual logging and thin wealth | PASS | Quick Add tests and seeded thin-wealth state |
| S29–S30 history and disputed valuation quarantine | PASS | ops, provenance and valuation suites |

## UX/professional-quality corrections

- Cold backend transport errors no longer surface. A single floating notice says Sprout is waking, then announces recovery; after 60 seconds it calmly explains that sync is unavailable and local changes remain.
- The notice probes `/ready`, so it requires both API and database readiness rather than treating a listening process as usable.
- Today’s action label can wrap at 360 px instead of truncating.
- Quick Add keeps its Pakistan-specific categories and real CSV review path.
- Money no longer renders fixture investments or reassuring budget copy with zero data.
- Settings caches guest/offline edits locally and no longer claims an automatic sync that does not exist.
- The uncertain-transaction sheet is scroll-safe on short screens and at larger text sizes.
- A production deep-link can no longer open the in-memory Learn prototype.

## Verification run

- `pnpm check` — PASS.
- `flutter analyze` — PASS, zero issues.
- `flutter test --dart-define=SPROUT_ENV=dev` — PASS, 61 tests.
- `pnpm test:e2e:local` — PASS, 31 real API → local PostgreSQL assertions.
- `pnpm test:golden` — PASS, 9 deterministic fixtures.
- `pnpm test:money-invariants` against local DB — PASS, 7 tests.
- `pnpm test:insights` against local DB — PASS, 4 tests.
- `pnpm test:adversarial` against local DB — PASS, 7 API tests plus inert-rendering widget test.
- `pnpm test:ops` against local DB — PASS, 4 tests including backup/restore and local CORS.
- `pnpm test:score` against local DB — PASS, 20 tests.
- `pnpm test:ai-budget` against local DB — PASS, 5 tests.
- `pnpm test:no-mocks` — PASS; release web build contains no active mock repository path.
- `pnpm seed:ux-states` — PASS; 12 deterministic real-DB accounts available.

## Remaining verification and product gaps

1. `pnpm test:personas` passed all seven API journeys but correctly failed its final gate because current P1–P7 Flutter→API→PostgreSQL screenshots are absent from `artifacts/persona-evidence/`. Existing unrelated screenshots were not renamed or presented as persona proof. This is the remaining verification blocker.
2. Native notification delivery, biometric locking, and file-picker behavior still need one physical Android smoke pass; unit/widget coverage cannot prove OS permission sheets or delivery timing.
3. Bill tracking/reminders, Gmail/SMS ingestion, Urdu, alternate display currency, and the lesson path are not launched features. Their UI is disabled or production-inaccessible. Implementing them would expand product scope and needs a separate spec-backed build, not a fake success state.
4. Existing remote-goal edits are local-first during an outage but do not yet have a general durable mutation queue. The supported offline-first guarantee in this pass is the manual cash/transaction lifecycle and guest use.

READY FOR REAL-DEVICE AND PERSONA-EVIDENCE PASS; NOT SELF-APPROVED FOR SHIP.

# Sprout Financial

Sprout is a playful financial health companion for Pakistan. The first version focuses on the Today screen: clear status, one recommended action, auto-capture confidence, and lightweight gamification.

## Monorepo

```text
apps/
  api/      TypeScript Hono API
  mobile/   Flutter app shell
packages/
  shared/        API contracts and mock data
  design_tokens/ Cross-platform color, spacing, type, and motion tokens
  domain/        Financial Health Score model
  parsers/       Mock email, SMS, and CSV parsing adapters
```

## Setup

```bash
pnpm install
pnpm check
pnpm dev:api
```

The API runs at `http://localhost:8787`.

Flutter is expected for mobile development:

```bash
cd apps/mobile
flutter pub get
flutter run
```

## Current MVP Scope

- Today screen only
- Mock repositories and mock ingestion state
- Transparent Financial Health Score model
- API health endpoint and Today payload endpoint
- Bottom navigation with placeholder tabs for future MVP screens

## Security Notes

Sprout must not store bank passwords, perform screen scraping, or assume Plaid-style Pakistani bank APIs. Future ingestion should use explicit consent, minimal permissions, encrypted local/token storage, masked account references, audit-friendly logs, and clear disconnect/delete controls.

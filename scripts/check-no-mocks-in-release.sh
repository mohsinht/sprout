#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root/apps/mobile"
flutter build web --release --dart-define=SPROUT_ENV=production

if rg -a "Mock briefing|Mock Xe FX|USE_MOCK|Salaam, Mohsin|mock-ai|mock insights" build/web; then
  echo "audit_a2_no_mocks_in_release: forbidden mock marker found" >&2
  exit 1
fi

echo "audit_a2_no_mocks_in_release: passed"

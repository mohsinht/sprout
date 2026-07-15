#!/usr/bin/env bash
set -euo pipefail

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
output="${1:-artifacts/backups/sprout-${timestamp}.dump}"
mkdir -p "$(dirname "$output")"
umask 077

if command -v pg_dump >/dev/null 2>&1 && [[ -n "${DATABASE_URL:-}" ]]; then
  pg_dump "$DATABASE_URL" --format=custom --no-owner --no-privileges > "$output"
else
  docker compose exec -T postgres pg_dump \
    --username="${POSTGRES_USER:-sprout}" \
    --dbname="${POSTGRES_DB:-sprout}" \
    --format=custom --no-owner --no-privileges > "$output"
fi

test -s "$output"
echo "$output"

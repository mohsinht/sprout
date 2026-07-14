#!/usr/bin/env bash
set -euo pipefail

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
output="${1:-artifacts/backups/sprout-${timestamp}.dump}"
mkdir -p "$(dirname "$output")"
umask 077

docker compose exec -T postgres pg_dump \
  --username="${POSTGRES_USER:-sprout}" \
  --dbname="${POSTGRES_DB:-sprout}" \
  --format=custom \
  --no-owner \
  --no-privileges > "$output"

test -s "$output"
echo "$output"

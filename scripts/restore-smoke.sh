#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "--" ]]; then shift; fi
backup="${1:-}"
if [[ -z "$backup" || ! -s "$backup" ]]; then
  echo "Usage: pnpm ops:restore-smoke -- artifacts/backups/<backup>.dump" >&2
  exit 2
fi

database="sprout_restore_smoke_$(date -u +%s)"
cleanup() {
  docker compose exec -T postgres dropdb \
    --username="${POSTGRES_USER:-sprout}" \
    --if-exists "$database" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker compose exec -T postgres createdb \
  --username="${POSTGRES_USER:-sprout}" "$database"
docker compose exec -T postgres pg_restore \
  --username="${POSTGRES_USER:-sprout}" \
  --dbname="$database" \
  --no-owner \
  --no-privileges < "$backup"
docker compose exec -T postgres psql \
  --username="${POSTGRES_USER:-sprout}" \
  --dbname="$database" \
  --tuples-only \
  --command="select count(*) >= 0 from users;" | grep -q t

echo "Restore smoke test passed."

#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "--" ]]; then shift; fi
backup="${1:-}"
if [[ -z "$backup" || ! -s "$backup" ]]; then
  echo "Usage: pnpm ops:restore-smoke -- artifacts/backups/<backup>.dump" >&2
  exit 2
fi

database="sprout_restore_smoke_$(date -u +%s)_$RANDOM"
cleanup() {
  if command -v dropdb >/dev/null 2>&1 && [[ -n "${DATABASE_URL:-}" ]]; then
    dropdb --maintenance-db="${DATABASE_URL%/*}/postgres" --if-exists --force "$database" >/dev/null 2>&1 || true
  else
    docker compose exec -T postgres dropdb --username="${POSTGRES_USER:-sprout}" --if-exists "$database" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

if command -v createdb >/dev/null 2>&1 && [[ -n "${DATABASE_URL:-}" ]]; then
  admin_url="${DATABASE_URL%/*}/postgres"
  restore_url="${DATABASE_URL%/*}/$database"
  createdb --maintenance-db="$admin_url" "$database"
  pg_restore --dbname="$restore_url" --no-owner --no-privileges "$backup"
  psql "$restore_url" --tuples-only --command="select count(*) >= 0 from users;" | grep -q t
else
  docker compose exec -T postgres createdb --username="${POSTGRES_USER:-sprout}" "$database"
  docker compose exec -T postgres pg_restore --username="${POSTGRES_USER:-sprout}" --dbname="$database" --no-owner --no-privileges < "$backup"
  docker compose exec -T postgres psql --username="${POSTGRES_USER:-sprout}" --dbname="$database" --tuples-only --command="select count(*) >= 0 from users;" | grep -q t
fi

echo "Restore smoke test passed."

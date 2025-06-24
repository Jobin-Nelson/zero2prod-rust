#!/usr/bin/env bash

set -euxo pipefail

DB_USER="${POSTGRES_USER:-postgres}"
DB_PASSWORD="${POSTGRES_PASSWORD:-password}"
DB_NAME="${POSTGRES_DB:-newsletter}"
DB_PORT="${POSTGRES_PORT:-5432}"
DB_HOST="${POSTGRES_HOST:-localhost}"
SKIP_DOCKER="${SKIP_DOCKER:-}"


function bail() {
  echo
  echo "$1"
  echo $'Aborting ...\n'
  exit 1
}

function check_executable() {
  local -a executables
  local executable

  executables=(
    psql
    sqlx
  )

  # Install sqlx cli
  # cargo install --version="~0.7" sqlx-cli --no-default-features --features rustls,postgres
  for executable in "${executables[@]}"; do
    if ! type "${executable}" &>/dev/null; then
      bail "ERROR: ${executable} not found"
    fi
  done
}

function run_docker() {
  if [[ -z $SKIP_DOCKER ]]; then
    docker run \
      --rm \
      -e POSTGRES_USER="${DB_USER}" \
      -e POSTGRES_PASSWORD="${DB_PASSWORD}" \
      -e POSTGRES_ID="${DB_NAME}" \
      -p "${DB_PORT}:5432" \
      -d postgres \
      postgres -N 1000
  fi
}

function wait_till_db_is_up() {
  export PGPASSWORD="${DB_PASSWORD}"
  until psql -h "${DB_HOST}" -U "${DB_USER}" -p "${DB_PORT}" -d postgres -c '\q'; do
    echo 'Postgres is still unavailable - sleeping' >&2
    sleep 1
  done
  echo "Postgres is up and running on port ${DB_PORT}" >&2
}

function start_migration() {
  export DATABASE_URL="postgres://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}"
  sqlx database create
  sqlx migrate run
}

function main() {
  check_executable
  run_docker
  wait_till_db_is_up
  start_migration
}

main



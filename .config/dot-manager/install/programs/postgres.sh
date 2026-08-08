#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_postgres() {
  local postgres_root="${DOT_MANAGER_POSTGRES_ROOT:-/var/lib/postgres}"
  local postgres_data="$postgres_root/data"

  print_step "Installing postgres..."

  log "info" "Installing postgres via pacman..."
  if ! __install_package_arch postgresql postgresql-openrc; then
    log "error" "Failed to install PostgreSQL packages."
    return 1
  fi

  if ! __as_root mkdir -p "$postgres_root"; then
    log "error" "Failed to create $postgres_root."
    return 1
  fi
  if ! __as_root chmod 775 "$postgres_root"; then
    log "error" "Failed to set permissions on $postgres_root."
    return 1
  fi
  if ! __as_root chown postgres:postgres "$postgres_root"; then
    log "error" "Failed to set ownership on $postgres_root."
    return 1
  fi

  if [ ! -s "$postgres_data/PG_VERSION" ]; then
    log "info" "Initializing PostgreSQL cluster..."
    if ! __as_user postgres initdb \
      --locale=en_US.UTF-8 \
      -E UTF8 \
      --auth-local=peer \
      --auth-host=scram-sha-256 \
      -D "$postgres_data"; then
      log "error" "Failed to initialize the PostgreSQL cluster."
      return 1
    fi
  else
    log "info" "PostgreSQL cluster already initialized."
  fi

  if ! __as_root touch "$postgres_root/.psql_history"; then
    log "error" "Failed to create PostgreSQL history file."
    return 1
  fi
  if ! __as_root chown postgres:postgres "$postgres_root/.psql_history"; then
    log "error" "Failed to set PostgreSQL history ownership."
    return 1
  fi

  log "info" "Enabling postgresql service..."
  if ! __as_root rc-update add postgresql default; then
    log "error" "Failed to enable the PostgreSQL service."
    return 1
  fi
  if ! __as_root rc-service postgresql start; then
    log "error" "Failed to start the PostgreSQL service."
    return 1
  fi

  if ! __as_user postgres pg_isready -q -d postgres; then
    log "info" "PostgreSQL is not ready; resetting stale service state..."
    if ! __as_root rc-service postgresql zap; then
      log "error" "Failed to reset the PostgreSQL service state."
      return 1
    fi
    if ! __as_root rc-service postgresql start; then
      log "error" "Failed to start PostgreSQL after resetting its service state."
      return 1
    fi
    if ! __as_user postgres pg_isready -q -d postgres; then
      log "error" "PostgreSQL did not become ready after resetting its service state."
      return 1
    fi
  fi
  if ! __as_user postgres psql \
    -v ON_ERROR_STOP=1 \
    -d postgres \
    -c "SELECT 1"; then
    log "error" "Failed to validate the postgres database."
    return 1
  fi

  log "info" " doas -u postgres psql -d postgres"

  log "success" "Postgres installed."
}

install_postgres "$@"

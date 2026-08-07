#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_postgres() {
  print_step "Installing postgres..."

  log "info" "Installing postgres via pacman..."
  __install_package_arch postgresql postgresql-openrc

  __as_root mkdir -p /var/lib/postgres
  __as_root chmod 775 /var/lib/postgres
  __as_root chown postgres /var/lib/postgres

  __as_user postgres initdb --locale=en_US.UTF-8 -E UTF8 -D /var/lib/postgres/data
  __as_root touch /var/lib/postgres/.psql_history
  __as_user postgres createuser --interactive
  __as_user postgres createdb myDatabaseName

  log "info" "Enabling postgresql service..."
  __as_root rc-update add postgresql default
  __as_root rc-service postgresql start

  log "success" "Postgres installed."
}

install_postgres "$@"

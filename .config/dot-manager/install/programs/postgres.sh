#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_postgres() {
  print_step "Installing postgres..."

  log "info" "Installing postgres via pacman..."
  __install_package_arch postgresql postgresql-openrc

  sudo mkdir -p /var/lib/postgres
  sudo chmod 775 /var/lib/postgres
  sudo chown postgres /var/lib/postgres

  sudo -iu postgres
  initdb --locale=en_US.UTF-8 -E UTF8 -D /var/lib/postgres/data
  sudo touch /var/lib/postgres/.psql_history
  createuser --interactive
  createdb myDatabaseName

  log "info" "Enabling postgresql service..."
  sudo rc-update add postgresql default
  sudo rc-service postgresql start

  log "success" "Postgres installed."
}

install_postgres "$@"

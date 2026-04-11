#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_numi() {
  print_step "Installing Numi..."

  if __is_program_installed "numi"; then
    log "info" "numi is already installed. Skipping installation."
    return
  fi

  printf "y\n" | curl -sSL https://s.numi.app/cli | sh

  log "success" "Numi installed."
}

install_numi "$@"

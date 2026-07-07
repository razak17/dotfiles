#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_numi() {
  print_step "Installing Numi..."

  if __is_program_installed "numi"; then
    log "info" "numi is already installed. Skipping installation."
    return
  fi

  if ! printf "y\n" | curl -sSL https://s.numi.app/cli | sh >>"$DOT_MANAGER_LOG" 2>&1; then
    log "error" "Failed to install Numi."
    return 1
  fi

  log "success" "Numi installed."
}

install_numi "$@"

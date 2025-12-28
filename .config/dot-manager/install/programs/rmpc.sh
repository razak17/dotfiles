#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_rmpc() {
  log "info" "Installing rmpc..."

  if __is_program_installed "rmpc"; then
    log "info" "rmpc is already installed. Skipping installation."
    return
  fi

  if ! command -v cargo &>/dev/null; then
    source "$DOT_MANAGER_DIR/install/programs/cargo.sh"
  fi

  if command -v rmpc >/dev/null 2>&1; then
    log "info" "rmpc is already installed. Skipping installation."
    return
  fi

  cargo install rmpc --locked

  log "success" "rmpc installed."
}

install_rmpc "$@"

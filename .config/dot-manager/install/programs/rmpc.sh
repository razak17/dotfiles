#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_rmpc() {
  log "info" "Installing rmpc..."

  if __is_program_installed "rmpc"; then
    log "info" "rmpc is already installed. Skipping installation."
    return
  fi

  if command -v rmpc >>"$DOT_MANAGER_LOG" 2>&1; then
    log "info" "rmpc is already installed. Skipping installation."
    return
  fi

  if command -v cargo >>"$DOT_MANAGER_LOG" 2>&1; then
    if ! cargo install rmpc --locked; then
      log "error" "Failed to install rmpc with Cargo."
      return 1
    fi
  else
    if ! command -v mise >>"$DOT_MANAGER_LOG" 2>&1; then
      log "error" "Cargo is unavailable. Install Rust with 'dot install mise' first."
      return 1
    fi

    if ! mise use -g rust@latest; then
      log "error" "Failed to install stable Rust via mise."
      return 1
    fi

    if ! mise exec -- cargo install rmpc --locked; then
      log "error" "Failed to install rmpc with mise-managed Cargo."
      return 1
    fi
  fi

  log "success" "rmpc installed."
}

install_rmpc "$@"

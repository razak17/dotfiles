#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_uv() {
  print_step "Installing uv"

  if __is_program_installed "uv"; then
    log "info" "uv is already installed. Skipping installation."
    return
  fi

  if ! curl -LsSf https://astral.sh/uv/install.sh | sh >>"$DOT_MANAGER_LOG" 2>&1; then
    log "error" "Failed to install uv."
    return 1
  fi

  # uv self update

  log "success" "uv installed."
}

install_uv "$@"

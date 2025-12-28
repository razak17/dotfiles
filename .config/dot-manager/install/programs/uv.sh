#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_uv() {
  print_step "Installing uv"

  if __is_program_installed "uv"; then
    log "info" "uv is already installed. Skipping installation."
    return
  fi

  curl -LsSf https://astral.sh/uv/install.sh | sh
  # uv self update

  log "success" "uv installed."
}

install_uv "$@"

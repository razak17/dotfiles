#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_fzf() {
  print_step "Installing fzf..."

  if ! __install_package_arch fzf; then
    log "error" "Failed to install fzf."
    return 1
  fi

  log "success" "fzf installed."
}

install_fzf "$@"

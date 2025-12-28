#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_golang() {
  print_step "Installing GoLang..."

  if [ -f "$HOME/go/bin/g" ]; then
    log "info" "Removing old GoLang symlink."
    rm "$HOME/go/bin/g"
  fi

  curl -sSL https://git.io/g-install | sh -s

  log "success" "GoLang installed."
}

install_golang "$@"

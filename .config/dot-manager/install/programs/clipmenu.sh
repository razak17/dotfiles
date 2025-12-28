#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_clipmenu() {
  print_step "Installing Clipmenu..."

  if __is_program_installed "clipmenu"; then
    log "info" "clipmenu is already installed. Skipping installation."
    return
  fi

  git clone https://github.com/cdown/clipmenu /tmp/clipmenu >/dev/null
  cd /tmp/clipmenu || return
  make install >/dev/null

  log "success" "Clipmenu installed."
}

install_clipmenu "$@"

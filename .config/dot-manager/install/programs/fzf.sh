#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_fzf() {
  print_step "Installing fzf..."

  if __is_program_installed "fzf"; then
    log "info" "fzf is already installed. Skipping installation."
    return
  fi

  if [ -d "$HOME/.fzf" ]; then
    log "info" "Removing old fzf installation."
    rm -rf "$HOME/.fzf"
  fi

  git clone --depth 1 https://github.com/junegunn/fzf.git /tmp/fzf >/dev/null
  /tmp/fzf/install --bin >/dev/null
  mv /tmp/fzf "$HOME/.fzf"

  log "success" "fzf installed."
}

install_fzf "$@"

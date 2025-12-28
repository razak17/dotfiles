#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_deno() {
  print_step "Installing Deno..."

  if __is_program_installed "deno"; then
    log "info" "Deno is already installed. Skipping installation."
    return
  fi

  if [ -f "$HOME/.deno/bin/deno" ]; then
    log "info" "Removing old deno symlink."
    rm "$HOME/.deno/bin/deno"
  fi

  curl -fsSL https://deno.land/x/install/install.sh | sh

  log "success" "Deno installed."
}

install_deno "$@"

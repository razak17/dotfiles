#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_copilot_cli() {
  print_step "Installing copilot-cli..."

  if __is_program_installed "copilot-cli"; then
    log "info" "copilot-cli is already installed. Skipping installation."
    return
  fi

  PIP_BIN=$(which pip)
  if [ "$PIP_BIN" != "$HOME/.asdf/shims/pip" ]; then
    log "error" "pip is not installed through asdf."
    source "$DOT_MANAGER_DIR/install/programs/asdf.sh"
  fi

  if [ -f "$HOME/.asdf/shims/copilot-cli" ]; then
    log "info" "Removing old copilot-cli symlink."
    rm "$HOME/.asdf/shims/copilot-cli"
  fi

  git clone https://github.com/razak17/copilot-cli /tmp/copilot-cli >/dev/null
  cd /tmp/copilot-cli || return 1
  asdf set -u python 3.11.9
  $PIP_BIN install . >/dev/null
  cd - >/dev/null || return 1
  rm -rf /tmp/copilot-cli

  log "success" "copilot-cli installed."
}

install_copilot_cli "$@"

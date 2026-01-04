#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_copilot_cli() {
  print_step "Installing copilot-cli..."

  if __is_program_installed "copilot-cli"; then
    log "info" "copilot-cli is already installed. Skipping installation."
    return
  fi

  PYTHON_VERSION=$(python --version 2>&1 | awk '{print $2}')
  if [[ "$PYTHON_VERSION" != "3.11.9" ]]; then
    log "error" "Python 3.11.9 is required to install copilot-cli. Current version: $PYTHON_VERSION"
    return
  fi

  PIP_BIN=$(which pip)
  if [ "$PIP_BIN" != "$HOME/.local/share/mise/installs/python/3.11.9/bin/pip" ]; then
    log "error" "pip is not installed through mise."
    source "$DOT_MANAGER_DIR/install/programs/mise.sh"
  fi

  if [ -f "$HOME/.local/share/mise/installs/python/3.11.9/bin/copilot-cli" ]; then
    log "info" "Removing old copilot-cli symlink."
    rm "$HOME/.local/share/mise/installs/python/3.11.9/bin/copilot-cli"
  fi

  cd "$HOME" || return 1
  git clone https://github.com/razak17/copilot-cli /tmp/copilot-cli >/dev/null && log "success" "Cloned copilot-cli repository." || return 1
  cd /tmp/copilot-cli || return 1

  log "info" "Installing copilot-cli dependencies..."
  $PIP_BIN install . >/dev/null

  cd - >/dev/null || return 1
  rm -rf /tmp/copilot-cli

  log "success" "copilot-cli installed."
}

install_copilot_cli "$@"

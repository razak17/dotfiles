#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

# Retired: Node.js is now managed by install/programs/mise.sh. The legacy fnm
# implementation below is retained for reference, but this script no longer
# invokes it.

install_fnm() {
  print_step "Installing fnm..."

  if __is_program_installed "fnm"; then
    log "info" "fnm is already installed. Skipping installation."
    return
  fi

  if [ -f "$HOME/.local/share/fnm/fnm" ]; then
    log "info" "Removing old fnm symlink."
    rm "$HOME/.local/share/fnm/fnm"
  fi

  if ! curl -fsSL https://fnm.vercel.app/install | bash >>"$DOT_MANAGER_LOG" 2>&1; then
    log "error" "Failed to install fnm."
    return 1
  fi

  log "success" "fnm installed."
}

fnm_complete_setup() {
  log "info" "Setting up fnm completions..."

  if ! command -v fnm >>"$DOT_MANAGER_LOG" 2>&1; then
    log "error" "fnm is not installed. Please install fnm first."
    return 1
  fi

  if [ -f "$HOME/.config/zsh/plugins/fnm/_fnm" ]; then
    log "info" "Removing old fnm completions."
    rm "$HOME/.config/zsh/plugins/fnm/_fnm"
  fi

  mkdir -p "$HOME/.config/zsh/plugins/fnm"

  fnm completions --shell zsh >"$HOME/.config/zsh/plugins/fnm/_fnm"

  log "success" "fnm completions set up."
}

install_versions() {
  fnm list
  fnm install v18.0.0
  fnm install v16.13.0
  fnm install v25.0.0
  fnm default v25.0.0
}

print_step "fnm installer (retired)"
log "error" "The fnm installer is retired. Node.js is managed by mise; run 'dot program mise'."
return 1 2>/dev/null || exit 1

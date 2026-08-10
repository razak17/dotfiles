#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

# Retired: runtimes are now managed by install/programs/mise.sh. The legacy
# implementation below is intentionally retained for reference, but this script
# no longer invokes it.

install_asdf() {
  print_step "Installing asdf..."

  if __is_program_installed "asdf"; then
    log "info" "asdf is already installed. Skipping installation."
    return
  fi

  if [ -f "$HOME/.local/bin/asdf" ]; then
    log "info" "Removing old asdf symlink."
    rm "$HOME/.local/bin/asdf"
  fi

  VERSION=$(__get_latest_release "asdf-vm/asdf")

  __install_package_release "https://github.com/asdf-vm/asdf/releases/download/v0.18.0/asdf-$VERSION-linux-amd64.tar.gz" asdf
}

install_lua() {
  log "info" "Installing lua plugin for asdf..."

  if ! command -v asdf >>"$DOT_MANAGER_LOG" 2>&1; then
    log "error" "asdf is not installed. Please install asdf first."
    return 1
  fi

  asdf plugin add lua https://github.com/Stratus3D/asdf-lua.git
  asdf install lua 5.1
  asdf set -u lua 5.1
}

install_golang() {
  log "info" "Installing Golang via asdf"

  asdf plugin add golang https://github.com/kennyp/asdf-golang.git
  asdf install golang 1.25.5
  asdf set -u golang 1.25.5
}

install_python() {
  log "info" "Installing Python via asdf"

  asdf plugin add python
  asdf install python 3.11.9
  asdf install python 3.14.2
  asdf set -u python 3.11.9
}

print_step "asdf (retired)"
log "error" "asdf is retired. Runtimes are managed by mise; run 'dot install mise'."
return 1 2>/dev/null || exit 1

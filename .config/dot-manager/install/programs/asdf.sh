#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

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

  if ! command -v asdf &>/dev/null; then
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

install_asdf "$@"
install_lua
install_python

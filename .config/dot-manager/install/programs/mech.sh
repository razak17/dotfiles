#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_mech() {
  print_step "Installing Mech..."

  if __is_program_installed "mech"; then
    log "info" "Mech is already installed. Skipping installation."
    return
  fi

  VERSION=$(__get_latest_release "hainguyents13/mechvibes")

  __install_package_release "https://github.com/hainguyents13/mechvibes/releases/download/$VERSION/Mechvibes-${VERSION#v}.AppImage" mech

  log "success" "Mech installed."
}

install_mech "$@"

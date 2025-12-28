#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_jellyfin() {
  print_step "Installing jellyfin..."

  __install_package_aur jellyfin-server jellyfin-web jellyfin-ffmpeg

  if [ ! -e "/etc/init.d/jellyfind" ]; then
    log "info" "Downloading jellyfin openrc service file..."
    sudo wget -O /etc/init.d/jellyfind https://raw.githubusercontent.com/razak17/jellyfinopenrc/refs/heads/main/jellyfind
    sudo chmod +x /etc/init.d/jellyfind
  fi

  log "info" "Enabling jellyfin service..."
  sudo rc-update add jellyfind default
  sudo rc-service jellyfind start

  log "success" "Jellyfin installed."
}

install_jellyfin "$@"

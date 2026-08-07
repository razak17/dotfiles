#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_jellyfin() {
  print_step "Installing jellyfin..."

  __install_package_aur jellyfin-server jellyfin-web jellyfin-ffmpeg

  if [ ! -e "/etc/init.d/jellyfind" ]; then
    log "info" "Downloading jellyfin openrc service file..."
    __as_root wget -O /etc/init.d/jellyfind https://raw.githubusercontent.com/razak17/jellyfinopenrc/refs/heads/main/jellyfind
    __as_root chmod +x /etc/init.d/jellyfind
  fi

  log "info" "Enabling jellyfin service..."
  __as_root rc-update add jellyfind default
  __as_root rc-service jellyfind start

  log "success" "Jellyfin installed."
}

install_jellyfin "$@"

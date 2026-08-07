#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_valkey() {
  print_step "Installing redis..."

  log "info" "Installing redis via pacman..."
  __install_package_arch redis valkey-openrc

  log "info" "Enabling valkey service..."
  __as_root rc-update add valkey-sentinel default
  __as_root rc-update add valkey default
  __as_root rc-service valkey start

  log "success" "Redis installed."
}

install_valkey "$@"

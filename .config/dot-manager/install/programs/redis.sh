#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_valkey() {
  print_step "Installing redis..."

  log "info" "Installing redis via pacman..."
  __install_package_arch redis valkey-openrc

  log "info" "Enabling valkey service..."
  sudo rc-update add valkey-sentinel default
  sudo rc-update add valkey default
  sudo rc-service valkey start

  log "success" "Redis installed."
}

install_fd_find "$@"

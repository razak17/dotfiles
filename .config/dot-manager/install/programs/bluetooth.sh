#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_bluetooth() {
  print_step "Installing Bluetooth support..."

  __install_package_arch \
    bluez-openrc \
    bluez-utils \
    bluez-obex \
    bluedevil || return 1

  log "info" "Enabling Bluetooth service..."
  __as_root rc-update add bluetoothd default || return 1
  __as_root rc-service bluetoothd start || return 1

  log "success" "Bluetooth support installed."
}

install_bluetooth "$@"

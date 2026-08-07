#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_docker() {
  print_step "Installing docker..."

  log "info" "Installing docker via pacman..."
  __install_package_arch docker docker-openrc docker-compose

  log "info" "Installing docker-buildx via aur..."
  __install_package_aur docker-buildx

  __as_root groupadd docker
  __as_root usermod -aG docker "$USER"

  log "info" "Enabling docker service..."
  __as_root rc-update add docker default
  __as_root rc-service docker start

  log "success" "Docker installed."
}

install_docker "$@"

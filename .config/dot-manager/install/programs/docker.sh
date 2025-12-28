#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_docker() {
  print_step "Installing docker..."

  log "info" "Installing docker via pacman..."
  __install_package_arch docker docker-openrc docker-compose

  log "info" "Installing docker-buildx via aur..."
  __install_package_aur docker-buildx

  sudo groupadd docker
  sudo usermod -aG docker "$USER"

  log "info" "Enabling docker service..."
  sudo rc-update add docker default
  sudo rc-service docker start

  log "success" "Docker installed."
}

install_docker "$@"

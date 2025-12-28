#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_jackett() {
  print_step "Installing Jackett..."

  if [ -e "/opt/Jackett/jackett" ]; then
    log "info" "Jackett is already installed. Skipping installation."
    return 0
  fi

  log "info" "Installing Jackett..."
  cd /opt ||
    {
      log "error" "Failed to change directory to /opt"
      return 1
    }
  sudo rm -rf Jackett*

  f=Jackett.Binaries.LinuxAMDx64.tar.gz
  sudo wget -Nc https://github.com/Jackett/Jackett/releases/latest/download/"$f"
  sudo tar -xzf "$f" && sudo rm -f "$f"
  cd Jackett* || return
  sudo chown $(whoami):$(id -g) -R "/opt/Jackett"

  log "info" "Enabling jackett service..."
  sudo rc-update add jackett default
  sudo rc-service jackett start

  cd - >/dev/null || return 1
  echo -e "\nVisit http://127.0.0.1:9117"

  log "success" "Jackett installed."
}

install_jackett "$@"

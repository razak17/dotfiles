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
  __as_root rm -rf Jackett*

  f=Jackett.Binaries.LinuxAMDx64.tar.gz
  __as_root wget -Nc https://github.com/Jackett/Jackett/releases/latest/download/"$f"
  __as_root tar -xzf "$f" && __as_root rm -f "$f"
  cd Jackett* || return
  __as_root chown "$(whoami):$(id -g)" -R "/opt/Jackett"

  log "info" "Enabling jackett service..."
  __as_root rc-update add jackett default
  __as_root rc-service jackett start

  cd - >>"$DOT_MANAGER_LOG" 2>&1 || return 1
  echo -e "\nVisit http://127.0.0.1:9117"

  log "success" "Jackett installed."
}

install_jackett "$@"

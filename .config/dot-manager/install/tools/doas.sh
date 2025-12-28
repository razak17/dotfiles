#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

# NOTE: enter root shell before running i.e. su
# dot tool doas "razak"
use_tool_doas() {
  log "info" "Configuring doas..."

  username="$1"

  log "info" "Installing opendoas via pacman..."
  __install_package_arch opendoas

  if [ ! -f /etc/doas.conf ]; then
    log "info" "Creating /etc/doas.conf file..."
    [ -e "/usr/bin/sudo" ] && rm /usr/bin/sudo
    [ -e "/etc/doas.conf" ] && rm /etc/doas.conf
    echo "permit persist keepenv $username as root
  permit nopass $username as root cmd /usr/bin/poweroff
  permit nopass $username as root cmd /usr/bin/reboot
" | sudo tee /etc/doas.conf >/dev/null
  else
    log "info" "/etc/doas.conf already exists. Skipping creation."
  fi

  curl https://raw.githubusercontent.com/razak17/artix-install-script/main/config-files/doas-completion -o /usr/share/bash-completion/completions/doas

  ln -s /usr/bin/doas /usr/bin/sudo

  log "success" "doas configured."
}

use_tool_doas "$@"

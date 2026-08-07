#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

# dot tool doas "razak"
use_tool_doas() {
  local username="${1:-${USER:-}}"
  local completion_file
  local config_file

  log "info" "Configuring doas..."

  if [[ ! "$username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    log "error" "A valid username is required."
    return 1
  fi

  log "info" "Installing opendoas via pacman..."
  __install_package_arch opendoas

  if [ ! -f /etc/doas.conf ]; then
    log "info" "Creating /etc/doas.conf file..."
    config_file=$(mktemp)
    printf '%s\n' \
      "permit persist keepenv $username as root" \
      "permit nopass $username as root cmd /usr/bin/poweroff" \
      "permit nopass $username as root cmd /usr/bin/reboot" >"$config_file"
    if ! __as_root install -m 0400 "$config_file" /etc/doas.conf; then
      rm -f "$config_file"
      log "error" "Failed to install /etc/doas.conf."
      return 1
    fi
    rm -f "$config_file"
  else
    log "info" "/etc/doas.conf already exists. Skipping creation."
  fi

  completion_file=$(mktemp)
  if curl -fsSL https://raw.githubusercontent.com/razak17/artix-install-script/main/config-files/doas-completion -o "$completion_file"; then
    __as_root install -D -m 0644 "$completion_file" /usr/share/bash-completion/completions/doas
  else
    log "info" "Doas completion was unavailable; continuing without it."
  fi
  rm -f "$completion_file"

  log "success" "doas configured."
}

use_tool_doas "$@"

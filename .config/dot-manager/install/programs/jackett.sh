#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

# https://github.com/Jackett/Jackett/

install_jackett() {
  local install_dir="${JACKETT_INSTALL_DIR:-/opt/Jackett}"
  local install_parent
  local init_source="${JACKETT_INIT_SOURCE:-$DOT_MANAGER_DIR/install/services/jackett}"
  local init_target="${JACKETT_INIT_TARGET:-/etc/init.d/jackett}"
  local archive
  local filename="Jackett.Binaries.LinuxAMDx64.tar.gz"

  install_parent=$(dirname "$install_dir")

  print_step "Installing Jackett..."

  if ! getent group jackett >/dev/null 2>&1; then
    log "info" "Creating Jackett service group..."
    if ! __as_root groupadd --system jackett; then
      log "error" "Failed to create the Jackett service group."
      return 1
    fi
  fi

  if ! id -u jackett >/dev/null 2>&1; then
    log "info" "Creating Jackett service user..."
    if ! __as_root useradd --system --gid jackett --home-dir /var/lib/jackett \
      --create-home --shell /usr/bin/nologin jackett; then
      log "error" "Failed to create the Jackett service user."
      return 1
    fi
  fi

  if ! __as_root install -d -o jackett -g jackett -m 0755 /var/lib/jackett; then
    log "error" "Failed to prepare Jackett's data directory."
    return 1
  fi

  if [ ! -x "$install_dir/jackett" ]; then
    log "info" "Downloading Jackett..."
    archive=$(mktemp "/tmp/jackett.XXXXXXXX.tar.gz") || {
      log "error" "Failed to create a temporary file for Jackett."
      return 1
    }

    if ! wget -O "$archive" \
      "https://github.com/Jackett/Jackett/releases/latest/download/$filename"; then
      rm -f "$archive"
      log "error" "Failed to download Jackett."
      return 1
    fi

    if ! __as_root install -d -m 0755 "$install_parent" ||
      ! __as_root tar -xzf "$archive" -C "$install_parent"; then
      rm -f "$archive"
      log "error" "Failed to extract Jackett."
      return 1
    fi
    rm -f "$archive"
  else
    log "info" "Jackett is already installed. Repairing service setup."
  fi

  if ! __as_root chown -R jackett:jackett "$install_dir"; then
    log "error" "Failed to set Jackett application ownership."
    return 1
  fi

  if [ ! -f "$init_source" ]; then
    log "error" "Jackett OpenRC service file not found: $init_source"
    return 1
  fi

  if ! __as_root install -m 0755 "$init_source" "$init_target"; then
    log "error" "Failed to install the Jackett OpenRC service."
    return 1
  fi

  log "info" "Enabling jackett service..."
  if ! __as_root rc-update add jackett default; then
    log "error" "Failed to enable the Jackett service."
    return 1
  fi

  if __as_root rc-service jackett status >/dev/null 2>&1; then
    log "info" "Restarting jackett service..."
    if ! __as_root rc-service jackett restart; then
      log "error" "Failed to restart the Jackett service."
      return 1
    fi
  elif ! __as_root rc-service jackett start; then
    log "error" "Failed to start the Jackett service."
    return 1
  fi

  echo -e "\nVisit http://127.0.0.1:9117"

  log "success" "Jackett installed."
}

# https://github.com/qbittorrent/search-plugins/wiki/How-to-configure-Jackett-plugin#qbittorrent-plugin

install_qbittorrent() {
  print_step "Installing qbittorrent"

  __install_package_arch qbittorrent

  log "success" "qbittorrent installed."
}

install_jackett "$@"
install_qbittorrent "&@"

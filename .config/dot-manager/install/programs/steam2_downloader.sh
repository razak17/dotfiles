#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

# https://github.com/extremebleem/steam2_downloader

steam2_downloader_install_dir() {
  printf '%s\n' "${STEAM2_DOWNLOADER_INSTALL_DIR:-$HOME/.local/lib/steam2-downloader}"
}

steam2_downloader_bin_link() {
  printf '%s\n' "${STEAM2_DOWNLOADER_BIN_LINK:-$HOME/.local/bin/steam2browser}"
}

steam2_downloader_asset() {
  local machine="${STEAM2_DOWNLOADER_MACHINE:-$(uname -m)}"

  case "$machine" in
  x86_64 | amd64) printf '%s\n' 'steam2browser-linux-x64.zip' ;;
  aarch64 | arm64) printf '%s\n' 'steam2browser-linux-arm64.zip' ;;
  *) return 1 ;;
  esac
}

link_steam2_downloader() {
  local install_dir
  local bin_link

  install_dir=$(steam2_downloader_install_dir)
  bin_link=$(steam2_downloader_bin_link)

  mkdir -p "$(dirname "$bin_link")" || {
    log "error" "Failed to create the Steam2 Downloader bin directory."
    return 1
  }

  if ! ln -sfn "$install_dir/steam2browser" "$bin_link"; then
    log "error" "Failed to link steam2browser into $(dirname "$bin_link")."
    return 1
  fi
}

install_steam2_downloader_binary() {
  local install_dir
  local asset
  local url
  local tmp_dir
  local archive
  local extracted_binary

  if ! __is_program_installed wget; then
    log "error" "wget is required to download Steam2 Downloader."
    return 1
  fi
  if ! __is_program_installed unzip; then
    log "error" "unzip is required to install Steam2 Downloader."
    return 1
  fi

  if ! asset=$(steam2_downloader_asset); then
    log "error" "Steam2 Downloader does not provide a Linux build for '${STEAM2_DOWNLOADER_MACHINE:-$(uname -m)}'."
    return 1
  fi
  install_dir=$(steam2_downloader_install_dir)
  url="https://github.com/extremebleem/steam2_downloader/releases/latest/download/$asset"
  tmp_dir=$(mktemp -d) || {
    log "error" "Failed to create a temporary directory for Steam2 Downloader."
    return 1
  }
  archive="$tmp_dir/$asset"
  extracted_binary="$tmp_dir/extracted/steam2browser"

  log "download" "Downloading Steam2 Downloader"
  if ! wget -nv -O "$archive" "$url" >>"$DOT_MANAGER_LOG" 2>&1; then
    rm -rf "$tmp_dir"
    log "error" "Failed to download Steam2 Downloader."
    return 1
  fi

  if ! mkdir -p "$tmp_dir/extracted" ||
    ! unzip -q "$archive" -d "$tmp_dir/extracted" >>"$DOT_MANAGER_LOG" 2>&1; then
    rm -rf "$tmp_dir"
    log "error" "Failed to extract Steam2 Downloader."
    return 1
  fi

  if [ ! -f "$extracted_binary" ]; then
    rm -rf "$tmp_dir"
    log "error" "The Steam2 Downloader archive did not contain steam2browser."
    return 1
  fi

  if ! mkdir -p "$install_dir" ||
    ! cp -a "$tmp_dir/extracted/." "$install_dir/" ||
    ! chmod 0755 "$install_dir/steam2browser"; then
    rm -rf "$tmp_dir"
    log "error" "Failed to install Steam2 Downloader."
    return 1
  fi

  rm -rf "$tmp_dir"
  link_steam2_downloader
}

install_steam2_downloader() {
  local install_dir

  print_step "Installing Steam2 Downloader..."
  install_dir=$(steam2_downloader_install_dir)

  if [ -x "$install_dir/steam2browser" ] &&
    [ -f "$install_dir/steam2browser.dll" ] &&
    [ -f "$install_dir/libhostfxr.so" ]; then
    link_steam2_downloader || return 1
    log "info" "Steam2 Downloader is already installed."
    return 0
  fi

  install_steam2_downloader_binary || return 1
  log "success" "Steam2 Downloader installed."
}

reinstall_steam2_downloader() {
  local install_dir

  print_step "Reinstalling Steam2 Downloader..."
  install_dir=$(steam2_downloader_install_dir)

  if [ ! -x "$install_dir/steam2browser" ]; then
    log "error" "Steam2 Downloader is not installed. Cannot reinstall."
    return 1
  fi

  install_steam2_downloader_binary || return 1
  log "success" "Steam2 Downloader reinstalled."
}

do_program_install() {
  case "$1" in
  install) install_steam2_downloader ;;
  reinstall) reinstall_steam2_downloader ;;
  *)
    log "error" "Unknown action: $1"
    return 1
    ;;
  esac
}

if [ $# -eq 0 ]; then
  do_program_install install
else
  do_program_install "$1"
fi

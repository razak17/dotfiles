#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_browsers() {
  print_step "Installing Browsers"

  log "info" "Installing Firefox..."
  __install_package_arch firefox

  log "info" "Installing Qutebrowser..."
  __install_package_arch qutebrowser

  log "info" "Installing Tor browser..."
  __install_package_arch tor

  log "info" "Installing Helium..."
  __install_package_aur helium-browser-bin

  log "success" "Browsers installed."
}

install_binary() {
  if ! __is_program_installed "curl"; then
    log "error" "curl is required to download AWS CLI."
    return
  fi

  ZEN_APP_IMAGE="ZenBrowser"
  ZEN_APP_IMAGE_DIR="$HOME/.local/share/AppImage"
  ZEN_BIN="zen"

  if [[ "$1" == "twilight" ]]; then
    ZEN_BIN="zen-tw"
    ZEN_APP_IMAGE="ZenTwilight"
  fi

  if [ ! -e "$ZEN_APP_IMAGE_DIR/$ZEN_APP_IMAGE.AppImage" ]; then
    printf "1\n" | bash <(curl https://updates.zen-browser.app/appimage.sh) "$1"
  fi

  [ -e "$HOME/.local/bin/$ZEN_BIN" ] && mv "$HOME/.local/bin/$ZEN_BIN" "$HOME/.local/bin/$ZEN_BIN-$(date +%F_%H%M%S_%N)"
  ln -s "$HOME/.local/share/AppImage/$ZEN_APP_IMAGE.AppImage" "$HOME/.local/bin/$ZEN_BIN"
}

install_zen() {
  ZEN_BIN="zen"

  if [[ "$1" == "twilight" ]]; then
    ZEN_BIN="zen-tw"
  fi

  if [ -e "$HOME/.local/bin/$ZEN_BIN" ]; then
    log "info" "Zen browser already installed. Skipping installation."
    return
  fi

  log "info" "Installing Zen browser..."

  install_binary "$1"

  log "success" "Zen browser installed"
}

reinstall_zen() {
  ZEN_BIN="zen"

  if [[ "$1" == "twilight" ]]; then
    ZEN_BIN="zen-tw"
  fi

  if [ ! -e "$HOME/.local/bin/$ZEN_BIN" ]; then
    log "error" "Zen browser is not installed. Cannot reinstall."
    return
  fi

  log "info" "Reinstalling Zen browser..."

  install_binary "$1"

  log "success" "Zen browser reinstalled."
}

firefox_userjs() {
  print_step "Setting up Firefox user.js"

  if [ ! -d "$HOME/.dots/firefox-user.js" ]; then
    git clone https://github.com/razak17/firefox-user.js "$HOME/.dots/firefox-user.js"
  fi

  if [ -f "$HOME/.local/bin/fuj" ]; then
    log "Removing old firefox user.js symlink."
    rm "$HOME/.local/bin/fuj"
  fi

  log "info" "Creating firefox user.js symlink."
  ln -s "$HOME"/.dots/firefox-user.js/setup.sh "$HOME/.local/bin/fuj"

  cd "$HOME/.dots/firefox-user.js" || return 1

  sh ./setup.sh -all
  sh ./setup.sh -zen-all

  log "success" "Firefox user.js setup completed."
}

do_program_install() {
  case "$1" in
  install)
    install_browsers "$@"
    install_zen "stable" # stable | twilight
    ;;
  zen)
    shift
    if [ "$1" == "install" ]; then
      shift
      if [ $# -eq 0 ]; then
        install_zen "stable"
        return
      fi
      if [ "$1" == "twilight" ] || [ "$1" == "stable" ]; then
        install_zen "$1"
      else
        log "error" "Unknown zen version: $1"
      fi
    elif [ "$1" == "reinstall" ]; then
      shift
      if [ $# -eq 0 ]; then
        reinstall_zen "stable"
        return
      fi
      if [ "$1" == "twilight" ] || [ "$1" == "stable" ]; then
        reinstall_zen "$1"
      else
        log "error" "Unknown zen version: $1"
      fi
    else
      log "error" "Unknown action for zen: $1. Use 'install' or 'reinstall'."
    fi
    ;;
  # zen-twilight) install_zen "twilight" ;;
  userjs) firefox_userjs ;;
  *)
    log "error" "Unknown action: $1"
    return
    ;;
  esac
}

if [ $# -eq 0 ]; then
  install_browsers "$@"
  install_zen "stable" # stable | twilight
  firefox_userjs
else
  do_program_install "$@"
fi

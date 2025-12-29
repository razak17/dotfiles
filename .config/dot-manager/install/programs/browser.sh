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

install_zen() {
  log "info" "Installing Zen browser..."

  ZEN_BIN="zen"
  ZEN_APP_IMAGE="ZenBrowser"

  if [[ "$1" == "twilight" ]]; then
    ZEN_BIN="zen-tw"
    ZEN_APP_IMAGE="ZenTwilight"
  fi

  if [ ! -e "$HOME/.local/share/AppImage/$ZEN_APP_IMAGE.AppImage" ]; then
    bash <(curl https://updates.zen-browser.app/appimage.sh) "$1"
  fi

  [ -e "$HOME/.local/bin/$ZEN_BIN" ] && mv "$HOME/.local/bin/$ZEN_BIN" "$HOME/.local/bin/$ZEN_BIN-$(date +%F_%H%M%S_%N)"
  ln -s "$HOME/.local/share/AppImage/$ZEN_APP_IMAGE.AppImage" "$HOME/.local/bin/$ZEN_BIN"

  log "success" "Zen browser installed"
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

install_browsers "$@"
install_zen "stable" # stable | twilight
firefox_userjs

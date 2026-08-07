#!/bin/env bash

mkdir -p "$HOME"/.dots

__BOOTSTRAP_PRIVILEGE_RESOLVED=0
__BOOTSTRAP_PRIVILEGE_BIN=""

__bootstrap_as_root() {
  local requested="${DOT_PRIVILEGE_CMD:-}"

  if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    "$@"
    return
  fi

  if [ "$__BOOTSTRAP_PRIVILEGE_RESOLVED" -eq 0 ]; then
    if [ -n "$requested" ]; then
      case "$requested" in
      doas | sudo) ;;
      *)
        echo "[ERROR] DOT_PRIVILEGE_CMD must be 'doas' or 'sudo'." >&2
        return 1
        ;;
      esac
      command -v "$requested" >/dev/null 2>&1 || {
        echo "[ERROR] DOT_PRIVILEGE_CMD '$requested' is not available." >&2
        return 1
      }
      __BOOTSTRAP_PRIVILEGE_BIN=$(command -v "$requested")
    elif command -v doas >/dev/null 2>&1; then
      __BOOTSTRAP_PRIVILEGE_BIN=$(command -v doas)
    elif command -v sudo >/dev/null 2>&1; then
      __BOOTSTRAP_PRIVILEGE_BIN=$(command -v sudo)
    else
      echo "[ERROR] Neither doas nor sudo is available for privileged commands." >&2
      return 1
    fi
    __BOOTSTRAP_PRIVILEGE_RESOLVED=1
  fi

  "$__BOOTSTRAP_PRIVILEGE_BIN" "$@"
}

__echo_info() {
  echo "[INFO] $(tput setaf 6)$1"
  tput sgr 0
}

install_essentials() {
  __bootstrap_as_root pacman -S --noconfirm --needed \
    git \
    wget \
    zsh \
    base-devel \
    curl \
    jq

  __bootstrap_as_root pacman -S --noconfirm --needed \
    automake \
    autoconf \
    cmake
}

conf() {
  /usr/bin/git --git-dir="$HOME/.dots/dotfiles/" --work-tree="$HOME" "$@"
}

install_dotfiles() {
  if [ -d "$HOME/.dots/dotfiles" ]; then
    echo 'Dotfiles directory already exists. Exiting...'
    return
  fi

  __echo_info "Configuring dotfiles"

  mkdir -p "$HOME"/.dots/dotfiles

  if [ "$GIT_CLONE_METHOD" = "ssh" ]; then
    echo "Using SSH to clone dotfiles"
    git clone --bare --branch doas git@github.com:razak17/dotfiles.git "$HOME"/.dots/dotfiles
  else
    echo "Using HTTPS to clone dotfiles"
    git clone --bare --branch doas https://github.com/razak17/dotfiles.git "$HOME"/.dots/dotfiles
  fi

  conf checkout -f
  conf reset --hard HEAD
  conf config --local status.showUntrackedFiles no
}

prepare_dotfiles() {
  __echo_info "Preparing dotfiles"

  __echo_info "Creating $HOME/.local/bin"
  mkdir -p "$HOME/.local/bin"

  ln -sf "$HOME/.config/dot-manager/dot.sh" "$HOME/.local/bin/dot"
}

install_essentials
install_dotfiles
prepare_dotfiles

"$HOME"/.config/dot-manager/dot.sh init

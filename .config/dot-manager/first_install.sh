#!/bin/env bash

mkdir -p "$HOME"/.dots

__echo_info() {
  echo "[INFO] $(tput setaf 6)$1"
  tput sgr 0
}

install_essentials() {
  sudo pacman -S --noconfirm --needed \
    git \
    wget \
    zsh \
    base-devel \
    curl \
    jq

  sudo pacman -S --noconfirm --needed \
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
    git clone --bare git@github.com:razak17/dotfiles.git "$HOME"/.dots/dotfiles
  else
    echo "Using HTTPS to clone dotfiles"
    git clone --bare https://github.com/razak17/dotfiles.git "$HOME"/.dots/dotfiles
  fi

  conf checkout -f
  conf reset --hard HEAD
  conf config --local status.showUntrackedFiles no
}

prepare_dotfiles() {
  __echo_info "Preparing dotfiles"

  if [ ! -d "$HOME/.local/bin" ]; then
    __echo_info "Creating $HOME/.local/bin"
    mkdir -p "$HOME/.local/bin"
  fi

  dot_script_path="$HOME/.config/dot-manager/dot.sh"
  dot_script_link="$HOME/.local/bin/dot"

  if [ -L "$dot_script_link" ]; then
    __echo_info "Removing old dot symlink"
    rm "$dot_script_link"
  fi

  if [ ! -L "$dot_script_link" ] || [ ! -e "$dot_script_link" ]; then
    ln -s "$dot_script_path" "$dot_script_link"
  fi
}

install_essentials
install_dotfiles
prepare_dotfiles

"$HOME"/.config/dot-manager/dot.sh init

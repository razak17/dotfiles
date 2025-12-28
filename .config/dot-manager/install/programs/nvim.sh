#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_luarocks() {
  print_step "Installing LuaRocks..."

  ROCKS_VERSION=$(__get_latest_release "luarocks/luarocks")
  url="https://github.com/luarocks/luarocks/releases/download/$ROCKS_VERSION/luarocks-${ROCKS_VERSION#v}.tar.gz"

  log "download" "Downloading LuaRocks"
  cd /tmp || return 1
  wget -nv -q "$url" >/dev/null && log "success" "Downloaded LuaRocks." || return 1

  tar zxpf /tmp/luarocks-"${ROCKS_VERSION#v}".tar.gz && log "success" "Extracted LuaRocks." || return 1
  rm /tmp/luarocks-"${ROCKS_VERSION#v}".tar.gz
  cd /tmp/luarocks-"${ROCKS_VERSION#v}" || return 1
  ./configure --prefix="$HOME/.local" >/dev/null
  make build >/dev/null
  make install >/dev/null
  cd - >/dev/null || return 1
  rm -rf /tmp/luarocks-"${ROCKS_VERSION#v}" >/dev/null

  ROCKS_BIN=$(which luarocks)
  if [ "$ROCKS_BIN" != "$HOME/.local/bin/luarocks" ]; then
    log "info" "luarocks is now installed in $HOME/.local/bin/. Renaming old luarocks shim."
    [ "$ROCKS_BIN" == "$HOME/.asdf/shims/luarocks" ] && mv "$HOME/.asdf/shims/luarocks" "$HOME/.asdf/shims/luarocks-old"
  fi

  log "success" "LuaRocks installed."
}

install_treesitter() {
  print_step "Installing treesitter..."

  TS_VERSION=$(__get_latest_release "tree-sitter/tree-sitter")

  __install_package_release "https://github.com/tree-sitter/tree-sitter/releases/download/$TS_VERSION/tree-sitter-linux-x64.gz" "tree-sitter"

  log "success" "treesitter installed.""
}

install_neovide() {
  print_step "Installing Neovide..."

  __install_package_arch neovide

  log "success" "Neovide installed."
  end
}

install_nvim() {
  print_step "Installing Neovim..."

  NEOVIM_DIR="$HOME/.dots/neovim"

  [ ! -d "$NEOVIM_DIR" ] && git clone https://github.com/neovim/neovim "$NEOVIM_DIR"
  cd "$NEOVIM_DIR" || return 1

  git checkout master
  git pull

  [ -d "$NEOVIM_DIR/build/" ] && sudo rm -r ./build/ # clear the CMake cache
  sudo make CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/neovim"
  sudo make install

  [ -e "$HOME/.local/bin/nvim" ] && mv "$HOME/.local/bin/nvim" "$HOME/.local/bin/nvim-$(date +%F_%H%M%S_%N)"
  ln -s "$HOME/neovim/bin/nvim" "$HOME/.local/bin/nvim"
  cd - >/dev/null || return 1

  log "success" "Neovim installed."
}

install_luarocks
install_treesitter
install_neovide
install_nvim "$@"

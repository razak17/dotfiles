#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_luarocks() (
  print_step "Installing LuaRocks..."

  if command -v luarocks >>"$DOT_MANAGER_LOG" 2>&1; then
    log "info" "LuaRocks is already installed."
    return
  fi

  local rocks_version version archive_url tmp_dir archive source_dir

  rocks_version=$(__get_latest_release "luarocks/luarocks")
  if [ -z "$rocks_version" ]; then
    log "error" "Failed to determine the latest LuaRocks release."
    return 1
  fi

  version=${rocks_version#v}
  archive_url="https://luarocks.github.io/luarocks/releases/luarocks-$version.tar.gz"
  tmp_dir=$(mktemp -d /tmp/dot-manager-luarocks.XXXXXX) || {
    log "error" "Failed to create a temporary directory for LuaRocks."
    return 1
  }
  trap 'rm -rf -- "$tmp_dir"' EXIT
  archive="$tmp_dir/luarocks-$version.tar.gz"
  source_dir="$tmp_dir/luarocks-$version"

  log "download" "Downloading LuaRocks"
  if ! wget -nv -O "$archive" "$archive_url" >>"$DOT_MANAGER_LOG" 2>&1; then
    log "error" "Failed to download LuaRocks $version."
    return 1
  fi
  log "success" "Downloaded LuaRocks."

  if ! tar -xzf "$archive" -C "$tmp_dir" >>"$DOT_MANAGER_LOG" 2>&1; then
    log "error" "Failed to extract LuaRocks $version."
    return 1
  fi
  log "success" "Extracted LuaRocks."

  if ! cd "$source_dir"; then
    log "error" "LuaRocks source directory is missing after extraction."
    return 1
  fi

  if ! ./configure --prefix="$HOME/.local" >>"$DOT_MANAGER_LOG" 2>&1 ||
    ! make build >>"$DOT_MANAGER_LOG" 2>&1 ||
    ! make install >>"$DOT_MANAGER_LOG" 2>&1; then
    log "error" "Failed to build or install LuaRocks. (details: $DOT_MANAGER_LOG)"
    return 1
  fi

  if [ ! -x "$HOME/.local/bin/luarocks" ]; then
    log "error" "LuaRocks installation completed without creating the executable."
    return 1
  fi

  log "success" "LuaRocks installed."
)

install_treesitter() {
  print_step "Installing treesitter..."

  if command -v tree-sitter >>"$DOT_MANAGER_LOG" 2>&1; then
    log "info" "treesitter is already installed."
    return
  fi

  local ts_version asset_arch
  ts_version=$(__get_latest_release "tree-sitter/tree-sitter")
  if [ -z "$ts_version" ]; then
    log "error" "Failed to determine the latest tree-sitter release."
    return 1
  fi

  case $(uname -m) in
  x86_64) asset_arch=x64 ;;
  aarch64 | arm64) asset_arch=arm64 ;;
  *)
    log "error" "Unsupported architecture for tree-sitter: $(uname -m)"
    return 1
    ;;
  esac

  if ! __install_package_release "https://github.com/tree-sitter/tree-sitter/releases/download/$ts_version/tree-sitter-linux-$asset_arch.gz" "tree-sitter"; then
    log "error" "Failed to install treesitter."
    return 1
  fi

  log "success" "treesitter installed."
}

install_neovide() {
  print_step "Installing Neovide..."

  if ! __install_package_arch neovide; then
    log "error" "Failed to install Neovide."
    return 1
  fi

  log "success" "Neovide installed."
}

install_nvim() (
  print_step "Installing Neovim..."

  if command -v nvim >>"$DOT_MANAGER_LOG" 2>&1; then
    log "info" "Neovim is already installed."
    return
  fi

  local neovim_dir old_nvim
  neovim_dir="$HOME/.dots/neovim"

  if [ ! -d "$neovim_dir/.git" ]; then
    if [ -e "$neovim_dir" ]; then
      log "error" "$neovim_dir exists but is not a Git repository."
      return 1
    fi
    if ! git clone https://github.com/neovim/neovim "$neovim_dir" >>"$DOT_MANAGER_LOG" 2>&1; then
      log "error" "Failed to clone Neovim."
      return 1
    fi
  fi
  cd "$neovim_dir" || return 1

  if ! git checkout master >>"$DOT_MANAGER_LOG" 2>&1 ||
    ! git pull --ff-only >>"$DOT_MANAGER_LOG" 2>&1; then
    log "error" "Failed to update the Neovim source tree."
    return 1
  fi

  if [ -d "$neovim_dir/build" ] && ! rm -rf -- "$neovim_dir/build"; then
    log "info" "Removing a privileged Neovim build directory."
    __as_root rm -rf -- "$neovim_dir/build" || return 1
  fi
  if ! make CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/neovim" >>"$DOT_MANAGER_LOG" 2>&1 ||
    ! make install >>"$DOT_MANAGER_LOG" 2>&1; then
    log "error" "Failed to build or install Neovim. (details: $DOT_MANAGER_LOG)"
    return 1
  fi

  if [ ! -x "$HOME/neovim/bin/nvim" ]; then
    log "error" "Neovim installation completed without creating the executable."
    return 1
  fi

  mkdir -p "$HOME/.local/bin" || return 1
  if [ -e "$HOME/.local/bin/nvim" ] || [ -L "$HOME/.local/bin/nvim" ]; then
    old_nvim="$HOME/.local/bin/nvim-$(date +%F_%H%M%S_%N)"
    mv -- "$HOME/.local/bin/nvim" "$old_nvim" || return 1
  fi
  ln -s "$HOME/neovim/bin/nvim" "$HOME/.local/bin/nvim" || return 1
  cd - >>"$DOT_MANAGER_LOG" 2>&1 || return 1

  log "success" "Neovim installed."
)

install_rvim() {
  print_step "Installing rVim.."

  if command -v rvim >>"$DOT_MANAGER_LOG" 2>&1; then
    log "info" "rVim is already installed."
    return
  fi

  if [ ! -d "$HOME/.config/rvim" ]; then
    if ! git clone https://github.com/razak17/nvim "$HOME/.config/rvim" >>"$DOT_MANAGER_LOG" 2>&1; then
      log "error" "Failed to clone rVim."
      return 1
    fi
  fi

  if [ ! -x "$HOME/.config/rvim/bin/rvim" ]; then
    log "error" "The rVim launcher is missing or is not executable."
    return 1
  fi

  mkdir -p "$HOME/.local/bin" || return 1
  if [ -e "$HOME/.local/bin/rvim" ] || [ -L "$HOME/.local/bin/rvim" ]; then
    log "Removing old rVim symlink."
    rm -- "$HOME/.local/bin/rvim" || return 1
  fi

  log "info" "Creating rVim symlink."
  ln -s "$HOME/.config/rvim/bin/rvim" "$HOME/.local/bin/rvim" || return 1

  log "success" "rVim installed."
}

update_plugins() {
  print_step "Updating Neovim plugins..."

  if ! nvim --headless "+Lazy! sync" "+qall" >>"$DOT_MANAGER_LOG" 2>&1; then
    log "error" "Failed to update Neovim plugins."
    return 1
  fi
  log "success" "Neovim plugins updated."

  if ! rvim -no-min -ts-extra --coding --lsp --ai -nice --headless "+Lazy! sync" "+qall" >>"$DOT_MANAGER_LOG" 2>&1; then
    log "error" "Failed to update rVim plugins."
    return 1
  fi
  log "success" "rVim plugins updated."
}

main() {
  install_luarocks || return 1
  install_treesitter || return 1
  install_neovide || return 1
  install_nvim || return 1
  install_rvim || return 1
  # update_plugins || return 1
}

main "$@"

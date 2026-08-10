#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_mise() {
  print_step "Installing mise..."

  if __is_program_installed "mise"; then
    log "info" "mise is already installed. Skipping installation."
    return
  fi

  if ! curl https://mise.run | sh >>"$DOT_MANAGER_LOG" 2>&1; then
    log "error" "Failed to install mise."
    return 1
  fi

  log "success" "mise installed."
}

mise_completion() {
  log "info" "Setting up mise completions..."

  log "info" "Installing usage cli for mise completions..."
  mise use -g usage

  log "info" "Setting up mise completions..."
  if [ -f "$HOME/.config/zsh/plugins/mise/_mise" ]; then
    log "info" "Removing old mise completions."
    rm "$HOME/.config/zsh/plugins/mise/_mise"
  fi

  mise completion zsh >"$HOME/.config/zsh/plugins/mise/_mise"
  [ -f "$HOME/.cache/zsh/zcompdump" ] && rm "$HOME/.cache/zsh/zcompdump"

  log "success" "mise completions set up."
}

install_node() {
  log "info" "Installing Node.js LTS via mise..."

  if ! mise use -g node@lts; then
    log "error" "Failed to install Node.js LTS via mise."
    return 1
  fi

  log "success" "Node.js LTS installed."
}

install_pnpm() {
  log "info" "Installing pnpm via mise..."

  if ! mise use -g pnpm@latest; then
    log "error" "Failed to install pnpm via mise."
    return 1
  fi

  log "success" "pnpm installed."
}

install_go() {
  log "info" "Installing Go 1.26 via mise..."

  if ! mise use -g go@1.26; then
    log "error" "Failed to install Go 1.26 via mise."
    return 1
  fi

  log "success" "Go 1.26 installed."
}

install_lua() {
  log "info" "Installing Lua 5.1 via mise..."

  if ! mise use -g lua@5.1; then
    log "error" "Failed to install Lua 5.1 via mise."
    return 1
  fi

  log "success" "Lua 5.1 installed."
}

install_rust() {
  log "info" "Installing stable Rust via mise..."

  if ! mise use -g rust@latest; then
    log "error" "Failed to install stable Rust via mise."
    return 1
  fi

  log "success" "Stable Rust installed."
}

install_bun() {
  log "info" "Installing Bun via mise..."

  if ! mise use -g bun@latest; then
    log "error" "Failed to install Bun via mise."
    return 1
  fi

  log "info" "Setting up Bun completions..."
  if [ -f "$HOME/.config/zsh/plugins/bun/_bun" ]; then
    log "info" "Removing old Bun completions."
    rm "$HOME/.config/zsh/plugins/bun/_bun"
  fi

  bun completions zsh >"$HOME/.config/zsh/plugins/bun/_bun"

  [ -f "$HOME/.cache/zsh/zcompdump" ] && rm "$HOME/.cache/zsh/zcompdump"

  log success "Bun installed."
}

install_deno() {
  log "info" "Installing Deno via mise..."

  mise use -g deno@latest

  log "info" "Setting up Deno completions..."
  if [ -f "$HOME/.config/zsh/plugins/deno/_deno" ]; then
    log "info" "Removing old Deno completions."
    rm "$HOME/.config/zsh/plugins/deno/_deno"
  fi

  deno completions zsh >"$HOME/.config/zsh/plugins/deno/_deno"

  [ -f "$HOME/.cache/zsh/zcompdump" ] && rm "$HOME/.cache/zsh/zcompdump"

  log success "Deno installed."
}

install_python() {
  log "info" "Installing Python via mise..."

  MISE_PYTHON_GITHUB_ATTESTATIONS=false mise use -g python@3.11.9 python@3.14.2

  log success "Python installed."
}

install_uv() {
  log "info" "Installing uv plugin for mise..."

  mise use -g uv@latest

  log "info" "Seting up uv completions..."
  if [ -f "$HOME/.config/zsh/plugins/uv/_uv" ]; then
    log "info" "Removing old uv completions."
    rm "$HOME/.config/zsh/plugins/uv/_uv"
  fi

  uv generate-shell-completion zsh >"$HOME/.config/zsh/plugins/uv/_uv"

  [ -f "$HOME/.cache/zsh/zcompdump" ] && rm "$HOME/.cache/zsh/zcompdump"

  log success "uv installed."
}

install_zig() {
  log "info" "Installing Zig via mise..."

  mise use -g zig@latest

  log "info" "Setting up Zig completions..."
  if [ -f "$HOME/.config/zsh/plugins/zig/_zig" ]; then
    log "info" "Removing old Zig completions."
    rm "$HOME/.config/zsh/plugins/zig/_zig"
  fi

  curl -LO "https://codeberg.org/ziglang/shell-completions/raw/branch/master/_zig"
  mv "_zig" "$HOME/.config/zsh/plugins/zig/_zig"

  [ -f "$HOME/.cache/zsh/zcompdump" ] && rm "$HOME/.cache/zsh/zcompdump"

  log success "Zig installed."
}

install_mise "$@"

if ! command -v mise >>"$DOT_MANAGER_LOG" 2>&1; then
  log "error" "mise is not installed. Please install mise first."
  return 1
fi

mise_completion
install_node
install_pnpm
install_go
install_lua
install_rust
install_bun
install_python
install_uv

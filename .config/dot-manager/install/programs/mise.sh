#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_mise() {
  print_step "Installing mise..."

  if __is_program_installed "mise"; then
    log "info" "mise is already installed. Skipping installation."
    return
  fi

  curl https://mise.run | sh
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

install_bun() {
  log "info" "Installing Bun via mise..."

  mise use -g bun@latest

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

  mise use -g python@3.11.9 python@3.14.2

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

if ! command -v mise &>/dev/null; then
  log "error" "mise is not installed. Please install mise first."
  return 1
fi

mise_completion
install_bun
install_deno
install_python
install_uv
install_zig

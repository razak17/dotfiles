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
  mkdir -p "$HOME/.config/zsh/plugins/bun"
  if [ -f "$HOME/.config/zsh/plugins/bun/_bun" ]; then
    log "info" "Removing old Bun completions."
    rm "$HOME/.config/zsh/plugins/bun/_bun"
  fi

  if ! mise exec -- bun completions zsh >"$HOME/.config/zsh/plugins/bun/_bun"; then
    log "error" "Failed to generate Bun completions."
    return 1
  fi

  [ -f "$HOME/.cache/zsh/zcompdump" ] && rm "$HOME/.cache/zsh/zcompdump"

  log success "Bun installed."
}

install_deno() {
  log "info" "Installing Deno via mise..."

  if ! mise use -g deno@latest; then
    log "error" "Failed to install Deno via mise."
    return 1
  fi

  log "info" "Setting up Deno completions..."
  mkdir -p "$HOME/.config/zsh/plugins/deno"
  if [ -f "$HOME/.config/zsh/plugins/deno/_deno" ]; then
    log "info" "Removing old Deno completions."
    rm "$HOME/.config/zsh/plugins/deno/_deno"
  fi

  if ! mise exec -- deno completions zsh >"$HOME/.config/zsh/plugins/deno/_deno"; then
    log "error" "Failed to generate Deno completions."
    return 1
  fi

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

  if ! mise use -g uv@latest; then
    log "error" "Failed to install uv via mise."
    return 1
  fi

  log "info" "Seting up uv completions..."
  mkdir -p "$HOME/.config/zsh/plugins/uv"
  if [ -f "$HOME/.config/zsh/plugins/uv/_uv" ]; then
    log "info" "Removing old uv completions."
    rm "$HOME/.config/zsh/plugins/uv/_uv"
  fi

  if ! mise exec -- uv generate-shell-completion zsh >"$HOME/.config/zsh/plugins/uv/_uv"; then
    log "error" "Failed to generate uv completions."
    return 1
  fi

  [ -f "$HOME/.cache/zsh/zcompdump" ] && rm "$HOME/.cache/zsh/zcompdump"

  log success "uv installed."
}

install_cli_tools() {
  local tools=(
    aws-cli@latest
    duckdb@latest
    npm:skills@latest
    stripe@latest
    opencode@latest
    yt-dlp@latest
  )

  log "info" "Installing CLI tools via mise..."

  if ! mise use -g "${tools[@]}"; then
    log "error" "Failed to install one or more CLI tools via mise."
    return 1
  fi

  log "success" "CLI tools installed."
}

restore_agent_skills() {
  local lock_file="$HOME/.agents/.skill-lock.json"
  local source
  local -a agents
  local -a skill_names
  local -a sources

  if [ -n "${XDG_STATE_HOME:-}" ]; then
    lock_file="$XDG_STATE_HOME/skills/.skill-lock.json"
  fi

  if [ ! -f "$lock_file" ]; then
    log "info" "No global skills lockfile found. Skipping agent skill restore."
    return
  fi

  if ! command -v jq >>"$DOT_MANAGER_LOG" 2>&1; then
    log "error" "jq is required to restore agent skills from $lock_file."
    return 1
  fi

  if ! jq -e '
    .version == 3 and
    (.skills | type == "object") and
    (.lastSelectedAgents | type == "array") and
    ((.skills | length) == 0 or (.lastSelectedAgents | length) > 0) and
    all(.lastSelectedAgents[]; type == "string" and length > 0) and
    all(.skills | to_entries[];
      (.key | type == "string" and length > 0) and
      ((.value.sourceUrl // .value.source) | type == "string" and length > 0)
    )
  ' "$lock_file" >>"$DOT_MANAGER_LOG" 2>&1; then
    log "error" "Global skills lockfile is invalid: $lock_file"
    return 1
  fi

  mapfile -t sources < <(
    jq -r '.skills | to_entries | map(.value.sourceUrl // .value.source) | unique[]' "$lock_file"
  )

  if [ "${#sources[@]}" -eq 0 ]; then
    log "info" "No global agent skills are recorded in $lock_file."
    return
  fi

  mapfile -t agents < <(jq -r '.lastSelectedAgents[]' "$lock_file")

  log "info" "Restoring global agent skills from $lock_file..."

  for source in "${sources[@]}"; do
    mapfile -t skill_names < <(
      jq -r --arg source "$source" '
        .skills | to_entries[] |
        select((.value.sourceUrl // .value.source) == $source) |
        .key
      ' "$lock_file"
    )

    if ! mise exec -- skills add "$source" \
      --skill "${skill_names[@]}" \
      --agent "${agents[@]}" \
      --global --yes --full-depth; then
      log "error" "Failed to restore agent skills from $source."
      return 1
    fi
  done

  log "success" "Global agent skills restored."
}

install_zig() {
  log "info" "Installing Zig via mise..."

  if ! mise use -g zig@latest; then
    log "error" "Failed to install Zig via mise."
    return 1
  fi

  log "info" "Setting up Zig completions..."
  mkdir -p "$HOME/.config/zsh/plugins/zig"
  if [ -f "$HOME/.config/zsh/plugins/zig/_zig" ]; then
    log "info" "Removing old Zig completions."
    rm "$HOME/.config/zsh/plugins/zig/_zig"
  fi

  if ! curl -fsSL "https://codeberg.org/ziglang/shell-completions/raw/branch/master/_zig" \
    -o "$HOME/.config/zsh/plugins/zig/_zig"; then
    log "error" "Failed to download Zig completions."
    return 1
  fi

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
install_deno
install_python
install_uv
install_zig
install_cli_tools
restore_agent_skills

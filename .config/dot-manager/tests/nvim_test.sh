#!/usr/bin/env bash

set -euo pipefail

TEST_ROOT=$(mktemp -d)
trap 'rm -rf "$TEST_ROOT"' EXIT

DOT_MANAGER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
DOTFILES_HOME=$(cd "$DOT_MANAGER_ROOT/../.." && pwd)
LAUNCHER="$DOT_MANAGER_ROOT/bin/nvim-stable"
ARGS_FILE="$TEST_ROOT/mise-args"

mkdir -p "$TEST_ROOT/home/.local/bin"
cp "$DOT_MANAGER_ROOT/tests/fixtures/fake-mise" "$TEST_ROOT/home/.local/bin/mise"
chmod +x "$TEST_ROOT/home/.local/bin/mise"

HOME="$TEST_ROOT/home" NVIM_TEST_ARGS_FILE="$ARGS_FILE" \
  "$LAUNCHER" --headless '+qall'

expected=$(printf 'exec\nneovim@stable\n--\nnvim\n--headless\n+qall\n')
actual=$(cat "$ARGS_FILE")
if [ "$actual" != "$expected" ]; then
  printf 'Unexpected stable Neovim launcher arguments:\n%s\n' "$actual" >&2
  exit 1
fi

grep -q 'mise install --force neovim@stable' \
  "$DOT_MANAGER_ROOT/install/programs/mise.sh"
grep -q 'install_stable_nvim_launcher' \
  "$DOT_MANAGER_ROOT/install/programs/nvim.sh"
grep -q 'neovim-bin = "nvim-stable"' \
  "$DOTFILES_HOME/.config/neovide/config.toml"
grep -q '^nvimuse() {' "$DOTFILES_HOME/.config/zsh/scripts/utils"

printf 'Neovim tests passed\n'

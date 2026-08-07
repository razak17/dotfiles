#!/usr/bin/env bash

set -euo pipefail

TEST_ROOT=$(mktemp -d)
trap 'rm -rf "$TEST_ROOT"' EXIT

DOT_MANAGER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
UNINSTALL_SCRIPT="$DOT_MANAGER_ROOT/uninstall.sh"
FIXTURE_HOME="$TEST_ROOT/home"
SOURCE_REPO="$TEST_ROOT/source"
SUBMODULE_REPO="$TEST_ROOT/submodule"
BARE_REPO="$FIXTURE_HOME/.dots/dotfiles"

git_identity() {
  git -C "$1" config user.name 'Dot Manager Test'
  git -C "$1" config user.email 'dot-manager@example.invalid'
}

create_fixture() {
  mkdir -p "$SUBMODULE_REPO"
  git -C "$SUBMODULE_REPO" init -q
  git_identity "$SUBMODULE_REPO"
  printf 'tracked plugin\n' >"$SUBMODULE_REPO/tracked-plugin.zsh"
  git -C "$SUBMODULE_REPO" add tracked-plugin.zsh
  git -C "$SUBMODULE_REPO" commit -qm 'add plugin fixture'

  mkdir -p "$SOURCE_REPO"
  git -C "$SOURCE_REPO" init -q
  git_identity "$SOURCE_REPO"
  mkdir -p "$SOURCE_REPO/.config/app" "$SOURCE_REPO/.local/share/example"
  printf 'tracked config\n' >"$SOURCE_REPO/.config/app/config file"
  printf 'tracked data\n' >"$SOURCE_REPO/.local/share/example/data"
  printf 'readme\n' >"$SOURCE_REPO/README.md"
  ln -s 'config file' "$SOURCE_REPO/.config/app/current"
  git -C "$SOURCE_REPO" add .config .local README.md
  git -C "$SOURCE_REPO" commit -qm 'add dotfile fixture'
  git -C "$SOURCE_REPO" -c protocol.file.allow=always \
    submodule add -q "$SUBMODULE_REPO" .config/plugins/example
  git -C "$SOURCE_REPO" commit -qam 'add submodule fixture'

  mkdir -p "$FIXTURE_HOME/.dots"
  git clone -q --bare "$SOURCE_REPO" "$BARE_REPO"
  git --git-dir="$BARE_REPO" --work-tree="$FIXTURE_HOME" checkout -qf
  git clone -q "$SUBMODULE_REPO" "$FIXTURE_HOME/.config/plugins/example"

  printf 'keep me\n' >"$FIXTURE_HOME/.config/app/untracked"
  printf 'keep plugin data\n' >"$FIXTURE_HOME/.config/plugins/example/untracked-plugin"
  mkdir -p "$FIXTURE_HOME/.local/bin"
  ln -s "$UNINSTALL_SCRIPT" "$FIXTURE_HOME/.local/bin/dot"
}

run_uninstall() {
  env \
    HOME="$FIXTURE_HOME" \
    DOT_MANAGER_GIT_DIR="$BARE_REPO" \
    DOT_MANAGER_WORK_TREE="$FIXTURE_HOME" \
    bash "$UNINSTALL_SCRIPT" "$@"
}

create_fixture

run_uninstall --dry-run >"$TEST_ROOT/dry-run.out"
grep -q 'Would remove: .config/app/config file' "$TEST_ROOT/dry-run.out"
grep -q 'Would remove: .config/plugins/example/tracked-plugin.zsh' "$TEST_ROOT/dry-run.out"
[[ -f "$FIXTURE_HOME/.config/app/config file" ]]
[[ -f "$FIXTURE_HOME/.config/app/untracked" ]]

printf 'modified\n' >>"$FIXTURE_HOME/.config/app/config file"
if run_uninstall --dry-run >"$TEST_ROOT/dirty.out" 2>&1; then
  printf 'Dirty tracked file unexpectedly allowed uninstall\n' >&2
  exit 1
fi
grep -q 'tracked changes' "$TEST_ROOT/dirty.out"
git --git-dir="$BARE_REPO" --work-tree="$FIXTURE_HOME" checkout -qf -- .

if printf 'WRONG\n' | run_uninstall >"$TEST_ROOT/confirm.out" 2>&1; then
  printf 'Incorrect confirmation unexpectedly allowed uninstall\n' >&2
  exit 1
fi
grep -q 'Confirmation did not match' "$TEST_ROOT/confirm.out"
[[ -f "$FIXTURE_HOME/.config/app/config file" ]]

target_count=$(run_uninstall --dry-run | sed -n 's/^Tracked targets: \([0-9][0-9]*\)$/\1/p')
[[ -n "$target_count" ]]
printf 'REMOVE %s TRACKED FILES\n' "$target_count" | run_uninstall >"$TEST_ROOT/uninstall.out"

[[ ! -e "$FIXTURE_HOME/.config/app/config file" ]]
[[ ! -L "$FIXTURE_HOME/.config/app/current" ]]
[[ ! -e "$FIXTURE_HOME/.local/share/example/data" ]]
[[ ! -e "$FIXTURE_HOME/README.md" ]]
[[ ! -e "$FIXTURE_HOME/.config/plugins/example/tracked-plugin.zsh" ]]
[[ -f "$FIXTURE_HOME/.config/app/untracked" ]]
[[ -f "$FIXTURE_HOME/.config/plugins/example/untracked-plugin" ]]
[[ -d "$BARE_REPO" ]]
[[ -L "$FIXTURE_HOME/.local/bin/dot" ]]
grep -q 'checkout-index --all --force' "$TEST_ROOT/uninstall.out"

git --git-dir="$BARE_REPO" --work-tree="$FIXTURE_HOME" checkout-index --all --force
git -C "$FIXTURE_HOME" --git-dir="$BARE_REPO" --work-tree="$FIXTURE_HOME" \
  -c core.bare=false -c protocol.file.allow=always \
  submodule update -q --init --recursive --force
[[ -f "$FIXTURE_HOME/.config/app/config file" ]]
[[ -f "$FIXTURE_HOME/.config/plugins/example/tracked-plugin.zsh" ]]
[[ -f "$FIXTURE_HOME/.config/app/untracked" ]]
[[ -f "$FIXTURE_HOME/.config/plugins/example/untracked-plugin" ]]

printf 'Uninstall tests passed\n'

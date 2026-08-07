#!/usr/bin/env bash

set -euo pipefail

TEST_ROOT=$(mktemp -d)
trap 'rm -rf "$TEST_ROOT"' EXIT

DOT_MANAGER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
DOTFILES_HOME=$(cd "$DOT_MANAGER_ROOT/../.." && pwd)
SHARED_ENV="$DOTFILES_HOME/.config/shell/environment.sh"
COMPLETION_MODULE="$DOTFILES_HOME/.config/zsh/modules/compe"
ALIASES_MODULE="$DOTFILES_HOME/.config/zsh/modules/aliases"

[[ -f "$SHARED_ENV" ]]
/bin/sh -n "$SHARED_ENV"

env -i \
  HOME="$TEST_ROOT/home" \
  PATH=/usr/local/bin:/usr/bin:/bin \
  /bin/sh -c '
    . "$1"
    test "$XDG_CONFIG_HOME" = "$HOME/.config"
    test "$XDG_CACHE_HOME" = "$HOME/.cache"
    test "$ZDOTDIR" = "$HOME/.config/zsh"
    test "$ZSH_CACHE_DIR" = "$HOME/.cache/zsh"
  ' _ "$SHARED_ENV"

env -i \
  HOME="$TEST_ROOT/home" \
  PATH=/usr/local/bin:/usr/bin:/bin \
  /usr/bin/zsh -dfc '
    source "$1"
    source "$2"
    zstyle -a :chpwd: recent-dirs-file reply
    [[ ${reply[1]} == "$HOME/.cache/zsh/"* ]]
  ' _ "$SHARED_ENV" "$COMPLETION_MODULE"

grep -q 'ZDOTDIR/.zshenv' "$DOTFILES_HOME/.zshenv"
grep -q 'config/shell/environment.sh' "$DOTFILES_HOME/.config/zsh/.zshenv"
grep -q 'config/shell/environment.sh' "$DOTFILES_HOME/.config/x11/xprofile"
grep -q 'config/shell/environment.sh' \
  "$DOTFILES_HOME/.config/plasma-workspace/env/10-environment.sh"

/usr/bin/zsh -n "$ALIASES_MODULE"
if rg -n '\bsudo(edit)?\b' "$ALIASES_MODULE"; then
  printf 'Legacy sudo command found in Zsh aliases\n' >&2
  exit 1
fi
grep -q "alias i='doas'" "$ALIASES_MODULE"
grep -q "alias iv='doas true'" "$ALIASES_MODULE"

printf 'Environment tests passed\n'

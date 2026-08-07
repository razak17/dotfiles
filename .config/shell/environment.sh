#!/bin/sh

# Shared session environment for Zsh, DWM, and Plasma.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

export DEV_HOME="$HOME/personal/workspace/coding"
export DOTFILES="$HOME/.dots"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export ZSH_CACHE_DIR="$XDG_CACHE_HOME/zsh"
export SYNC_DIR="$HOME/Sync"

export SUDO_EDITOR="nvim"
export BROWSER="zen"
export TERMINAL="ghostty"
export IMAGE="sxiv"
export VIDEO="mpv"
export MUSIC="mpv"
export READER="zathura"
export COLORTERM="truecolor"
export OPENER="xdg-open"
export PAGER="less"

TEXT_EDITOR="vi"
if command -v rvim >/dev/null 2>&1; then
  TEXT_EDITOR="rvim"
  DIFFPROG="rvim -d"
elif command -v nvim >/dev/null 2>&1; then
  TEXT_EDITOR="nvim"
  DIFFPROG="nvim -d"
elif command -v vim >/dev/null 2>&1; then
  TEXT_EDITOR="vim"
fi
export TEXT_EDITOR
export DIFFPROG
export VISUAL="$TEXT_EDITOR"
export EDITOR="$TEXT_EDITOR"
export USE_EDITOR="$EDITOR"

if command -v "$TEXT_EDITOR" >/dev/null 2>&1; then
  export MANPAGER="$TEXT_EDITOR +Man!"
else
  export MANPAGER="less"
fi

export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export CLICOLOR=1
export SUDO_ASKPASS="$HOME/.local/bin/dmenu/dmenupass"

export FZF_TMUX_OPTS='-p80%,60%'
export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git'"
export FZF_DEFAULT_OPTS="--reverse \
--cycle \
--keep-right \
--bind=esc:abort \
--height 60% \
--border sharp \
--prompt '∷ ' \
--pointer ▶ "

export FZF_CTRL_R_OPTS="
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"

# config
CASE_SENSITIVE="true"
HIST_STAMPS="mm/dd/yyyy"
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

autoload -U colors && colors	# Load colors

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

zle_highlight=('paste:none')
zshcache_time="$(date +%s%N)"

# Which plugins would you like to load?
plugins=(
  git
  docker
  docker-compose
  zsh-z
  zsh-autosuggestions
  zsh-syntax-highlighting
)

typeset -g -A key
typeset -U PATH path

# opts
setopt always_to_end        # move cursor to end if word had one match
setopt auto_cd              # cd by typing directory name if it's not a command
setopt auto_list            # automatically list choices on ambiguous completion
setopt auto_menu            # automatically use menu completion
setopt correct_all          # autocorrect commands
unsetopt nomatch
unsetopt PROMPT_SP
setopt append_history
setopt hist_ignore_all_dups # remove older duplicate entries from history
setopt hist_reduce_blanks   # remove superfluous blanks from history items
setopt inc_append_history   # save history entries as soon as they are entered
setopt share_history        # share history between different instances
setopt interactive_comments # allow comments in interactive shells
setopt complete_aliases     # autocomplete for aliases

# Default programs:
export EDITOR="nvim"
export TERMINAL="alacritty"
export BROWSER="firefox"

#autoload -U colors && colors
export CLICOLOR=1

export MANPAGER='nvim +Man!'
export MANWIDTH=999

# Colorful Man Pages
export PAGER=less
export LESS=-R
export LESS_TERMCAP_mb=$'\E[01;31m'         # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m'    # begin bold
export LESS_TERMCAP_me=$'\E[0m'             # end mode
export LESS_TERMCAP_se=$'\E[0m'             # end standout-mode
export LESS_TERMCAP_so=$'\E[38;5;246m'      # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'             # end underline
export LESS_TERMCAP_us=$'\E[04;38;5;146m'   # begin underline

# IMPORTANT: shell/profile should come before binds (avoid weird behavior)
[ -f $HOME/.config/shell/profile ] && source $HOME/.config/shell/profile
[ -f $HOME/.config/zsh/aliases ]   && source $HOME/.config/zsh/aliases
[ -f $HOME/.config/zsh/binds ]     && source $HOME/.config/zsh/binds
[ -f $HOME/.config/zsh/func ]      && source $HOME/.config/zsh/func
[ -f $HOME/.config/zsh/prompt ]    && source $HOME/.config/zsh/prompt
[ -f $HOME/.config/zsh/compe ]     && source $HOME/.config/zsh/compe

source $HOME/lib/azure-cli/az.completion
source $HOME/.asdf/asdf.sh
source $HOME/.asdf/completions/asdf.bash

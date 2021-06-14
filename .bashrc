[ -f $HOME/.config/sh/aliases.sh ] && source $HOME/.config/sh/aliases.sh
[ -f $HOME/.config/sh/exports.sh ] && source $HOME/.config/sh/exports.sh
[ -f $HOME/.config/sh/prompt.sh ] && source $HOME/.config/sh/prompt.sh
[ -f $HOME/.fzf.bash ] && source $HOME/.fzf.bash
[ -f /etc/bash_completion ] && . /etc/bash_completion
# Improve output of less for binary files.
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Append to the history file, don't overwrite it.
shopt -s histappend

# Ensure $LINES and $COLUMNS always get updated.
shopt -s checkwinsize

# Auto cd into directories without cd
shopt -s autocd

# Vim movements in terminal
# set -o vi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

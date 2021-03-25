# Limit number of lines and entries in the history.
export HISTFILESIZE=50000
export HISTSIZE=50000

# Add a timestamp to each command.
export HISTTIMEFORMAT="%Y/%m/%d %H:%M:%S:   "

# Duplicate lines and lines starting with a space are not put into the history.
export HISTCONTROL=ignoreboth

# if [ -d "$HOME/.bin" ] ;
  # then PATH="$HOME/.bin:$PATH"
# fi

# if [ -d "$HOME/.local/bin" ] ;
  # then PATH="$HOME/.local/bin:$PATH"
# fi

# Cargo
# export PATH="$HOME/.cargo/bin:$PATH"

export PATH=$PATH:/home/razak/.local/bin
# source '/home/razak/lib/azure-cli/az.completion'

# Enable asdf to manage various programming runtime versions.
#   Requires: https://asdf-vm.com/#/
# source "$HOME/.asdf/asdf.sh"
# source "$HOME/.asdf/completions/asdf.bash"

# Enable a better reverse search experience.
#   Requires: https://github.com/junegunn/fzf (to use fzf in general)
#   Requires: https://github.com/BurntSushi/ripgrep (for using rg below)
export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git'"
export FZF_DEFAULT_OPTS="--color=dark"



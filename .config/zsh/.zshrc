# Created by newuser for 5.8
plugins=(
  git
  docker
  docker-compose
  zsh-z
  zsh-autosuggestions
  zsh-syntax-highlighting
)

PLUGIN_DIR=$HOME/.config/zsh/plugins

source $HOME/.oh-my-zsh/oh-my-zsh.sh

[ -f $HOME/.config/zsh/hooks ]      && source $HOME/.config/zsh/hooks
[ -f $HOME/.config/zsh/prompt ]     && source $HOME/.config/zsh/prompt
[ -f $HOME/.config/zsh/aliases ]    && source $HOME/.config/zsh/aliases
[ -f $HOME/.config/zsh/vim-mode ]   && source $HOME/.config/zsh/vim-mode
[ -f $HOME/.config/zsh/shortcuts ]  && source $HOME/.config/zsh/shortcuts
[ -f $HOME/.fzf.zsh ]               && source $HOME/.fzf.zsh

source $HOME/.asdf/asdf.sh
source $HOME/.asdf/completions/asdf.bash
# source $HOME/lib/azure-cli/az.completion
# eval "`pip completion --zsh`"



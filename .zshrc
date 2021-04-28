plugins=(
  git
  docker
  docker-compose
  zsh-z
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $HOME/.oh-my-zsh/oh-my-zsh.sh

[ -f $HOME/.config/zsh/func ]    && source $HOME/.config/zsh/func
[ -f $HOME/.config/zsh/prompt ]  && source $HOME/.config/zsh/prompt
[ -f $HOME/.config/zsh/aliases ] && source $HOME/.config/zsh/aliases
[ -f $HOME/.fzf.zsh ]            && source $HOME/.fzf.zsh

source $HOME/.asdf/asdf.sh
source $HOME/.asdf/completions/asdf.bash
# source $HOME/lib/azure-cli/az.completion


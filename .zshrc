plugins=(
  git
  docker
  docker-compose
  zsh-z
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $HOME/.oh-my-zsh/oh-my-zsh.sh

[ -f $HOME/.config/zsh/aliases ] && source $HOME/.config/zsh/aliases
[ -f $HOME/.config/zsh/prompt ]  && source $HOME/.config/zsh/prompt
[ -f $HOME/.config/zsh/binds ]   && source $HOME/.config/zsh/binds
[ -f $HOME/.config/zsh/compe ]   && source $HOME/.config/zsh/compe
[ -f $HOME/.config/zsh/func ]    && source $HOME/.config/zsh/func

source $HOME/.asdf/asdf.sh
source $HOME/.asdf/completions/asdf.bash
# source $HOME/lib/azure-cli/az.completion


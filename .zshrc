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

source $HOME/.asdf/asdf.sh
source $HOME/.asdf/completions/asdf.bash
# source $HOME/lib/azure-cli/az.completion


# # >>> conda initialize >>>
# # !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/home/razak/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/home/razak/miniconda3/etc/profile.d/conda.sh" ]; then
#         . "/home/razak/miniconda3/etc/profile.d/conda.sh"
#     else
#         export PATH="/home/razak/miniconda3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# # <<< conda initialize <<<


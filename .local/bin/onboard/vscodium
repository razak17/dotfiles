# {{ if (and (eq .chezmoi.os "darwin" "linux") (not .headless)) -}}
#!/bin/bash

set -eufo pipefail

extensions=(
  asvetliakov.vscode-neovim
  atishay-jain.all-autocomplete
  dbaeumer.vscode-eslint
  dkundel.vscode-new-file
  eamodio.gitlens
  esbenp.prettier-vscode
  formulahendry.code-runner
  ms-azuretools.vscode-azureappservice
  ms-azuretools.vscode-docker
  ms-vscode.azure-account
  ms-vscode.azurecli
  vspacecode.whichkey
  wallabyjs.quokka-vscode
  zhuangtongfa.material-theme
)

for extension in ${extensions[@]}; do
	codium --force --install-extension $extension
done

{{ if (eq .chezmoi.os "darwin") }}
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
defaults delete -g ApplePressAndHoldEnabled || true
{{ end }}

{{ end }}

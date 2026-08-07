# Dotfiles


```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/razak17/dotfiles/refs/heads/doas/.config/dot-manager/first_install.sh)"
```

The installer prefers `doas` when available and falls back to `sudo`. Set
`DOT_PRIVILEGE_CMD=doas` or `DOT_PRIVILEGE_CMD=sudo` to override automatic
selection for one run.

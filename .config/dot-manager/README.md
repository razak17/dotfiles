# Dot Manager

Dot Manager installs and maintains this Artix Linux development environment.
It manages system packages, developer tools, fonts, and the bare dotfiles Git
repository through the `dot` command.

## Requirements

- Artix Linux or another pacman-based system
- Internet access and `curl`
- `doas` or `sudo`

## Install

Run the bootstrap script from the `doas` branch:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/razak17/dotfiles/refs/heads/doas/.config/dot-manager/first_install.sh)"
```

The script installs its base dependencies, clones the bare repository into
`~/.dots/dotfiles`, creates `~/.local/bin/dot`, and starts the complete setup.

## Privilege command

Dot Manager prefers `doas` when it is installed and falls back to `sudo`.
Override the choice for a single command when needed:

```bash
DOT_PRIVILEGE_CMD=doas dot init
DOT_PRIVILEGE_CMD=sudo dot init
```

The override must be either `doas` or `sudo`, and that command must be
installed. Dot Manager never replaces one command with a symlink to the other.

## Common commands

```bash
dot help                    # Show command help
dot list                    # List programs in the complete setup
dot init                    # Install the complete configuration
dot program <name>          # Install one program
dot program all             # Install all default programs
dot reinstall <name>        # Reinstall one program
dot reinstall all           # Reinstall the complete setup
dot update                  # Update Neovim and tmux plugins
dot fonts update            # Install or update Nerd Fonts
dot tool <name> [arguments] # Run a tool script
```

Unknown commands are passed to the bare dotfiles repository, so normal Git
operations work through `dot`:

```bash
dot status
dot diff
dot log --oneline
```

## Tests

Run the privilege regression tests, shell syntax checks, and static sudo check:

```bash
~/.config/dot-manager/tests/run.sh
```

## Troubleshooting

Installer details are written to:

```text
~/.cache/dot-manager/last-run.log
```

If a privileged operation reports that neither command is available, install
`opendoas` or `sudo`, then rerun the failed `dot` command. Use
`DOT_PRIVILEGE_CMD=sudo` when doas is installed but not configured yet.

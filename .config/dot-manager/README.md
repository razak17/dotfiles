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
bash -c "$(curl -fsSL https://raw.githubusercontent.com/razak17/dotfiles/refs/heads/main/.config/dot-manager/first_install.sh)"
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
dot shell zsh               # Set Zsh as your login shell
dot uninstall --dry-run     # Preview removal of tracked files
dot uninstall               # Remove tracked files after confirmation
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

## Optional Bluetooth support

Bluetooth is not installed by `dot init` or `dot program all`. Install and
enable it explicitly on machines that need it:

```bash
dot program bluetooth
```

This installs the BlueZ OpenRC service and utilities, OBEX file-transfer
support, and Plasma's Bluetooth integration. It enables and starts
`bluetoothd` immediately.

## Login shell

Changing the login shell is opt-in and is not part of `dot init`. After Zsh is
installed, run the command as your normal user:

```bash
dot shell zsh
```

Do not run it with `sudo`; Dot Manager refuses root execution to avoid changing
root's login shell. Log out and back in after a successful change.

## Uninstall tracked files

Preview the exact tracked-file manifest first:

```bash
dot uninstall --dry-run
```

`dot uninstall` refuses to run when tracked changes exist and requires an exact
confirmation phrase. It removes only files tracked by the current branch,
including tracked files in initialized submodules. Untracked files and non-empty
directories are preserved.

The bare repository at `~/.dots/dotfiles` and the `~/.local/bin/dot` launcher
are retained. The command prints a recovery command after it finishes.

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

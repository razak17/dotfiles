## Dotfiles

![2022-10-17_224903_931020021](https://user-images.githubusercontent.com/52210954/196298390-d07e519b-e164-49ad-a283-4b8a9a68ef3a.png)
![2022-10-17_224900_391823712](https://user-images.githubusercontent.com/52210954/196298380-792d49dd-6ab7-481e-87a0-54c0123374fb.png)

## Installation

You will need `curl`

Run the install script. Files are cloned to `~/.dots/dotfiles` by default.

NOTE: Installation is done using a bare repo.

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/razak17/dotfiles/refs/heads/main/.config/dot-manager/first_install.sh)"

```
Old files are stored in `~/.config-backup`

The installer prefers `doas` when available and falls back to `sudo`. Override
the selection for one run with `DOT_PRIVILEGE_CMD=doas` or
`DOT_PRIVILEGE_CMD=sudo`.

## Uninstall

Preview the tracked files that would be removed:

```bash
~/.local/bin/dot uninstall --dry-run
```

Then run the guarded uninstall:

```bash
~/.local/bin/dot uninstall
```

The command refuses to run when tracked changes exist and requires an exact
confirmation phrase. It removes only tracked files; untracked files and
non-empty directories are preserved. The bare repository at
`~/.dots/dotfiles` and the `~/.local/bin/dot` launcher are retained, and the
command prints recovery instructions when it finishes.

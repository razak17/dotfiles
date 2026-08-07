# Tracked dotfiles uninstall design

## Goal

Add a guarded `dot uninstall` command that removes the current branch's tracked
working-tree content while preserving all untracked content and recovery
metadata.

## Scope

The command removes every tracked file and symlink in the main bare repository,
including tracked non-dot paths such as `Pictures`, `README.md`, and `docs`.
For initialized submodules, it removes files tracked by the submodule while
preserving untracked files and the submodule Git metadata.

The following are retained:

- Untracked files and non-empty directories.
- The bare repository at `~/.dots/dotfiles`.
- The `~/.local/bin/dot` launcher.

Installed packages and application data outside the tracked manifest are out of
scope.

## Interface

```text
dot uninstall --dry-run
dot uninstall
```

Dry-run mode prints the manifest and summary without changing files. The real
operation refuses to continue when tracked changes are present, prints the
manifest count, and requires an exact confirmation containing that count.

## Safety boundaries

- Generate NUL-delimited manifests using Git rather than filesystem globs.
- Reject absolute paths, empty paths, and any path containing a `..` component.
- Resolve every target beneath the selected work tree.
- Delete files and symlinks individually; do not recursively remove general
  directories.
- Remove directories only with `rmdir`, deepest first, so directories containing
  untracked data survive.
- Build all manifests before deleting the dot-manager scripts that are currently
  running.
- Refuse dirty tracked files rather than silently discarding user edits.

## Submodules

Gitlinks are not recursively deleted. When an initialized submodule has an
accessible Git work tree, its own tracked-file manifest is added and its tracked
files are removed individually. Uninitialized submodules and untracked content
inside initialized submodules are left in place.

## Recovery

After completion, print an explicit recovery command using the retained bare
repository:

```text
git --git-dir="$HOME/.dots/dotfiles" --work-tree="$HOME" checkout -- .
```

## Testing

All destructive tests run under a temporary fake home and repository. Coverage
includes dry-run, confirmation mismatch, dirty-file refusal, spaces in paths,
tracked symlinks, initialized submodules, untracked-file preservation, empty
directory cleanup, retained repository/launcher, and recovery output.

# Doas privilege design

## Goal

Add a `doas`-first privilege model to the dot-manager while retaining a real
`sudo` fallback. Keep the existing `main` branch unchanged and publish the
behavior on a dedicated `doas` branch.

## Privilege selection

The installed dot-manager will resolve one privilege command when it loads:

1. Use `DOT_PRIVILEGE_CMD` when the user explicitly sets it.
2. Otherwise prefer `doas` when it is available.
3. Otherwise use `sudo` when it is available.
4. Fail with an actionable error when privilege is required and neither exists.

An explicit override must name an executable command. Root sessions bypass the
escalator and execute the requested command directly.

## Interface

`helper.sh` will expose three operations:

- `__as_root command...` executes a command as root.
- `__as_user user command...` executes a command as another user using the
  selected escalator's native syntax.
- `__authenticate` obtains or refreshes credentials without relying on
  `sudo -v`; it runs a harmless root command through the selected escalator.

All installed program scripts will call these operations instead of invoking
`sudo` or `doas` directly. This keeps the different `sudo -u` and `doas -u`
semantics inside one module and avoids emulating sudo with a symlink.

`first_install.sh` runs before the repository exists, so it will contain a
small bootstrap version of root execution with the same selection rules.

## Doas setup

The doas setup tool may install `opendoas` and create a missing configuration,
but it must not delete `/usr/bin/sudo`, remove an existing `/etc/doas.conf`, or
create `/usr/bin/sudo` as a symlink. Existing configuration is preserved.

## Documentation

The root README and dot-manager README will point their bootstrap URL at the
`doas` branch. They will document automatic doas preference, sudo fallback,
and the `DOT_PRIVILEGE_CMD` override.

## Error handling

Privilege resolution reports invalid overrides and unavailable escalators
before a privileged operation is attempted. Command failures retain their
original exit status so existing installer failure reporting continues to
work. No privilege helper will use `eval`.

## Verification

- Parse every shell script with `bash -n`.
- Use a shell test with mocked `doas` and `sudo` executables to verify automatic
  preference, sudo fallback, explicit overrides, missing-command failure, root
  bypass, authentication, and run-as-user argument translation.
- Search executable scripts for direct `sudo` calls outside the bootstrap
  resolver and compatibility tests.
- Confirm the branch diff contains only dot-manager, README, tests, and design
  documentation changes.

## Worktree safety

Implementation happens in an isolated temporary worktree based on `main`.
The checked-out home worktree and its unrelated modified
`.config/rmpc/config.ron` are not changed.

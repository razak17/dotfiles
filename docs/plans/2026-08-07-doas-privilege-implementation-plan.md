# Doas privilege implementation plan

## 1. Add regression coverage for privilege selection

- Add a shell test that loads `helper.sh` with a temporary `PATH` containing
  mocked `doas` and `sudo` commands.
- Cover automatic doas preference, sudo-only fallback, both override choices,
  invalid override failure, authentication, root command execution, and
  run-as-user syntax for both escalators.
- Keep the test isolated from the host's real privilege commands.

## 2. Centralize installed-script privilege behavior

- Resolve and validate the selected escalator in `helper.sh`.
- Implement `__as_root`, `__as_user`, and `__authenticate` without `eval`.
- Preserve command arguments and exit statuses.
- Replace `sudo -v`, root command calls, and run-as-user calls in `dot.sh`,
  package helpers, and program installers.

## 3. Make bootstrap installation compatible

- Add a minimal doas-first/sudo-fallback root helper to `first_install.sh`.
- Use it for initial package installation before the bare repository exists.
- Produce a clear error if neither escalator exists and the script is not root.

## 4. Make doas configuration non-destructive

- Install `opendoas` through the shared privilege helper.
- Preserve any existing `/etc/doas.conf` and `/usr/bin/sudo`.
- Create a missing configuration through `__as_root` with restrictive mode.
- Install optional completion data through the same privilege boundary.

## 5. Update branch documentation

- Change both bootstrap examples from `main` to `doas`.
- Document selection order and `DOT_PRIVILEGE_CMD=doas|sudo`.

## 6. Verify and commit

- Run the privilege regression test.
- Run `bash -n` across all shell scripts.
- Search for unapproved direct `sudo` invocations.
- Review the complete branch diff and confirm the home worktree is unchanged.
- Commit implementation and test changes on the `doas` branch.

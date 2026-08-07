# Tracked dotfiles uninstall implementation plan

## 1. Add an isolated regression harness

- Create a temporary fake home and bare repository fixture.
- Populate tracked files, a filename containing spaces, a tracked symlink,
  nested directories, and an untracked neighbor.
- Add an initialized local submodule with both tracked and untracked content.
- Assert that dry-run changes nothing and reports tracked targets.
- Assert that dirty tracked files and incorrect confirmation block deletion.

## 2. Implement the uninstall module

- Add `uninstall.sh` with argument parsing and no side effects when sourced.
- Validate the repository/work-tree paths and every Git-provided relative path.
- Collect main-repository and initialized-submodule manifests before deletion.
- Refuse dirty tracked state in the main repository or initialized submodules.
- Remove manifest files individually and prune only empty directories.
- Preserve the bare repository and launcher, then print the recovery command.

## 3. Connect the command and documentation

- Add `uninstall` to `dot.sh` dispatch and help.
- Add dry-run, behavior, and recovery notes to the dot-manager README.

## 4. Verify and commit

- Run the isolated destructive regression harness.
- Run all existing privilege and shell-syntax tests.
- Run `git diff --check` and inspect the complete branch diff.
- Commit the implementation on `doas` without running uninstall against the
  real home directory.

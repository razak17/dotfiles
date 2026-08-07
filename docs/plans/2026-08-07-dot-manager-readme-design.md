# Dot-manager quick-start README design

## Goal

Replace the minimal dot-manager README with a concise, command-first guide for
installing and operating the `doas` branch.

## Structure

The README will cover, in order:

1. A one-paragraph description of dot-manager.
2. Requirements and supported privilege commands.
3. Fresh installation from the `doas` branch.
4. Automatic privilege selection and explicit override examples.
5. The common `dot` commands exposed by `dot.sh`.
6. The test-suite command.
7. Two troubleshooting pointers: the last-run log and missing privilege tools.

## Constraints

- Keep the document short and terminal-friendly.
- Document only commands that exist in the current `doas` branch.
- Do not enumerate every program installer or explain internal helper functions.
- Do not change runtime code.

## Verification

- Compare documented commands with `dot.sh` command dispatch.
- Confirm the bootstrap URL and clone target both use the `doas` branch.
- Check Markdown fences and whitespace with `git diff --check`.

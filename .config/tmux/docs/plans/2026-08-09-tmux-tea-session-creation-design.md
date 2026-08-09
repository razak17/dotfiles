# tmux-tea session creation reliability

## Problem

`prefix + f` opens tmux-tea and fzf accepts a directory selection, but the
popup closes without creating or selecting the corresponding tmux session.
The script currently discards errors from session lookup and switching, and it
does not report a failed `new-session` command. This makes a post-selection
failure indistinguishable from a successful cancellation.

## Design

Keep the existing tmux binding, picker modes, and session naming behavior.
Harden only `create_and_attach_session`:

1. Reject an empty or nonexistent selected directory before creating a session.
2. Capture stderr from `tmux new-session` and tmuxinator commands.
3. Verify that the expected session exists after creation.
4. Switch or attach only after verification.
5. Show a concise tmux status-line error and return nonzero on failure.

Existing session, window, and pane selection behavior remains unchanged.

## Verification

- Run Bash syntax validation on `tea.sh`.
- Exercise directory selection against an isolated tmux server so the live
  sessions are not modified.
- Confirm the selected directory creates a session with the expected name and
  working directory.
- Reload the live tmux configuration after the checks pass.


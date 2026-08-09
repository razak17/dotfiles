# tmux-tea session creation implementation plan

1. Add reusable failure reporting to `tea.sh`.
2. Validate selected filesystem paths before session creation.
3. make tmuxinator and `tmux new-session` failures explicit.
4. Verify creation before switching or attaching.
5. Run syntax and isolated integration checks.
6. Reload the live tmux configuration.

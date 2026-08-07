# Dot-manager quick-start README implementation plan

1. Rewrite `.config/dot-manager/README.md` using the approved command-first
   structure.
2. Verify every documented command against `dot.sh`.
3. Verify the installation URL targets `doas` and `first_install.sh` clones the
   same branch.
4. Run the existing dot-manager tests and `git diff --check`.
5. Commit only the README and planning documentation on `doas`.

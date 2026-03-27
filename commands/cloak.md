---
allowed-tools: Bash(cat:*), Bash(grep:*), Bash(echo:*), Bash(sed:*), Bash(touch:*), Bash(mkdir:*)
---

# Cloak — Toggle Claude File Visibility in Git

Check if Claude files are currently hidden or visible in this repo's git history, then flip it.

## Steps

1. Verify this is a git repo. If not, say so and stop.

2. Check if `.git/info/exclude` exists. If not, create it.

3. Check if `CLAUDE.md` is listed in `.git/info/exclude`.

4. If Claude files ARE currently hidden (found in exclude):
   - Remove `CLAUDE.md`, `.claude/`, and `docs/claude/` lines from `.git/info/exclude`
   - Report: "Claude files are now VISIBLE in this repo's git history."

5. If Claude files are NOT currently hidden (not found in exclude):
   - Append `CLAUDE.md`, `.claude/`, and `docs/claude/` to `.git/info/exclude`
   - Report: "Claude files are now HIDDEN from this repo's git history."

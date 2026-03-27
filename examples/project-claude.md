# Example Project CLAUDE.md
#
# This file goes at the root of each project. It inherits from global CLAUDE.md
# and adds project-specific rules. Claude reads both every turn.
#
# The hierarchy: global (~/.claude/CLAUDE.md) → workspace (~/dev/CLAUDE.md) → project (./CLAUDE.md)
# More specific files override more general ones.

# [Project Name]

## Current Focus
# Keep this to 2-3 lines. Update it when priorities change.
# This is the first thing Claude reads — make it count.
<!-- What's done, what's in progress, what's next -->

## Project Docs
# Point Claude to the docs/claude/ directory.
# Run `/init-proj` to scaffold this structure automatically.
- `docs/claude/roadmap.md` — current plan, milestones, what's next
- `docs/claude/decisions.md` — settled questions, do not relitigate
- `docs/claude/gotchas.md` — known traps, quirks, things that don't work as expected
- `docs/claude/plans/` — active implementation plans (temporary, archived when done)
- `docs/claude/reference/` — research findings, API details, technical notes
- `docs/claude/changelog.md` — recent doc changes
- `docs/claude/session-handoff.md` — notes from paused sessions

### Doc maintenance rules
- After completing any milestone, update the roadmap and Current Focus above
- After making any decision or rejecting an approach, log it in decisions.md
- After hitting an external quirk or unexpected behavior, add it to gotchas.md
- After researching any topic, save findings in reference/
- When updating any doc in docs/claude/, add an entry to changelog.md

## Code Style
# Only include rules that DIFFER from your global CLAUDE.md or language defaults.
# Don't restate things Claude already knows (language conventions, standard patterns).

## Architecture
# Key constraints a new Claude session needs to understand immediately.
# Not the full architecture — just the rules that prevent mistakes.

## Dependencies
# Prevent Claude from adding packages without your approval.
- No third-party dependencies without my explicit approval
- Before suggesting a dependency, explain what it does and why we can't do it ourselves

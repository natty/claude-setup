Read the CLAUDE.md for this project. Then check for docs/claude/changelog.md — read the most recent 2-3 entries for context on what happened last.

Check if FOCUS.md exists in the project root. If it does:
- Display the focus check: current task, progress counter, next action
- Count items in docs/claude/stash.md and ~/claude-output/stash.md if they exist
- Create a Claude Code task for the current YOU ARE DOING item (mark it in_progress)
- Report: "Focus: [task]. Progress: [X/Y]. Stash: [N] project, [N] global."

If FOCUS.md does NOT exist but docs/claude/roadmap.md does:
- Ask: "What are you working on this session?" — then create FOCUS.md from their answer with YOU ARE DOING, NEXT ACTION, DONE WHEN, and a progress counter. Keep it to one task.
- If they decline, move on without it.

Summarize concisely:
1. What is this project?
2. What's the current state?
3. What should I work on next? (check FOCUS.md first, then Roadmap in CLAUDE.md, then docs/claude/roadmap.md)

If docs/claude/ doesn't exist, offer to run `/init-proj` to scaffold it.

Check if any docs/claude/ files need trimming (see Archive policy in CLAUDE.md).

Ask the user: "What kind of task is this? (investigation, bug fix, feature, refactor, exploratory)" — this sets scope expectations for the session.

$ARGUMENTS

# GG — Session Wrap-Up

Do each step ONCE, in order. Do not repeat or re-verify completed steps.

1. **FOCUS.md check** (if it exists):
   - Ask: "Did you complete the current task?" (or determine from context if obvious).
   - If yes: increment the progress counter in FOCUS.md, mark the Claude Code task as completed, and ask what the next task is (propose one from the roadmap if available). Update FOCUS.md with the new task.
   - If no: leave FOCUS.md as-is. Note where things left off in session-handoff.md.
   - Scan the conversation for any ideas or tangents that didn't get stashed. Add them to the appropriate stash file.
   - Report: tasks completed this session, items stashed this session, current progress counter.

2. **Run `/brb`** — this saves all session context to docs/claude/ (changelog, decisions, gotchas, plans, reference, roadmap). Pass along any $ARGUMENTS.

3. **Run lint and tests** (if configured for this project).
   Report results once. If there are failures, report them — do not fix, skip, or suppress.

4. **Run `git status`** and report. Do NOT run any other git commands
   unless the user explicitly asks.

5. **Done.** Report the summary and stop.

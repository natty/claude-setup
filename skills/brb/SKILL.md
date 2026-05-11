---
name: brb
description: Mid-session checkpoint — saves session context to docs/claude/ without ending the session. Use when the user says "brb", "checkpoint", or "save progress"; pausing mid-work; or before context compaction.
disable-model-invocation: false
claude-md-version: 2026-05-06
---

# BRB — Mid-Session Checkpoint

Save progress to docs/claude/ so nothing is lost. This is not a wrap-up — the session continues after.

Do each step once, in order. Do not repeat or re-verify completed steps.
Be thorough on each step — scan fully before moving to the next.

1. **Summarize** what was accomplished so far this session in 2-3 sentences.

2. **Update `docs/claude/changelog.md`** with a dated entry:
   - What was done and key files changed
   - Decisions made and why
   - Anything surprising or learned
   - What's next

3. **If new decisions were made or approaches were rejected**, add them to `docs/claude/decisions.md`.
   Scan the full session — not just recent messages. Capture all decisions and rejected approaches with reasoning.

4. **If any external quirks or unexpected behaviors were discovered**, add them to `docs/claude/gotchas.md`.

5. **If a plan was discussed or agreed on**, ensure it exists in `docs/claude/plans/[topic].md`.
   If a plan was completed this session, extract lasting decisions into decisions.md, archive the plan to archive.md, then delete the plan file.

6. **If research was conducted** (any topic), save findings in `docs/claude/reference/[topic].md`.

7. **Update `docs/claude/roadmap.md`** if milestones were completed or priorities shifted.

8. **FOCUS.md snapshot** (if it exists):
   - Note the current task, progress counter, and next action in session-handoff.md
   - If any in-progress Claude Code tasks exist, note their status
   - Scan the conversation for ideas or tangents that didn't get stashed — add them to the appropriate stash

9. **Cold-start check.** Before finishing, ask yourself: "Would a Claude starting
   fresh with only docs/claude/ understand what was done, what was decided, why,
   and what's next?" Consider:
   - Is there anything about this codebase, its patterns, or its quirks that took
     you significant effort to understand this session?
   - Are there connections between systems, non-obvious constraints, or "almost went
     wrong" moments that aren't captured in the docs above?
   - Any mental models, debugging strategies, or context that helped you reason about
     the code effectively?
   - Any decisions, rejected approaches, or context that only exists in the conversation
     and hasn't been written down yet?
   If anything is missing, add it to the appropriate doc (gotchas, reference, decisions).
   If nothing new, skip this step.

10. **Done.** Report what was saved and continue working.

If $ARGUMENTS is provided, use it as additional context for the session notes.
